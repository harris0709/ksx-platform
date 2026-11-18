"""ksxkg(S5) 회귀 시험: 사업장 그래프 배정·N-Quads 분할·Ontop 합본. pytest 또는 python으로 실행."""
import os
import re
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "ksxkg"))
sys.path.insert(0, os.path.join(ROOT, "tools", "ksxgen"))

from ksxgen import derive  # noqa: E402
from ksxkg import materialize as M  # noqa: E402
from ksxkg.mappings import read_rml  # noqa: E402

ONTO = os.path.join(ROOT, "ontologies")


def test_every_triples_map_has_graph():
    """모든 물질화 매핑이 사업장 그래프를 정한다(rr:graphMap) — 사업장 없는 확장 속성·헤더–라인은 주어 명사의 원장 행에서."""
    import glob
    files = sorted(glob.glob(os.path.join(ONTO, "mappings", "rml", "*.rml.ttl")))
    tms = read_rml(files, {})
    assert len(tms) == 114
    assert all(" AS kg_graph FROM (" in t.sql for t in tms)
    noplant = [t for t in tms if " AS plantid" not in t.sql.split(" AS kg_graph FROM (", 1)[1]]
    joined = [t for t in noplant if "LEFT JOIN" in t.sql]
    # 공장 컬럼이 없는 매핑: 기업·사업장(Site) 명사(기업 공통 그래프), 헤더–라인 연결 8(주어 2개씩), 확장 속성 17
    assert {os.path.basename(t.file) for t in noplant if t not in joined} == {
        "Enterprise.rml.ttl", "Site.rml.ttl", "IMPIX_CustomerPartyMasterExt.rml.ttl"}
    assert len(joined) == 8 * 2 + 17 - 1, len(joined)   # 고객 확장 속성은 기업 공통(아래)이라 조인 없음
    # 기업 공통 기준정보(S5 D-2): 품목·공급사·고객과 그 확장 속성은 공장이 있어도 graph/{Ent}
    common = [t for t in tms if os.path.basename(t.file) in (
        "ItemMaster.rml.ttl", "VendorPartyMaster.rml.ttl", "CustomerPartyMaster.rml.ttl", "IMPIX_CustomerPartyMasterExt.rml.ttl")]
    assert len(common) == 4 and all("CASE" not in t.sql.split(" FROM (", 1)[0] for t in common)
    assert len({c for t in tms for c in t.classes}) == 76 + 5


def test_graph_sql():
    d = "https://data.example/"
    src = 'SELECT "EnterpriseID" AS enterpriseid, "SiteID" AS siteid, "PlantID" AS plantid, "LotID" AS lotid FROM ksx."Lot"'
    g = derive.graph_sql(src, d)
    assert "'https://data.example/graph/' || q.enterpriseid || '/' || q.siteid || '/' || q.plantid" in g
    assert derive.unwrap_graph_sql(g) == src
    idx = derive.site_index(["[PrefixDeclaration]\nd:\t" + d + "\n\n[MappingDeclaration] @collection [[\nmappingId\tLot\n"
                             "target\t\td:{enterpriseid}/Lot/{lotid} a ksx:Lot ; ksx:lotID {lotid} .\nsource\t\t" + src + "\n]]\n"])
    ext = 'SELECT "EnterpriseID" AS enterpriseid, "LotID" AS lotid, "VendorID" AS vendorid FROM ext."LotExt"'
    g2 = derive.graph_sql(ext, d, d + "{enterpriseid}/Lot/{lotid}", idx)
    assert 'LEFT JOIN ksx."Lot" AS o ON o."EnterpriseID"::text = q.enterpriseid::text AND o."LotID"::text = q.lotid::text' in g2
    assert derive.unwrap_graph_sql(g2) == ext
    assert derive.graph_sql('SELECT "EnterpriseID" AS enterpriseid FROM ksx."Enterprise"', d).count("CASE") == 0


