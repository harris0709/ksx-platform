"""S6 검증(구현안내서 9장): 적합성 셰이프(S4 생성물) + 품질 셰이프(저작)로 물질화 그래프를 검증한다.

  validate          데이터 그래프 전체(공장·기업 공통 + 어휘)를 Fuseki SHACL 서비스로 한 번에 검증
                    → audit.shacl_result 적재 → 위반(sh:Violation) 대상에 graph/quality 의 ksxq:violates 표식
                    → mapping/<기업>/S6_검증결과.md (사업장·명사·차원별 집계)
  validate --seed   계획 파일의 의도적 위반(seeds)을 시험 그래프에 넣고 검증 → 전건 검출 확인
                    → 위반 표식을 단 뒤 추론 규칙(R-010)에서 빠지는지 확인 → 시험 그래프 삭제
기업 공통 그래프의 기준정보를 공장 그래프 개체가 참조하므로(S5 D-2) 그래프를 하나씩이 아니라 합집합으로 검증하고,
결과는 대상 개체가 든 그래프로 나눈다.
"""
from __future__ import annotations

import collections
import glob
import json
import os
import re

from .base import Config, SparqlError, put_graph, psql, shacl, sparql, sparql_raw, update
from .materialize import end_run, start_run

SH = "http://www.w3.org/ns/shacl#"
RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
QNS = "https://ontology.impix.co.kr/quality/"
UNION = ("union", "urn:x-arq:UnionGraph")

AUDIT_SQL = """
create table if not exists audit.shacl_result (
  result_id  bigint generated always as identity primary key,
  run_id     uuid   not null references audit.run(run_id),
  mode       text   not null check (mode in ('data','seed')),
  graph      text,
  focus      text   not null,
  class      text,
  shape      text   not null,
  rule_id    text,
  path       text,
  component  text,
  dimension  text   not null,
  severity   text   not null,
  message    text,
  value      text,
  logged_at  timestamptz not null default now()
);
comment on table audit.shacl_result is 'S6 SHACL 검증 결과(구현안내서 9.2) — 실행·셰이프·대상·차원·메시지';
create index if not exists shacl_result_run on audit.shacl_result(run_id);
grant select on audit.shacl_result to ksx_reader;
"""

TERM = r'(<[^>]*>|_:\S+|"(?:[^"\\]|\\.)*"(?:\^\^<[^>]*>|@[\w-]+)?)'
NT = re.compile(rf"^{TERM} {TERM} {TERM} \.\s*$")


def _unq(t: str) -> str:
    if t.startswith("<"):
        return t[1:-1]
    if t.startswith('"'):
        body = re.match(r'"((?:[^"\\]|\\.)*)"', t).group(1)
        try:
            return json.loads('"' + body + '"')       # N-Triples 이스케이프(\\n \\" \\uXXXX)는 JSON과 같다
        except ValueError:
            return body
    return t


def parse_report(nt: str) -> tuple[bool, list[dict]]:
    """sh:ValidationReport(N-Triples) → (conforms, 결과 목록). 결과 항목은 sh: 속성 이름 → 값(문자)."""
    by = collections.defaultdict(dict)
    results, conforms = [], True
    for line in nt.splitlines():
        m = NT.match(line)
        if not m:
            continue
        s, p, o = m.groups()
        p = _unq(p)
        if p == SH + "conforms":
            conforms = _unq(o) == "true"
        elif p == SH + "result":
            results.append(o)
        elif p.startswith(SH):
            by[s][p[len(SH):]] = _unq(o) if not o.startswith("_:") else o
    return conforms, [by[r] for r in results]


# ------------------------------------------------------------------ 셰이프
def shapes_text(cfg: Config) -> tuple[bytes, list[str]]:
    files = sorted(glob.glob(os.path.join(cfg.onto, "shapes", "*.ttl"))) + quality_files(cfg)
    return b"\n".join(open(f, "rb").read() for f in files), files


def quality_files(cfg: Config) -> list[str]:
    v = (cfg.raw.get("validate") or {}).get("quality") or ["ontologies/quality/*.ttl"]
    return sorted(f for pat in v for f in glob.glob(os.path.join(cfg.repo, pat)))


