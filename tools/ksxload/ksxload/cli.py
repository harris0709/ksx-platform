"""ksxload 명령행 — S3 데이터 전환·적재(구현안내서 6장).

  python -m ksxload ddl     --plan mapping/impix/s3_plan.yaml [--recreate]   # 표준·확장 테이블, xfm·audit 준비
  python -m ksxload stage   --plan …                                          # 원천 → stg 전체 복제 + 행 수 대사
  python -m ksxload gen     --plan …                                          # 매핑 명세 → dbt 모델·테스트·seed
  python -m ksxload xfm     --plan …                                          # dbt 없이 같은 모델 실행(seed·뷰·테스트)
  python -m ksxload publish --plan … [--dry-run]                              # xfm → 표준 원장 + 대사·감사 기록
  python -m ksxload check   --plan …                                          # 생성물(gen) 최신 여부
  python -m ksxload dbt seed|run|test|build …                                  # etl/dbt에서 dbt 실행(Docker s3-tools)
--plan을 생략하면 환경변수 S3_PLAN(기본 mapping/impix/s3_plan.yaml)을 쓴다.
"""
from __future__ import annotations

import argparse
import os
import sys

from .base import DbError, load_config


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="ksxload")
    ap.add_argument("cmd", choices=["ddl", "stage", "gen", "xfm", "publish", "check", "dbt"])
    ap.add_argument("--plan", default=os.environ.get("S3_PLAN", "mapping/impix/s3_plan.yaml"))
    ap.add_argument("--repo", default=os.getcwd())
    ap.add_argument("--recreate", action="store_true", help="ddl: 표준·확장 테이블을 지우고 다시 만든다")
    ap.add_argument("--dry-run", action="store_true", help="publish: 적재·검사 후 되돌린다(커밋 안 함)")
    ap.add_argument("--table", action="append", help="stage: 특정 원천 테이블만(schema.table)")
    a, rest = ap.parse_known_args(argv)
    cfg = load_config(a.plan, a.repo)
    if a.cmd == "dbt":                       # dbt는 etl/dbt에서 실행(profiles.yml도 그 폴더)
        import subprocess
        args = rest or ["build"]
        return subprocess.call(["dbt", *args, "--project-dir", cfg.dbt_dir, "--profiles-dir", cfg.dbt_dir])
    if rest:
        ap.error(f"알 수 없는 인자: {rest}")
    try:
        if a.cmd == "ddl":
            from .load import ddl
            ddl(cfg, recreate=a.recreate)
            return 0
        if a.cmd == "stage":
            from .load import stage
            return 0 if stage(cfg, a.table) else 1
        if a.cmd == "gen":
            from .gen import generate
            generate(cfg)
            return 0
        if a.cmd == "check":
            from .gen import stale
            bad = stale(cfg)
            for x in bad[:20]:
                print(f"  최신 아님 · {x} — ksxload gen 다시 실행")
            print("ksxload check: " + ("통과" if not bad else "실패"))
            return 1 if bad else 0
        if a.cmd == "xfm":
            from .xfm import run_xfm
            return 0 if run_xfm(cfg) else 1
        if a.cmd == "publish":
            from .publish import publish
            return 0 if publish(cfg, dry_run=a.dry_run) else 1
    except DbError as e:
        print(f"ksxload {a.cmd}: DB 오류 — {e}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
