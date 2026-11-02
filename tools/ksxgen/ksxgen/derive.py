"""OBDA·모델에서 파생하는 생성물(구현안내서 7.1 #4·6·8·9·10).

  mappings/rml/<mappingId>.rml.ttl  물질화 매핑(R2RML 문법 — Morph-KGC가 읽는다). OBDA와 같은 IRI·리터럴을 만든다
  graph/age_schema.sql             속성 그래프(Apache AGE) 노드·관계 라벨과 인덱스
  catalog/tools/<server>.json      MCP 도구 스키마(어휘에서 정해지는 열거값 포함)
  rules/A-<nnn>_<이름>.rq          자동 전이 규칙(자기 참조 관계의 닫힘)
  tbox/catalog-v001.xml            온톨로지 IRI → 파일(ROBOT·Protégé가 owl:imports를 로컬로 해석)
  vocab/uom.ttl                    단위(SKOS) — 공통코드와 분리

OBDA를 입력으로 쓰므로 Core와 기업 확장이 같은 규칙으로 파생된다.
"""
from __future__ import annotations

import glob
import json
import os
import re

from .model import Model
from .vocab import Vocab

XSD_NS = "http://www.w3.org/2001/XMLSchema#"


# ---------------------------------------------------------------- OBDA 읽기
def parse_obda(text: str):
    head, body = text.split("[MappingDeclaration]", 1)
    prefixes = dict(re.findall(r"^(\w+):\t(\S+)$", head, re.M))
    maps = []
    for block in body.split("mappingId\t")[1:]:
        mid = block.split("\n", 1)[0].strip()
        target = re.search(r"^target\t\t(.*)$", block, re.M).group(1)
        source = re.search(r"^source\t\t(.*)$", block, re.M).group(1)
        stmts = []
        for st in [s.strip() for s in target.split(" . ") if s.strip()]:
            st = st.rstrip(" .")
            subj, rest = st.split(" ", 1)
            pos = []
            for po in rest.split(" ; "):
                p, o = po.strip().split(" ", 1)
                pos.append((p, o.strip()))
            stmts.append((subj, pos))
        maps.append((mid, stmts, source))
    return prefixes, maps


def _expand(tok: str, pfx: dict) -> str:
    p, local = tok.split(":", 1)
    return pfx[p] + local