def quality_meta(cfg: Config) -> dict[str, dict]:
    """품질 셰이프 IRI → {rule, dimension, owner, label} (Turtle에서 읽음)."""
    meta = {}
    for f in quality_files(cfg):
        t = open(f, encoding="utf-8").read() + "\n\n"
        for m in re.finditer(r"^ksxq:(\w+) a sh:NodeShape ;(.*?)\n\n", t, re.M | re.S):
            body = m.group(2)

            def g(k):
                x = re.search(rf'ksxq:{k} "([^"]+)"', body)
                return x.group(1) if x else None
            lab = re.search(r'rdfs:label "([^"]+)"', body)
            meta[QNS + m.group(1)] = {"rule": g("ruleId"), "dimension": g("dimension"), "owner": g("owner"),
                                      "label": lab.group(1) if lab else m.group(1)}
    return meta


def classify(r: dict, qmeta: dict) -> dict:
    """결과 → 셰이프 이름·규칙·차원(구조·값·관계·의미)."""
    comp = r.get("sourceConstraintComponent", "").replace(SH, "").replace("ConstraintComponent", "")
    shape = r.get("sourceShape", "")
    if shape in qmeta:
        q = qmeta[shape]
        return {"shape": shape, "rule": q["rule"], "dimension": q["dimension"], "component": comp}
    path = r.get("resultPath", "")
    if comp in ("MinCount", "MaxCount"):
        dim = "구조"
    elif comp == "Class":
        v = r.get("value", "")                       # 코드·단위 값이 틀리면 값, 개체 참조가 틀리면 관계
        dim = "값" if "/codelist/" in v or "/uom/" in v else "관계"
    elif comp in ("Datatype", "MinInclusive", "MaxInclusive", "MinExclusive", "MaxExclusive", "Pattern", "In",
                  "NodeKind", "MinLength", "MaxLength"):
        dim = "값"
    else:
        dim = "의미"
    return {"shape": f"적합성:{path.rsplit('/', 1)[-1] or comp}", "rule": None, "dimension": dim, "component": comp}


# ------------------------------------------------------------------ 실행
def run_shacl(cfg: Config, shapes: bytes) -> tuple[bool, list[dict], str]:
    last = None
    for g in UNION:
        try:
            return (*parse_report(shacl(cfg.shacl, g, shapes)), g)
        except SparqlError as e:
            last = e
    raise last


def focus_info(cfg: Config, nodes: list[str]) -> dict[str, tuple[str, str]]:
    """대상 IRI → (그래프, 클래스). 어휘·시험 그래프도 포함."""
    info = {}
    nodes = [n for n in nodes if not n.startswith("_:")]
    for i in range(0, len(nodes), 400):
        vals = " ".join(f"<{n}>" for n in nodes[i:i + 400])
        for b in sparql(cfg.query, f"SELECT ?s ?g ?c WHERE {{ VALUES ?s {{ {vals} }} GRAPH ?g {{ ?s a ?c }} }}"):
            info.setdefault(b["s"], (b["g"], b["c"]))
    return info


def short(iri: str, cfg: Config) -> str:
    return (iri or "").replace(cfg.ns, "ksx:").replace(QNS, "ksxq:").replace(cfg.data_ns, "d:")


def store(cfg: Config, rid: str, mode: str, rows: list[dict]):
    psql(cfg.owner, AUDIT_SQL)
    if not rows:
        return
    cols = ["graph", "focus", "class", "shape", "rule_id", "path", "component", "dimension", "severity", "message", "value"]
    lit = lambda v: "null" if v in (None, "") else "'" + str(v).replace("'", "''")[:2000] + "'"  # noqa: E731
    for i in range(0, len(rows), 500):
        vals = ",".join("(" + ",".join([f"'{rid}'", f"'{mode}'"] + [lit(r.get(c)) for c in cols]) + ")" for r in rows[i:i + 500])
        psql(cfg.owner, f"insert into audit.shacl_result(run_id, mode, {', '.join(cols)}) values {vals}")


