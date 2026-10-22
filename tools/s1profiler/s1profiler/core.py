"""S1 원천 분석 핵심 로직 (PostgreSQL 원천).

구현안내서 4.1 절차 4~7:
  4) 스키마 추출   extract_schema()
  5) 프로파일링     profile_tables()
  6) 코드 수집     collect_codes()
  7) 암묵 관계     find_relations()
+ 품질 점검(run_checks)과 인벤토리 조립(build_inventory)
"""
from __future__ import annotations

import os
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime

try:
    import psycopg
except ImportError:  # psycopg 미설치 환경 → psql 대체 드라이버
    psycopg = None

from . import sqlc as sql

TEXT_TYPES = ("character", "text", "varchar", "char")
NUM_TYPES = ("numeric", "integer", "bigint", "smallint", "double", "real")
TIME_TYPES = ("timestamp", "date")


# ----------------------------------------------------------------------------
# 연결
# ----------------------------------------------------------------------------
def _expand(v):
    if isinstance(v, str):
        return re.sub(r"\$\{(\w+)(?::-([^}]*))?\}", lambda m: os.environ.get(m.group(1), m.group(2) or ""), v)
    if isinstance(v, dict):
        return {k: _expand(x) for k, x in v.items()}
    if isinstance(v, list):
        return [_expand(x) for x in v]
    return v


def expand_config(cfg: dict) -> dict:
    return _expand(cfg)


def connect(dsn: dict, retries: int = 20, wait: float = 3.0):
    """읽기 전용 연결. 원천 DB가 막 기동 중이면 retries × wait 초까지 재시도한다."""
    import time
    args = {k: v for k, v in dsn.items() if v not in (None, "")}
    for n in range(retries):
        try:
            return _connect_once(args)
        except Exception:  # noqa: BLE001
            if n == retries - 1:
                raise
            time.sleep(wait)


def _connect_once(args):
    if psycopg is None or os.environ.get("S1_DB_DRIVER") == "psql":
        from .psqlshim import connect as shim_connect
        return shim_connect(**args)
    conn = psycopg.connect(**args, autocommit=True)
    conn.execute("SET default_transaction_read_only = on")
    conn.execute("SET statement_timeout = '300s'")
    return conn


# ----------------------------------------------------------------------------
# 4) 스키마 추출
# ----------------------------------------------------------------------------
@dataclass
class Column:
    name: str
    ordinal: int
    type: str
    not_null: bool
    default: str | None
    comment: str | None
    pk: bool = False
    fk: str | None = None


@dataclass
class Table:
    system: str
    db: str
    schema: str
    name: str
    comment: str | None
    columns: list[Column] = field(default_factory=list)
    pk: list[str] = field(default_factory=list)
    uniques: list[list[str]] = field(default_factory=list)
    fks: list[dict] = field(default_factory=list)
    rows: int = 0
    profile: dict = field(default_factory=dict)
    daily: dict | None = None

    @property
    def fqn(self):
        return f"{self.schema}.{self.name}"

    @property
    def key(self):
        return f"{self.system}:{self.schema}.{self.name}"

    def col(self, name):
        return next(c for c in self.columns if c.name == name)


