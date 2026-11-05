"""S5 완료 기준 검사(구현안내서 표 19): 가상 = SQL, 물질화 = 기대치, 사업장별 그래프 분리.

  가상화   Ontop에 클래스별 개체 수를 물어 원장 SQL 행 수와 비교, 사업장별 로트 수 질의도 비교
  물질화   Fuseki의 (그래프, 클래스)별 개체 수 = 물질화 매핑 SQL의 (그래프)별 행 수,
           그래프별 트리플 수 = 마지막 물질화 기록(audit.kg_load)
  분리     개체의 사업장 속성과 그래프가 같은가, 한 개체가 두 그래프에 있는가, 기본 그래프가 비었는가,
           데이터 그래프 = 원장의 사업장(Plant) + 기업 공통
결과는 mapping/<기업>/S5_검증결과.md와 audit.kg_load(kind=check)에 남긴다.
"""
from __future__ import annotations

import os
from collections import defaultdict

from .base import Config, SparqlError, rows, sparql
from .mappings import class_label, read_rml
from .materialize import end_run, log, start_run


def _n(x) -> int:
    return int(float(x))


def expected(cfg: Config, materialized=True):
    """물질화 매핑 SQL로 (그래프, 클래스)별 기대 개체 수. materialized=False면 물질화 필터 없이(가상 그래프 기준)."""
    tm = read_rml(cfg.rml_texts() if materialized else cfg.rml_files(), {})
    exp = defaultdict(int)
    classes = sorted({c for t in tm for c in t.classes})
    for t in tm:
        if not t.classes:
            continue
        for r in rows(cfg.reader, f"select kg_graph g, count(*) n from ({t.sql}) x group by 1"):
            for c in t.classes:
                exp[(r["g"], c)] += r["n"]
    return exp, classes


