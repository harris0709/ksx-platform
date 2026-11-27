"""원장 범위 격리(RLS) — S9 D-5 공장 단위 격리, 구현안내서 15장.

조회 계정(ksx_reader — MCP 도구)은 세션 변수로 받은 범위의 행만 본다. 변수가 없으면 0행(기본 거부).
  app.enterprise_id · app.site_id · app.plant_ids(쉼표 목록) — OPA ledger_session이 토큰 클레임에서 만든다.

테이블별 정책(DDL에서 자동 판정):
  기업·사업장·공장 열이 있음      기업 일치 AND 사업장 일치 AND (공장 = 사업장(사업장 공통) OR 공장 ∈ 허용 공장)
  기업 공통 기준정보(ksxgen.yaml common_graph_nouns)   기업 일치 — 지식 그래프의 기업 공통 그래프와 같은 범위
  기업·사업장 열만(Site)          기업 일치 AND 사업장 일치
  기업 열만(Enterprise)           기업 일치
  확장 1:1 테이블(*Ext, 범위 열 없음)   부모 표준 테이블 행이 보일 때만(EXISTS — 부모의 RLS가 그대로 걸린다)
적재(ksx_loader)·배치 읽기(ksx_batch — 물질화·검사·Ontop)는 BYPASSRLS, 소유자(ksx_owner)는 RLS 대상 아님.
"""
from __future__ import annotations

import re

ENT = "current_setting('app.enterprise_id', true)"
SITE = "current_setting('app.site_id', true)"
PLANTS = "string_to_array(coalesce(current_setting('app.plant_ids', true), ''), ',')"
POLICY = "scope_isolation"


def tables_from_ddl(texts: list[str]) -> dict[str, dict]:
    """DDL 텍스트 → {schema.table: {cols, fks: [(cols, ref_table, ref_cols)]}}."""
    out: dict[str, dict] = {}
    s = "\n".join(texts)
    for m in re.finditer(r'CREATE TABLE (\w+)\."(\w+)" \((.*?)\n\);', s, re.S):
        out[f"{m.group(1)}.{m.group(2)}"] = {"schema": m.group(1), "table": m.group(2),
                                             "cols": re.findall(r'^\s+"(\w+)"', m.group(3), re.M), "fks": []}
    for m in re.finditer(r'ALTER TABLE (\w+)\."(\w+)" ADD CONSTRAINT "[^"]+" FOREIGN KEY \(([^)]*)\) '
                         r'REFERENCES (\w+)\."(\w+)" \(([^)]*)\)', s):
        k = f"{m.group(1)}.{m.group(2)}"
        if k in out:
            cols = [c.strip().strip('"') for c in m.group(3).split(",")]
            rcols = [c.strip().strip('"') for c in m.group(6).split(",")]
            out[k]["fks"].append((cols, f"{m.group(4)}.{m.group(5)}", rcols))
    return out


def q(fq: str) -> str:
    s, t = fq.split(".", 1)
    return f'{s}."{t}"'


def condition(t: dict, all_tables: dict, common: set[str]) -> tuple[str, str]:
    """(정책 종류, USING 식)."""
    cols = set(t["cols"])
    if {"EnterpriseID", "SiteID", "PlantID"} <= cols:
        if t["table"] in common:
            return "기업 공통", f'"EnterpriseID" = {ENT}'
        return "공장", (f'"EnterpriseID" = {ENT} AND "SiteID" = {SITE} '
                       f'AND ("PlantID" = "SiteID" OR "PlantID" = ANY({PLANTS}))')
    if {"EnterpriseID", "SiteID"} <= cols:
        return "사업장", f'"EnterpriseID" = {ENT} AND "SiteID" = {SITE}'
    if t["table"].endswith("Ext"):
        parent = f"ksx.{t['table'][:-3]}"
        for cs, ref, rcs in t["fks"]:
            if ref == parent and parent in all_tables:
                on = " AND ".join(f'p."{r}" = {q(t["schema"] + "." + t["table"])}."{c}"' for c, r in zip(cs, rcs))
                return "부모 행", f"EXISTS (SELECT 1 FROM {q(parent)} p WHERE {on})"
    if "EnterpriseID" in cols:
        return "기업", f'"EnterpriseID" = {ENT}'
    raise ValueError(f"{t['schema']}.{t['table']}: 범위 열·부모 FK가 없어 RLS 정책을 정할 수 없음")


def build_sql(texts: list[str], common: set[str]) -> tuple[str, dict]:
    """모든 표준·확장 테이블에 RLS 정책(다시 실행 가능). 반환: (SQL, {종류: 테이블 수})."""
    tabs = tables_from_ddl(texts)
    lines, kinds = [], {}
    for fq in sorted(tabs):
        t = tabs[fq]
        kind, cond = condition(t, tabs, common)
        kinds[kind] = kinds.get(kind, 0) + 1
        lines += [f"ALTER TABLE {q(fq)} ENABLE ROW LEVEL SECURITY;",
                  f"DROP POLICY IF EXISTS site_isolation ON {q(fq)};",
                  f"DROP POLICY IF EXISTS {POLICY} ON {q(fq)};",
                  f"CREATE POLICY {POLICY} ON {q(fq)} USING ({cond}) WITH CHECK ({cond});"]
    return "BEGIN;\n" + "\n".join(lines) + "\nCOMMIT;\n", kinds


BATCH_GRANTS = """
grant usage on schema ksx, ext, stg, xfm, audit to ksx_batch;
grant select on all tables in schema ksx, ext, stg, xfm to ksx_batch;
grant select on audit.healthcheck to ksx_batch;
alter default privileges for role ksx_owner in schema ksx, ext, stg, xfm grant select on tables to ksx_batch;
-- 조회 계정(MCP)은 원천 복제(stg)·변환 뷰(xfm)를 읽지 않는다 — 범위 열·RLS가 없는 원천 데이터 우회 차단(S9 D-5)
revoke all on all tables in schema stg, xfm from ksx_reader;
revoke usage on schema stg, xfm from ksx_reader;
alter default privileges for role ksx_owner in schema stg, xfm revoke select on tables from ksx_reader;
"""
