"""범위(기업·사업장·공장) 나누기 — S9 D-5 공장 단위 격리.

추론 결과(S7)·위반 표식(S6)을 **주어가 속한 데이터 그래프의 범위**로 나눠 저장한다.
  데이터 그래프 키 K = {기업} | {기업}/{사업장}/{사업장}(사업장 공통) | {기업}/{사업장}/{공장}
  · 주어가 데이터 그래프에 있으면 그 키
  · 추론이 새로 만든 노드(이벤트 등)는 목적어로 연결된 노드의 키 중 가장 좁은 범위(공장 > 사업장 공통 > 기업 공통)
  · 공장이 둘 이상 섞이면 이름순 첫 공장(건수를 보고), 어느 것도 없으면 사업장 공통
"""
from __future__ import annotations

import re

from .base import Config, sparql

NT = re.compile(r"^(<[^>]+>|_:\S+) <([^>]+)> (.+?) \.\s*$")


def home_keys(cfg: Config) -> dict[str, str]:
    """노드 IRI → 데이터 그래프 키(rdf:type이 있는 그래프)."""
    pre = cfg.data_graph_prefix
    rows = sparql(cfg.query, "SELECT DISTINCT ?s ?g WHERE { GRAPH ?g { ?s a ?c } "
                             f'FILTER(?g = <{pre}> || STRSTARTS(STR(?g), "{pre}/")) }}')
    out = {}
    for r in rows:
        k = cfg.data_key(r["g"])
        if k and not r["s"].startswith("_:"):
            out[r["s"]] = narrow(out.get(r["s"]), k)
    return out


def rank(key: str) -> int:
    """좁을수록 큰 값: 공장 2 · 사업장 공통 1 · 기업 공통 0."""
    p = key.split("/")
    if len(p) == 3:
        return 1 if p[1] == p[2] else 2
    return 0


def narrow(a: str | None, b: str) -> str:
    if a is None:
        return b
    return max((a, b), key=lambda k: (rank(k), [-ord(c) for c in k]))   # 같은 순위면 이름순 앞


def split(cfg: Config, nt: str, home: dict[str, str], site: str) -> tuple[dict[str, list[str]], dict]:
    """N-Triples → {키: 줄 목록}. home은 새로 정해진 노드로 갱신된다. 반환 통계: 혼합·미결·범위 넘는 관계 수."""
    by_s: dict[str, list[tuple[str, str]]] = {}
    for line in nt.splitlines():
        m = NT.match(line)
        if not m:
            continue
        s, o = m.group(1), m.group(3)
        by_s.setdefault(s, []).append((line, o))
    default = f"{cfg.ent}/{site}/{site}"
    key: dict[str, str] = {}
    mixed = unresolved = 0
    pending = [s for s in by_s if s[1:-1] not in home]
    for s in by_s:
        if s[1:-1] in home:
            key[s] = home[s[1:-1]]
    for _ in range(3):                      # 새 노드가 다른 새 노드를 가리키면 한 번 더
        for s in list(pending):
            ks = set()
            for _, o in by_s[s]:
                if o.startswith("<"):
                    k = home.get(o[1:-1]) or key.get(o)
                    if k:
                        ks.add(k)
            if ks:
                plants = sorted(k for k in ks if rank(k) == 2)
                if len(set(plants)) > 1:
                    mixed += 1
                best = None
                for k in sorted(ks):
                    best = narrow(best, k)
                key[s] = best
                if not s.startswith("_:"):
                    home[s[1:-1]] = best
                pending.remove(s)
    for s in pending:                       # 빈 노드: 가리키는 쪽 주어의 범위
        ref = next((key[t] for t, ls in by_s.items() if t in key and any(o == s for _, o in ls)), None)
        if ref:
            key[s] = ref
        else:
            key[s] = default
            unresolved += 1
            if not s.startswith("_:"):
                home[s[1:-1]] = default
    out: dict[str, list[str]] = {}
    cross = 0
    for s, ls in by_s.items():
        k = key[s]
        for line, o in ls:
            out.setdefault(k, []).append(line)
            ok = home.get(o[1:-1]) if o.startswith("<") else None
            if ok and rank(ok) == 2 and rank(k) == 2 and ok != k:
                cross += 1
    return out, {"mixed": mixed, "unresolved": unresolved, "cross": cross}
