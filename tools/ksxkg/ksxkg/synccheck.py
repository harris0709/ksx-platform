"""S8 기능 점검(구현안내서 11장 보완) — 지식 그래프가 바뀌면 속성 그래프가 그대로 따라오는가.

  sync-check   Fuseki의 지식 그래프를 잠깐 바꾸고 → 속성 그래프 반영(sync와 같은 경로) → 전수 비교 → 원래대로 되돌린다.
                 ① 삭제: 노드 하나(관계가 걸린)를 지우면 노드 1·그 관계 전부가 지워지고, 되돌리면 다시 생긴다.
                 ② 라벨 변경: 노드의 클래스를 바꾸면 옛 라벨에서 지워지고 새 라벨로 생긴다(관계는 다시 잇는다).
                 ③ 반영 지연(E2E-07): 추론 그래프의 값 하나를 바꾸고 조회 계정 cypher로 보일 때까지의 시간 × 회차 → p95.
                    배치(명령 실행) 기준이다. 실시간(CDC·Kafka) 지연은 S11에서 다시 잰다.
               벡터(Qdrant)·임베딩은 쓰지 않는다 — PC에서 임베딩 서버 없이 돌릴 수 있다.
               실패해도 finally에서 바꾼 트리플을 되돌리고 속성 그래프를 다시 맞춘다.
리포트: mapping/<기업>/S8_기능점검결과.md · 기록: audit.graph_sync(target = sync-check)
"""
from __future__ import annotations

import json
import math
import os
import time
import urllib.parse
import urllib.request

from .base import Config, sparql, update
from .materialize import end_run, start_run
from .sync import (AUDIT_SQL, RDF_TYPE, age_dump, apply_age, build, code_labels, compare, compare_line, fetch, graph_filter, quality_filter,
                   local, log, psql_at, settings)

PROBE = "http://ksx.local/s8check#syncProbe"


def term(b: dict) -> str:
    """SPARQL 결과의 값 하나 → SPARQL/N-Triples 표기."""
    if b["type"] == "uri":
        return f"<{b['value']}>"
    v = b["value"].replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r")
    if b.get("xml:lang"):
        return f'"{v}"@{b["xml:lang"]}'
    if b.get("datatype"):
        return f'"{v}"^^<{b["datatype"]}>'
    return f'"{v}"'


def p95(xs: list[float]) -> float:
    """최근접 순위 p95(관측값 중 하나)."""
    s = sorted(xs)
    return s[max(0, math.ceil(0.95 * len(s)) - 1)] if s else 0.0


def quads_of(cfg: Config, iri: str) -> list[tuple]:
    """노드가 주어·목적어인 트리플 전부(데이터·추론·위반 표식 그래프) — 지웠다가 되돌릴 원본."""
    q = (f"SELECT ?g ?s ?p ?o WHERE {{ GRAPH ?g {{ {{ ?s ?p ?o FILTER(?s = <{iri}>) }} UNION {{ ?s ?p ?o FILTER(?o = <{iri}>) }} }} "
         f"FILTER({graph_filter(cfg)} || {quality_filter(cfg)}) }}")
    data = urllib.parse.urlencode({"query": q}).encode()
    req = urllib.request.Request(cfg.query, data=data, method="POST", headers={
        "Accept": "application/sparql-results+json", "Content-Type": "application/x-www-form-urlencoded"})
    with urllib.request.urlopen(req, timeout=300) as r:
        js = json.load(r)
    return [(b["g"]["value"], b["s"], b["p"], b["o"]) for b in js["results"]["bindings"]]


def data_block(quads: list[tuple]) -> str:
    by = {}
    for g, s, p, o in quads:
        by.setdefault(g, []).append(f"{term(s)} {term(p)} {term(o)} .")
    return " ".join(f"GRAPH <{g}> {{ {' '.join(ts)} }}" for g, ts in by.items())


def pick(cfg: Config, kg: dict, label: str, skip: set) -> str:
    """라벨의 노드 중 관계가 걸린 첫 노드(IRI 순) — 지식 그래프 내보내기 결과에서 고른다."""
    deg = {}
    for (a, _, b) in kg["edges"]:
        deg[a] = deg.get(a, 0) + 1
        deg[b] = deg.get(b, 0) + 1
    cands = sorted(i for i, n in kg["nodes"].items() if n["label"] == label and deg.get(i) and i not in skip)
    if not cands:
        raise RuntimeError(f"sync_check: 관계가 걸린 {label} 노드가 없습니다 — 계획 sync_check의 라벨을 바꾸세요")
    return cands[0]