def test_materialize_filter():
    """물질화 필터(S5 D-3): 시계열 본 매핑과 확장 속성 매핑에 같은 원장 행 조건 — 다른 매핑·S4 파일은 그대로."""
    import glob
    from ksxkg.mappings import filtered
    files = sorted(glob.glob(os.path.join(ONTO, "mappings", "rml", "*.rml.ttl")))
    out = filtered(files, {"TraceParameter": "\"ValidationResultCode\" IS DISTINCT FROM 'NORMAL'"})
    changed = sorted(os.path.basename(f) for f, t in out.items() if t != open(f, encoding="utf-8").read())
    assert changed == ["IMPIX_TraceParameterExt.rml.ttl", "TraceParameter.rml.ttl"], changed
    t = out[[f for f in out if f.endswith("/TraceParameter.rml.ttl")][0]]
    assert 'WHERE EXISTS (SELECT 1 FROM ksx.\\"TraceParameter\\" AS w WHERE w.\\"EnterpriseID\\"::text = f.enterpriseid::text' in t
    assert filtered(files, {}) == {f: open(f, encoding="utf-8").read() for f in files}


def test_shacl_report_parse_and_classify():
    """S6: 검증 리포트(N-Triples) 파싱, 결과 차원 분류(구조·값·관계·의미), 품질 셰이프 메타."""
    from ksxkg import validate as Vd
    SH = "http://www.w3.org/ns/shacl#"
    nt = "\n".join([
        f'_:r <{SH}conforms> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> .',
        f"_:r <{SH}result> _:a .", f"_:r <{SH}result> _:b .", f"_:r <{SH}result> _:c .",
        f"_:a <{SH}focusNode> <https://d/IMPIX/Lot/L1> .", f"_:a <{SH}resultPath> <https://o/lotID> .",
        f"_:a <{SH}sourceConstraintComponent> <{SH}MinCountConstraintComponent> .",
        f"_:a <{SH}resultSeverity> <{SH}Violation> .", f'_:a <{SH}resultMessage> "최소 1개 \\"lotID\\"" .',
        f"_:b <{SH}focusNode> <https://d/IMPIX/Lot/L2> .", f"_:b <{SH}resultPath> <https://o/lotState> .",
        f"_:b <{SH}sourceConstraintComponent> <{SH}ClassConstraintComponent> .",
        f"_:b <{SH}value> <https://d/codelist/LotState/NOPE> .",
        f"_:c <{SH}focusNode> <https://d/IMPIX/ProductionPerformance/P1> .",
        f"_:c <{SH}sourceShape> <https://ontology.impix.co.kr/quality/Q01_PerformanceEndAfterStart> .",
        f"_:c <{SH}sourceConstraintComponent> <{SH}SPARQLConstraintComponent> ."])
    conforms, res = Vd.parse_report(nt)
    assert not conforms and len(res) == 3 and res[0]["resultMessage"] == '최소 1개 "lotID"'
    class Cfg:
        repo = ROOT
        raw = {}
    q = Vd.quality_meta(Cfg)
    assert {m["rule"] for m in q.values()} == {"Q-01", "Q-02", "Q-03", "Q-04", "Q-05"}
    assert {m["dimension"] for m in q.values()} == {"구조", "값", "관계", "의미"}
    dims = [Vd.classify(r, q)["dimension"] for r in res]
    assert dims == ["구조", "값", "의미"], dims


def test_s6_seeds_cover_four_dimensions():
    import yaml
    p = yaml.safe_load(open(os.path.join(ROOT, "mapping", "impix", "s6_plan.yaml"), encoding="utf-8"))
    seeds = [s for s in p["validate"]["seeds"] if s.get("expect")]
    assert len(seeds) == 10 and {s["dimension"] for s in seeds} == {"구조", "값", "관계", "의미"}
    assert [s for s in p["validate"]["seeds"] if not s.get("expect")]          # 정상 대조군