def _q(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


# ---------------------------------------------------------------- R2RML(RML 호환)
def rml(obda_text: str) -> dict[str, str]:
    pfx, maps = parse_obda(obda_text)
    files = {}
    head = "".join(f"@prefix {k}: <{v}> .\n" for k, v in pfx.items() if k != "d")
    head += "@prefix rr: <http://www.w3.org/ns/r2rml#> .\n@prefix map: <urn:ksx:map:> .\n\n"
    for mid, stmts, src in maps:
        out = [f"# {mid} — ksxgen 생성물(OBDA {mid}와 같은 트리플). 직접 수정 금지", head.rstrip("\n"), ""]
        for i, (subj, pos) in enumerate(stmts):
            name = f"map:{mid}" + (f"_{i}" if i else "")
            classes = [o for p, o in pos if p == "a"]
            sm = f"rr:template {_q(_expand(subj, pfx))}" + "".join(f" ; rr:class {c}" for c in classes)
            lines = [f"{name} a rr:TriplesMap ;",
                     f"    rr:logicalTable [ rr:sqlQuery {_q(src)} ; rr:sqlVersion rr:SQL2008 ] ;",
                     f"    rr:subjectMap [ {sm} ]"]
            for p, o in pos:
                if p == "a":
                    continue
                m = re.match(r"^\{([a-z0-9_]+)\}(?:\^\^(\w+):(\w+))?$", o)
                if m:
                    om = f"rr:column {_q(m.group(1))}" + (f" ; rr:datatype {m.group(2)}:{m.group(3)}" if m.group(2) else "")
                else:
                    om = f"rr:template {_q(_expand(o, pfx))}"
                lines[-1] += " ;"
                lines.append(f"    rr:predicateObjectMap [ rr:predicate {p} ; rr:objectMap [ {om} ] ]")
            out.append("\n".join(lines) + " .\n")
        files[f"{mid}.rml.ttl"] = "\n".join(out)
    return files


# ---------------------------------------------------------------- Apache AGE 스키마
def age_schema(obda_texts: list[str], graph: str) -> str:
    vl, el = [], []
    for text in obda_texts:
        pfx, maps = parse_obda(text)
        for _, stmts, _ in maps:
            for _, pos in stmts:
                for p, o in pos:
                    if p == "a":
                        c = o.split(":", 1)[1]
                        if c not in vl:
                            vl.append(c)
                    elif not o.startswith("{") and "/codelist/" not in _expand(o, pfx) and "/uom/" not in _expand(o, pfx):
                        e = p.split(":", 1)[1]
                        if e not in el:
                            el.append(e)
    o = [f"-- Apache AGE 속성 그래프 스키마(ksxgen 생성물, 구현안내서 11.1) — 노드 라벨 {len(vl)} · 관계 라벨 {len(el)}",
         "-- 노드 = 명사 개체(키: iri), 관계 = 객체 관계(ref*·hasLine·lineOf). 코드·단위는 노드 속성으로 둔다.",
         "-- 다시 실행해도 된다(있으면 건너뜀). 이 세션에서만 AGE를 쓴다.",
         "LOAD 'age';", 'SET search_path = ag_catalog, "$user", public;', "",
         "DO $$ BEGIN",
         f"  IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = '{graph}') THEN",
         f"    PERFORM ag_catalog.create_graph('{graph}');",
         "  END IF;", "END $$;", "",
         "CREATE OR REPLACE FUNCTION pg_temp.ksx_label(lbl text, kind text) RETURNS void LANGUAGE plpgsql AS $f$",
         "BEGIN",
         "  IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph g ON l.graph = g.graphid",
         f"                 WHERE g.name = '{graph}' AND l.name = lbl) THEN",
         f"    IF kind = 'v' THEN PERFORM ag_catalog.create_vlabel('{graph}', lbl);",
         f"    ELSE PERFORM ag_catalog.create_elabel('{graph}', lbl); END IF;",
         "  END IF;",
         "END $f$;", "", "-- 노드 라벨(명사·라인 구조체·확장 명사)"]
    o += [f"SELECT pg_temp.ksx_label('{x}', 'v');" for x in vl]
    o += ["", "-- 관계 라벨(객체 관계)"]
    o += [f"SELECT pg_temp.ksx_label('{x}', 'e');" for x in el]
    o += ["", "-- 노드 속성 인덱스(iri·식별 속성 조회)"]
    o += [f'CREATE INDEX IF NOT EXISTS "ix_{x}_props" ON {graph}."{x}" USING gin (properties);' for x in vl]
    return "\n".join(o) + "\n"


# ---------------------------------------------------------------- MCP 도구 스키마
def tools(out: str, model: Model) -> dict[str, str]:
    cards = sorted(glob.glob(os.path.join(out, "catalog", "nouns", "*.json")))
    nouns = [json.load(open(c, encoding="utf-8"))["noun"] for c in cards]
    structs = sorted({t.noun for t in model.tables.values() if t.role == "line"})
    tables = sorted(model.tables)

    def tool(name, desc, props, req):
        return {"name": name, "description": desc,
                "inputSchema": {"type": "object", "properties": props, "required": req, "additionalProperties": False}}

    out_fmt = "출력은 {rows, provenance, scope, truncated}. 회사·사업장·공장은 입력으로 받지 않고 토큰 클레임에서 주입한다(구현안내서 12.2)."
    onto = {"server": "ksx-ontology", "generatedBy": "ksxgen", "tools": [
        tool("get_noun_card", "명사 카드(정의·식별·속성·참조·코드)를 돌려준다. " + out_fmt,
             {"noun": {"type": "string", "enum": nouns}}, ["noun"]),
        tool("sparql_query", "읽기 전용 SPARQL(SELECT·ASK). 구문·어휘·LIMIT 검사 후 허용된 Named Graph에서 실행. " + out_fmt,
             {"query": {"type": "string", "maxLength": 8000}, "limit": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 200}},
             ["query"]),
        tool("get_lot_genealogy", "로트 계보(모로트·자로트, 투입 로트)를 깊이 제한으로 펼친다. " + out_fmt,
             {"lotID": {"type": "string"}, "direction": {"type": "string", "enum": ["up", "down", "both"], "default": "up"},
              "depth": {"type": "integer", "minimum": 1, "maximum": 10, "default": 5}}, ["lotID"]),
        tool("find_affected_orders", "로트·생산실적에서 영향받는 생산지시·수주를 찾는다(추론 R-010). " + out_fmt,
             {"lotID": {"type": "string"}, "productionPerformanceID": {"type": "string"}}, []),
        tool("explain_inference", "추론 결과 트리플의 근거(규칙 ID·입력 트리플)를 설명한다. " + out_fmt,
             {"subject": {"type": "string", "format": "iri"}, "predicate": {"type": "string", "format": "iri"}}, ["subject"]),
    ]}
    ledger = {"server": "ksx-ledger", "generatedBy": "ksxgen", "tools": [
        tool("sql_query", "표준 원장 읽기 전용 SQL(SELECT). catalog/sql_schema.md의 테이블·FK만 사용. " + out_fmt,
             {"sql": {"type": "string", "maxLength": 8000}, "limit": {"type": "integer", "minimum": 1, "maximum": 1000, "default": 200}},
             ["sql"]),
        tool("get_struct", "헤더·라인 구조체 명사 1건을 헤더와 라인 전체로 돌려준다. " + out_fmt,
             {"noun": {"type": "string", "enum": structs}, "key": {"type": "object", "additionalProperties": {"type": "string"},
                                                              "description": "헤더 식별 속성(UK, EnterpriseID 제외) → 값"}},
             ["noun", "key"]),
        tool("get_bom_tree", "품목의 자재명세서를 다단으로 펼친다. " + out_fmt,
             {"itemID": {"type": "string"}, "depth": {"type": "integer", "minimum": 1, "maximum": 20, "default": 10}}, ["itemID"]),
    ], "tables": tables}
    dump = lambda x: json.dumps(x, ensure_ascii=False, indent=1) + "\n"   # noqa: E731
    return {"ksx-ontology.json": dump(onto), "ksx-ledger.json": dump(ledger)}


