"""생성물 검증(구현안내서 7.3) — ksxgen verify.

  1. 문법     모든 Turtle(T-Box·SHACL·SKOS·물질화 매핑)과 도구 스키마(JSON)를 읽는다
  2. 선언     OWL 2 DL에서 쓰는 어휘가 모두 선언됐는가(클래스·속성·데이터 타입), 속성 이중 선언(데이터·객체) 없음
  3. 일관성   Core + 확장 T-Box의 OWL RL 닫힘에서 owl:Nothing 개체·하위 클래스가 없는가
              (DL 추론기 검사는 ROBOT/HermiT로 따로 한다: robot reason --reasoner hermit)
  4. 셰이프   SHACL 셰이프 자체가 SHACL-SHACL에 맞는가(pyshacl meta-shacl), 셰이프의 경로·대상이 T-Box에 있는가
  5. 매핑     물질화 매핑마다 TriplesMap·logicalTable·subjectMap이 있는가

rdflib·pyshacl·owlrl이 필요하다(pip install rdflib pyshacl owlrl).
결과는 report/verify.md에 남긴다(같은 생성물이면 같은 내용).
"""
from __future__ import annotations

import glob
import json
import os

OWL2_DATATYPES = {  # OWL 2 데이터 타입 맵 + rdfs:Literal
    "string", "integer", "decimal", "boolean", "dateTime", "dateTimeStamp", "double", "float", "long", "int", "short",
    "byte", "nonNegativeInteger", "positiveInteger", "nonPositiveInteger", "negativeInteger", "unsignedLong",
    "unsignedInt", "unsignedShort", "unsignedByte", "normalizedString", "token", "language", "Name", "NCName",
    "NMTOKEN", "hexBinary", "base64Binary", "anyURI"}


def _load(paths):
    import rdflib
    g = rdflib.Graph()
    for p in paths:
        g.parse(p, format="turtle")
    return g


