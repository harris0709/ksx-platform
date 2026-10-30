"""ddl(표준 원장 준비)·stage(원천 → stg 복제)·감사 기록."""
from __future__ import annotations

import json
import subprocess

from .base import Config, DbError, parse_ddl, psql, rel, rows, scalar

AUDIT_SQL = """
create table if not exists audit.load_log (
  log_id       bigint generated always as identity primary key,
  run_id       uuid        not null references audit.run(run_id),
  step         text        not null,              -- stage / publish / check
  object       text        not null,              -- stg.erp__tb_mm_item, ksx.Lot, 모델 이름
  source_rows  bigint,
  target_rows  bigint,
  failed_rows  bigint      not null default 0,
  status       text        not null check (status in ('ok','warn','fail')),
  detail       jsonb       not null default '{}'::jsonb,
  logged_at    timestamptz not null default now()
);
comment on table audit.load_log is 'S3 적재·대사 기록(안내서 6.6 표 15)';
create table if not exists audit.quarantine (
  q_id      bigint generated always as identity primary key,
  run_id    uuid        not null references audit.run(run_id),
  rule_id   text        not null,
  issue_id  text,
  action    text        not null,                 -- quarantine / dedupe / nullify_orphan / flag
  model     text        not null,
  row_data  jsonb       not null,
  logged_at timestamptz not null default now()
);
comment on table audit.quarantine is 'S3 정제 규칙으로 격리·수정·표시한 행(원천 정정 요청 근거)';
"""

XFM_GRANTS = """
create schema if not exists xfm;
grant usage on schema xfm to ksx_loader, ksx_reader;
alter default privileges for role ksx_owner in schema xfm grant select on tables to ksx_loader, ksx_reader;
grant usage on schema stg to ksx_reader;
"""


def start_run(cfg: Config, job: str, dsn=None) -> str:
    d = dsn or cfg.owner
    import uuid
    rid = str(uuid.uuid4())
    psql(d, f"insert into audit.run(run_id, stage, job, actor, enterprise_id) values "
            f"('{rid}', 'S3', '{job}', current_user, '{cfg.ent}')")
    return rid


def end_run(cfg: Config, run_id: str, ok: bool, detail: dict, dsn=None):
    d = dsn or cfg.owner
    js = json.dumps(detail, ensure_ascii=False).replace("'", "''")
    psql(d, f"update audit.run set status = '{'succeeded' if ok else 'failed'}', ended_at = now(), "
            f"detail = '{js}'::jsonb where run_id = '{run_id}'")


def log(cfg: Config, run_id, step, obj, src, tgt, status, detail=None, failed=0, dsn=None):
    d = dsn or cfg.owner
    js = json.dumps(detail or {}, ensure_ascii=False).replace("'", "''")
    n = lambda v: "null" if v is None else str(int(v))  # noqa: E731
    psql(d, f"insert into audit.load_log(run_id, step, object, source_rows, target_rows, failed_rows, status, detail) "
            f"values ('{run_id}', '{step}', '{obj}', {n(src)}, {n(tgt)}, {int(failed)}, '{status}', '{js}'::jsonb)")


# ====================================================================== ddl
def ddl(cfg: Config, recreate=False, out=print):
    paths = [rel(cfg.repo, p) for p in cfg.raw["ddl"]]
    tables = parse_ddl(paths)
    # 0) 권한 보강(기존 S0 환경): 스키마 생성 권한 — 관리자 계정으로 1회
    has_create = scalar(cfg.owner, "select has_database_privilege(current_user, current_database(), 'CREATE')")
    if not has_create:
        if cfg.admin is None or not cfg.admin.password and cfg.admin.host:
            raise DbError("ksx_owner에 스키마 생성 권한이 없음 — target.admin(POSTGRES_SUPERUSER_PASSWORD) 필요")
        psql(cfg.admin, f"grant create on database {cfg.owner.dbname} to {cfg.owner.user}")
        out("  권한: ksx_owner에 스키마 생성 권한 부여(최초 1회)")
    psql(cfg.owner, XFM_GRANTS)
    psql(cfg.owner, AUDIT_SQL)
    out("  스키마: xfm(변환 뷰) · audit.load_log · audit.quarantine 준비")
    have = {f"{r['s']}.{r['t']}" for r in rows(cfg.owner,
            "select table_schema s, table_name t from information_schema.tables where table_schema in ('ksx','ext')")}
    want = set(tables)
    if recreate and have & want:
        drops = ", ".join(tables[k].fq for k in sorted(have & want))
        psql(cfg.owner, f"drop table if exists {drops} cascade")
        out(f"  다시 만들기: 기존 표준·확장 테이블 {len(have & want)}개 삭제")
        have -= want
    for p in paths:
        mine = {k for k in tables if k in parse_ddl([p])}
        if mine and mine <= have:
            out(f"  건너뜀(이미 있음): {p.split('/')[-1]} — 테이블 {len(mine)}개")
            continue
        if mine & have:
            raise DbError(f"{p}: 일부 테이블만 있음 {sorted(mine & have)[:3]}… — --recreate로 다시 만든다")
        psql(cfg.owner, file=p)
        out(f"  적용: {p.split('/')[-1]} — 테이블 {len(mine)}개")
    n = scalar(cfg.owner, "select count(*) from information_schema.tables where table_schema in ('ksx','ext') and table_type='BASE TABLE'")
    fk = scalar(cfg.owner, "select count(*) from information_schema.table_constraints where table_schema in ('ksx','ext') "
                           "and constraint_type='FOREIGN KEY'")
    out(f"ksxload ddl: 표준·확장 테이블 {n}개, FK {fk}개 — {cfg.owner.label()}")
    return n