# ---------------------------------------------------------------- 온톨로지 카탈로그(owl:imports 해석)
def import_catalog(out: str) -> str:
    """tbox/catalog-v001.xml — 온톨로지 IRI → 파일. ROBOT·Protégé가 확장의 owl:imports Core를 로컬 파일로 읽는다."""
    o = ['<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
         "<!-- ksxgen 생성물: 온톨로지 IRI → 로컬 파일(ROBOT·Protégé용) -->",
         '<catalog prefer="public" xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">']
    for p in sorted(glob.glob(os.path.join(out, "tbox", "*.ttl"))):
        m = re.search(r"^<([^>]+)> a owl:Ontology", open(p, encoding="utf-8").read(), re.M)
        if m:
            o.append(f'  <uri name="{m.group(1)}" uri="{os.path.basename(p)}"/>')
    return "\n".join(o + ["</catalog>"]) + "\n"


# ---------------------------------------------------------------- 자동 전이 규칙
def auto_rules(model: Model, v: Vocab) -> dict[str, str]:
    """자기 참조 관계(부모 부서·모로트·상위 설비 등)의 닫힘. 업무 규칙(R-*)보다 먼저 실행된다(파일명 순)."""
    head = ("PREFIX ksx: <https://ontology.impix.co.kr/ksx9101/1.0/>\n"
            "PREFIX inf: <https://ontology.impix.co.kr/inference/>\n"
            "PREFIX ksxq: <https://ontology.impix.co.kr/quality/>\n")
    seen, files = [], {}
    for t in model.tables.values():
        for r in v.refs[t.en]:
            if r.rel.kind != "자기 참조" or r.prop.name in seen:
                continue
            seen.append(r.prop.name)
            n = len(seen)
            p = r.prop.name
            files[f"A-{n:03d}_{p}_closure.rq"] = (
                f"# A-{n:03d} 자동 전이 규칙(ksxgen 생성물): {t.ko} {r.prop.label_ko}를 끝까지 따라간다\n" + head +
                f"CONSTRUCT {{ ?x inf:{p}Closure ?y }}\n"
                f"WHERE {{ ?x a ksx:{t.cls} ; ksx:{p}+ ?y . FILTER (?x != ?y) "
                f"FILTER NOT EXISTS {{ ?x ksxq:violates ?v }} }}\n")
    return files