def test_quality_params_filled():
    """S6 D-4: 품질 셰이프 매개변수 — 계획 값으로 채우고, 계획에 없는 매개변수는 오류."""
    import yaml
    from ksxkg import validate as Vd
    class Cfg:
        repo = ROOT
        onto = ONTO
        raw = yaml.safe_load(open(os.path.join(ROOT, "mapping", "impix", "s6_plan.yaml"), encoding="utf-8"))
    txt, files = Vd.shapes_text(Cfg)
    assert b"{{" not in txt and b'VALUES ?plant { "P2" }' in txt
    Cfg.raw = {"validate": {}}
    try:
        Vd.shapes_text(Cfg)
        raise AssertionError("매개변수 누락이 통과됨")
    except SystemExit as e:
        assert "order_driven_plants" in str(e)


def test_delete_data_braces():
    """S5 차이 반영: DELETE DATA 문의 중괄호가 짝이 맞는다(삭제가 있는 재적재에서만 실행되는 경로)."""
    from ksxkg import materialize as Mt
    sent = []
    old = Mt.update
    Mt.update = lambda ep, q: sent.append(q)
    try:
        with tempfile.TemporaryDirectory() as tmp:
            f = os.path.join(tmp, "d.nt")
            open(f, "w", encoding="utf-8").write('<https://d/a> <https://o/p> "x}" .\n')
            class C:
                update = "http://x/update"
            Mt.delete_data(C, "https://d/graph/E", f)
    finally:
        Mt.update = old
    q = sent[0].replace('"x}"', '""')
    assert q.count("{") == q.count("}") == 2 and q.rstrip().endswith("} }"), q


def test_s6_templates():
    """S6 양식: 계획 양식은 seeds 10(4차원) + 대조군, 품질 셰이프 양식은 매개변수를 채우면 Turtle로 읽힌다."""
    import yaml
    p = yaml.safe_load(open(os.path.join(ROOT, "mapping", "_template", "s6_plan.yaml"), encoding="utf-8"))
    seeds = [s for s in p["validate"]["seeds"] if s.get("expect")]
    assert len(seeds) == 10 and {s["dimension"] for s in seeds} == {"구조", "값", "관계", "의미"}
    t = open(os.path.join(ROOT, "mapping", "_template", "quality_shapes_양식.ttl"), encoding="utf-8").read()
    assert t.count("    sh:severity sh:") == 5 and "{{order_driven_plants}}" in t
    try:
        import rdflib
    except ImportError:
        return
    g = rdflib.Graph().parse(data=t.replace("{{order_driven_plants}}", '"P2"'), format="turtle")
    SH = rdflib.Namespace("http://www.w3.org/ns/shacl#")
    assert len(set(g.subjects(rdflib.RDF.type, SH.NodeShape))) == 5


