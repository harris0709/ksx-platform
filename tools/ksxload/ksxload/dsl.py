"""매핑 명세의 변환 어휘(transform) → PostgreSQL 식.

S2 계획 머리말의 어휘를 그대로 받는다. 어휘 함수는 xfm 스키마의 SQL 함수로 구현되어 있고
(etl/dbt/macros/xfm_functions.sql), 이 모듈은 이름에 스키마를 붙이고 SQL에 없는 형식만 바꾼다.

  const(v)                → 숫자·true·false는 그대로, 나머지는 문자열 상수
  case(c1, v1, …, else)   → CASE WHEN c1 THEN v1 … ELSE else END (대문자 단어 값은 문자열로)
  eq(a, b)                → (a = b)
  code(col)               → 같은 명세에서 col에 붙은 코드 대응 그룹으로 xfm.code(group, col)
  xref(name, col)         → xfm.xref('name', col)
  unpivot(c1→E1, …)       → 모델 생성기가 LATERAL VALUES로 펼친다(이 식은 u.ev_ts)
  그 밖의 어휘(upper_trim·to_date8·…)  → xfm.<함수>(…)
식 안의 맨 컬럼 이름은 주 원천 별칭(s.)을 붙이고, 조인 별칭(o.col)은 그대로 둔다.
"""
from __future__ import annotations

import re

VOCAB = {"upper_trim", "to_date8", "to_ts14", "to_ts", "to_date", "ym_first", "ym_last", "yn", "int",
         "seconds", "minutes", "days", "mat_lot", "code", "xref", "uom"}
SQL_WORDS = {"and", "or", "not", "in", "is", "null", "like", "between", "select", "from", "where", "true", "false",
             "case", "when", "then", "else", "end", "as", "distinct", "time", "date", "timestamp", "interval",
             "current_date", "current_timestamp", "exists", "max", "min", "count", "sum", "coalesce", "to_char",
             "concat", "upper", "lower", "trim", "round", "cast", "numeric", "text", "integer"}


class DslError(ValueError):
    pass


def split_args(s: str) -> list[str]:
    """최상위 쉼표로 인자를 나눈다(괄호·따옴표 안의 쉼표는 무시)."""
    out, depth, cur, q = [], 0, [], False
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == "'":
            q = not q if not (q and s[i:i + 2] == "''") else q
            if q is True and s[i:i + 2] == "''":
                cur.append("''")
                i += 2
                continue
        if not q:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            elif ch == "," and depth == 0:
                out.append("".join(cur).strip())
                cur = []
                i += 1
                continue
        cur.append(ch)
        i += 1
    if "".join(cur).strip():
        out.append("".join(cur).strip())
    return out


def _find_call(s: str, start: int):
    """s[start:]에서 '이름(' 다음의 짝 괄호 끝 위치를 찾는다."""
    depth, q = 0, False
    for i in range(start, len(s)):
        ch = s[i]
        if ch == "'":
            q = not q
        elif not q and ch == "(":
            depth += 1
        elif not q and ch == ")":
            depth -= 1
            if depth == 0:
                return i
    raise DslError(f"괄호 짝이 맞지 않음: {s}")