def verify(out: str, quiet: bool = False) -> bool:
    import rdflib
    from rdflib.namespace import OWL, RDF, RDFS, XSD
    SH = rdflib.Namespace("http://www.w3.org/ns/shacl#")
    rows, fails = [], []

    def check(name, ok, detail=""):
        rows.append((name, "OK" if ok else "실패", detail))
        if not ok:
            fails.append(f"{name}: {detail}")

    # 1. 문법 ---------------------------------------------------------------
    ttl = sorted(glob.glob(os.path.join(out, "**", "*.ttl"), recursive=True))
    bad = []
    for p in ttl:
        try:
            _load([p])
        except Exception as e:  # noqa: BLE001 — 파서 예외 종류가 다양함
            bad.append(f"{os.path.relpath(p, out)}: {str(e)[:200]}")
    check("Turtle 문법", not bad, f"{len(ttl)}개 파일" + (" — " + "; ".join(bad[:3]) if bad else ""))
    tj = sorted(glob.glob(os.path.join(out, "catalog", "**", "*.json"), recursive=True))
    badj = []
    for p in tj:
        try:
            json.load(open(p, encoding="utf-8"))
        except ValueError as e:
            badj.append(f"{os.path.relpath(p, out)}: {e}")
    check("JSON 문법(명사 카드·도구 스키마)", not badj, f"{len(tj)}개 파일" + (" — " + "; ".join(badj[:3]) if badj else ""))
    if bad:
        return _report(out, rows, fails, quiet)

    # 2. 선언 ---------------------------------------------------------------
    tb = _load(sorted(glob.glob(os.path.join(out, "tbox", "*.ttl"))))
    classes = set(tb.subjects(RDF.type, OWL.Class))
    dprops = set(tb.subjects(RDF.type, OWL.DatatypeProperty))
    oprops = set(tb.subjects(RDF.type, OWL.ObjectProperty))
    aprops = set(tb.subjects(RDF.type, OWL.AnnotationProperty))
    dtypes = set(tb.subjects(RDF.type, RDFS.Datatype))
    pun = sorted(str(x) for x in dprops & oprops)
    check("속성 이중 선언(데이터·객체)", not pun, ", ".join(pun[:5]) or "없음")
    und = set()
    for p in oprops:
        for r in tb.objects(p, RDFS.range):
            if r not in classes:
                und.add(f"range {r} ({p})")
        for inv in tb.objects(p, OWL.inverseOf):
            if inv not in oprops:
                und.add(f"inverseOf {inv}")
    for p in dprops:
        for r in tb.objects(p, RDFS.range):
            local = str(r).replace(str(XSD), "")
            if str(r).startswith(str(XSD)) and local not in OWL2_DATATYPES and r not in dtypes:
                und.add(f"datatype {r}")
    for c in classes:
        for s in tb.objects(c, RDFS.subClassOf):
            if s not in classes:
                und.add(f"subClassOf {s} ({c})")
    for s, p, o in tb:
        if p not in (RDF.type,) and isinstance(o, rdflib.Literal) and p not in aprops | dprops and \
                str(p).startswith(("http://www.w3.org/2004/02/skos/", "http://purl.org/dc/terms/")):
            und.add(f"annotation {p}")
    check("OWL 2 DL 선언(클래스·속성·데이터 타입)", not und, "; ".join(sorted(und)[:5]) or "누락 없음")
    noun = rdflib.URIRef(str(next(iter(tb.subjects(RDFS.label, rdflib.Literal("KS X 9101 명사", lang="ko"))))))
    nouns = set(tb.subjects(RDFS.subClassOf, noun))
    lines = {c for c in classes if (c, RDFS.subClassOf, rdflib.URIRef(str(noun)[:-4] + "StructLine")) in tb}
    check("클래스 수", len(nouns) >= 68 and len(lines) == 8,
          f"명사 {len(nouns)}(Core 68 + 확장 {len(nouns) - 68}) · 라인 구조체 {len(lines)} · 데이터 속성 {len(dprops)} · 객체 관계 {len(oprops)}")

    # 3. 일관성(OWL RL) -----------------------------------------------------
    import owlrl
    cl = rdflib.Graph()
    cl += tb
    owlrl.DeductiveClosure(owlrl.OWLRL_Semantics, axiomatic_triples=False, datatype_axioms=False).expand(cl)
    nothing = sorted(str(s) for s in cl.subjects(RDF.type, OWL.Nothing))
    unsat = sorted(str(s) for s in cl.subjects(RDFS.subClassOf, OWL.Nothing) if s != OWL.Nothing)
    check("일관성(OWL RL 닫힘)", not nothing and not unsat,
          f"닫힘 {len(cl):,}트리플, owl:Nothing 개체 {len(nothing)} · 불만족 클래스 {len(unsat)}")

    # 4. 셰이프 -------------------------------------------------------------
    import pyshacl
    sg_paths = sorted(glob.glob(os.path.join(out, "shapes", "*.ttl")))
    sg = _load(sg_paths)
    try:
        conforms, _, txt = pyshacl.validate(rdflib.Graph(), shacl_graph=sg, meta_shacl=True, inference="none")
        meta_ok, meta_txt = True, f"셰이프 {len(set(sg.subjects(RDF.type, SH.NodeShape)))}개"
    except Exception as e:  # noqa: BLE001 — meta-shacl 실패는 예외로 온다
        meta_ok, meta_txt = False, str(e)[:300]
    check("SHACL 셰이프 자체 유효성(SHACL-SHACL)", meta_ok, meta_txt)
    known = dprops | oprops | {rdflib.URIRef(str(noun)[:-4] + x) for x in ("hasLine", "lineOf")}
    paths = {o for o in sg.objects(None, SH.path) if isinstance(o, rdflib.URIRef)}
    targets = set(sg.objects(None, SH.targetClass))
    miss = sorted(str(x) for x in (paths - known)) + sorted(str(x) for x in (targets - classes))
    check("셰이프 경로·대상이 T-Box에 있음", not miss, ", ".join(miss[:5]) or f"경로 {len(paths)} · 대상 {len(targets)}")

    # 5. 물질화 매핑 ---------------------------------------------------------
    RR = rdflib.Namespace("http://www.w3.org/ns/r2rml#")
    rml = sorted(glob.glob(os.path.join(out, "mappings", "rml", "*.rml.ttl")))
    rg = _load(rml)
    tms = set(rg.subjects(RDF.type, RR.TriplesMap))
    badm = [str(t) for t in tms if (t, RR.logicalTable, None) not in rg or (t, RR.subjectMap, None) not in rg]
    preds = set(rg.objects(None, RR.predicate))
    check("물질화 매핑(R2RML)", not badm and preds <= known | {RDF.type},
          f"파일 {len(rml)} · TriplesMap {len(tms)} · 술어 {len(preds)}" + (f" — 구조 오류 {badm[:3]}" if badm else ""))
    return _report(out, rows, fails, quiet)


def _report(out, rows, fails, quiet) -> bool:
    md = ["# ksxgen 생성물 검증 리포트 (ksxgen verify)", "", "| 검사 | 결과 | 내용 |", "|---|---|---|"]
    md += [f"| {a} | {b} | {c} |" for a, b, c in rows]
    md += ["", "DL 추론기(HermiT) 일관성은 `robot reason`으로 따로 확인한다(구현안내서 7.3)."]
    os.makedirs(os.path.join(out, "report"), exist_ok=True)
    with open(os.path.join(out, "report", "verify.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
    if not quiet:
        for a, b, c in rows:
            print(f"  {b:<3} {a} — {c}")
        print("ksxgen verify:", "통과" if not fails else f"실패 {len(fails)}건")
    return not fails
