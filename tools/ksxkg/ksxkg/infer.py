"""S7 규칙 추론(구현안내서 10장).

  infer          규칙(ontologies/rules/*.rq, A-* → R-* 파일명 순)을 합집합 그래프에 CONSTRUCT로 실행하고
                 결과를 graph/inferred/{기업}/{사업장}/{규칙 ID}에 통째로 교체(PUT) — 다시 실행해도 결과가 같다.
                 실행 전 이 기업의 추론 그래프를 모두 지워 이전 결과가 섞이지 않게 한다(앞 규칙 결과는 뒤 규칙이 쓴다).
                 규칙마다 ID·버전(파일 해시)·입력 그래프·결과 트리플·소요 시간을 audit.rule_run에 남긴다.
  infer --eval   계획의 정답 사례(S1 업무 질의서 답·원천 판정)와 추론 결과를 비교해 정밀도·재현율을 낸다.
리포트: mapping/<기업>/S7_추론결과.md
"""
from __future__ import annotations

import datetime as dt
import glob
import hashlib
import json
import os
import re
import time

from .base import Config, psql, put_graph, sparql, sparql_raw, update
from .materialize import end_run, start_run

AUDIT_SQL = """
create table if not exists audit.rule_run (
  log_id     bigint generated always as identity primary key,
  run_id     uuid        not null references audit.run(run_id),
  rule_id    text        not null,
  rule_file  text        not null,
  version    text        not null,
  graph      text        not null,
  inputs     jsonb       not null default '[]'::jsonb,
  params     jsonb       not null default '{}'::jsonb,
  triples    bigint      not null,
  seconds    numeric     not null,
  logged_at  timestamptz not null default now()
);
comment on table audit.rule_run is 'S7 규칙 추론 실행 기록(구현안내서 10.2) — 규칙 ID·버전·입력 그래프·결과 트리플·소요 시간. AI 답변의 추론 근거';
create index if not exists rule_run_run on audit.rule_run(run_id);
create table if not exists audit.rule_eval (
  log_id     bigint generated always as identity primary key,
  run_id     uuid        not null references audit.run(run_id),
  case_id    text        not null,
  rule_id    text        not null,
  question   text,
  expected   int         not null,
  got        int         not null,
  tp         int         not null,
  logged_at  timestamptz not null default now()
);
comment on table audit.rule_eval is 'S7 규칙 정확도 평가(정답 사례 대비) — 정밀도 = tp/got, 재현율 = tp/expected';
grant select on audit.rule_run, audit.rule_eval to ksx_reader;
"""

UNION = {"default-graph-uri": "urn:x-arq:UnionGraph"}
PREFIXES = """PREFIX ksx: <{ns}>
PREFIX inf: <https://ontology.impix.co.kr/inference/>
PREFIX ksxq: <https://ontology.impix.co.kr/quality/>
PREFIX impix: <https://ontology.impix.co.kr/ext/impix/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
"""


# ------------------------------------------------------------------ 설정·파라미터
def settings(cfg: Config) -> dict:
    s = dict(cfg.raw.get("infer") or {})
    s.setdefault("rules", "ontologies/rules")
    s.setdefault("site", "HQ")
    s.setdefault("batch_target_seconds", 600)
    s.setdefault("thresholds", {"recall": 0.95, "precision": 0.9})
    return s


def load_params(rules_dir: str, today: str | None) -> dict:
    p = {}
    f = os.path.join(rules_dir, "params.yaml")
    if os.path.exists(f):
        for line in open(f, encoding="utf-8"):
            m = re.match(r"^\s*([A-Za-z_]\w*)\s*:\s*([^#\n]+)", line)
            if m:
                p[m.group(1)] = m.group(2).strip()
    p["today"] = str(today or dt.date.today().isoformat())
    if "due_within_days" in p:   # 엔진마다 날짜 연산이 달라 실행기가 계산한다
        p["due_limit"] = (dt.date.fromisoformat(p["today"]) + dt.timedelta(days=int(p["due_within_days"]))).isoformat()
    return p


def render(q: str, params: dict) -> str:
    def sub(m):
        if m.group(1) not in params:
            raise SystemExit(f"규칙 파라미터 누락: {m.group(1)}")
        return str(params[m.group(1)])
    return re.sub(r"\$\{(\w+)\}", sub, q)


def rule_files(cfg: Config, s: dict) -> list[str]:
    return sorted(glob.glob(os.path.join(cfg.repo, s["rules"], "*.rq")))


def inferred_graph(cfg: Config, site: str, rid: str) -> str:
    return cfg.graph(f"inferred/{cfg.ent}/{site}/{rid}")


def graphs(cfg: Config) -> list[str]:
    return sorted(b["g"] for b in sparql(cfg.query, "SELECT DISTINCT ?g WHERE { GRAPH ?g { } }"))


