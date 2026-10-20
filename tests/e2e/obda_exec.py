"""검증용 경량 OBDA 실행기.

Ontop 없이 생성된 ksx9101.obda를 PostgreSQL에 그대로 실행해 N-Triples를 만든다.
운영에서는 Ontop(가상화)·Morph-KGC(물질화)를 쓰며, 이 스크립트는 생성물 회귀 시험 전용이다.
psql만 있으면 되도록 표준 라이브러리로 작성했다.

  python tests/e2e/obda_exec.py ontologies/mappings/ksx9101.obda "<psql 접속 인자>" > out.nt
"""
from __future__ import annotations

import csv
import io
import re
import shlex
import subprocess
import sys
from urllib.parse import quote

PH = re.compile(r"\{([a-z0-9_]+)\}")


def parse_obda(path: str):
    text = open(path, encoding="utf-8").read()
    prefixes = dict(re.findall(r"^(\w+):\t(\S+)$", text.split("[MappingDeclaration]")[0], re.M))
    maps = []
    for block in text.split("mappingId\t")[1:]:
        mid = block.split("\n", 1)[0].strip()
        target = re.search(r"^target\t\t(.*)$", block, re.M).group(1)
        source = re.search(r"^source\t\t(.*)$", block, re.M).group(1)
        maps.append((mid, target, source))
    return prefixes, maps


def run_sql(sql: str, conn: str) -> list[dict]:
    out = subprocess.run(["psql", *shlex.split(conn), "-v", "ON_ERROR_STOP=1", "--csv", "-c", sql],
                         capture_output=True, text=True, check=True).stdout
    return list(csv.DictReader(io.StringIO(out)))


def term(tok: str, row: dict, prefixes: dict) -> str | None:
    """템플릿 항 1개를 N-Triples 항으로. 값이 비면 None(트리플 생략, Ontop과 같은 동작)."""
    for name in PH.findall(tok):
        if row.get(name) in (None, ""):
            return None
    if tok == "a":
        return "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>"
    if tok.startswith("{"):
        m = re.match(r"^\{([a-z0-9_]+)\}(?:\^\^(\w+):(\w+))?$", tok)
        val = row[m.group(1)]
        if m.group(2) == "xsd" and m.group(3) == "boolean":
            val = {"t": "true", "f": "false"}.get(val, val)
        if m.group(2) == "xsd" and m.group(3) == "dateTime":
            val = val.replace(" ", "T")
            val = re.sub(r"([+-]\d\d)$", r"\1:00", val)
        esc = val.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
        return f'"{esc}"' + (f"^^<{prefixes[m.group(2)]}{m.group(3)}>" if m.group(2) else "")
    pfx, local = tok.split(":", 1)
    local = PH.sub(lambda m: quote(row[m.group(1)], safe=""), local)
    return f"<{prefixes[pfx]}{local}>"


def triples(target: str):
    """'S p o ; p o . S2 p o .' → (S, p, o) 토큰 목록."""
    for stmt in [s for s in re.split(r"\s\.(?:\s|$)", target) if s.strip()]:
        parts = [p.split() for p in stmt.split(" ; ")]
        subj, rest = parts[0][0], [parts[0][1:]] + parts[1:]
        for po in rest:
            yield subj, po[0], po[1]


def main(obda: str, conn: str) -> None:
    prefixes, maps = parse_obda(obda)
    w = sys.stdout.write
    for mid, target, source in maps:
        for row in run_sql(source, conn):
            for s, p, o in triples(target):
                ts, tp, to = term(s, row, prefixes), term(p, row, prefixes), term(o, row, prefixes)
                if ts and tp and to:
                    w(f"{ts} {tp} {to} .\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