def test_s7_rules_and_plan():
    """S7: 규칙 파라미터(기준일·due_limit), 모든 규칙이 파라미터로 채워지고 SPARQL로 읽힌다, 평가 사례의 규칙이 있다."""
    import glob
    import yaml
    from ksxkg import infer as I
    rules = os.path.join(ROOT, "ontologies", "rules")
    prm = I.load_params(rules, "2026-10-20")
    assert prm["due_limit"] == "2026-10-27" and prm["min_defect_rate"] == "0.02"
    files = sorted(glob.glob(os.path.join(rules, "*.rq")))
    ids = {os.path.basename(f).split("_", 1)[0] for f in files}
    assert {"R-001", "R-002", "R-003", "R-005", "R-010", "R-020", "R-030", "R-100"} <= ids
    import re as _re
    for f in files:   # 규칙 ID 체계(rules/README.md): {ID}_{영문 소문자 이름}.rq, R은 001~039·100~299
        n = os.path.basename(f)
        assert _re.fullmatch(r"(A-\d{3}_\w+|R-(00[1-9]|0[1-3]\d|[12]\d\d)_[a-z0-9_]+)\.rq", n), n
    assert all('inf:ruleId "' + os.path.basename(f).split("_")[0] + '"' in open(f, encoding="utf-8").read()
               for f in files if "Event" in open(f, encoding="utf-8").read() and os.path.basename(f).startswith("R-"))
    texts = [I.render(open(f, encoding="utf-8").read(), prm) for f in files]
    assert all("${" not in t for t in texts)
    plan = yaml.safe_load(open(os.path.join(ROOT, "mapping", "impix", "s7_plan.yaml"), encoding="utf-8"))
    cases = plan["evaluate"]["cases"]
    assert {c["rule"] for c in cases} <= ids and plan["base"].endswith("s6_plan.yaml")
    assert {c["rule"] for c in cases} >= {"R-001", "R-002", "R-003", "R-005", "R-010", "R-020", "R-030", "R-100"}
    try:
        from rdflib.plugins.sparql import prepareQuery
    except ImportError:
        return
    for f, t in zip(files, texts):
        prepareQuery(t)
    for c in cases:
        prepareQuery(I.PREFIXES.format(ns="https://ontology.impix.co.kr/ksx9101/1.0/") + "SELECT DISTINCT ?x WHERE { " + c["select"] + " }")


def test_inference_vocabulary():
    """S7 D-5: 규칙이 쓰는 inf: 어휘는 모두 ontologies/inference/inf.ttl에 선언되고, inf:producedBy가 실제 규칙 ID다."""
    import glob
    import re
    rules = sorted(glob.glob(os.path.join(ONTO, "rules", "*.rq")))
    used = {}
    for f in rules:
        rid = os.path.basename(f).split("_", 1)[0]
        body = "\n".join(l for l in open(f, encoding="utf-8") if not l.lstrip().startswith(("#", "PREFIX")))
        for t in re.findall(r"inf:([A-Za-z]\w*)", body):
            used.setdefault(t, set()).add(rid)
    voc = open(os.path.join(ONTO, "inference", "inf.ttl"), encoding="utf-8").read()
    declared = set(re.findall(r"^inf:(\w+) a ", voc, re.M))
    assert set(used) - declared == set(), sorted(set(used) - declared)
    ids = {os.path.basename(f).split("_", 1)[0] for f in rules}
    for block in re.split(r"\n\s*\n", voc):                    # 선언 하나 = 빈 줄로 나뉜 블록 하나
        m = re.match(r"inf:(\w+) a ", block.strip())
        pb = re.search(r"inf:producedBy \"([A-Z]-\d{3})\"", block)
        if m and pb:
            t, rid = m.group(1), pb.group(1)
            assert rid in ids, (t, rid)
            assert t in used and rid in used[t], (t, rid, used.get(t))
    try:
        import rdflib
    except ImportError:
        return
    g = rdflib.Graph().parse(os.path.join(ONTO, "inference", "inf.ttl"))
    SK = rdflib.Namespace("http://www.w3.org/2004/02/skos/core#")
    INF = rdflib.Namespace("https://ontology.impix.co.kr/inference/")
    for t in used:
        s = INF[t]
        assert any(l.language == "ko" for l in g.objects(s, rdflib.RDFS.label)) and (s, SK.definition, None) in g, t


def test_s7_templates():
    """S7 양식: 계획 양식은 base·infer·사례, 규칙 양식은 파라미터 없이 SPARQL로 읽힌다."""
    import yaml
    t = os.path.join(ROOT, "mapping", "_template")
    p = yaml.safe_load(open(os.path.join(t, "s7_plan.yaml"), encoding="utf-8"))
    assert p["base"].endswith("s6_plan.yaml") and p["infer"]["thresholds"] == {"precision": 0.9, "recall": 0.95}
    assert all({"id", "rule", "select", "expected"} <= set(c) for c in p["evaluate"]["cases"])
    q = open(os.path.join(t, "rule_양식.rq"), encoding="utf-8").read()
    assert sum(1 for l in q.splitlines() if l.startswith("CONSTRUCT {")) == 1 and "ksxq:violates" in q
    try:
        from rdflib.plugins.sparql import prepareQuery
    except ImportError:
        return
    prepareQuery(q)


