"""ksxgen 회귀 시험: 커버리지·생성물 최신 여부·Turtle 문법. pytest 또는 python으로 실행."""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "ksxgen"))

from ksxgen import cli, emit, vocab  # noqa: E402
from ksxgen import ext as X  # noqa: E402
from ksxgen.model import load  # noqa: E402

STD = os.path.join(ROOT, "standards")
EXT = os.path.join(ROOT, "extensions", "impix")


def test_counts_and_coverage():
    m = load(STD)
    v = vocab.build(m)
    assert len(m.tables) == 76 and m.noun_count == 68
    assert sum(t.role == "line" for t in m.tables.values()) == 8
    assert sum(len(x) for x in v.refs.values()) + len(v.lines) == sum(r.physical for r in m.relations) == 609
    _, ok = emit.coverage(m, v)
    assert ok and not v.issues


def test_generated_files_are_current():
    with tempfile.TemporaryDirectory() as tmp:
        cli.build(STD, tmp, cli._cfg(os.path.join(ROOT, "ksxgen.yaml")), quiet=True, exts=[EXT])
        new, cur = cli._digest(tmp), cli._digest(os.path.join(ROOT, "ontologies"))
        stale = [k for k in new if cur.get(k) != new[k]]
    assert not stale, f"ksxgen build 다시 실행 필요: {stale[:5]}"


def test_turtle_parses():
    try:
        import rdflib
    except ImportError:
        print("rdflib 없음 — Turtle 문법 시험 생략")
        return
    for f in ("tbox/ksx9101_core.ttl", "shapes/ksx9101_conformance.ttl", "vocab/codelist.ttl"):
        g = rdflib.Graph()
        g.parse(os.path.join(ROOT, "ontologies", f), format="turtle")
        assert len(g) > 1000, f
    g = rdflib.Graph().parse(os.path.join(ROOT, "ontologies", "vocab", "uom.ttl"), format="turtle")
    assert len(g) > 200


def test_extension_impix():
    """IMPIX 확장: 오류 0, 확장 명사 5·확장 속성 8, Core 이름 추가 없음."""
    m = load(STD)
    v = vocab.build(m)
    cfg = X.ext_config(EXT)
    e = X.read(cfg["path"], m, cfg)
    X.complete(e, m)
    issues = X.validate(e, m)
    assert not [i for i in issues if i.level == "오류"], issues
    kinds = [t.ext_type for t in e.tables.values()]
    assert kinds.count("확장 명사") == 5 and kinds.count("확장 속성") == 17   # S1 8 + S2 매핑 9
    props, _, _, viss = X.ext_vocab(e, m, v)
    assert not viss
    assert all(p.name.startswith("impix:") for p in props.values() if p.new)
    ttl = open(os.path.join(ROOT, "ontologies", "tbox", "impix_ext.ttl"), encoding="utf-8").read()
    assert not [l for l in ttl.splitlines() if l.startswith("ksx:")], "확장 T-Box에 ksx: 이름 선언 금지"
    assert "owl:equivalentClass" not in ttl and "owl:disjointWith" not in ttl and "rdfs:domain" not in ttl


def test_extension_prohibitions():
    """금지 규칙: Core 테이블명·속성 타입 재정의, 고정형 표준 그룹 코드 추가, 복합 UK 부분 참조는 오류."""
    import openpyxl
    import shutil
    with tempfile.TemporaryDirectory() as tmp:
        d = os.path.join(tmp, "bad")
        shutil.copytree(EXT, d)
        p = os.path.join(d, "확장정의서.xlsx")
        wb = openpyxl.load_workbook(p)
        wb["테이블목록"].append([None, "x", "확장", None, "로트", "Lot", "Lot", "x", None, "EnterpriseID + LotID", None, None,
                                 None, None, None, "확장 명사", None, None, "x", None, "초안"])
        wb["테이블정의서"].append(["CustomerComplaint", "x", None, None, "x", "LotCreatedQuantity", None, "확장", "string",
                                  None, None, None, None, None, None, None, None, "x", "x", None, "초안"])
        wb["코드그룹목록"].append([None, "x", "EquipmentState", "x", "고정형", None, "x", "x", "x", "표준 그룹 하위 확장", "초안"])
        wb["테이블정의서"].append(["CustomerComplaint", "x", None, None, "x", "ProductionOrderID", None, "확장", "IDREF",
                                  None, None, None, None, None, "ProductionOrder.ProductionOrderID", None, None, "x", "x", None, "초안"])
        wb.save(p)
        m = load(STD)
        e = X.read(p, m, X.ext_config(d))
        X.complete(e, m)
        msgs = " | ".join(i.msg for i in X.validate(e, m) if i.level == "오류")
    assert "표준 테이블명" in msgs and "재정의 금지" in msgs and "고정형 표준 그룹" in msgs, msgs
    assert "부모 UK 일부만" in msgs, msgs                    # 복합 UK 부모를 한 컬럼으로만 참조