def edges_of(kg: dict, iri: str) -> int:
    return sum(1 for (a, _, b) in kg["edges"] if a == iri or b == iri)


def graph_pass(cfg: Config, s: dict, labels: dict) -> tuple[dict, dict, float]:
    t = time.time()
    kg = build(cfg, fetch(cfg), labels)
    age = apply_age(cfg, s, kg)
    return kg, age, round(time.time() - t, 2)


def cypher_one(cfg: Config, s: dict, cy: str) -> list[str]:
    q = (f"SET search_path = ag_catalog, \"$user\", public;\n"
         f"SELECT x FROM cypher('{s['graph']}', $q$ {cy} $q$) AS (x agtype);")
    return [x.strip().strip('"') for x in psql_at(cfg, q, dsn=cfg.reader).splitlines() if x.strip()]


def sync_check(cfg: Config, out=print) -> bool:
    s = settings(cfg)
    sc = dict(cfg.raw.get("sync_check") or {})
    del_label = sc.get("delete", "OperationEnd")
    rel_from, rel_to = (sc.get("relabel") or ["OperationEnd", "OperationStart"])[:2]
    rounds = int(sc.get("rounds", 10))
    target = float(sc.get("latency_p95", 10))
    rid = start_run(cfg, "kg_sync_check", stage="S8")
    psql_at(cfg, AUDIT_SQL)
    labels = code_labels(cfg)
    out(f"S8 기능 점검 run_id={rid} (속성 그래프 {s['graph']} — 삭제 {del_label} · 라벨 변경 {rel_from}→{rel_to} · 지연 {rounds}회)")
    res = {"rid": rid, "steps": [], "lat": []}
    undo = []                                            # (설명, SPARQL UPDATE) — 실패해도 되돌린다

    def step(sid, desc, exp, got, ok, **kw):
        res["steps"].append({"id": sid, "desc": desc, "expected": exp, "got": got, "ok": ok, **kw})
        out(f"  {sid} {'OK' if ok else '불일치'} — {desc}: 기대 {exp} / 결과 {got}")
        log(cfg, rid, "sync-check", sid, {"total": 0}, {"desc": desc, "expected": str(exp), "got": str(got), "ok": ok})

    def full(sid, kg):
        f = compare(kg, age_dump(cfg, s))
        out("  " + compare_line(f).strip())
        step(sid, "전수 비교(지식 그래프 ↔ 속성 그래프)", "차이 0", f"차이 {f['error']}", f["ok"])
        return f

    ok = True
    try:
        kg0, age0, sec = graph_pass(cfg, s, labels)
        base_changes = sum(age0[k][x] for k in ("nodes", "edges") for x in ("added", "updated", "removed"))
        out(f"  시작: 노드 {age0['nodes']['total']:,} · 관계 {age0['edges']['total']:,} (이번 반영 변경 {base_changes}) {sec}초")
        full("S0", kg0)

        # ① 삭제 → 되돌리기
        iri = pick(cfg, kg0, del_label, set())
        ne = edges_of(kg0, iri)
        quads = quads_of(cfg, iri)
        blk = data_block(quads)
        update(cfg.update, f"DELETE DATA {{ {blk} }}")
        undo.append(("삭제 되돌리기", f"INSERT DATA {{ {blk} }}"))
        kg1, age1, sec = graph_pass(cfg, s, labels)
        got = (age1["nodes"]["removed"], age1["edges"]["removed"])
        step("D1", f"노드 삭제 {local(iri)}(관계 {ne}) — 트리플 {len(quads)} 지움", f"노드 삭제 1 · 관계 삭제 {ne}",
             f"노드 삭제 {got[0]} · 관계 삭제 {got[1]} ({sec}초)", got == (1, ne))
        gone = cypher_one(cfg, s, f"MATCH (n {{iri: '{iri}'}}) RETURN count(n)")
        step("D2", "조회 계정 cypher로 지운 노드 찾기", "0", ",".join(gone), gone == ["0"])
        full("D3", kg1)
        update(cfg.update, undo.pop()[1])
        kg2, age2, sec = graph_pass(cfg, s, labels)
        got = (age2["nodes"]["added"], age2["edges"]["added"])
        step("D4", "삭제 되돌리기(트리플 다시 넣음)", f"노드 추가 1 · 관계 추가 {ne}",
             f"노드 추가 {got[0]} · 관계 추가 {got[1]} ({sec}초)", got == (1, ne))
        full("D5", kg2)

        # ② 라벨 변경 → 되돌리기
        iri2 = pick(cfg, kg2, rel_from, {iri})
        ne2 = edges_of(kg2, iri2)
        cls = sparql(cfg.query, f"SELECT ?g ?c WHERE {{ GRAPH ?g {{ <{iri2}> <{RDF_TYPE}> ?c }} FILTER({graph_filter(cfg)}) }}")
        c = cls[0]["c"]
        c2 = c[: -len(local(c))] + rel_to
        gs = sorted({x["g"] for x in cls if x["c"] == c})          # 같은 클래스가 여러 그래프에 있으면 모두 바꾼다
        flip = lambda a, b: "; ".join(f"DELETE DATA {{ GRAPH <{g}> {{ <{iri2}> <{RDF_TYPE}> <{a}> }} }}; "  # noqa: E731
                                      f"INSERT DATA {{ GRAPH <{g}> {{ <{iri2}> <{RDF_TYPE}> <{b}> }} }}" for g in gs)
        update(cfg.update, flip(c, c2))
        undo.append(("라벨 되돌리기", flip(c2, c)))
        kg3, age3, sec = graph_pass(cfg, s, labels)
        got = (age3["nodes"]["removed"], age3["nodes"]["added"], age3["edges"]["removed"], age3["edges"]["added"])
        step("L1", f"라벨 변경 {local(iri2)} {rel_from}→{rel_to}(관계 {ne2})", f"노드 삭제 1·추가 1 · 관계 삭제 {ne2}·추가 {ne2}",
             f"노드 삭제 {got[0]}·추가 {got[1]} · 관계 삭제 {got[2]}·추가 {got[3]} ({sec}초)", got == (1, 1, ne2, ne2))
        now = cypher_one(cfg, s, f"MATCH (n:{rel_to} {{iri: '{iri2}'}}) RETURN count(n)")
        old = cypher_one(cfg, s, f"MATCH (n:{rel_from} {{iri: '{iri2}'}}) RETURN count(n)")
        step("L2", "조회 계정 cypher — 새 라벨에 1, 옛 라벨에 0", "1/0", f"{','.join(now)}/{','.join(old)}", now == ["1"] and old == ["0"])
        full("L3", kg3)
        update(cfg.update, undo.pop()[1])
        kg4, age4, sec = graph_pass(cfg, s, labels)
        step("L4", "라벨 되돌리기", "노드 삭제 1·추가 1", f"노드 삭제 {age4['nodes']['removed']}·추가 {age4['nodes']['added']} ({sec}초)",
             (age4["nodes"]["removed"], age4["nodes"]["added"]) == (1, 1))
        full("L5", kg4)

        # ③ 반영 지연(E2E-07) — 추론 그래프의 값 하나를 바꿔 조회 계정에서 보일 때까지
        inf = cfg.inferred_prefix
        r = sparql(cfg.query, f"SELECT ?g ?s WHERE {{ GRAPH ?g {{ ?s <{RDF_TYPE}> ?c }} FILTER(STRSTARTS(STR(?g), \"{inf}\")) }} ORDER BY ?s LIMIT 1")
        if not r:
            raise RuntimeError("추론 그래프에 노드가 없습니다 — S7 infer를 먼저 실행하세요")
        ig, iiri = r[0]["g"], r[0]["s"]
        undo.append(("지연 시험 값 지우기", f"DELETE WHERE {{ GRAPH <{ig}> {{ <{iiri}> <{PROBE}> ?v }} }}"))
        for i in range(1, rounds + 1):
            t0 = time.time()
            update(cfg.update, f"DELETE WHERE {{ GRAPH <{ig}> {{ <{iiri}> <{PROBE}> ?v }} }}; "
                               f"INSERT DATA {{ GRAPH <{ig}> {{ <{iiri}> <{PROBE}> \"r{i}\" }} }}")
            t1 = time.time()
            kg5 = build(cfg, fetch(cfg), labels)
            t2 = time.time()
            a5 = apply_age(cfg, s, kg5)
            t3 = time.time()
            seen = cypher_one(cfg, s, f"MATCH (n {{iri: '{iiri}'}}) RETURN n.syncProbe")
            t4 = time.time()
            res["lat"].append({"round": i, "total": round(t4 - t0, 2), "update": round(t1 - t0, 2), "export": round(t2 - t1, 2),
                               "apply": round(t3 - t2, 2), "read": round(t4 - t3, 2), "seen": seen == [f"r{i}"],
                               "changed": a5["nodes"]["updated"]})
            out(f"    지연 {i}/{rounds}: {t4 - t0:.2f}초 (갱신 {t1 - t0:.2f} · 내보내기 {t2 - t1:.2f} · 반영 {t3 - t2:.2f} · 조회 {t4 - t3:.2f}) "
                f"{'보임' if seen == [f'r{i}'] else '안 보임 ' + str(seen)}")
        tot = [x["total"] for x in res["lat"]]
        res["p95"] = p95(tot)
        res["target"] = target
        step("E1", f"반영 지연 p95(배치, {rounds}회, {local(iiri)} 값 바꿈 → 조회 계정에서 보임)", f"≤ {target:g}초",
             f"p95 {res['p95']:.2f}초 · 중앙 {sorted(tot)[len(tot) // 2]:.2f} · 최대 {max(tot):.2f}",
             res["p95"] <= target and all(x["seen"] and x["changed"] == 1 for x in res["lat"]))
        update(cfg.update, undo.pop()[1])
        kg6, age6, sec = graph_pass(cfg, s, labels)
        step("E2", "지연 시험 값 지우기", "노드 변경 1", f"노드 변경 {age6['nodes']['updated']} ({sec}초)", age6["nodes"]["updated"] == 1)
        full("Z", kg6)
    except Exception as e:
        ok = False
        out(f"  중단: {e}")
        res["error"] = str(e)[:500]
    finally:
        while undo:                                       # 중간에 멈춰도 지식 그래프·속성 그래프를 되돌린다
            desc, u = undo.pop()
            try:
                update(cfg.update, u)
                out(f"  되돌림: {desc}")
            except Exception as e:  # noqa: BLE001
                out(f"  되돌림 실패({desc}): {e}")
        if res.get("error") or not res["steps"] or res["steps"][-1]["id"] != "Z":
            try:
                kg, age, sec = graph_pass(cfg, s, labels)
                out(f"  다시 맞춤: 노드 {age['nodes']['total']:,} · 관계 {age['edges']['total']:,} {sec}초")
            except Exception as e:  # noqa: BLE001
                out(f"  다시 맞춤 실패: {e}")
    ok = ok and bool(res["steps"]) and all(x["ok"] for x in res["steps"])
    report(cfg, res, ok)
    end_run(cfg, rid, ok, {"p95": res.get("p95"), "failed": [x["id"] for x in res["steps"] if not x["ok"]], "error": res.get("error")})
    out(f"ksxkg sync-check: {'완료' if ok else '완료 기준 미충족'}")
    return ok


