"""결정론 매칭(구현안내서 5.2 표 11): ① 정확 ② 정규화 ③ 컴포넌트 ④ 국문명. 미해소 컬럼은 ⑤ 유사도 후보.

⑤는 임베딩 대신 문자열 유사도(영문 정규화명·국문명)로 상위 후보를 낸다. 후보는 매핑이 아니며
검토자(⑥ 재순위·근거)와 승인자(⑦)가 확정한다.
"""
from __future__ import annotations

import difflib
import itertools
import re
from dataclasses import dataclass

from .stdmodel import Attr

COMPONENTS = ("DateTime", "Date", "Time", "ID", "Name", "Code", "Quantity", "UOMCode", "Type", "Status", "State",
              "Sequence", "Indicator", "Number", "Description", "Price", "Amount", "Rate", "Count", "Class", "Item")


@dataclass
class Hit:
    attr: Attr
    stage: str           # exact / normalized / component / korean
    evidence: str


def tokens(name: str) -> list[str]:
    return [t for t in re.split(r"[_\W]+", name) if t]


def expansions(tok: str, abbrev: dict) -> list[str]:
    v = abbrev.get(tok.upper()) or abbrev.get(tok.lower())
    if v is None:
        return [tok[:1].upper() + tok[1:].lower()]
    return list(v) if isinstance(v, (list, tuple)) else [v]


def normalized_names(name: str, abbrev: dict, limit=64) -> list[str]:
    exps = [expansions(t, abbrev) for t in tokens(name)]
    out = []
    for combo in itertools.islice(itertools.product(*exps), limit):
        out.append("".join(combo))
    return out


def clean_ko(s: str | None) -> str:
    if not s:
        return ""
    s = re.sub(r"\(.*?\)", "", s)
    s = re.split(r"[:：,]", s)[0]
    return re.sub(r"\s+", "", s)


def match(col: str, comment: str | None, attrs: list[Attr], abbrev: dict, ko_syn: dict | None = None) -> Hit | None:
    by = {a.en.lower(): a for a in attrs}
    # ① 정확 일치
    k = col.replace("_", "").lower()
    if k in by:
        return Hit(by[k], "exact", f"{col} = {by[k].en}")
    # ② 정규화 일치
    names = normalized_names(col, abbrev)
    for n in names:
        if n.lower() in by:
            return Hit(by[n.lower()], "normalized", f"{col} → {n}")
    # ③ 컴포넌트 일치: 끝 토큰을 컴포넌트로, 앞 토큰을 접두로
    toks = tokens(col)
    if len(toks) >= 2:
        comps = [c for c in expansions(toks[-1], abbrev) if c in COMPONENTS]
        prefixes = {"".join(p) for p in itertools.islice(itertools.product(*[expansions(t, abbrev) for t in toks[:-1]]), 32)}
        # 앞쪽 수식 토큰(oper_·mgr_ 등)을 떼어 낸 꼬리 접두도 시도한다: oper_emp_no → Personnel + ID
        for k in range(1, len(toks) - 1):
            prefixes |= {"".join(p) for p in itertools.islice(itertools.product(*[expansions(t, abbrev) for t in toks[k:-1]]), 16)}
        for comp in comps:
            cands = [a for a in attrs if a.en.endswith(comp)]
            hits = [a for a in cands if any(p.lower() in a.en.lower() for p in prefixes)]
            if len(hits) > 1:
                hits = [a for a in hits if any(a.en.lower().startswith(p.lower()) for p in prefixes)] or hits
            if len(hits) == 1:
                return Hit(hits[0], "component", f"{col}: 접두 {'/'.join(sorted(prefixes))[:40]} + {comp}")
    # ④ 국문명 일치
    ck = clean_ko(comment)
    if ck:
        variants = {ck}
        for a, b in (ko_syn or {}).items():
            variants.add(ck.replace(a, b))
        for a in attrs:
            if clean_ko(a.ko) in variants:
                return Hit(a, "korean", f"주석 '{comment}' = {a.ko}")
    return None


def candidates(col: str, comment: str | None, attrs: list[Attr], abbrev: dict, n=5) -> list[tuple[Attr, float]]:
    """⑤ 유사도 후보(결정론 미해소 컬럼용)."""
    names = normalized_names(col, abbrev, limit=8) or [col]
    ck = clean_ko(comment)
    scored = []
    for a in attrs:
        s = max(difflib.SequenceMatcher(None, x.lower(), a.en.lower()).ratio() for x in names)
        if ck:
            s = max(s, difflib.SequenceMatcher(None, ck, clean_ko(a.ko)).ratio())
        scored.append((a, round(s, 3)))
    return sorted(scored, key=lambda x: -x[1])[:n]
