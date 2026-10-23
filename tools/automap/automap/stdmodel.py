"""매핑 대상 모델: KS X 9101 Core(standards/) + 기업 확장(extensions/{ent}) 속성 목록.

명사마다 대상 속성을 모은다. Core 명사의 확장 속성({Noun}Ext)은 같은 명사의 속성으로 합치고 layer='ext'로 표시한다.
"""
from __future__ import annotations

import os
import sys
from dataclasses import dataclass, field

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_HERE, "..", "..", "ksxgen"))

from ksxgen import ext as X  # noqa: E402
from ksxgen.model import load  # noqa: E402

BASE = ("EnterpriseID", "SiteID", "PlantID")
AUDIT = ("CreatorID", "CreationDateTime", "ModifierID", "ModificationDateTime", "Note")


@dataclass
class Attr:
    en: str
    ko: str
    dtype: str
    kind: str              # 기본 / 명사 / 확장
    uk: bool
    notnull: bool
    code_group: str | None
    fkref: str | None
    desc: str
    layer: str             # core / ext
    table: str             # 물리 테이블(ksx.X 또는 ext.XExt)
    copy_of: str | None = None

    @property
    def required(self) -> bool:
        return self.uk or self.en in BASE or (self.notnull and self.kind != "기본")


@dataclass
class Noun:
    name: str
    ko: str
    layer: str             # core / ext
    uk: list[str]
    attrs: dict[str, Attr] = field(default_factory=dict)

    def get(self, en: str) -> Attr | None:
        return self.attrs.get(en)


@dataclass
class Std:
    nouns: dict[str, Noun]
    code_groups: set[str]
    codes: dict[str, dict[str, str]]       # group → code → name
    uoms: dict[str, str]                   # code → name
    core: object
    ext: object | None


def load_std(std_dir: str, ext_dir: str | None = None) -> Std:
    core = load(std_dir)
    nouns: dict[str, Noun] = {}
    for t in core.tables.values():
        n = Noun(t.en, t.ko, "core", list(t.uk))
        for c in t.columns:
            if c.pk:
                continue
            cp = c.copy_of
            n.attrs[c.en] = Attr(c.en, c.ko, c.dtype, c.kind, c.uk, c.notnull, c.code_group, c.fkref, c.desc, "core",
                                 f"ksx.{t.en}", f"{cp[0]}.{cp[1]}" if cp else None)
        nouns[t.en] = n
    codes: dict[str, dict[str, str]] = {}
    for c in core.codes:
        codes.setdefault(c.group, {})[c.code] = c.name
    groups = set(core.code_groups)
    e = None
    if ext_dir:
        cfg = X.ext_config(ext_dir)
        e = X.read(cfg["path"], core, cfg)
        X.complete(e, core)
        for et in e.tables.values():
            t = et.t
            if et.ext_type == "확장 명사":
                n = nouns[t.en] = Noun(t.en, t.ko, "ext", list(t.uk))
            else:
                n = nouns[et.target]
            for c in t.columns:
                if c.pk or c.kind == "Core키" or (et.ext_type == "확장 속성" and c.en in n.attrs):
                    continue
                n.attrs[c.en] = Attr(c.en, c.ko, c.dtype, "기본" if c.kind == "기본" else "확장", c.uk, c.notnull,
                                     c.code_group, c.fkref, c.desc, "ext", f"ext.{t.en}")
        for c in e.codes:
            codes.setdefault(c.group, {})[c.code] = c.name
        groups |= set(e.groups)
    uoms = {u.code: u.name for u in core.uoms}
    return Std(nouns, groups, codes, uoms, core, e)