def check(cfg: Config, out=print, report=True) -> bool:
    rid = start_run(cfg, "kg_check")
    res = []           # (구분, 검사, 기대, 실제, 결과, 비고)

    def add(group, name, exp, act, ok, note=""):
        res.append((group, name, exp, act, "OK" if ok else "실패", note))
        log(cfg, rid, name, "check", act if isinstance(act, int) else None,
            exp if isinstance(exp, int) else None, "ok" if ok else "fail", {"group": group, "note": note})
        out(f"  {'OK ' if ok else '실패'} [{group}] {name} — 기대 {exp} · 실제 {act}" + (f" ({note})" if note else ""))

    exp, classes = expected(cfg)
    vexp, _ = expected(cfg, materialized=False) if cfg.filters else (exp, classes)
    by_class = {c: 0 for c in classes}
    for (g, c), n in vexp.items():
        by_class[c] += n
    pre = cfg.data_graph_prefix

    # 1. 가상화(Ontop) = SQL ---------------------------------------------------
    diffs, nonzero = [], 0
    try:
        for c in sorted(by_class):
            v = _n(sparql(cfg.ontop, f"SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE {{ ?s a <{c}> }}")[0]["n"])
            nonzero += v > 0
            if v != by_class[c]:
                diffs.append(f"{class_label(c)} {v}/{by_class[c]}")
        add("가상화", "클래스별 개체 수(Ontop) = 원장 행 수", f"{len(by_class)}개 클래스", f"차이 {len(diffs)}",
            not diffs, "; ".join(diffs[:5]) or f"데이터 있는 클래스 {nonzero}")
        q = (f"PREFIX ksx: <{cfg.ns}>\nSELECT ?site ?plant (COUNT(?l) AS ?n) WHERE {{ ?l a ksx:Lot ; ksx:siteID ?site ; "
             "ksx:plantID ?plant } GROUP BY ?site ?plant")
        v = sorted((r["site"], r["plant"], _n(r["n"])) for r in sparql(cfg.ontop, q))
        s = sorted((r["SiteID"], r["PlantID"], r["n"]) for r in rows(
            cfg.reader, 'select "SiteID", "PlantID", count(*) n from ksx."Lot" group by 1, 2'))
        add("가상화", "사업장별 로트 수 질의(SPARQL) = SQL", str(s), str(v), v == s)
    except SparqlError as e:
        add("가상화", "Ontop 엔드포인트", "응답", "실패", False, str(e)[:200])

    # 2. 물질화(Fuseki) = 기대치 -------------------------------------------------
    q = (f"SELECT ?g ?c (COUNT(DISTINCT ?s) AS ?n) WHERE {{ GRAPH ?g {{ ?s a ?c }} "
         f"FILTER(STRSTARTS(STR(?g), \"{pre}\")) }} GROUP BY ?g ?c")
    act = {(r["g"], r["c"]): _n(r["n"]) for r in sparql(cfg.query, q)}
    keys = set(k for k, n in exp.items() if n) | set(act)
    d = sorted(k for k in keys if exp.get(k, 0) != act.get(k, 0))
    add("물질화", "(그래프, 클래스)별 개체 수 = 매핑 SQL 행 수" + (" (물질화 필터 적용)" if cfg.filters else ""), f"{len([k for k in exp if exp[k]])}쌍 · {sum(exp.values()):,}",
        f"{len(act)}쌍 · {sum(act.values()):,}", not d,
        "; ".join(f"{k[0].split('/graph/')[-1]} {class_label(k[1])} {act.get(k, 0)}/{exp.get(k, 0)}" for k in d[:5]))
    last = rows(cfg.owner, "select graph, triples from audit.kg_load where kind = 'data' and triples > 0 and run_id = "
                "(select run_id from audit.run where stage = 'S5' and job = 'kg_materialize' and status = 'succeeded' "
                "order by started_at desc limit 1)")
    exp_t = {r["graph"]: r["triples"] for r in last}
    act_t = {r["g"]: _n(r["n"]) for r in sparql(cfg.query, (
        f"SELECT ?g (COUNT(*) AS ?n) WHERE {{ GRAPH ?g {{ ?s ?p ?o }} FILTER(STRSTARTS(STR(?g), \"{pre}\")) }} GROUP BY ?g"))}
    dt = sorted(g for g in set(exp_t) | set(act_t) if exp_t.get(g) != act_t.get(g))
    add("물질화", "그래프별 트리플 수 = 마지막 물질화 기록", f"{len(exp_t)}개 · {sum(exp_t.values()):,}",
        f"{len(act_t)}개 · {sum(act_t.values()):,}", bool(exp_t) and not dt,
        "; ".join(f"{g.split('/graph/')[-1]} {act_t.get(g)}/{exp_t.get(g)}" for g in dt[:5]) or
        ("물질화 기록 없음 — materialize 먼저" if not exp_t else ""))

    # 3. 사업장별 그래프 분리 -----------------------------------------------------
    base = cfg.data_ns + "graph/"
    common = " ".join(f"<{cfg.ns}{c}>" for c in cfg.common)
    # 공장 그래프의 개체: 그래프 = 개체의 기업·사업장·공장 속성
    q = (f"PREFIX ksx: <{cfg.ns}>\nSELECT (COUNT(DISTINCT ?s) AS ?n) WHERE {{ GRAPH ?g {{ ?s ksx:enterpriseID ?e ; "
         f"ksx:siteID ?si ; ksx:plantID ?p }} FILTER(STRSTARTS(STR(?g), \"{pre}/\") && "
         f"?g != IRI(CONCAT(\"{base}\", STR(?e), \"/\", STR(?si), \"/\", STR(?p)))) }}")
    n = _n(sparql(cfg.query, q)[0]["n"])
    add("분리", "공장 그래프 개체의 사업장 속성과 그래프가 다름", 0, n, n == 0)
    # 기업 공통 그래프의 개체: 공장 속성이 있으면 기업 공통 기준정보 명사여야 한다(S5 D-2)
    q = (f"PREFIX ksx: <{cfg.ns}>\nSELECT (COUNT(DISTINCT ?s) AS ?n) WHERE {{ GRAPH <{pre}> {{ ?s a ?c ; ksx:plantID ?p }} "
         + (f"FILTER(?c NOT IN ({common.replace(' ', ', ')}))" if common else "") + " }")
    n = _n(sparql(cfg.query, q)[0]["n"])
    add("분리", "기업 공통 그래프에 든 공장 개체(기준정보 아닌 것)", 0, n, n == 0, "공통: " + (", ".join(cfg.common) or "없음"))
    if common:
        q = (f"SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE {{ VALUES ?c {{ {common} }} GRAPH ?g {{ ?s a ?c }} "
             f"FILTER(?g != <{pre}>) }}")
        n = _n(sparql(cfg.query, q)[0]["n"])
        add("분리", "기업 공통 기준정보인데 공장 그래프에 있는 개체", 0, n, n == 0)
    q = (f"SELECT (COUNT(DISTINCT ?s) AS ?n) WHERE {{ GRAPH ?g1 {{ ?s a ?c1 }} GRAPH ?g2 {{ ?s a ?c2 }} "
         f"FILTER(?g1 != ?g2 && STRSTARTS(STR(?g1), \"{pre}\") && STRSTARTS(STR(?g2), \"{pre}\")) }}")
    n = _n(sparql(cfg.query, q)[0]["n"])
    add("분리", "두 사업장 그래프에 함께 있는 개체", 0, n, n == 0)
    n = _n(sparql(cfg.query, "SELECT (COUNT(*) AS ?n) WHERE { ?s ?p ?o }")[0]["n"])
    add("분리", "기본 그래프 트리플(그래프 지정 없는 질의에 보이는 데이터)", 0, n, n == 0, "unionDefaultGraph false")
    plants = sorted(f"{pre}/{r['SiteID']}/{r['PlantID']}" for r in rows(
        cfg.reader, f"select \"SiteID\", \"PlantID\" from ksx.\"Plant\" where \"EnterpriseID\" = '{cfg.ent}'"))
    graphs = sorted(g for g in act_t)
    extra = [g for g in graphs if g != pre and g not in plants]
    add("분리", "데이터 그래프 ⊆ 원장 사업장 + 기업 공통", ", ".join(x.split("/graph/")[-1] for x in plants + [pre]),
        ", ".join(x.split("/graph/")[-1] for x in graphs), not extra,
        ("원장에 없는 사업장: " + ", ".join(extra)) if extra else "")
    ok = all(r[4] == "OK" for r in res)
    end_run(cfg, rid, ok, {"checks": len(res), "failed": sum(r[4] != "OK" for r in res)})
    if report:
        _report(cfg, res, exp, act)
    out("ksxkg check: " + ("통과" if ok else f"실패 {sum(r[4] != 'OK' for r in res)}건"))
    return ok


def _report(cfg: Config, res, exp, act):
    md = [f"# S5 지식 그래프 검증 결과 ({cfg.ent}) — ksxkg check", "",
          "구현안내서 표 19 완료 기준: 가상 질의 결과 = SQL 결과, 물질화 트리플 수 = 기대치, 사업장별 그래프 분리.", "",
          "| 구분 | 검사 | 기대 | 실제 | 결과 | 비고 |", "|---|---|---|---|---|---|"]
    md += [f"| {a} | {b} | {c} | {d} | {e} | {f} |" for a, b, c, d, e, f in res]
    md += ["", "## 그래프별 개체 수", "", "| 그래프 | 클래스 | 개체 |", "|---|---|---|"]
    per = defaultdict(lambda: [0, 0])
    for (g, c), n in act.items():
        per[g][0] += 1
        per[g][1] += n
    for g in sorted(per):
        md.append(f"| `{g.split('/graph/')[-1]}` | {per[g][0]} | {per[g][1]:,} |")
    p = os.path.join(cfg.mapping_dir(), "S5_검증결과.md")
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