def collect(cfg: Config, results: list[dict], qmeta: dict) -> list[dict]:
    info = focus_info(cfg, sorted({r.get("focusNode", "") for r in results}))
    rows = []
    for r in results:
        c = classify(r, qmeta)
        g, k = info.get(r.get("focusNode"), ("", ""))
        rows.append({"graph": g, "focus": r.get("focusNode"), "class": k, "shape": c["shape"], "rule_id": c["rule"],
                     "path": r.get("resultPath"), "component": c["component"], "dimension": c["dimension"],
                     "severity": r.get("resultSeverity", "").replace(SH, ""), "message": r.get("resultMessage"),
                     "value": r.get("value")})
    return rows


def markers(cfg: Config, rows: list[dict], graph: str):
    """위반(Violation) 대상에 ksxq:violates 표식 — 그래프 단위 교체. S7 규칙은 FILTER NOT EXISTS로 제외한다."""
    lines = sorted({f"<{r['focus']}> <{QNS}violates> <{r['shape'] if r['shape'].startswith('http') else QNS + 'conformance'}> ."
                    for r in rows if r["severity"] == "Violation" and r["focus"] and not r["focus"].startswith("_:")})
    path = os.path.join(cfg.out, "quality_markers.nt")
    os.makedirs(cfg.out, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + ("\n" if lines else ""))
    put_graph(cfg.gsp, graph, path, "application/n-triples")
    return len(lines)


def validate(cfg: Config, out=print) -> bool:
    rid = start_run(cfg, "kg_validate")
    out(f"S6 검증 run_id={rid}")
    ok, detail = True, {}
    try:
        shapes, files = shapes_text(cfg)
        qmeta = quality_meta(cfg)
        out(f"  셰이프: {', '.join(os.path.relpath(f, cfg.repo) for f in files)} (품질 셰이프 {len(qmeta)})")
        conforms, results, used = run_shacl(cfg, shapes)
        rows = [r for r in collect(cfg, results, qmeta) if not r["graph"].startswith(cfg.graph("test"))]
        store(cfg, rid, "data", rows)
        n = markers(cfg, rows, cfg.graph("quality"))
        out(f"  검증 대상: 합집합 그래프({used}) · 결과 {len(rows):,}건 · 위반 표식 {n:,}개 → {cfg.graph('quality')}")
        excl = exclusion_check(cfg, [r["focus"] for r in rows if r["severity"] == "Violation"])
        report(cfg, rows, rid, n, excl)
        detail = {"results": len(rows), "markers": n, "exclusion": excl}
        for (d, s), c in sorted(collections.Counter((r["dimension"], r["severity"]) for r in rows).items()):
            out(f"    {d} {s}: {c:,}")
    except Exception as e:  # noqa: BLE001
        ok, detail = False, {"error": str(e)[:2000]}
        out("실패: " + str(e))
    end_run(cfg, rid, ok, detail)
    out("ksxkg validate: " + ("완료" if ok else "실패"))
    return ok


# ------------------------------------------------------------------ 추론 제외 확인
def rule_where(cfg: Config, rule: str) -> tuple[str, str]:
    """규칙 파일의 CONSTRUCT를 대상 변수 SELECT로 바꾼다 — (질의, 대상 변수)."""
    t = open(os.path.join(cfg.onto, "rules", rule), encoding="utf-8").read()
    pre = "\n".join(line for line in t.splitlines() if line.startswith("PREFIX"))
    m = re.search(r"CONSTRUCT \{\s*\?(\w+)", t)
    where = t[t.index("WHERE"):]
    return f"{pre}\nSELECT DISTINCT ?{m.group(1)} {where}", m.group(1)


def exclusion_check(cfg: Config, violated: list[str], rule=None) -> dict:
    """위반 표식이 있는 개체가 추론 규칙 결과에 나오지 않는지 — 합집합을 기본 그래프로 질의."""
    rule = rule or (cfg.raw.get("validate") or {}).get("exclusion_rule", "R-010_affected_sales_order.rq")
    q, var = rule_where(cfg, rule)
    got = {b[var] for b in sparql_union(cfg, q)}
    leaked = sorted(set(violated) & got)
    return {"rule": rule, "derived": len(got), "violated": len(set(violated)), "leaked": len(leaked), "examples": leaked[:3]}