def test_extension_turtle_parses():
    try:
        import rdflib
    except ImportError:
        print("rdflib 없음 — 확장 Turtle 문법 시험 생략")
        return
    for f in ("tbox/impix_ext.ttl", "shapes/impix_ext_shapes.ttl", "vocab/impix_codelist.ttl"):
        g = rdflib.Graph()
        g.parse(os.path.join(ROOT, "ontologies", f), format="turtle")
        assert len(g) > 100, f


def _obda_triples(text):
    """OBDA → (주어 템플릿, 술어, 목적어) 집합(접두어 펼침)."""
    from ksxgen import derive
    pfx, maps = derive.parse_obda(text)
    out = set()
    for _, stmts, src in maps:
        for subj, pos in stmts:
            for p, o in pos:
                o2 = o if o.startswith("{") or p == "a" else derive._expand(o, pfx)
                out.add((src, derive._expand(subj, pfx), p, o2))
    return out


def _rml_triples(texts):
    import re
    from ksxgen import derive
    out = set()
    for t in texts:
        for tm in t.split(" a rr:TriplesMap ;")[1:]:
            src = re.search(r'rr:sqlQuery "((?:[^"\\]|\\.)*)"', tm).group(1).replace('\\"', '"')
            src = derive.unwrap_graph_sql(src)  # 물질화 매핑은 사업장 그래프 컬럼을 더한다
            src = src.replace("::text", "")   # 물질화 매핑은 IRI 템플릿 컬럼을 문자로 읽는다
            subj = re.search(r'rr:subjectMap \[ rr:template "([^"]+)"', tm).group(1)
            for c in re.findall(r"rr:class (\S+)", tm.split("rr:predicateObjectMap")[0]):
                out.add((src, subj, "a", c.rstrip(" ];")))
            for p, om in re.findall(r"rr:predicate (\S+) ; rr:objectMap \[ (.*?) \] \]", tm):
                m = re.match(r'rr:column "([^"]+)"(?: ; rr:datatype (\S+))?$', om)
                o = ("{" + m.group(1) + "}" + ("^^" + m.group(2) if m.group(2) else "")) if m else \
                    re.match(r'rr:template "([^"]+)"', om).group(1)
                out.add((src, subj, p, o))
    return out


def test_rml_equals_obda():
    """물질화 매핑(R2RML)이 가상화 매핑(OBDA)과 같은 트리플 패턴을 만든다 — Core + 확장."""
    import glob
    mp = os.path.join(ROOT, "ontologies", "mappings")
    obda = set()
    for f in ("ksx9101.obda", "impix_ext.obda"):
        obda |= _obda_triples(open(os.path.join(mp, f), encoding="utf-8").read())
    files = sorted(glob.glob(os.path.join(mp, "rml", "*.rml.ttl")))
    rml = _rml_triples([open(f, encoding="utf-8").read() for f in files])
    assert len(files) == 84 + 22
    assert obda == rml, (sorted(obda - rml)[:3], sorted(rml - obda)[:3])


def test_derived_outputs():
    """속성 그래프 스키마·도구 스키마·자동 전이 규칙·단위 분리."""
    import json
    import re
    o = os.path.join(ROOT, "ontologies")
    age = open(os.path.join(o, "graph", "age_schema.sql"), encoding="utf-8").read()
    arrays = re.findall(r"FOREACH x IN ARRAY ARRAY\[(.*?)\] LOOP", age)
    vl, el = (re.findall(r"'(\w+)'", a) for a in arrays)
    assert len(vl) == 76 + 5 and {"Lot", "BOMLine", "CustomerComplaint"} <= set(vl)
    assert {"refParentLot", "hasLine", "lineOf", "refItem"} <= set(el) and "lotState" not in el
    onto = json.load(open(os.path.join(o, "catalog", "tools", "ksx-ontology.json"), encoding="utf-8"))
    card = next(t for t in onto["tools"] if t["name"] == "get_noun_card")
    assert len(card["inputSchema"]["properties"]["noun"]["enum"]) == 68 + 5
    led = json.load(open(os.path.join(o, "catalog", "tools", "ksx-ledger.json"), encoding="utf-8"))
    assert len(next(t for t in led["tools"] if t["name"] == "get_struct")["inputSchema"]["properties"]["noun"]["enum"]) == 8
    auto = sorted(f for f in os.listdir(os.path.join(o, "rules")) if f.startswith("A-"))
    assert len(auto) == 9 and not [f for f in auto if "refParentLot" in f]   # D-3: 로트 계보는 R-001(inf:derivedFrom)이 맡음
    assert "refParentLot" in open(os.path.join(o, "rules", "R-001_lot_genealogy.rq"), encoding="utf-8").read()
    cl = open(os.path.join(o, "vocab", "codelist.ttl"), encoding="utf-8").read()
    assert "/uom/" not in cl and "/uom/EA>" in open(os.path.join(o, "vocab", "uom.ttl"), encoding="utf-8").read()


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
            print("PASS", name)