def extract_schema(conn, system: str, db: str, schemas: list[str]) -> list[Table]:
    q_tables = """
      SELECT n.nspname, c.relname, obj_description(c.oid,'pg_class'), c.oid
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind IN ('r','p') AND n.nspname = ANY(%s)
      ORDER BY 1,2"""
    q_cols = """
      SELECT a.attname, a.attnum, format_type(a.atttypid, a.atttypmod), a.attnotnull,
             pg_get_expr(d.adbin, d.adrelid), col_description(a.attrelid, a.attnum)
      FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
      WHERE a.attrelid = %s AND a.attnum > 0 AND NOT a.attisdropped ORDER BY a.attnum"""
    q_cons = """
      SELECT con.contype,
             ARRAY(SELECT attname FROM unnest(con.conkey) WITH ORDINALITY k(n,o)
                   JOIN pg_attribute ON attrelid = con.conrelid AND attnum = k.n ORDER BY k.o),
             fn.nspname || '.' || fc.relname,
             ARRAY(SELECT attname FROM unnest(con.confkey) WITH ORDINALITY k(n,o)
                   JOIN pg_attribute ON attrelid = con.confrelid AND attnum = k.n ORDER BY k.o)
      FROM pg_constraint con
      LEFT JOIN pg_class fc ON fc.oid = con.confrelid
      LEFT JOIN pg_namespace fn ON fn.oid = fc.relnamespace
      WHERE con.conrelid = %s AND con.contype IN ('p','u','f')"""
    out = []
    for nsp, rel, cmt, oid in conn.execute(q_tables, (schemas,)).fetchall():
        t = Table(system, db, nsp, rel, cmt)
        for name, num, typ, nn, dflt, ccmt in conn.execute(q_cols, (oid,)).fetchall():
            t.columns.append(Column(name, num, typ, nn, dflt, ccmt))
        for ctype, cols, ftab, fcols in conn.execute(q_cons, (oid,)).fetchall():
            if ctype == "p":
                t.pk = list(cols)
            elif ctype == "u":
                t.uniques.append(list(cols))
            else:
                t.fks.append({"columns": list(cols), "ref_table": ftab, "ref_columns": list(fcols)})
        for c in t.columns:
            c.pk = c.name in t.pk
            for fk in t.fks:
                if c.name in fk["columns"]:
                    i = fk["columns"].index(c.name)
                    c.fk = f"{fk['ref_table']}.{fk['ref_columns'][i]}"
        out.append(t)
    return out


# ----------------------------------------------------------------------------
# 5) 프로파일링
# ----------------------------------------------------------------------------
def _family(typ: str) -> str:
    t = typ.lower()
    if t.startswith(TIME_TYPES):
        return "time"
    if t.startswith(NUM_TYPES):
        return "num"
    if t.startswith(TEXT_TYPES):
        return "text"
    return "other"


def mask(v: str) -> str:
    v = re.sub(r"[A-Za-z]", "A", v)
    v = re.sub(r"[0-9]", "9", v)
    v = re.sub(r"[가-힣]", "가", v)
    return v