# ====================================================================== stage
def stg_name(t: dict) -> str:
    return f"{t['schema']}__{t['table']}"


def stage(cfg: Config, only: list[str] | None = None, out=print) -> bool:
    run_id = start_run(cfg, "stage")
    tables = cfg.extract["tables"]
    if only:
        tables = [t for t in tables if f"{t['schema']}.{t['table']}" in only]
    total, bad = 0, []
    dropped_views = False
    for t in tables:
        src_dsn, _ = cfg.sources[t["system"]]
        name = stg_name(t)
        cols = [c["name"] for c in t["columns"]]
        coldefs = ", ".join(f'"{c["name"]}" {c["type"]}' for c in t["columns"])
        have = [r["c"] for r in rows(cfg.owner, "select column_name c from information_schema.columns where table_schema = 'stg' "
                                                f"and table_name = '{name}' order by ordinal_position")]
        if have == cols + ["_run_id", "_loaded_at"]:
            # 다시 적재: 구조가 같으면 비우기만 한다 — xfm 뷰(dbt)가 이 테이블을 참조하므로 지우지 않음
            psql(cfg.owner, f'truncate stg."{name}"')
        else:
            if have:
                dropped_views = True          # 원천 구조가 바뀜 → 참조하는 xfm 뷰도 함께 지움(dbt build로 다시 생성)
            psql(cfg.owner, f'drop table if exists stg."{name}" cascade; '
                            f'create table stg."{name}" ({coldefs}, _run_id uuid, _loaded_at timestamptz not null default now()); '
                            f"comment on table stg.\"{name}\" is '원천 복제: {t['schema']}.{t['table']} ({t['system']})'")
        cl = ", ".join(f'"{c}"' for c in cols)
        pout = subprocess.Popen(["psql", *src_dsn.args(), "-c",
                                 f"\\copy (select {cl} from {t['schema']}.{t['table']}) to stdout with (format csv)"],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=src_dsn.environ())
        pin = subprocess.run(["psql", *cfg.owner.args(), "-c",
                              f'\\copy stg."{name}" ({cl}) from stdin with (format csv)'],
                             stdin=pout.stdout, capture_output=True, text=True, env=cfg.owner.environ())
        pout.stdout.close()
        err = pout.stderr.read().decode()
        pout.wait()
        if pout.returncode or pin.returncode:
            raise DbError(f"{t['schema']}.{t['table']} 복제 실패: {(err or pin.stderr).strip()[-500:]}")
        psql(cfg.owner, f"update stg.\"{name}\" set _run_id = '{run_id}'")
        n_src = scalar(src_dsn, f"select count(*) from {t['schema']}.{t['table']}")
        n_stg = scalar(cfg.owner, f'select count(*) from stg."{name}"')
        ok = n_src == n_stg
        log(cfg, run_id, "stage", f"stg.{name}", n_src, n_stg, "ok" if ok else "fail")
        total += n_stg
        if not ok:
            bad.append(name)
        out(f"  {'OK ' if ok else '불일치'} {t['schema']}.{t['table']:<18} → stg.{name:<22} {n_src:>7,} → {n_stg:>7,}")
    psql(cfg.owner, "grant select on all tables in schema stg to ksx_reader")
    end_run(cfg, run_id, not bad, {"tables": len(tables), "rows": total, "mismatch": bad})
    if dropped_views:
        out("  원천 구조가 바뀐 테이블이 있어 참조하는 xfm 뷰를 함께 지웠다 — gen → dbt build를 다시 실행")
    out(f"ksxload stage: 테이블 {len(tables)}개, 행 {total:,} — 행 수 대사 {'일치' if not bad else '불일치 ' + str(len(bad))} (run {run_id})")
    return not bad
