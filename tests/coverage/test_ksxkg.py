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
    assert {os.path.basename(t.file) for t in noplant if t not in joined} == {"Enterprise.rml.ttl", "Site.rml.ttl"}
    assert len(joined) == 8 * 2 + 17, len(joined)
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


def test_split_nquads():
    with tempfile.TemporaryDirectory() as tmp:
        nq = os.path.join(tmp, "x.nq")
        g1, g2 = "https://d/graph/E/S/P1", "https://d/graph/E"
        with open(nq, "w", encoding="utf-8") as f:
            f.write(f'<https://d/E/Lot/1> <https://o/lotID> "1" <{g1}> .\n'
                    f'<https://d/E/Lot/1> <https://o/lotID> "1" <{g1}> .\n'      # 중복
                    f'<https://d/E/Lot/1> <https://o/note> "a <b> c" <{g1}> .\n'
                    f'<https://d/E/Enterprise/E> <https://o/name> "E"@ko <{g2}> .\n')
        parts = M.split(nq, tmp)
        assert parts[g1][1] == 2 and parts[g2][1] == 1
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
