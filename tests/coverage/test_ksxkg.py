"""ksxkg(S5) 회귀 시험: 사업장 그래프 배정·N-Quads 분할·Ontop 합본. pytest 또는 python으로 실행."""
import os
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


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
            print("PASS", name)