def sparql_union(cfg: Config, q: str) -> list[dict]:
    raw = sparql_raw(cfg.query, q, accept="application/sparql-results+json",
                     params={"default-graph-uri": "urn:x-arq:UnionGraph"})
    js = json.loads(raw)
    return [{k: v["value"] for k, v in b.items()} for b in js["results"]["bindings"]]


# ------------------------------------------------------------------ 의도적 위반(seed)
def _copy(cfg: Config, cls: str, where: str, new: str) -> list[str]:
    pre = cfg.data_graph_prefix
    # 원본은 기업 데이터 그래프에서 고르되, 조건(where)은 그래프를 넘어 본다(공장 실적 → P2 지시 등) — TDB2 합집합 그래프 이름
    w = f"GRAPH <urn:x-arq:UnionGraph> {{ {where} }}" if where.strip() else ""
    b = sparql(cfg.query, f"PREFIX ksx: <{cfg.ns}>\nSELECT ?s WHERE {{ GRAPH ?g {{ ?s a {cls} }} "
                          f"FILTER(STRSTARTS(STR(?g), \"{pre}\")) {w} }} ORDER BY ?s LIMIT 1")
    if not b:
        raise RuntimeError(f"시험 원본 개체 없음: {cls} {where}")
    src = b[0]["s"]
    nt = sparql_raw(cfg.query, f"CONSTRUCT {{ <{src}> ?p ?o }} WHERE {{ GRAPH ?g {{ <{src}> ?p ?o }} }}")
    return [f"<{new}>" + line[len(f"<{src}>"):] for line in nt.splitlines() if line.startswith(f"<{src}> ")]


def _expand(cfg: Config, term: str) -> str:
    term = term.replace("{data_ns}", cfg.data_ns)
    m = re.match(r"^(ksx|xsd):(\w+)$", term)
    if m:
        return f"<{cfg.ns if m.group(1) == 'ksx' else 'http://www.w3.org/2001/XMLSchema#'}{m.group(2)}>"
    return re.sub(r"\^\^xsd:(\w+)", r"^^<http://www.w3.org/2001/XMLSchema#\1>", term)


