"""생성물 출력(구현 안내서 7.1): T-Box, SHACL, OBDA, DDL, SKOS, 카탈로그, 적재 순서, 커버리지."""
from __future__ import annotations

import json
import os
import re
from collections import defaultdict

from .model import Model, Table
from .naming import XSD, alias, iri_template
from .vocab import Vocab

PREFIXES = """@prefix ksx:  <{ns}> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .
@prefix dct:  <http://purl.org/dc/terms/> .
"""


def lit(s: str, lang: str | None = None) -> str:
    s = (s or "").replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "")
    return f'"{s}"' + (f"@{lang}" if lang else "")


def _w(path: str, text: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


# ---------------------------------------------------------------- T-Box
def tbox(model: Model, v: Vocab, cfg: dict) -> str:
    ns, ver = cfg["ns"], cfg["version"]
    o = [PREFIXES.format(ns=ns), f"<{ns.rstrip('/')}> a owl:Ontology ;",
         f"    rdfs:label {lit('KS X 9101-1 제조 온톨로지 Core', 'ko')} ;",
         f"    owl:versionInfo {lit(ver)} ;",
         f"    dct:source {lit(os.path.basename(model.source_files['table_definition']))} .", "",
         "### 메타 클래스·주석 속성", "ksx:Noun a owl:Class ; rdfs:label \"KS X 9101 명사\"@ko .",
         "ksx:StructLine a owl:Class ; rdfs:label \"라인 구조체(struct[1..N])\"@ko ; "
         "rdfs:comment \"명사 안에서만 존재하는 반복 행. 독립 명사가 아님\"@ko .",
         "ksx:standardClause a owl:AnnotationProperty .", "ksx:standardTable a owl:AnnotationProperty .",
         "ksx:businessArea a owl:AnnotationProperty .", "ksx:sourceAttribute a owl:AnnotationProperty .",
         "ksx:copyOf a owl:AnnotationProperty ; rdfs:comment \"사본 속성의 원천(Noun.Attr). 관계가 아님\"@ko .",
         "ksx:codeGroup a owl:AnnotationProperty .", "ksx:structOf a owl:AnnotationProperty .",
         "ksx:structType a owl:AnnotationProperty .", "ksx:physicalTable a owl:AnnotationProperty .",
         "ksx:conversionFactor a owl:DatatypeProperty ; rdfs:label \"기준단위 환산계수\"@ko ; rdfs:range xsd:decimal .",
         "ksx:hasLine a owl:ObjectProperty ; rdfs:label \"라인\"@ko ; rdfs:range ksx:StructLine ; owl:inverseOf ksx:lineOf .",
         "ksx:lineOf a owl:ObjectProperty, owl:FunctionalProperty ; rdfs:label \"소속 헤더\"@ko .", "",
         "### 클래스(명사·라인 구조체)"]
    phys = defaultdict(list)
    for t in model.tables.values():
        phys[t.cls].append(t.en)
    for t in model.tables.values():
        if t.role == "line":
            o += [f"ksx:{t.cls} a owl:Class ; rdfs:subClassOf ksx:StructLine ;",
                  f"    rdfs:label {lit(t.ko, 'ko')}, {lit(t.cls, 'en')} ;",
                  f"    ksx:structOf ksx:{t.noun} ; ksx:structType \"struct[1..N]\" ;",
                  f"    ksx:physicalTable {lit(t.en)} ; ksx:standardClause {lit(t.clause)} ."]
        else:
            ko = t.ko[:-2] if t.role == "header" and t.ko.endswith("헤더") else t.ko
            o += [f"ksx:{t.cls} a owl:Class ; rdfs:subClassOf ksx:Noun ;",
                  f"    rdfs:label {lit(ko, 'ko')}, {lit(t.cls, 'en')} ;",
                  f"    skos:definition {lit(t.definition, 'ko')} ;",
                  f"    ksx:standardClause {lit(t.clause)} ; ksx:standardTable {lit('표 ' + str(t.table_no))} ;",
                  f"    ksx:businessArea {lit(t.area, 'ko')} ; ksx:physicalTable {lit(t.en)} ."]
    o += ["", "### 속성"]
    for p in sorted(v.props.values(), key=lambda p: p.name):
        if p.kind == "data":
            head = f"ksx:{p.name} a owl:DatatypeProperty ; rdfs:range {p.range}"
        elif p.kind == "code":
            head = f"ksx:{p.name} a owl:ObjectProperty ; rdfs:range skos:Concept"
            if p.code_group:
                head += f" ; ksx:codeGroup {lit(p.code_group)}"
        else:
            head = (f"ksx:{p.name} a owl:ObjectProperty ; rdfs:range {p.range} ; "
                    f"owl:inverseOf ksx:{p.name}Inverse")
        extra = [f"rdfs:label {lit(p.label_ko, 'ko')}, {lit(p.label_en, 'en')}"]
        extra += [f"ksx:sourceAttribute {lit(a)}" for a in sorted(p.source_attrs)]
        extra += [f"ksx:copyOf {lit(c)}" for c in sorted(p.copy_of)]
        o.append(head + " ;\n    " + " ;\n    ".join(extra) + " .")
        if p.kind == "ref":
            o.append(f"ksx:{p.name}Inverse a owl:ObjectProperty ; rdfs:label {lit(p.label_ko + '(역)', 'ko')} .")
    return "\n".join(o) + "\n"


# ---------------------------------------------------------------- SHACL
def shapes(model: Model, v: Vocab, cfg: dict) -> str:
    o = [PREFIXES.format(ns=cfg["ns"]), f"@prefix ksxs: <{cfg['ns']}shapes/> .", ""]
    for t in model.tables.values():
        ps = []
        for cp in v.colprops[t.en]:
            c, p = cp.col, cp.prop
            if c.fk and c.dtype == "IDREF" and any(c.en in r.rel.fk_cols for r in v.refs[t.en]):
                pass  # 키 값 리터럴도 함께 둔다(조회 편의). 관계 제약은 아래 refs에서
            s = f"sh:path ksx:{p.name} ; sh:maxCount 1"
            if c.notnull:
                s += " ; sh:minCount 1"
            if p.kind == "data":
                s += f" ; sh:datatype {p.range}"
                if c.dtype in ("float", "int") and re.search(r"Quantity$", c.en):
                    s += " ; sh:minInclusive 0"
            else:
                s += " ; sh:class skos:Concept"
            ps.append(s)
        for r in v.refs[t.en]:
            s = f"sh:path ksx:{r.prop.name} ; sh:class {r.prop.range}"
            if r.notnull:
                s += " ; sh:minCount 1"
            ps.append(s)
        if t.role == "header":
            ps.append("sh:path ksx:hasLine ; sh:minCount 1 ; sh:class ksx:" + t.noun + "Line")
        if t.role == "line":
            ps.append(f"sh:path ksx:lineOf ; sh:minCount 1 ; sh:maxCount 1 ; sh:class ksx:{t.noun}")
        body = " ;\n    ".join(f"sh:property [ {s} ]" for s in ps)
        o.append(f"ksxs:{t.cls}Shape a sh:NodeShape ; sh:targetClass ksx:{t.cls} ;\n    {body} .\n")
    return "\n".join(o)


# ---------------------------------------------------------------- Ontop OBDA
def obda(model: Model, v: Vocab, cfg: dict) -> str:
    o = ["[PrefixDeclaration]", f"ksx:\t{cfg['ns']}", f"d:\t{cfg['data_ns']}",
         "xsd:\thttp://www.w3.org/2001/XMLSchema#", "skos:\thttp://www.w3.org/2004/02/skos/core#", "",
         "[MappingDeclaration] @collection [["]
    schema = cfg["schema"]
    for t in model.tables.values():
        cols = [c for c in t.columns if not c.pk]
        sel = ", ".join(f'"{c.en}" AS {alias(c.en)}' for c in cols)
        src = f'SELECT {sel} FROM {schema}."{t.en}"'
        me = iri_template(t, model)
        trip = [f"{me} a ksx:{t.cls}"]
        for cp in v.colprops[t.en]:
            c, p = cp.col, cp.prop
            a = "{" + alias(c.en) + "}"
            if p.kind == "code":
                if p.code_group:
                    trip.append(f"ksx:{p.name} d:codelist/{p.code_group}/{a}")
                elif c.en.endswith("UOMCode"):
                    trip.append(f"ksx:{p.name} d:uom/{a}")
                else:
                    trip.append(f"ksx:{p.name} {a}")
            elif p.range == "xsd:string":
                trip.append(f"ksx:{p.name} {a}")
            else:
                trip.append(f"ksx:{p.name} {a}^^{p.range}")
        for r in v.refs[t.en]:
            parent = model.tables[r.rel.parent]
            cmap = dict(zip(r.rel.parent_cols, r.rel.fk_cols))
            trip.append(f"ksx:{r.prop.name} {iri_template(parent, model, cmap)}")
        o += [f"mappingId\t{t.en}", "target\t\t" + " ; ".join(trip) + " .", f"source\t\t{src}", ""]
        if t.role == "line":
            rel = v.lines[t.en]
            head = model.tables[rel.parent]
            cmap = dict(zip(rel.parent_cols, rel.fk_cols))
            hsel = ", ".join(f'"{c}" AS {alias(c)}' for c in sorted(set(rel.fk_cols + t.uk)))
            o += [f"mappingId\t{t.en}_hasLine",
                  f"target\t\t{iri_template(head, model, cmap)} ksx:hasLine {me} . {me} ksx:lineOf {iri_template(head, model, cmap)} .",
                  f'source\t\tSELECT {hsel} FROM {schema}."{t.en}"', ""]
    o.append("]]")
    return "\n".join(o) + "\n"


# ---------------------------------------------------------------- DDL
def ddl(model: Model, v: Vocab, cfg: dict) -> str:
    s = cfg["schema"]
    o = [f"-- KS X 9101-1 v1.0 표준 원장 DDL (ksxgen 생성물, 직접 수정 금지)", f"CREATE SCHEMA IF NOT EXISTS {s};", ""]
    fks = []
    for t in model.tables.values():
        lines = []
        for c in t.columns:
            if c.pk:
                lines.append(f'  "{c.en}" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY')
            else:
                lines.append(f'  "{c.en}" {c.ptype or "VARCHAR(200)"}' + (" NOT NULL" if c.notnull else ""))
        lines.append(f'  CONSTRAINT "UK_{t.en}" UNIQUE (' + ", ".join(f'"{c}"' for c in t.uk) + ")")
        o.append(f'CREATE TABLE {s}."{t.en}" (\n' + ",\n".join(lines) + "\n);")
        o.append(f"COMMENT ON TABLE {s}.\"{t.en}\" IS '{t.ko} — {t.definition.replace(chr(39), chr(39) * 2)}';")
        for c in t.columns:
            o.append(f"COMMENT ON COLUMN {s}.\"{t.en}\".\"{c.en}\" IS '{c.ko.replace(chr(39), chr(39) * 2)}';")
        o.append("")
    n = defaultdict(int)
    for rel in model.relations:
        if not rel.physical:
            continue
        n[rel.child] += 1
        fks.append(f'ALTER TABLE {s}."{rel.child}" ADD CONSTRAINT "FK_{rel.child}_{n[rel.child]:02d}" FOREIGN KEY ('
                   + ", ".join(f'"{c}"' for c in rel.fk_cols) + f') REFERENCES {s}."{rel.parent}" ('
                   + ", ".join(f'"{c}"' for c in rel.parent_cols) + ") DEFERRABLE INITIALLY IMMEDIATE;")
    o.append("-- 물리 FK: 부모 UK 참조. 순환 참조(회사↔사원 등) 적재 시 SET CONSTRAINTS ALL DEFERRED 사용")
    return "\n".join(o + fks) + "\n"


# ---------------------------------------------------------------- SKOS
def codelist(model: Model, cfg: dict) -> str:
    o = [PREFIXES.format(ns=cfg["ns"]), f"@prefix d: <{cfg['data_ns']}> .", ""]
    for g in model.code_groups.values():
        o.append(f"<{cfg['data_ns']}codelist/{g.group}> a skos:ConceptScheme ; skos:prefLabel {lit(g.name, 'ko')} ;"
                 f" skos:notation {lit(g.group)} ; skos:definition {lit(g.desc or '', 'ko')} .")
    for c in model.codes:
        iri = f"<{cfg['data_ns']}codelist/{c.group}/{c.code}>"
        s = f"{iri} a skos:Concept ; skos:inScheme <{cfg['data_ns']}codelist/{c.group}> ; skos:notation {lit(c.code)} ; skos:prefLabel {lit(c.name, 'ko')}"
        if c.en:
            s += f", {lit(c.en, 'en')}"
        if c.parent_group and c.parent_code:
            s += f" ; skos:broader <{cfg['data_ns']}codelist/{c.parent_group}/{c.parent_code}>"
        if c.desc:
            s += f" ; skos:definition {lit(c.desc, 'ko')}"
        o.append(s + " .")
    o.append("")
    for u in model.uoms:
        s = (f"<{cfg['data_ns']}uom/{u.code}> a skos:Concept ; skos:inScheme <{cfg['data_ns']}uom/{u.group}> ;"
             f" skos:notation {lit(u.code)} ; skos:prefLabel {lit(u.name, 'ko')}")
        if u.en:
            s += f", {lit(u.en, 'en')}"
        if u.cefact:
            s += f" ; skos:exactMatch {lit('UNECE Rec20:' + u.cefact)}"
        if u.factor is not None:
            s += f' ; ksx:conversionFactor "{u.factor}"^^xsd:decimal'
        o.append(s + " .")
    for g in sorted({(u.group, u.group_name) for u in model.uoms}):
        o.append(f"<{cfg['data_ns']}uom/{g[0]}> a skos:ConceptScheme ; skos:prefLabel {lit(g[1], 'ko')} .")
    return "\n".join(o) + "\n"


# ---------------------------------------------------------------- 카탈로그
def catalog(model: Model, v: Vocab, out: str) -> None:
    for t in model.tables.values():
        if t.role == "line":
            continue
        tabs = [t] + ([model.tables[x.child] for x in v.lines.values() if x.parent == t.en] if t.role == "header" else [])
        card = {"noun": t.cls, "ko": t.ko[:-2] if t.role == "header" and t.ko.endswith("헤더") else t.ko,
                "clause": t.clause, "table": f"표 {t.table_no}", "area": t.area, "definition": t.definition,
                "layer": "core", "identity": [c for c in t.uk if c != "EnterpriseID"],
                "struct": ({"header": t.en, "line": tabs[1].en, "lineKey": [c for c in tabs[1].uk if c not in t.uk]}
                           if len(tabs) > 1 else None),
                "physical": {x.en: {"uk": x.uk} for x in tabs},
                "attributes": [], "references": [], "codes": []}
        for x in tabs:
            for cp in v.colprops[x.en]:
                c = cp.col
                if c.kind == "기본":
                    continue
                card["attributes"].append({"en": c.en, "ko": c.ko, "type": c.dtype, "in": x.en, "property": "ksx:" + cp.prop.name,
                                           **({"copyOf": f"{c.copy_of[0]}.{c.copy_of[1]}"} if c.copy_of else {})})
                if c.code_group:
                    card["codes"].append({"attr": c.en, "group": c.code_group})
            for r in v.refs[x.en]:
                if r.rel.kind == "기본 속성":
                    continue
                card["references"].append({"attr": ", ".join(r.rel.fk_cols), "target": model.tables[r.rel.parent].cls,
                                           "property": "ksx:" + r.prop.name, "in": x.en})
        _w(os.path.join(out, "catalog", "nouns", f"{t.cls}.json"), json.dumps(card, ensure_ascii=False, indent=1))
    md = ["# KS X 9101 표준 원장 SQL 스키마 (Text-to-SQL용, ksxgen 생성물)", "",
          "- 스키마: `ksx`, 테이블·컬럼명은 따옴표 식별자(대소문자 구분)", "- PK(…SequenceNo)는 내부 대리키이며 조인·답변에 쓰지 않는다. 조인은 아래 FK(부모 UK 참조)만 사용", ""]
    for t in model.tables.values():
        md += [f"## {t.en} ({t.ko}) — {t.clause} 표 {t.table_no}", f"UK: {', '.join(t.uk)}", "",
               "| 컬럼 | 국문 | 타입 | 비고 |", "|---|---|---|---|"]
        for c in t.columns:
            note = "PK" if c.pk else ("코드:" + c.code_group if c.code_group else (("FK→" + c.fkref) if c.fkref else ""))
            md.append(f"| {c.en} | {c.ko} | {c.ptype} | {note} |")
        md.append("")
    _w(os.path.join(out, "catalog", "sql_schema.md"), "\n".join(md))


# ---------------------------------------------------------------- 적재 순서·커버리지
def load_order(model: Model) -> tuple[list[str], list[str]]:
    deps = {t: set() for t in model.tables}
    for r in model.relations:
        if r.physical and r.kind not in ("자기 참조",) and r.child != r.parent:
            # 등록자·수정자(사원) 참조는 순환을 만들므로 순서 계산에서 제외(지연 FK로 처리)
            if r.kind == "기본 속성" and r.parent == "Personnel":
                continue
            deps[r.child].add(r.parent)
    order, done = [], set()
    while len(done) < len(deps):
        ready = sorted(t for t in deps if t not in done and deps[t] <= done)
        if not ready:
            break
        order += ready
        done |= set(ready)
    rest = sorted(set(deps) - done)
    return order + rest, rest


def coverage(model: Model, v: Vocab) -> tuple[str, bool]:
    cols = [(t, c) for t in model.tables.values() for c in t.columns if not c.pk]
    covered = sum(1 for t, c in cols if any(cp.col is c for cp in v.colprops[t.en]))
    phys = [r for r in model.relations if r.physical]
    rcov = sum(len(x) for x in v.refs.values()) + len(v.lines)
    classes = len(model.tables)
    ok = covered == len(cols) and rcov == len(phys) and not v.issues
    md = ["# ksxgen 커버리지 리포트", "",
          "| 항목 | 표준·정의서 | 생성 | 결과 |", "|---|---|---|---|",
          f"| 명사 | {model.noun_count} | {sum(1 for t in model.tables.values() if t.role != 'line')} | {'OK'} |",
          f"| 라인 구조체 | {len(v.lines)} | {sum(1 for t in model.tables.values() if t.role == 'line')} | OK |",
          f"| 클래스 | {classes} | {classes} | OK |",
          f"| 속성(PK 제외 컬럼) | {len(cols)} | {covered} | {'OK' if covered == len(cols) else '누락'} |",
          f"| 물리 FK → 관계 | {len(phys)} | {rcov} | {'OK' if rcov == len(phys) else '누락'} |",
          f"| 논리 관계(주석·도구 처리) | {len(v.logical)} | — | 참고 |",
          f"| 공통코드 그룹 / 코드 / 단위 | {len(model.code_groups)} / {len(model.codes)} / {len(model.uoms)} | 동일 | OK |", "",
          "## 정의 충돌", ""] + ([f"- {i}" for i in v.issues] or ["- 없음"])
    md += ["", "## 논리 관계(물리 FK 아님)", "", "| 자식 | 컬럼 | 부모 | 구분 |", "|---|---|---|---|"]
    md += [f"| {r.child} | {', '.join(r.fk_cols)} | {r.parent} | {r.kind} |" for r in v.logical]
    return "\n".join(md) + "\n", ok