# ------------------------------------------------------------------ 실행
def run_rules(cfg: Config, rid: str, out=print) -> list[dict]:
    s = settings(cfg)
    params = load_params(os.path.join(cfg.repo, s["rules"]), s.get("today"))
    pre = cfg.graph(f"inferred/{cfg.ent}/")
    old = [g for g in graphs(cfg) if g.startswith(pre)]
    for g in old:                                   # 이전 추론 결과를 지운다 — 규칙은 원본 + 앞 규칙 결과만 본다
        update(cfg.update, f"DROP SILENT GRAPH <{g}>")
    inputs = [g for g in graphs(cfg) if not g.startswith(pre)]
    os.makedirs(os.path.join(cfg.out, "inferred"), exist_ok=True)
    rows = []
    for f in rule_files(cfg, s):
        name = os.path.basename(f)
        rule = name.split("_", 1)[0]
        text = open(f, encoding="utf-8").read()
        q = render(text, params)
        used = {k: params[k] for k in re.findall(r"\$\{(\w+)\}", text)}
        t0 = time.time()
        nt = sparql_raw(cfg.query, q, params=UNION)
        path = os.path.join(cfg.out, "inferred", f"{rule}.nt")
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(nt)
        g = inferred_graph(cfg, s["site"], rule)
        put_graph(cfg.gsp, g, path, "application/n-triples")
        n = sum(1 for line in nt.splitlines() if line.strip())
        sec = round(time.time() - t0, 2)
        row = {"rule": rule, "file": name, "version": hashlib.sha1(text.encode("utf-8")).hexdigest()[:12],
               "graph": g, "triples": n, "seconds": sec, "params": used}
        rows.append(row)
        out(f"  {rule:7} {n:>8,} 트리플  {sec:>6.2f}초  ({name})")
    vals = ", ".join(
        f"('{rid}', '{r['rule']}', '{r['file']}', '{r['version']}', '{r['graph']}', "
        f"'{json.dumps(inputs)}'::jsonb, '{json.dumps(r['params'], ensure_ascii=False)}'::jsonb, {r['triples']}, {r['seconds']})"
        for r in rows)
    if vals:
        psql(cfg.owner, "insert into audit.rule_run(run_id, rule_id, rule_file, version, graph, inputs, params, triples, seconds) "
                        f"values {vals}")
    return rows


# ------------------------------------------------------------------ 평가
def evaluate(cfg: Config, rid: str | None = None, out=print) -> dict:
    s = settings(cfg)
    cases = (cfg.raw.get("evaluate") or {}).get("cases") or []
    pre = PREFIXES.format(ns=cfg.ns)
    res = []
    for c in cases:
        q = pre + "SELECT DISTINCT ?x WHERE { " + c["select"] + " }"
        got = {b["x"] for b in sparql_raw_json(cfg, q)}
        exp = {str(x) for x in c["expected"]}
        tp = got & exp
        res.append({"id": c["id"], "rule": c["rule"], "question": c.get("question", ""), "desc": c.get("desc", ""),
                    "expected": len(exp), "got": len(got), "tp": len(tp),
                    "missing": sorted(exp - got)[:5], "extra": sorted(got - exp)[:5]})
        out(f"  {c['id']:4} {c['rule']:6} 정답 {len(exp):>4} · 결과 {len(got):>4} · 일치 {len(tp):>4}  {c.get('desc', '')}")
    by_rule = {}
    for r in res:
        a = by_rule.setdefault(r["rule"], {"expected": 0, "got": 0, "tp": 0, "cases": []})
        for k in ("expected", "got", "tp"):
            a[k] += r[k]
        a["cases"].append(r["id"])
    tot = {k: sum(r[k] for r in res) for k in ("expected", "got", "tp")}
    th = s["thresholds"]
    def pr(a):
        p = a["tp"] / a["got"] if a["got"] else (1.0 if not a["expected"] else 0.0)
        rc = a["tp"] / a["expected"] if a["expected"] else 1.0
        return round(p, 4), round(rc, 4)
    for a in list(by_rule.values()) + [tot]:
        a["precision"], a["recall"] = pr(a)
    ok = all(a["precision"] >= th["precision"] and a["recall"] >= th["recall"] for a in by_rule.values())
    if rid and res:
        psql(cfg.owner, "insert into audit.rule_eval(run_id, case_id, rule_id, question, expected, got, tp) values " +
             ", ".join(f"('{rid}', '{r['id']}', '{r['rule']}', '{r['question']}', {r['expected']}, {r['got']}, {r['tp']})" for r in res))
    return {"cases": res, "by_rule": by_rule, "total": tot, "ok": ok, "thresholds": th}


def sparql_raw_json(cfg: Config, q: str) -> list[dict]:
    js = json.loads(sparql_raw(cfg.query, q, accept="application/sparql-results+json", params=UNION))
    return [{k: v["value"] for k, v in b.items()} for b in js["results"]["bindings"]]


