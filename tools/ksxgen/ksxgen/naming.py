"""이름·IRI 규칙(구현 안내서 7.2, 8.1)."""
from __future__ import annotations

import re

from .model import BASE_COLS, Model, Relation, Table

XSD = {"string": "xsd:string", "ID": "xsd:string", "IDREF": "xsd:string", "int": "xsd:integer",
       "bigint": "xsd:integer", "float": "xsd:decimal", "date": "xsd:date", "dateTime": "xsd:dateTime",
       "boolean": "xsd:boolean", "duration": "xsd:duration", "enum": "xsd:string"}


def lower_camel(name: str) -> str:
    """ProducedQuantity → producedQuantity, UOMCode → uomCode, BOMID → bomID, ItemID → itemID."""
    m = re.match(r"^([A-Z]+)(?=[A-Z][a-z])|^([A-Z]+)(?=ID$)|^([A-Z]+)$|^([A-Z])", name)
    if not m:
        return name
    head = next(g for g in m.groups() if g)
    return head.lower() + name[len(head):]


def strip_id(attr: str) -> str:
    return attr[:-2] if attr.endswith("ID") and len(attr) > 2 else attr


def ref_name(rel: Relation, model: Model) -> str:
    """참조 관계 이름: ItemID → refItem, (EnterpriseID, CreatorID) → refCreator.
    ID로 끝나지 않는 키(문서번호+순번 등)는 ref + 부모 클래스명."""
    cols = [c for c in rel.fk_cols if c != "EnterpriseID"] or rel.fk_cols
    attr = cols[0]
    if attr.endswith("ID"):
        return "ref" + strip_id(attr)
    return "ref" + model.tables[rel.parent].cls


def alias(col: str) -> str:
    """OBDA SQL 별칭(소문자): Ontop 템플릿에서 대소문자 문제를 피한다."""
    return col.lower()


def key_cols(t: Table) -> list[str]:
    return [c for c in t.uk if c != "EnterpriseID"]


def iri_template(t: Table, model: Model, colmap: dict[str, str] | None = None) -> str:
    """A-Box IRI 템플릿. colmap은 부모 UK 컬럼 → 자식 컬럼(참조 IRI 생성용).
    단일·조합 식별: d:{Ent}/{Class}/{k1}_{k2}
    라인 구조체:   d:{Ent}/{Noun}/{헤더키}/line/{라인키}"""
    cm = colmap or {}

    def v(c: str) -> str:
        return "{" + alias(cm.get(c, c)) + "}"

    ent = v("EnterpriseID")
    if t.role == "line":
        head = model.tables[t.header]
        hk = key_cols(head)
        lk = [c for c in key_cols(t) if c not in hk]
        return f"d:{ent}/{t.noun}/" + "_".join(v(c) for c in hk) + "/line/" + "_".join(v(c) for c in lk)
    keys = key_cols(t) or ["EnterpriseID"]
    return f"d:{ent}/{t.cls}/" + "_".join(v(c) for c in keys)


def is_base(col: str) -> bool:
    return col in BASE_COLS
