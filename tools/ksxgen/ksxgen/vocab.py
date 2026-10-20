"""표준 모델에서 온톨로지 어휘(클래스·속성·관계)를 계산한다. 모든 생성기가 이 결과를 공유한다."""
from __future__ import annotations

from dataclasses import dataclass, field

from .model import Column, Model, Relation, Table
from .naming import XSD, lower_camel, ref_name


@dataclass
class Prop:
    name: str
    kind: str                       # data / code / ref / struct
    range: str                      # xsd:... / skos:Concept / ksx:Class
    label_ko: str = ""
    label_en: str = ""
    code_group: str | None = None
    source_attrs: set[str] = field(default_factory=set)
    copy_of: set[str] = field(default_factory=set)
    used_by: set[str] = field(default_factory=set)
    conflicts: list[str] = field(default_factory=list)


@dataclass
class ColProp:
    """테이블 컬럼 1개가 만드는 속성 사용(SHACL·OBDA가 쓴다)."""
    table: Table
    col: Column
    prop: Prop


@dataclass
class RefUse:
    table: Table
    rel: Relation
    prop: Prop
    notnull: bool


@dataclass
class Vocab:
    props: dict[str, Prop]
    colprops: dict[str, list[ColProp]]     # table → 데이터·코드 속성 사용
    refs: dict[str, list[RefUse]]          # table → 참조 관계 사용
    lines: dict[str, Relation]             # line table → 헤더-라인 관계
    logical: list[Relation]                # 물리 FK가 아닌 관계(사본·다형·표준 외 등)
    issues: list[str]


def build(model: Model) -> Vocab:
    props: dict[str, Prop] = {}
    colprops: dict[str, list[ColProp]] = {t: [] for t in model.tables}
    refs: dict[str, list[RefUse]] = {t: [] for t in model.tables}
    issues: list[str] = []

    def get(name: str, kind: str, rng: str) -> Prop:
        p = props.get(name)
        if p is None:
            p = props[name] = Prop(name, kind, rng)
        elif (p.kind, p.range) != (kind, rng):
            p.conflicts.append(f"{kind}:{rng}")
        return p

    for t in model.tables.values():
        for c in t.columns:
            if c.pk:
                continue
            if c.dtype == "enum":
                name = lower_camel(c.en)
                if name in props and props[name].kind != "code":
                    name += "Code"
                p = get(name, "code", "skos:Concept")
                p.code_group = p.code_group or c.code_group
            else:
                name = lower_camel(c.en)
                if name in props and props[name].kind == "code":
                    name += "Value"
                p = get(name, "data", XSD.get(c.dtype, "xsd:string"))
            p.label_ko = p.label_ko or c.ko
            p.label_en = p.label_en or c.en
            p.source_attrs.add(c.en)
            p.used_by.add(t.cls)
            if c.copy_of:
                p.copy_of.add(f"{c.copy_of[0]}.{c.copy_of[1]}")
            colprops[t.en].append(ColProp(t, c, p))

    lines: dict[str, Relation] = {}
    logical: list[Relation] = []
    for rel in model.relations:
        if rel.kind == "헤더-라인":
            lines[rel.child] = rel
            continue
        if not rel.physical:
            logical.append(rel)
            continue
        child, parent = model.tables[rel.child], model.tables[rel.parent]
        name = ref_name(rel, model)
        p = get(name, "ref", "ksx:" + parent.cls)
        if p.conflicts and p.conflicts[-1] == f"ref:ksx:{parent.cls}":
            # 같은 이름이 다른 부모를 가리키면 부모 클래스명을 붙여 분리
            p.conflicts.pop()
            name = name + "To" + parent.cls
            p = get(name, "ref", "ksx:" + parent.cls)
        attr = next((c for c in rel.fk_cols if c != "EnterpriseID"), rel.fk_cols[0])
        col = child.col(attr)
        p.label_ko = p.label_ko or ((col.ko + " 참조") if col else parent.ko + " 참조")
        p.label_en = p.label_en or name
        p.source_attrs.add(attr)
        p.used_by.add(child.cls)
        notnull = all((child.col(c) and child.col(c).notnull) for c in rel.fk_cols)
        refs[child.en].append(RefUse(child, rel, p, notnull))

    for p in props.values():
        if p.conflicts:
            issues.append(f"속성 {p.name}: 정의 충돌 {sorted(set(p.conflicts))} (첫 정의 {p.kind}:{p.range} 사용)")
    return Vocab(props, colprops, refs, lines, logical, issues)