def report(cfg: Config, res: dict, ok: bool):
    md = [f"# S8 기능 점검 결과 ({cfg.ent}) — ksxkg sync-check", "",
          f"- 실행: `{res['rid']}` · 판정 **{'충족' if ok else '미충족'}**",
          "- 방법: Fuseki의 지식 그래프를 잠깐 바꾸고 → 속성 그래프 반영(sync와 같은 경로) → 조회 계정 cypher·전수 비교 → 되돌림.",
          "- 벡터(Qdrant)·임베딩은 쓰지 않는다. 지연은 명령 실행(배치) 기준이며 실시간(CDC·Kafka) 지연은 S11에서 다시 잰다.", ""]
    if res.get("error"):
        md += [f"> 중단: {res['error']}", ""]
    md += ["## 점검 항목", "", "| ID | 내용 | 기대 | 결과 | 판정 |", "|---|---|---|---|---|"]
    md += [f"| {x['id']} | {x['desc']} | {x['expected']} | {x['got']} | {'✔' if x['ok'] else '✘'} |" for x in res["steps"]]
    if res["lat"]:
        md += ["", f"## 반영 지연 (E2E-07, 배치 기준) — p95 {res.get('p95', 0):.2f}초 / 목표 {res.get('target', 10):g}초", "",
               "추론 그래프의 값 하나를 바꾼 때부터 조회 계정 cypher로 새 값이 보일 때까지. 내보내기는 매번 전체(데이터·추론 그래프)를 읽는다.", "",
               "| 회차 | 전체(초) | 갱신 | 내보내기 | 반영 | 조회 | 보임 |", "|---:|---:|---:|---:|---:|---:|---|"]
        md += [f"| {x['round']} | {x['total']} | {x['update']} | {x['export']} | {x['apply']} | {x['read']} | {'✔' if x['seen'] else '✘'} |"
               for x in res["lat"]]
    p = os.path.join(cfg.mapping_dir(), "S8_기능점검결과.md")
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