def seed_graph(cfg: Config) -> tuple[list[dict], str]:
    seeds = (cfg.raw.get("validate") or {}).get("seeds") or []
    lines, out = [], []
    for s in seeds:
        cls = s["from"]
        iri = f"{cfg.data_ns}S6TEST/{cls.split(':')[-1]}/{s['id']}"
        t = _copy(cfg, cls, s.get("where", ""), iri)
        for p in (s.get("drop") or []) + list((s.get("set") or {}).keys()):
            pp = _expand(cfg, p)
            t = [x for x in t if x.split(" ", 2)[1] != pp]
        for p, v in (s.get("set") or {}).items():
            t.append(f"<{iri}> {_expand(cfg, p)} {_expand(cfg, v)} .")
        for p, v in (s.get("add") or {}).items():
            t.append(f"<{iri}> {_expand(cfg, p)} {_expand(cfg, v)} .")
        lines += t
        out.append({**s, "iri": iri})
    path = os.path.join(cfg.out, "s6_seed.nt")
    os.makedirs(cfg.out, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    return out, path


def seed_test(cfg: Config, out=print) -> bool:
    rid = start_run(cfg, "kg_validate_seed")
    out(f"S6 의도적 위반 시험 run_id={rid}")
    g_seed, g_mark = cfg.graph("test/s6-seed"), cfg.graph("test/s6-seed-quality")
    ok, detail, checks = True, {}, []
    try:
        seeds, path = seed_graph(cfg)
        put_graph(cfg.gsp, g_seed, path, "application/n-triples")
        out(f"  시험 그래프 {g_seed}: 개체 {len(seeds)}")
        shapes, _ = shapes_text(cfg)
        qmeta = quality_meta(cfg)
        _, results, used = run_shacl(cfg, shapes)
        ids = {s["iri"]: s for s in seeds}
        rows = [r for r in collect(cfg, [r for r in results if r.get("focusNode") in ids], qmeta)]
        store(cfg, rid, "seed", rows)
        by = collections.defaultdict(list)
        for r in rows:
            by[r["focus"]].append(r)
        for s in seeds:
            e = s.get("expect")
            hit = [r for r in by[s["iri"]] if e and _match(cfg, r, e)]
            got = hit[0] if hit else None
            checks.append({"id": s["id"], "dimension": s.get("dimension"), "desc": s.get("desc", ""), "expect": e,
                           "detected": bool(hit) if e else not by[s["iri"]],
                           "result": (f"{got['shape'].replace(QNS, 'ksxq:')} · {got['component']} · {got['severity']}"
                                      if got else ("결과 없음(정상 대조군)" if not by[s["iri"]] else
                                                   "; ".join(sorted({short(r['path'] or r['shape'], cfg) for r in by[s['iri']]})))),
                           "others": len(by[s["iri"]]) - len(hit)})
        for c in checks:
            out(f"  {'OK ' if c['detected'] else '실패'} {c['id']} [{c['dimension'] or '대조군'}] {c['desc']} → {c['result']}")
        # 추론 제외: 시험 개체 중 위반에 표식을 달고 R-010을 돌린다
        markers(cfg, rows, g_mark)
        q, var = rule_where(cfg, (cfg.raw.get("validate") or {}).get("exclusion_rule", "R-010_affected_sales_order.rq"))
        got = {b[var] for b in sparql_union(cfg, q)} & set(ids)
        viol = {r["focus"] for r in rows if r["severity"] == "Violation"}
        ctrl = [s["iri"] for s in seeds if not s.get("expect")]
        rule_rows = [{"id": s["id"], "violation": s["iri"] in viol, "derived": s["iri"] in got} for s in seeds
                     if s["from"] == "ksx:ProductionPerformance"]
        excl_ok = all((not r["violation"]) == r["derived"] for r in rule_rows) and all(c in got for c in ctrl)
        for r in rule_rows:
            out(f"  추론 R-010 {r['id']}: 위반 {'있음' if r['violation'] else '없음'} → 규칙 결과 {'포함' if r['derived'] else '제외'}")
        found = sum(c["detected"] for c in checks if c["expect"])
        total = sum(1 for c in checks if c["expect"])
        ok = found == total and all(c["detected"] for c in checks) and excl_ok
        detail = {"seeds": total, "detected": found, "exclusion": rule_rows, "union": used}
        seed_report(cfg, checks, rule_rows, found, total, excl_ok)
        out(f"  의도적 위반 {total}건 중 {found}건 검출 · 추론 제외 {'확인' if excl_ok else '실패'}")
    except Exception as e:  # noqa: BLE001
        ok, detail = False, {"error": str(e)[:2000]}
        out("실패: " + str(e))
    finally:
        for g in (g_seed, g_mark):
            try:
                update(cfg.update, f"DROP SILENT GRAPH <{g}>")
            except SparqlError:
                pass
    end_run(cfg, rid, ok, detail)
    out("ksxkg validate --seed: " + ("통과" if ok else "실패"))
    return ok


def _match(cfg: Config, r: dict, e: dict) -> bool:
    if e.get("shape") and not r["shape"].endswith(e["shape"]):
        return False
    if e.get("component") and r["component"] != e["component"]:
        return False
    if e.get("path") and (r.get("path") or "") != _expand(cfg, e["path"])[1:-1]:
        return False
    return True


# ------------------------------------------------------------------ 리포트
def report(cfg: Config, rows: list[dict], rid: str, nmark: int, excl: dict):
    gname = lambda g: (g or "").split("/graph/")[-1] or "(그래프 없음)"  # noqa: E731
    md = [f"# S6 검증 결과 ({cfg.ent}) — ksxkg validate", "",
          "적합성 셰이프(S4 생성물) + 품질 셰이프(저작)로 물질화 그래프(합집합)를 검증한 결과. 대상 개체가 든 그래프로 나눈다.", "",
          f"- 결과 {len(rows):,}건 (위반 {sum(r['severity'] == 'Violation' for r in rows):,} · 경고 "
          f"{sum(r['severity'] == 'Warning' for r in rows):,}), 위반 표식 {nmark:,}개 → `graph/quality`",
          f"- 추론 제외 확인({excl['rule']}): 규칙 결과 {excl['derived']:,}개 중 위반 개체 {excl['leaked']}개 (0이어야 함)", "",
          "## 그래프 × 차원", "", "| 그래프 | 구조 | 값 | 관계 | 의미 | 합계 |", "|---|---|---|---|---|---|"]
    t = collections.defaultdict(collections.Counter)
    for r in rows:
        t[gname(r["graph"])][r["dimension"]] += 1
    for g in sorted(t):
        md.append(f"| `{g}` | " + " | ".join(f"{t[g][d]:,}" for d in ("구조", "값", "관계", "의미")) + f" | {sum(t[g].values()):,} |")
    md += ["", "## 셰이프별", "", "| 셰이프 | 차원 | 심각도 | 명사 | 건수 | 메시지 |", "|---|---|---|---|---|---|"]
    s, msg, vals = collections.Counter(), {}, collections.defaultdict(set)
    for r in rows:
        k = (r["shape"].replace(QNS, "ksxq:"), r["dimension"], r["severity"], short(r["class"], cfg))
        s[k] += 1
        msg.setdefault(k, r["message"])
        if r["value"]:
            vals[k].add(short(r["value"], cfg))
    md[-2] = "| 셰이프 | 차원 | 심각도 | 명사 | 건수 | 값(서로 다른 것) | 메시지 예 |"
    md[-1] = "|---|---|---|---|---|---|---|"
    for k, n in sorted(s.items(), key=lambda x: (-x[1], x[0])):
        v = sorted(vals[k])
        md.append(f"| `{k[0]}` | {k[1]} | {k[2]} | {k[3]} | {n:,} | {', '.join(v[:4])}{' …' if len(v) > 4 else ''} | "
                  f"{(msg[k] or '').replace('|', '/')[:90]} |")
    md += ["", "## 대상 예(셰이프별 최대 5개)", "", "| 셰이프 | 대상 | 그래프 | 값 |", "|---|---|---|---|"]
    seen = collections.Counter()
    for r in sorted(rows, key=lambda r: (r["shape"], r["focus"] or "")):
        k = r["shape"]
        if seen[k] < 5:
            seen[k] += 1
            md.append(f"| `{k.replace(QNS, 'ksxq:')}` | `{short(r['focus'], cfg)}` | `{gname(r['graph'])}` | "
                      f"{short(r['value'], cfg)[:60]} |")
    with open(os.path.join(cfg.mapping_dir(), "S6_검증결과.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")


def seed_report(cfg: Config, checks, rule_rows, found, total, excl_ok):
    md = [f"# S6 의도적 위반 시험 ({cfg.ent}) — ksxkg validate --seed", "",
          "실제 개체를 복제한 시험 개체에 위반을 하나씩 넣어 시험 그래프(`graph/test/s6-seed`)로 검증한다. 시험 후 그래프는 지운다.", "",
          f"- 검출: **{found}/{total}** · 정상 대조군 결과 없음 · 추론 제외 **{'확인' if excl_ok else '실패'}**", "",
          "| No | 차원 | 넣은 위반 | 기대 | 검출 결과 | 다른 결과 |", "|---|---|---|---|---|---|"]
    for c in checks:
        e = c["expect"] or {}
        exp = " · ".join(str(v) for v in (e.get("shape"), e.get("component"), e.get("path")) if v) or "결과 없음"
        md.append(f"| {c['id']} | {c['dimension'] or '대조군'} | {c['desc']} | {exp} | "
                  f"{'✔ ' if c['detected'] else '✘ '}{c['result']} | {c['others']} |")
    md += ["", "## 추론 제외(R-010 생산실적 → 영향 수주)", "", "| No | 위반 | 규칙 결과 |", "|---|---|---|"]
    md += [f"| {r['id']} | {'있음' if r['violation'] else '없음'} | {'포함' if r['derived'] else '제외'} |" for r in rule_rows]
    with open(os.path.join(cfg.mapping_dir(), "S6_의도적위반시험.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