def test_split_nquads():
    with tempfile.TemporaryDirectory() as tmp:
        nq = os.path.join(tmp, "x.nq")
        g1, g2 = "https://d/graph/E/S/P1", "https://d/graph/E"
        with open(nq, "w", encoding="utf-8") as f:
            f.write(f'<https://d/E/Lot/1> <https://o/lotID> "1" <{g1}> .\n'
                    f'<https://d/E/Lot/1> <https://o/lotID> "1" <{g1}> .\n'      # 중복
                    f'<https://d/E/Lot/1> <https://o/note> "a <b> c" <{g1}> .\n'
                    f'<https://d/E/Enterprise/E> <https://o/name> "E"@ko <{g2}> .\n')
        with open(nq, "a", encoding="utf-8", newline="") as f:   # 윈도우 원천: 문자값 안의 CR이 이스케이프 없이 나옴
            f.write(f'<https://d/E/Lot/2> <https://o/note> "a\r\\nb" <{g1}> .\n')
        parts = M.split(nq, tmp, out=lambda *_: None)
        assert parts[g1][1] == 3 and parts[g2][1] == 1
        assert '<https://d/E/Lot/2> <https://o/note> "a\\r\\nb" .\n' in open(parts[g1][0], encoding="utf-8", newline="\n").read()
        assert open(parts[g2][0], encoding="utf-8").read() == '<https://d/E/Enterprise/E> <https://o/name> "E"@ko .\n'


def test_ontop_merged_files():
    obda = open(os.path.join(ONTO, "ontop", "ksx.obda"), encoding="utf-8").read()
    ttl = open(os.path.join(ONTO, "ontop", "ksx.ttl"), encoding="utf-8").read()
    assert obda.startswith("[PrefixDeclaration]") and obda.count("mappingId\t") == 84 + 22
    assert "impix:\t" in obda and obda.rstrip().endswith("]]")
    assert "owl:imports <" not in ttl and "impix:StandardCost a owl:Class" in ttl


# ------------------------------------------------------------------ S8 속성 그래프·벡터 인덱스
def _s8_cfg():
    from ksxkg.base import load_config
    return load_config("mapping/impix/s8_plan.yaml", ROOT)


def test_s8_build_nodes_edges():
    """트리플 → 노드(라벨·속성)·관계: 코드는 값(+레이블), 위반 표식은 속성, 추론 관계는 규칙 ID, 대상 없는 참조는 속성."""
    from ksxkg import sync as S
    cfg = _s8_cfg()
    d, ns, inf = cfg.data_ns, cfg.ns, "https://ontology.impix.co.kr/inference/"
    g1, gi, gq = cfg.graph("IMPIX/HQ/P2"), cfg.graph("inferred/IMPIX/HQ/R-001"), cfg.graph("quality")
    U = lambda v: {"type": "uri", "value": v}  # noqa: E731
    L = lambda v, dt=None: {"type": "literal", "value": v, **({"datatype": dt} if dt else {})}  # noqa: E731
    a, b, c = d + "IMPIX/HQ/P2/Lot/E1", d + "IMPIX/HQ/P2/Lot/H1", d + "IMPIX/HQ/P2/Lot/X"
    T = [(g1, U(a), S.RDF_TYPE, U(ns + "Lot")), (g1, U(b), S.RDF_TYPE, U(ns + "Lot")),
         (g1, U(a), ns + "lotID", L("E1")), (g1, U(a), ns + "lotQuantity", L("12", S.XSD + "decimal")),
         (g1, U(a), ns + "lotState", U(d + "codelist/LotState/H")), (g1, U(a), ns + "refParentLot", U(c)),
         (gi, U(a), inf + "derivedFrom", U(b)), (gq, U(a), "https://ontology.impix.co.kr/quality/violates", U(d + "shape/Q-01"))]
    kg = S.build(cfg, T, {d + "codelist/LotState/H": "보류"})
    n = kg["nodes"][a]
    assert n["label"] == "Lot" and n["props"]["lotID"] == "E1" and n["props"]["lotQuantity"] == 12.0
    assert n["props"]["lotState"] == "H" and kg["labels"][("lotState", "H")] == "보류"
    assert n["props"]["plant"] == "P2" and n["props"]["graph"] == "IMPIX/HQ/P2" and n["props"]["violates"] == ["Q-01"]
    assert n["props"]["refParentLot"] == c and kg["dangling"] == 1          # 대상 없는 참조는 IRI 속성
    assert kg["edges"] == {(a, "derivedFrom", b): {"graph": "inferred/IMPIX/HQ/R-001", "inferred": True, "ruleId": "R-001"}}
    assert S.fmt("H", "lotState", kg["labels"]) == "보류(H)"


