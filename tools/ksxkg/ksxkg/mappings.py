"""물질화 매핑(R2RML)에서 검사 기준을 읽는다: TriplesMap별 SQL·클래스."""
from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass
class Tmap:
    file: str
    name: str
    sql: str
    classes: list[str]


def read_rml(paths: list[str], prefixes: dict[str, str]) -> list[Tmap]:
    out = []
    for f in paths:
        t = open(f, encoding="utf-8").read()
        pfx = dict(re.findall(r"@prefix (\w*): <([^>]+)> \.", t))
        for block in t.split(" a rr:TriplesMap ;")[1:]:
            name = None
            sql = re.search(r'rr:sqlQuery "((?:[^"\\]|\\.)*)"', block).group(1).replace('\\"', '"').replace("\\\\", "\\")
            sm = block.split("rr:predicateObjectMap")[0]
            cls = []
            for c in re.findall(r"rr:class (\S+?)(?= ;| \])", sm):
                p, local = c.split(":", 1)
                cls.append((pfx.get(p) or prefixes[p]) + local)
            out.append(Tmap(f, name, sql, cls))
    return out


def class_label(iri: str) -> str:
    return re.split(r"[/#]", iri)[-1]