class Translator:
    def __init__(self, primary_cols: set[str], aliases: set[str], code_of: dict[str, str] | None = None,
                 extra_names: dict[str, str] | None = None, schema: str = "xfm"):
        self.cols = primary_cols
        self.aliases = aliases
        self.code_of = code_of or {}          # 원천 컬럼 → 코드 대응 그룹(code(col)용)
        self.extra = extra_names or {}        # 특수 이름 → 식(예: ev → u.ev)
        self.fn = schema

    # ------------------------------------------------------------ 상수·값
    @staticmethod
    def const(v: str) -> str:
        v = v.strip()
        if re.fullmatch(r"-?\d+(\.\d+)?", v) or v.lower() in ("true", "false", "null"):
            return v.lower() if v.lower() in ("true", "false", "null") else v
        if v.startswith("'") and v.endswith("'"):
            return v
        return "'" + v.replace("'", "''") + "'"

    def value(self, v: str) -> str:
        """case의 값: 대문자 단어(OVER_USL·ALARM)는 문자열 상수, 나머지는 식."""
        if re.fullmatch(r"[A-Z][A-Z0-9_\-]*", v.strip()) and v.strip() != "NULL":
            return self.const(v)
        return self.expr(v)

    # ------------------------------------------------------------ 식
    def expr(self, s: str) -> str:
        s = s.strip()
        out, i = [], 0
        while i < len(s):
            ch = s[i]
            if ch == "'":                                   # 문자열 상수는 그대로
                j = i + 1
                while j < len(s):
                    if s[j] == "'" and s[j:j + 2] == "''":
                        j += 2
                        continue
                    if s[j] == "'":
                        break
                    j += 1
                out.append(s[i:j + 1])
                i = j + 1
                continue
            m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)(\.[A-Za-z_][A-Za-z0-9_]*)?", s[i:])
            if m and (i == 0 or not (s[i - 1].isalnum() or s[i - 1] in "_.\"")):
                name, dotted = m.group(1), m.group(2)
                j = i + m.end()
                k = j
                while k < len(s) and s[k] == " ":
                    k += 1
                if not dotted and k < len(s) and s[k] == "(":          # 함수 호출
                    end = _find_call(s, k)
                    args = split_args(s[k + 1:end])
                    out.append(self.call(name, args))
                    i = end + 1
                    continue
                if dotted:                                               # 별칭.컬럼
                    out.append(m.group(0))
                elif name in self.extra:
                    out.append(self.extra[name])
                elif name in self.cols:
                    out.append(f"s.{name}")
                elif name.lower() in SQL_WORDS or name in self.aliases:
                    out.append(name)
                else:
                    raise DslError(f"원천에 없는 이름 '{name}': {s}")
                i = j
                continue
            out.append(ch)
            i += 1
        return "".join(out)

    def call(self, name: str, args: list[str]) -> str:
        n = name.lower()
        if n == "const":
            return self.const(args[0])
        if n == "case":
            if len(args) < 3 or len(args) % 2 == 0:
                raise DslError(f"case 인자는 (조건, 값, …, 기본값) — {args}")
            parts = [f"WHEN {self.expr(args[i])} THEN {self.value(args[i + 1])}" for i in range(0, len(args) - 1, 2)]
            return f"CASE {' '.join(parts)} ELSE {self.value(args[-1])} END"
        if n == "eq":
            return f"({self.expr(args[0])} = {self.expr(args[1])})"
        if n == "xref":
            return f"{self.fn}.xref('{args[0].strip()}', ({self.expr(args[1])})::text)"
        if n == "code" and len(args) == 1:
            col = args[0].strip().split(".")[-1]
            g = self.code_of.get(col)
            if not g:
                raise DslError(f"code({col}): 같은 명세에 이 컬럼의 코드 대응이 없음")
            return f"{self.fn}.code('{g}', ({self.expr(args[0])})::text)"
        if n == "unpivot":
            raise DslError("unpivot은 모델 생성기가 처리한다")
        if n in VOCAB:
            return f"{self.fn}.{n}({', '.join(self.expr(a) for a in args)})"
        return f"{name}({', '.join(self.expr(a) for a in args)})"      # SQL 내장 함수(concat·to_char 등)


def parse_unpivot(t: str) -> list[tuple[str, str]]:
    m = re.fullmatch(r"\s*unpivot\((.*)\)\s*", t)
    if not m:
        return []
    pairs = []
    for a in split_args(m.group(1)):
        col, _, ev = a.partition("→")
        if not ev:
            col, _, ev = a.partition("->")
        pairs.append((col.strip(), ev.strip()))
    return pairs
