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


def read_rml(paths, prefixes: dict[str, str]) -> list[Tmap]:
    """paths: 파일 경로 목록 또는 {경로: 내용}(물질화 필터를 적용한 내용)."""
    out = []
    items = paths.items() if isinstance(paths, dict) else ((f, open(f, encoding="utf-8").read()) for f in paths)
    for f, t in items:
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


def _subject(block: str) -> str:
    m = re.search(r'rr:subjectMap \[ rr:template "([^"]+)"', block)
    return m.group(1) if m else ""


def _noun(subj: str) -> str:
    m = re.search(r"\{enterpriseid\}/(\w+)/", subj)
    return m.group(1) if m else ""


def filtered(paths: list[str], filters: dict[str, str]) -> dict[str, str]:
    """물질화 필터(S5 결정 D-3): 주어 명사가 filters에 있는 TriplesMap은 그 명사의 원장 행이 조건을 만족할 때만 만든다.

    filters = {명사: 원장 테이블 컬럼으로 쓴 SQL 조건}. 명사 본 매핑·확장 속성·헤더–라인 매핑이 모두 같은 행 집합을 쓰도록
    주어 IRI 템플릿의 키로 원장 행을 찾는다. S4 생성물(매핑 파일)은 바꾸지 않고, 바뀐 내용만 돌려준다.
    """
    texts = {f: open(f, encoding="utf-8").read() for f in paths}
    if not filters:
        return texts
    owner = {}                                  # 명사 → (테이블, {별칭: 컬럼}) — 명사 본 매핑(rr:class 있는 것)에서
    for f, t in texts.items():
        for block in t.split(" a rr:TriplesMap ;")[1:]:
            noun = _noun(_subject(block))
            sm = block.split("rr:predicateObjectMap")[0]
            m = re.search(r'FROM ((?:\w+)\.\\"(\w+)\\")\) AS q', block)
            if noun in filters and "rr:class" in sm and m:
                sql = re.search(r'rr:sqlQuery "((?:[^"\\]|\\.)*)"', block).group(1)
                owner[noun] = (m.group(1).replace('\\"', '"'),
                               dict((a, c) for c, a in re.findall(r'\\"(\w+)\\"(?:::text)? AS (\w+)', sql)))
    miss = sorted(set(filters) - set(owner))
    if miss:
        raise ValueError(f"물질화 필터 대상 명사의 매핑을 찾지 못함: {miss}")
    out = {}
    for f, t in texts.items():
        parts = t.split(" a rr:TriplesMap ;")
        changed = False
        for i in range(1, len(parts)):
            subj = _subject(parts[i])
            noun = _noun(subj)
            if noun not in filters:
                continue
            table, cols = owner[noun]
            keys = re.findall(r"\{([a-z0-9_]+)\}", subj)
            on = " AND ".join(f'w.\\"{cols[k]}\\"::text = f.{k}::text' for k in keys)
            cond = filters[noun].replace('"', '\\"')
            parts[i] = re.sub(r'rr:sqlQuery "((?:[^"\\]|\\.)*)"',
                              lambda m: f'rr:sqlQuery "SELECT f.* FROM ({m.group(1)}) AS f WHERE EXISTS '
                                        f'(SELECT 1 FROM {table.replace(chr(34), chr(92) + chr(34))} AS w WHERE {on} AND ({cond}))"',
                              parts[i], count=1)
            changed = True
        out[f] = " a rr:TriplesMap ;".join(parts) if changed else t
    return out