# ------------------------------------------------------------------ 진입점·리포트
def infer(cfg: Config, eval_only=False, out=print) -> bool:
    s = settings(cfg)
    psql(cfg.owner, "select 1")
    rid = start_run(cfg, "kg_eval" if eval_only else "kg_infer", stage="S7")
    psql(cfg.owner, AUDIT_SQL)
    out(f"S7 규칙 추론 run_id={rid} (기준일 {s.get('today', '오늘')}, 사업장 {s['site']})")
    rows = []
    try:
        if not eval_only:
            t0 = time.time()
            rows = run_rules(cfg, rid, out)
            total = round(time.time() - t0, 2)
            out(f"  합계 {sum(r['triples'] for r in rows):,} 트리플 · {total}초 (목표 {s['batch_target_seconds']}초 이내)")
        else:
            total = None
        ev = evaluate(cfg, rid, out)
        t = ev["total"]
        out(f"  평가: 정밀도 {t['precision']:.3f} · 재현율 {t['recall']:.3f} "
            f"(기준 정밀도 ≥ {ev['thresholds']['precision']}, 재현율 ≥ {ev['thresholds']['recall']}, 규칙별) → {'충족' if ev['ok'] else '미충족'}")
        time_ok = total is None or total <= s["batch_target_seconds"]
        ok = ev["ok"] and time_ok
        report(cfg, rid, s, rows, total, ev)
        end_run(cfg, rid, ok, {"rules": len(rows), "triples": sum(r["triples"] for r in rows), "seconds": total,
                               "precision": t["precision"], "recall": t["recall"]})
        out(f"ksxkg infer: {'완료' if ok else '완료 기준 미충족'}")
        return ok
    except Exception as e:
        end_run(cfg, rid, False, {"error": str(e)[:500]})
        raise


def report(cfg: Config, rid: str, s: dict, rows: list[dict], total, ev: dict):
    th = ev["thresholds"]
    md = [f"# S7 규칙 추론 결과 ({cfg.ent}) — ksxkg infer", "",
          f"- 실행: `{rid}` · 기준일 {s.get('today', '오늘')} · 사업장 {s['site']}",
          f"- 결과 그래프: `{cfg.graph('inferred/' + cfg.ent + '/' + s['site'])}/{{규칙 ID}}` (규칙별 통째 교체)",
          ""]
    if rows:
        md += ["## 규칙 실행 (audit.rule_run)", "", "| 규칙 | 파일 | 버전 | 결과 트리플 | 소요(초) | 파라미터 |", "|---|---|---|---:|---:|---|"]
        md += [f"| {r['rule']} | `{r['file']}` | `{r['version']}` | {r['triples']:,} | {r['seconds']} | "
               f"{', '.join(f'{k}={v}' for k, v in r['params'].items()) or '—'} |" for r in rows]
        md += ["", f"합계 {sum(r['triples'] for r in rows):,} 트리플 · **{total}초** (배치 목표 {s['batch_target_seconds']}초 이내 → "
                   f"{'충족' if total <= s['batch_target_seconds'] else '미충족'})", ""]
    t = ev["total"]
    md += ["## 정확도 평가 (정답 사례 대비)", "",
           f"기준: 규칙마다 정밀도 ≥ {th['precision']} · 재현율 ≥ {th['recall']}(구현안내서 표 25). "
           f"전체 정밀도 **{t['precision']:.3f}** · 재현율 **{t['recall']:.3f}** → **{'충족' if ev['ok'] else '미충족'}**", "",
           "| 규칙 | 사례 | 정답 | 결과 | 일치 | 정밀도 | 재현율 | 판정 |", "|---|---|---:|---:|---:|---:|---:|---|"]
    for k, a in sorted(ev["by_rule"].items()):
        okr = a["precision"] >= th["precision"] and a["recall"] >= th["recall"]
        md.append(f"| {k} | {', '.join(a['cases'])} | {a['expected']} | {a['got']} | {a['tp']} | {a['precision']:.3f} | {a['recall']:.3f} | {'✔' if okr else '✘'} |")
    md += ["", "### 사례별", "", "| 사례 | 규칙 | 업무 질의(S1) | 내용 | 정답 | 결과 | 일치 | 빠짐(예) | 더 나옴(예) |",
           "|---|---|---|---|---:|---:|---:|---|---|"]
    for r in ev["cases"]:
        md.append(f"| {r['id']} | {r['rule']} | {r['question']} | {r['desc']} | {r['expected']} | {r['got']} | {r['tp']} | "
                  f"{', '.join(r['missing']) or '—'} | {', '.join(r['extra']) or '—'} |")
    p = os.path.join(cfg.mapping_dir(), "S7_추론결과.md")
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