def test_s8_plan_and_documents():
    """계획: 평가 사례(명사 카드 = S1 질의 155건)·문서·탐색 확인이 실제 명사·문서와 맞는다. 문서 청크 500~800자, 폐기 판 포함."""
    import json
    import glob
    from ksxkg import sync as S
    cfg = _s8_cfg()
    s = S.settings(cfg)
    assert s["dim"] == 1024 and s["model"] == "BAAI/bge-m3" and s["eval"]["k"] == 5 and s["eval"]["threshold"] == 0.9
    cards = S.load_cards(cfg, s)
    items = S.noun_card_items(cfg, s, cards)
    assert len(items) == 73 and items["BOM"]["payload"]["layer"] == "core" and items["CustomerComplaint"]["payload"]["layer"] == "ext"
    assert "BOMLine" in items["BOM"]["text"] and cards["BOMLine"] is cards["BOM"]
    cases = s["eval"]["cases"]
    by = {}
    for c in cases:
        by.setdefault(c["collection"], []).append(c)
    assert len(by["noun_cards"]) == 155 and all(set(c["expected"]) <= set(items) for c in by["noun_cards"])
    docs = {}
    for f in glob.glob(os.path.join(ROOT, "mapping", "impix", "sop", "SOP-*.md")):
        m, body = S.front_matter(open(f, encoding="utf-8").read())
        docs.setdefault(m["doc_id"], []).append((str(m["version"]), m["status"]))
        assert all(len(t) <= 800 for _, t in S.chunks(body, 500, 800))
    assert sorted(docs["SOP-DC-001"]) == [("2", "폐기"), ("3", "현행")] and len(docs) == 10
    for c in by["documents"]:
        assert set(c["expected"]) <= set(docs)
        for mn in c.get("must_not") or []:
            i, v = mn.split("@")
            assert (v, dict(docs[i])[v]) in docs[i]
    assert {g["id"] for g in s["checks"]} == {"G01", "G02", "G03", "G04", "G05"}
    assert S.default_filter("documents", None) == {"must": [{"key": "status", "match": {"value": "현행"}}]}
    assert S.default_filter("documents", {"status": "폐기"})["must"] == [{"key": "status", "match": {"value": "폐기"}}]
    assert S.default_filter("nodes", None) is None
    json.dumps(items)


