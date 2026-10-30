"""dbt 없이 xfm 모델을 실행한다(dbt seed → run → test와 같은 순서·같은 SQL).

dbt를 쓸 수 없는 환경(패키지 저장소 차단 등)과 빠른 확인용이다. 운영·CI는 dbt를 쓴다.
모델의 Jinja는 source()·ref()·config()만 쓰므로 그대로 치환할 수 있다.
"""
from __future__ import annotations

import csv
import glob
import io
import os
import re
import subprocess

import yaml

from .base import Config, DbError, psql, rows, scalar


def _render(sql: str) -> str:
    sql = re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql, flags=re.S)
    sql = re.sub(r"\{\{\s*source\('(\w+)',\s*'(\w+)'\)\s*\}\}", lambda m: f'{m.group(1)}."{m.group(2)}"', sql)
    sql = re.sub(r"\{\{\s*ref\('(\w+)'\)\s*\}\}", lambda m: f'xfm."{m.group(1)}"', sql)
    if "{{" in sql or "{%" in sql:
        raise DbError(f"지원하지 않는 Jinja: {sql[sql.find('{'):][:80]}")
    return sql


def functions_sql(cfg: Config) -> str:
    txt = open(os.path.join(cfg.dbt_dir, "macros", "xfm_functions.sql"), encoding="utf-8").read()
    m = re.search(r"\{% macro ksx_xfm_functions\(\) %\}(.*)\{% endmacro %\}", txt, re.S)
    return m.group(1)


def load_seeds(cfg: Config, out):
    for p in sorted(glob.glob(os.path.join(cfg.seeds_dir, "*.csv"))):
        name = os.path.splitext(os.path.basename(p))[0]
        data = open(p, encoding="utf-8").read()
        hdr = next(csv.reader(io.StringIO(data)))
        psql(cfg.owner, f'drop table if exists xfm."{name}" cascade; create table xfm."{name}" ('
                        + ", ".join(f'"{h}" text' for h in hdr) + ")")
        r = subprocess.run(["psql", *cfg.owner.args(), "-c",
                            f'\\copy xfm."{name}" from stdin with (format csv, header true)'],
                           input=data, capture_output=True, text=True, env=cfg.owner.environ())
        if r.returncode:
            raise DbError(r.stderr)
        out(f"  seed  xfm.{name:<8} {scalar(cfg.owner, f'select count(*) from xfm.{name}'):>5}행")


def run_xfm(cfg: Config, out=print) -> bool:
    psql(cfg.owner, _render(functions_sql(cfg)))
    out("  함수  xfm 변환 어휘 SQL 함수 생성")
    load_seeds(cfg, out)
    models = {}
    for p in glob.glob(os.path.join(cfg.models_dir, "xfm", "*.sql")):
        models[os.path.splitext(os.path.basename(p))[0]] = open(p, encoding="utf-8").read()
    deps = {m: set(re.findall(r"ref\('(\w+)'\)", s)) & set(models) for m, s in models.items()}
    order, done = [], set()
    while len(order) < len(models):
        ready = sorted(m for m in models if m not in done and deps[m] <= done)
        if not ready:
            raise DbError(f"모델 순환 참조: {sorted(set(models) - done)[:5]}")
        order += ready
        done |= set(ready)
    # 기존 뷰 정리 후 의존 순서대로 생성
    for v in rows(cfg.owner, "select table_name t from information_schema.views where table_schema='xfm'"):
        psql(cfg.owner, f'drop view if exists xfm."{v["t"]}" cascade')
    fail = []
    for m in order:
        try:
            psql(cfg.owner, f'create view xfm."{m}" as\n{_render(models[m])}')
        except DbError as e:
            fail.append(m)
            out(f"  오류  {m}: {str(e).splitlines()[0]}")
    out(f"  run   뷰 {len(order) - len(fail)}/{len(order)}개 생성")
    if fail:
        return False
    # 테스트(schema.yml과 같은 내용)
    sch = yaml.safe_load(open(os.path.join(cfg.models_dir, "schema.yml"), encoding="utf-8"))
    tests, bad = 0, []
    for md in sch["models"]:
        name = md["name"]
        for t in md.get("tests", []):
            cols = t["ksx_unique_key"]["columns"]
            cl = ", ".join(f'"{c}"' for c in cols)
            n = scalar(cfg.owner, f'select count(*) from (select {cl} from xfm."{name}" group by {cl} having count(*) > 1) x')
            tests += 1
            if n:
                bad.append((name, f"UK 중복 {n}건 ({'+'.join(cols)})"))
        for c in md.get("columns", []):
            for t in c.get("tests", []):
                tests += 1
                if t == "not_null":
                    n = scalar(cfg.owner, f'select count(*) from xfm."{name}" where "{c["name"]}" is null')
                    if n:
                        bad.append((name, f"필수 값 NULL {n}건 ({c['name']})"))
                elif isinstance(t, dict) and "ksx_code_mapped" in t:
                    g = t["ksx_code_mapped"]["group"]
                    r = rows(cfg.owner, f'select m."{c["name"]}" v, count(*) n from xfm."{name}" m where m."{c["name"]}" is not null '
                                        f"and not exists (select 1 from xfm.codes k where k.src_group = '{g}' "
                                        f'and k.src_code = m."{c["name"]}") group by 1')
                    if r:
                        bad.append((name, f"코드 미대응 {g}: " + ", ".join(f"{x['v']}({x['n']})" for x in r)))
    for name, msg in bad:
        out(f"  실패  {name}: {msg}")
    out(f"ksxload xfm: 모델 {len(order)}개, 테스트 {tests}개 — 통과 {tests - len(bad)}, 실패 {len(bad)}")
    return not bad