DATE_PATTERNS = [
    ("YYYYMMDD", re.compile(r"^\d{8}$"), "%Y%m%d"),
    ("YYYYMMDDHH24MISS", re.compile(r"^\d{14}$"), "%Y%m%d%H%M%S"),
    ("YYYY-MM-DD", re.compile(r"^\d{4}-\d{2}-\d{2}$"), "%Y-%m-%d"),
    ("YYYY-MM-DD HH24:MI:SS", re.compile(r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$"), "%Y-%m-%d %H:%M:%S"),
]


def date_like(values: list[str]) -> dict | None:
    """문자열 일시 컬럼 판정: 형식별 건수와 해석 실패 건수."""
    vals = [v for v in values if v is not None]
    if not vals:
        return None
    fmt_counts, invalid = Counter(), 0
    for v in vals:
        hit = None
        for name, rx, fmt in DATE_PATTERNS:
            if rx.match(v):
                hit = name
                try:
                    if not v.startswith("9999"):
                        datetime.strptime(v, fmt)
                except ValueError:
                    invalid += 1
                break
        if hit:
            fmt_counts[hit] += 1
    matched = sum(fmt_counts.values())
    if matched / len(vals) < 0.9 or (matched and invalid / matched > 0.1):   # 사번 같은 8자리 숫자 배제
        return None
    return {"formats": dict(fmt_counts), "invalid": invalid, "sampled": len(vals), "unmatched": len(vals) - matched}


def profile_tables(conn, tables: list[Table], top_n=5, pattern_sample=5000, daily_cols=None):
    daily_cols = daily_cols or []
    for t in tables:
        ident = sql.Identifier(t.schema, t.name)
        t.rows = conn.execute(sql.SQL("SELECT count(*) FROM {}").format(ident)).fetchone()[0]
        parts, plan = [], []
        for c in t.columns:
            ci = sql.Identifier(c.name)
            fam = _family(c.type)
            plan.append((c, fam))
            parts += [sql.SQL("count({})").format(ci), sql.SQL("count(DISTINCT {})").format(ci)]
            if fam in ("text", "num", "time"):
                parts += [sql.SQL("min({})::text").format(ci), sql.SQL("max({})::text").format(ci)]
            else:
                parts += [sql.SQL("NULL"), sql.SQL("NULL")]
            if fam == "text":
                parts += [sql.SQL("avg(length({}))").format(ci),
                          sql.SQL("count(*) FILTER (WHERE {0} <> btrim({0}))").format(ci),
                          sql.SQL("count(DISTINCT upper(btrim({})))").format(ci)]
            else:
                parts += [sql.SQL("NULL"), sql.SQL("NULL"), sql.SQL("NULL")]
            if fam == "num":
                parts += [sql.SQL("avg({})::float8").format(ci), sql.SQL("stddev_pop({})::float8").format(ci)]
            else:
                parts += [sql.SQL("NULL"), sql.SQL("NULL")]
        row = conn.execute(sql.SQL("SELECT {} FROM {}").format(sql.SQL(", ").join(parts), ident)).fetchone() if t.rows else None
        for i, (c, fam) in enumerate(plan):
            if row is None:
                t.profile[c.name] = {"family": fam, "non_null": 0, "null": 0, "null_pct": 0, "distinct": 0}
                continue
            nn, dist, mn, mx, alen, ws, ndist, avg, sd = row[i * 9:(i + 1) * 9]
            p = {"family": fam, "non_null": nn, "null": t.rows - nn,
                 "null_pct": round(100.0 * (t.rows - nn) / t.rows, 2) if t.rows else 0,
                 "distinct": dist, "min": mn, "max": mx,
                 "avg_len": round(float(alen), 1) if alen is not None else None,
                 "whitespace": ws, "norm_distinct": ndist,
                 "mean": avg, "stddev": sd}
            ci = sql.Identifier(c.name)
            if t.rows and dist:
                tops = conn.execute(sql.SQL("SELECT {0}::text, count(*) FROM {1} WHERE {0} IS NOT NULL "
                                            "GROUP BY 1 ORDER BY 2 DESC, 1 LIMIT %s").format(ci, ident), (top_n,)).fetchall()
                p["top"] = [(v, n) for v, n in tops]
            if fam == "text" and t.rows:
                vals = [r[0] for r in conn.execute(sql.SQL("SELECT {0}::text FROM {1} WHERE {0} IS NOT NULL LIMIT %s")
                                                   .format(ci, ident), (pattern_sample,)).fetchall()]
                pc = Counter(mask(v) for v in vals)
                p["patterns"] = pc.most_common(3)
                p["date_like"] = date_like(vals)
            p["key_candidate"] = bool(t.rows and nn == t.rows and dist == t.rows)
            t.profile[c.name] = p
        t.daily = _daily(conn, t, daily_cols)
    return tables


DAILY_PRIORITY = ["crt_dtm", "reg_dt", "trk_in_dtm", "trk_out_dtm", "coll_dtm", "st_dtm", "occur_dtm",
                  "insp_dtm", "link_dtm", "rslt_dt", "plan_st_dt", "upd_dtm"]


def _daily(conn, t: Table, overrides):
    """일 증가량: 기준 일시 컬럼의 활동일 평균 건수."""
    if not t.rows:
        return None
    col = next((o["column"] for o in overrides if o["table"] == t.fqn), None)
    names = [c.name for c in t.columns]
    if col is None:
        col = next((n for n in DAILY_PRIORITY if n in names), None)
    if col is None:
        return None
    c = t.col(col)
    fam = _family(c.type)
    ci = sql.Identifier(col)
    if fam == "time":
        day = sql.SQL("date_trunc('day', {})").format(ci)
    elif fam == "text":
        day = sql.SQL("substr({}, 1, 8)").format(ci)
    else:
        return None
    r = conn.execute(sql.SQL("SELECT count({0}), count(DISTINCT {1}), min({1})::text, max({1})::text FROM {2}")
                     .format(ci, day, sql.Identifier(t.schema, t.name))).fetchone()
    n, days, d0, d1 = r
    if not days:
        return None
    return {"column": col, "rows": n, "active_days": days, "per_day": round(n / days, 1),
            "from": str(d0)[:10], "to": str(d1)[:10]}


# ----------------------------------------------------------------------------
# 6) 코드 수집
# ----------------------------------------------------------------------------
NON_CODE_NAME = re.compile(r"(_nm|_no|_ip|_rev|_dtm|_dt|_user|_emp|rmk|email|spec|maker|model|serial|(^|_)unit)$|^(rmk|email)")


def collect_codes(conns: dict, tables: list[Table], cfg: dict, relations=None):
    """코드 마스터(테이블) + 코드 후보 컬럼(저카디널리티) + 주석 정의 코드.

    참조 컬럼(다른 마스터를 가리키는 FK·암묵 관계)과 이름·비고·연락처 같은 서술 컬럼은 제외한다.
    """
    ccfg = cfg.get("codes", {})
    master_tables = {m["table"] for m in ccfg.get("masters", [])}
    ref_cols = {(r["child"], r["child_col"]) for r in (relations or [])
                if r.get("child_col") and r["parent"] not in master_tables}
    masters = []
    for m in ccfg.get("masters", []):
        conn = conns[m["system"]]
        rows = conn.execute(sql.SQL("SELECT {g}::text, {c}::text, {n}::text FROM {t} ORDER BY 1, 2").format(
            g=sql.Identifier(m["group"]), c=sql.Identifier(m["code"]), n=sql.Identifier(m["name"]),
            t=sql.Identifier(*m["table"].split(".")))).fetchall()
        for g, c, n in rows:
            masters.append({"system": m["system"], "table": m["table"], "group": g, "code": c, "name": n})
    by_group = defaultdict(set)
    for r in masters:
        by_group[(r["system"], r["group"])].add(r["code"].upper())

    # 키 값 사전: 작은 마스터의 단일 PK 값(코드 후보가 실은 다른 마스터 참조인지 판별)
    key_values = defaultdict(list)
    for t in tables:
        if len(t.pk) == 1 and 0 < t.rows <= 5000 and t.fqn not in master_tables \
                and _family(t.col(t.pk[0]).type) == "text":
            key_values["*"].append((t.fqn, _distinct_values(conns, {t.fqn: t}, t.fqn, t.pk[0])))
    maxd = ccfg.get("candidate_max_distinct", 30)
    exclude = set(ccfg.get("exclude_columns", []))
    skip_tables = {m["table"] for m in ccfg.get("masters", [])}
    cands = []
    for t in tables:
        if t.fqn in skip_tables or not t.rows:
            continue
        for c in t.columns:
            p = t.profile[c.name]
            if p["family"] != "text" or t.pk == [c.name] or p.get("date_like") or f"{t.fqn}.{c.name}" in exclude:
                continue
            if (t.fqn, c.name) in ref_cols or NON_CODE_NAME.search(c.name) or (p.get("avg_len") or 0) > 12:
                continue
            if not (1 <= p["distinct"] <= maxd) or p["distinct"] >= t.rows:
                continue
            dv = _distinct_values(conns, {t.fqn: t}, t.fqn, c.name)
            if any(dv <= kv for kt, kv in key_values["*"]) and not re.search(r"(_yn|_flag)$", c.name):
                continue                                         # 다른(또는 자기) 마스터의 키를 가리키는 참조 컬럼
            allv = conns[t.system].execute(sql.SQL("SELECT {0}::text, count(*) FROM {1} WHERE {0} IS NOT NULL GROUP BY 1 ORDER BY 1")
                                           .format(sql.Identifier(c.name), sql.Identifier(t.schema, t.name))).fetchall()
            values = {v: n for v, n in allv}
            # 코드 마스터 그룹 매칭(같은 시스템 우선, 값 포함률 기준)
            best, best_cov = None, 0.0
            for (sys_, grp), codes in by_group.items():
                if sys_ != t.system:                              # 코드는 시스템 내부에서만 연결
                    continue
                cov = sum(1 for v in values if v.strip().upper() in codes) / len(values)
                score = cov + (0.01 if sys_ == t.system else 0)
                if cov >= 0.6 and score > best_cov:
                    best, best_cov = (sys_, grp), score
            comment_codes = parse_comment_codes(c.comment)
            if comment_codes and all(v in comment_codes for v in values):
                best = None                                       # 주석 정의가 값을 모두 설명하면 우선
            if best:
                kind = "코드마스터 연결"
                link = f"{best[0]}.{best[1]}"
                unmatched = [v for v in values if v.strip().upper() not in by_group[best]]
            elif comment_codes:
                kind = "주석 정의(코드 테이블 없음)"
                link = "주석"
                unmatched = [v for v in values if v not in comment_codes]
            elif re.search(r"(_yn|_flag)$", c.name):
                kind = "여부 플래그"
                link = ""
                unmatched = [v for v in values if v.upper() not in ("Y", "N")]
            else:
                kind = "하드코딩 의심"
                link = ""
                unmatched = []
            cands.append({"system": t.system, "table": t.fqn, "column": c.name, "comment": c.comment,
                          "distinct": len(values), "values": values, "kind": kind, "link": link,
                          "unmatched": unmatched, "comment_codes": comment_codes})
    return masters, cands


def parse_comment_codes(comment: str | None) -> dict:
    """'W:대기 R:진행' 또는 'P:생산 I:검사' 형태의 주석 코드 정의 추출."""
    if not comment:
        return {}
    pairs = re.findall(r"\b([A-Z0-9]{1,4}):([^\s,/]+)", comment)
    return {k: v for k, v in pairs} if len(pairs) >= 2 else {}


# ----------------------------------------------------------------------------
# 7) 암묵 관계
# ----------------------------------------------------------------------------
REL_FROM = re.compile(r"\b(?:FROM|JOIN)\s+([a-z_][\w]*\.[a-z_][\w]*)\s+(?:AS\s+)?([a-z_]\w*)", re.I)
REL_EQ = re.compile(r"\b([a-z_]\w*)\.([a-z_]\w*)\s*=\s*([a-z_]\w*)\.([a-z_]\w*)\b", re.I)
REL_CONST = re.compile(r"\b([a-z_]\w*)\.([a-z_]\w*)\s*=\s*'([^']*)'", re.I)


def parse_sql_relations(text: str, const_tables=()):
    """리포트·인터페이스 SQL에서 '별칭.컬럼 = 별칭.컬럼' 조인 조건을 뽑는다.

    상수 조건(c.grp_cd = 'DEFECT_CD')은 코드 마스터 테이블(const_tables)에 걸린 것만 부모 조건으로 쓴다.
    """
    out = []
    for stmt in re.split(r";\s*\n", text):
        qid = re.search(r"--\s*\[([^\]]+)\]", stmt)
        qid = qid.group(1) if qid else "?"
        body = "\n".join(l for l in stmt.splitlines() if not l.strip().startswith("--"))
        alias = {a.lower(): t.lower() for t, a in REL_FROM.findall(body)
                 if a.upper() not in ("ON", "WHERE", "GROUP", "LEFT", "JOIN", "INNER")}
        consts = defaultdict(dict)
        for a, c, v in REL_CONST.findall(body):
            if a.lower() in alias and alias[a.lower()] in const_tables:
                consts[a.lower()][c.lower()] = v
        for a1, c1, a2, c2 in REL_EQ.findall(body):
            a1, a2 = a1.lower(), a2.lower()
            if a1 in alias and a2 in alias and alias[a1] != alias[a2]:
                out.append({"query": qid,
                            "left": (alias[a1], c1.lower(), consts.get(a1, {})),
                            "right": (alias[a2], c2.lower(), consts.get(a2, {}))})
    return out


def _distinct_values(conns, tmap, table, column, filt=None):
    t = tmap[table]
    where = [sql.SQL("{} IS NOT NULL").format(sql.Identifier(column))]
    params = []
    for k, v in (filt or {}).items():
        where.append(sql.SQL("{}::text = %s").format(sql.Identifier(k)))
        params.append(v)
    q = sql.SQL("SELECT DISTINCT {}::text FROM {} WHERE {}").format(
        sql.Identifier(column), sql.Identifier(t.schema, t.name), sql.SQL(" AND ").join(where))
    return {r[0] for r in conns[t.system].execute(q, params).fetchall()}


def find_relations(conns, tables: list[Table], cfg: dict, repo_root: str):
    rcfg = cfg.get("relations", {})
    tmap = {t.fqn: t for t in tables}
    found = {}

    def add(child, ccol, parent, pcol, by, query=None, pfilter=None, note=None):
        if child not in tmap or parent not in tmap:
            return
        if ccol not in [c.name for c in tmap[child].columns] or pcol not in [c.name for c in tmap[parent].columns]:
            return
        k = (child, ccol, parent, pcol, tuple(sorted((pfilter or {}).items())))
        r = found.setdefault(k, {"child": child, "child_col": ccol, "parent": parent, "parent_col": pcol,
                                 "parent_filter": pfilter or {}, "found_by": [], "queries": [], "note": note})
        if by not in r["found_by"]:
            r["found_by"].append(by)
        if query and query not in r["queries"]:
            r["queries"].append(query)
        if note and not r["note"]:
            r["note"] = note

    def is_key(table, col):
        t = tmap[table]
        return t.pk == [col] or [col] in t.uniques or t.profile.get(col, {}).get("key_candidate")

    # (a) 선언 FK
    for t in tables:
        for fk in t.fks:
            for c, rc in zip(fk["columns"], fk["ref_columns"]):
                add(t.fqn, c, fk["ref_table"], rc, "FK 선언")
    # (b) 리포트·인터페이스 SQL
    for f in rcfg.get("sql_files", []):
        text = open(os.path.join(repo_root, f), encoding="utf-8").read()
        for r in parse_sql_relations(text, {m["table"] for m in cfg.get("codes", {}).get("masters", [])}):
            (lt, lc, lf), (rt, rc, rf) = r["left"], r["right"]
            if lt not in tmap or rt not in tmap:
                continue
            # 부모 판정: 상수 조건(코드 그룹) 쪽 → 키인 쪽 → PK인 쪽 → 오른쪽
            if rf:
                right_parent = True
            elif lf:
                right_parent = False
            elif is_key(rt, rc) != is_key(lt, lc):
                right_parent = bool(is_key(rt, rc))
            elif tmap[rt].pk == [rc] or tmap[lt].pk == [lc]:
                right_parent = tmap[rt].pk == [rc]
            else:
                right_parent = True
            if right_parent:
                add(lt, lc, rt, rc, "SQL 조인", r["query"], rf)
            else:
                add(rt, rc, lt, lc, "SQL 조인", r["query"], lf)
    # (c) 이름·값 일치(같은 이름 또는 erp_ 접두 대응, 부모가 단일 키)
    thr = rcfg.get("name_match_inclusion", 0.9)
    keys = [(t.fqn, t.pk[0]) for t in tables if len(t.pk) == 1]
    for t in tables:
        for c in t.columns:
            base = re.sub(r"^erp_", "", c.name)
            if c.pk and len(t.pk) == 1:
                continue
            hits = []
            for pt, pc in keys:
                if pt == t.fqn or pc != base:
                    continue
                cv = _distinct_values(conns, tmap, t.fqn, c.name)
                if len(cv) < 2:
                    break
                pv = _distinct_values(conns, tmap, pt, pc)
                inc = len(cv & pv) / len(cv)
                if inc >= thr:
                    hits.append((tmap[pt].system == t.system, inc, pt, pc))
            # 같은 시스템 부모가 있으면 그쪽만(타 시스템 사본 테이블과의 우연 일치 배제). erp_ 접두 컬럼은 ERP 쪽을 가리킨다
            same = [h for h in hits if h[0]] if not c.name.startswith("erp_") else []
            for _, inc, pt, pc in (same or hits):
                add(t.fqn, c.name, pt, pc, "이름·값 일치")
    # (d) 수작업 등록(인터뷰·인터페이스 정의서)
    for m in rcfg.get("manual", []):
        ct, cc = m["child"].rsplit(".", 1)
        pt, pc = m["parent"].rsplit(".", 1)
        add(ct, cc, pt, pc, "수작업 등록", None, m.get("parent_filter"), m.get("note"))
    # 검증: 포함률·고아 건수
    out = []
    for r in found.values():
        cv = _distinct_values(conns, tmap, r["child"], r["child_col"])
        pv = _distinct_values(conns, tmap, r["parent"], r["parent_col"], r["parent_filter"])
        orphans = sorted(cv - pv)
        r.update({"child_system": tmap[r["child"]].system, "parent_system": tmap[r["parent"]].system,
                  "child_distinct": len(cv), "matched": len(cv) - len(orphans),
                  "inclusion": round(1 - len(orphans) / len(cv), 4) if cv else None,
                  "orphans": len(orphans), "orphan_samples": orphans[:5],
                  "declared": "FK 선언" in r["found_by"],
                  "cross_system": tmap[r["child"]].system != tmap[r["parent"]].system})
        out.append(r)
    for m in rcfg.get("non_key", []):
        out.append({"child": m["child"], "child_col": "", "parent": m["parent"], "parent_col": "",
                    "parent_filter": {}, "found_by": ["수작업 등록"], "queries": [], "note": m["note"],
                    "child_system": m.get("child_system", ""), "parent_system": m.get("parent_system", ""),
                    "child_distinct": None, "matched": None, "inclusion": None, "orphans": None,
                    "orphan_samples": [], "declared": False, "cross_system": False, "kind": m.get("kind")})
    out.sort(key=lambda r: (r["declared"], r["child"], r["child_col"]))
    return out


# ----------------------------------------------------------------------------
# 품질 점검
# ----------------------------------------------------------------------------
def run_checks(conns, tables: list[Table], codes, relations, cfg: dict):
    issues = []
    ccfg = cfg.get("checks", {})
    unit_alias = {k.upper(): v for k, v in ccfg.get("unit_aliases", {}).items()}

    def add(sev, t, col, kind, count, sample, action):
        issues.append({"severity": sev, "system": t.system if t else "", "table": t.fqn if t else "",
                       "column": col, "issue": kind, "count": count, "sample": sample, "action": action})

    tmap = {t.fqn: t for t in tables}
    for t in tables:
        if not t.comment:
            add("하", t, "", "테이블 주석 없음", 1, "", "현업 인터뷰로 업무 의미 보완")
        nocmt = [c.name for c in t.columns if not c.comment]
        if nocmt and len(nocmt) == len(t.columns):
            add("하", t, "", "컬럼 주석 전무", len(nocmt), ", ".join(nocmt[:5]), "데이터 사전·화면 정의서로 의미 확인")
        for c in t.columns:
            p = t.profile.get(c.name, {})
            if not p or not t.rows:
                continue
            if p.get("whitespace"):
                add("중", t, c.name, "앞뒤 공백 포함 값", p["whitespace"], "", "S3 변환 시 trim, 키 컬럼이면 중복 여부 확인")
            if p["family"] == "text" and p.get("norm_distinct") is not None and p["distinct"] > p["norm_distinct"] \
                    and (c.pk or p.get("key_candidate")):
                add("상", t, c.name, "대소문자·공백만 다른 중복 키", p["distinct"] - p["norm_distinct"],
                    _dup_samples(conns[t.system], t, c.name), "업무 키 정규화 규칙 확정 후 중복 정리(현업 승인)")
            dl = p.get("date_like")
            if dl and (len(dl["formats"]) > 1 or dl["invalid"] or dl["unmatched"]):
                add("중", t, c.name, "문자열 일시 형식 혼재·오류", dl["invalid"] + dl["unmatched"],
                    str(dl["formats"]), "표준 일시(ISO 8601)로 변환 규칙 정의")
            elif dl:
                add("하", t, c.name, f"문자열 일시({'/'.join(dl['formats'])})", p["non_null"], "",
                    "dbt 매크로로 timestamp 변환")
            if re.search(r"(^|_)unit$", c.name) and p.get("top"):
                vals = _all_values(conns[t.system], t, c.name)
                groups = defaultdict(list)
                for v in vals:
                    groups[unit_alias.get(v.upper(), v.upper())].append(v)
                mixed = {g: vs for g, vs in groups.items() if len(vs) > 1}
                if mixed:
                    add("중", t, c.name, "단위 표기 혼재", sum(len(v) for v in mixed.values()),
                        "; ".join(f"{g}←{','.join(vs)}" for g, vs in mixed.items()), "units.csv 단위 대응표에 등록")
        for col in ccfg.get("expect_not_null", {}).get(t.fqn, []):
            p = t.profile.get(col)
            if p and p["null"]:
                add("중", t, col, "필수 예상 컬럼 NULL", p["null"], f"{p['null_pct']}%", "원천 담당자 확인 후 기본값 또는 제외 사유 기록")
    for cand in codes:
        if cand["kind"] == "주석 정의(코드 테이블 없음)" or cand["kind"] == "하드코딩 의심":
            add("중", tmap[cand["table"]], cand["column"], f"코드 테이블 없음({cand['kind']})", cand["distinct"],
                ", ".join(f"{k}({v})" for k, v in list(cand["values"].items())[:6]), "codes.csv 코드 대응표에 직접 등록")
        if cand["unmatched"]:
            add("중", tmap[cand["table"]], cand["column"],
                "여부 값 비정상(Y/N 외)" if cand["kind"] == "여부 플래그" else "코드 마스터에 없는 값", len(cand["unmatched"]),
                ", ".join(cand["unmatched"][:5]), "코드 마스터 보완 또는 변환 규칙 정의")
    for r in relations:
        if r.get("orphans"):
            add("상" if not r["declared"] else "중", tmap.get(r["child"]), r["child_col"],
                f"참조 고아 → {r['parent']}.{r['parent_col']}", r["orphans"], ", ".join(r["orphan_samples"]),
                "원천 정정 또는 S3 적재 시 격리(FK 위반)")
    for chk in ccfg.get("custom", []):
        conn = conns[chk["system"]]
        rows = conn.execute(chk["sql"]).fetchall()
        n = rows[0][0] if rows and len(rows[0]) == 1 and isinstance(rows[0][0], int) else len(rows)
        sample = "" if (rows and len(rows[0]) == 1 and isinstance(rows[0][0], int)) else \
            "; ".join(" ".join(str(x) for x in r) for r in rows[:3])
        if n:
            add(chk.get("severity", "중"), tmap.get(chk["table"]), chk.get("column", ""), chk["issue"], n, sample,
                chk.get("action", ""))
    order = {"상": 0, "중": 1, "하": 2}
    issues.sort(key=lambda i: (order.get(i["severity"], 9), i["system"], i["table"], i["column"]))
    for n, i in enumerate(issues, 1):
        i["id"] = f"Q{n:03d}"
    return issues


def _all_values(conn, t, col):
    return [r[0] for r in conn.execute(sql.SQL("SELECT DISTINCT {0}::text FROM {1} WHERE {0} IS NOT NULL")
                                       .format(sql.Identifier(col), sql.Identifier(t.schema, t.name))).fetchall()]


def _dup_samples(conn, t, col):
    rows = conn.execute(sql.SQL("SELECT string_agg(quote_literal({0}), ' = ') FROM {1} GROUP BY upper(btrim({0})) "
                                "HAVING count(DISTINCT {0}) > 1 LIMIT 3")
                        .format(sql.Identifier(col), sql.Identifier(t.schema, t.name))).fetchall()
    return "; ".join(r[0] for r in rows)


# ----------------------------------------------------------------------------
# 인벤토리(표 8)
# ----------------------------------------------------------------------------
def build_inventory(tables: list[Table], issues, relations, cfg: dict):
    hints = cfg.get("noun_hints", [])
    owners = {s["system"]: s.get("owner", "") for s in cfg["sources"]}
    inv = []
    for t in tables:
        h = next((h for h in hints if re.fullmatch(h["table"], t.fqn)), None)
        keys = []
        if t.pk:
            keys.append("PK(" + ", ".join(t.pk) + ")")
        for c in t.columns:
            p = t.profile.get(c.name, {})
            if p.get("key_candidate") and not c.pk and t.rows >= 5 and re.search(r"(_cd|_no|_id)$", c.name) \
                    and not re.search(r"(tel|hp|fax|zip|reg)_", c.name):
                keys.append(f"후보({c.name})")
        if h and h.get("business_key"):
            keys.append("업무키(" + ", ".join(h["business_key"]) + ")")
        inv.append({
            "system": t.system, "schema": t.schema, "table": t.name, "fqn": t.fqn,
            "meaning": (h or {}).get("meaning") or t.comment or "",
            "comment": t.comment or "", "rows": t.rows,
            "per_day": t.daily["per_day"] if t.daily else None,
            "daily_basis": f"{t.daily['column']} {t.daily['from']}~{t.daily['to']}" if t.daily else "",
            "keys": "; ".join(keys), "nouns": ", ".join((h or {}).get("nouns", [])),
            "scenarios": ", ".join((h or {}).get("scenarios", [])),
            "scope": (h or {}).get("scope", "대상" if (h and h.get("scenarios")) else "제외(1차 범위 밖)"),
            "owner": owners.get(t.system, ""),
            "columns": len(t.columns),
            "comment_cov": round(100.0 * sum(1 for c in t.columns if c.comment) / len(t.columns)),
            "fks": len(t.fks),
            "implicit": sum(1 for r in relations if r["child"] == t.fqn and not r["declared"]),
            "issues": sum(1 for i in issues if i["table"] == t.fqn),
            "note": (h or {}).get("note", ""),
        })
    return inv