def test_s8_business_terms():
    """명사 카드 업무 용어(D-1): 원천 업무 의미·KPI명·참조 개체 이름·코드 레이블·현업 용어. 평가 질문(S1 업무 질의서)은 쓰지 않는다."""
    import inspect
    from ksxkg import sync as S
    cfg = _s8_cfg()
    s = S.settings(cfg)
    s["terms"] = {"Personnel": ["퇴직자"]}
    cards = S.load_cards(cfg, s)
    tp = {"label": "TraceParameter", "props": {"parameterID": "P01", "validationResultCode": "OVER_USL"}}
    ep = {"label": "EquipmentParameter", "props": {"parameterID": "P01", "parameterName": "금형온도"}}
    kg = {"nodes": {"a": tp, "b": ep}, "edges": {}, "labels": {("validationResultCode", "OVER_USL"): "규격 상한 초과"}}
    t = S.business_terms(cfg, s, cards, kg)
    assert t["TraceParameter"]["파라미터 수집값"] == "원천 업무 의미"
    assert t["TraceParameter"]["금형온도"] == "참조 개체 이름" and t["TraceParameter"]["규격 상한 초과"] == "코드 레이블"
    assert t["EquipmentState"]["설비 종합효율(OEE)"] == "KPI" and t["Personnel"]["퇴직자"] == "현업"
    assert all(re.search(r"[가-힣]", x) for v in t.values() for x in v)
    assert "업무질의서" not in inspect.getsource(S.business_terms)
    items = S.noun_card_items(cfg, s, cards, t)
    assert "업무 용어: " in items["TraceParameter"]["text"] and "금형온도" in items["TraceParameter"]["payload"]["terms"]
    assert s["eval"]["metric"] == {"noun_cards": "hit"}


def test_s8_chunks():
    from ksxkg import sync as S
    body = "# 제목\n\n## 1. 가\n\n" + "가" * 450 + "\n\n## 2. 나\n\n" + "나" * 300 + "\n\n## 3. 다\n\n" + "다" * 120 + "\n"
    cs = S.chunks(body, 500, 800)
    assert [(sec, len(t)) for sec, t in cs] == [("1. 가", 450 + 1 + len("[2. 나]\n") + 300), ("3. 다", 120)]   # 500자를 넘기면 끊고, 800자 이하
    assert "[2. 나]" in cs[0][1]                        # 절이 바뀌면 절 제목을 넣는다
    cs = S.chunks("## 1. 가\n\n" + "가" * 600 + "\n\n## 2. 나\n\n" + "나" * 100, 500, 800)
    assert len(cs) == 1 and "[2. 나]" in cs[0][1]       # 짧은 끝 청크는 앞 청크에 붙는다
    long = S.chunks("문장입니다. " * 200, 500, 800)
    assert len(long) > 1 and all(len(t) <= 800 for _, t in long)


class _FakeQdrant:
    """Qdrant REST 대신 메모리 — 색인(차이만)·검색·필터 동작 시험."""
    def __init__(self):
        self.c = {}

    def ensure(self, name, dim, fields):
        self.c.setdefault(name, {})

    def hashes(self, name):
        return {k: v["payload"]["hash"] for k, v in self.c[name].items()}

    def upsert(self, name, pts):
        for p in pts:
            self.c[name][p["id"]] = p

    def delete(self, name, ids):
        for i in ids:
            self.c[name].pop(i)

    def count(self, name):
        return len(self.c[name])

    def search(self, name, vec, k, flt=None):
        def ok(p):
            return all(p["payload"].get(m["key"]) == m["match"]["value"] for m in (flt or {}).get("must", []))
        sc = sorted(((sum(a * b for a, b in zip(vec, p["vector"])), p) for p in self.c[name].values() if ok(p)), key=lambda x: -x[0])
        return [{"score": s, "payload": p["payload"]} for s, p in sc[:k]]


def test_s8_index_and_eval():
    """색인은 문장이 바뀐 점만 다시 임베딩하고 없어진 점은 지운다. 평가: 문서 단위 상위 k, 폐기 판은 기본 필터로 나오지 않는다."""
    from ksxkg import sync as S
    q, emb = _FakeQdrant(), S.Embedder("hash:", 64, 8)
    s = {"dim": 64, "model": "hash", "eval": {"k": 2, "threshold": 0.9, "cases": []}}
    items = {"a": {"text": "금형온도 상한 조치", "payload": {"key": "DOC-1", "status": "현행", "doc_version": "DOC-1@2"}},
             "b": {"text": "금형온도 상한 조치 구판", "payload": {"key": "DOC-1", "status": "폐기", "doc_version": "DOC-1@1"}},
             "c": {"text": "누설시험 합격 기준", "payload": {"key": "DOC-2", "status": "현행", "doc_version": "DOC-2@1"}}}
    st = S.index(q, emb, s, "documents", items, out=lambda *_: None)
    assert (st["total"], st["added"], st["updated"], st["removed"]) == (3, 3, 0, 0)
    items["c"]["text"] = "누설시험 합격 기준 2.0 cc/min"
    del items["b"]
    st = S.index(q, emb, s, "documents", items, out=lambda *_: None)
    assert (st["total"], st["added"], st["updated"], st["removed"]) == (2, 0, 1, 1)
    s["eval"]["cases"] = [{"id": "D1", "collection": "documents", "query": "금형온도 상한", "expected": ["DOC-1"], "must_not": ["DOC-1@1"]},
                          {"id": "D2", "collection": "documents", "query": "누설시험 기준", "expected": ["DOC-2"]}]
    ev = S.evaluate(None, s, q, emb, None, out=lambda *_: None)
    assert ev["recall"] == 1.0 and ev["ok"] and ev["by"]["documents"]["cases"] == 2
    # 컬렉션마다 판정 지표: 정답 2개 중 1개만 상위 k → recall 0.5, 적중 1 (metric hit이면 통과)
    s["eval"]["k"] = 1
    s["eval"]["cases"] = [{"id": "D3", "collection": "documents", "query": "누설시험 기준", "expected": ["DOC-2", "DOC-1"]}]
    ev = S.evaluate(None, s, q, emb, None, out=lambda *_: None)
    assert ev["by"]["documents"]["recall"] == 1.0          # min(정답 수, k) = 1
    s["eval"]["k"] = 2
    s["eval"]["cases"] = [{"id": "D4", "collection": "documents", "query": "누설시험 기준", "expected": ["DOC-2", "DOC-3"]}]
    ev = S.evaluate(None, s, q, emb, None, out=lambda *_: None)
    assert ev["by"]["documents"]["recall"] == 0.5 and not ev["ok"]
    s["eval"]["metric"] = {"documents": "hit"}
    ev = S.evaluate(None, s, q, emb, None, out=lambda *_: None)
    assert ev["by"]["documents"]["score"] == 1.0 and ev["ok"]


def test_s8_age_schema_labels_and_grants():
    """속성 그래프 스키마: 명사·관계 라벨 + 추론 이벤트·관계 라벨(inf.ttl), 서비스 계정 권한·접속 시 미리 로드."""
    import re
    age = open(os.path.join(ONTO, "graph", "age_schema.sql"), encoding="utf-8").read()
    arrays = [re.findall(r"'(\w+)'", a) for a in re.findall(r"FOREACH x IN ARRAY ARRAY\[(.*?)\] LOOP", age)]
    assert [len(a) for a in arrays] == [81, 70, 4, 26]
    assert {"OTDRiskEvent", "SpecOutLotEvent", "RiskCause"} <= set(arrays[2])
    assert {"derivedFrom", "consumedLot", "component", "onLot", "onSalesOrderLine"} <= set(arrays[3])
    vl, iv = derive.inference_labels(open(os.path.join(ONTO, "inference", "inf.ttl"), encoding="utf-8").read())
    assert iv == arrays[3]
    assert "CREATE EXTENSION IF NOT EXISTS age;" in age and "session_preload_libraries = ''age''" in age
    assert "GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ksx_graph TO ksx_owner" in age

if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
            print("PASS", name)
