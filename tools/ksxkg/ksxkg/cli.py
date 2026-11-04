"""ksxkg 명령행 — S5 지식 그래프(A-Box) 구성(구현안내서 8장).

  python -m ksxkg materialize --plan mapping/impix/s5_plan.yaml   # 원장 → Morph-KGC → 사업장 Named Graph → Fuseki
  python -m ksxkg check       --plan …                            # 완료 기준: 가상 = SQL, 물질화 = 기대치, 그래프 분리
  python -m ksxkg query       --plan … --endpoint ontop|fuseki "SPARQL"   # 질의 한 건(확인용)
--plan을 생략하면 환경변수 S5_PLAN(기본 mapping/impix/s5_plan.yaml)을 쓴다.
"""
from __future__ import annotations

import argparse
import os
import sys

from .base import DbError, SparqlError, load_config, sparql


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="ksxkg")
    ap.add_argument("cmd", choices=["materialize", "check", "query"])
    ap.add_argument("text", nargs="?", help="query: SPARQL")
    ap.add_argument("--plan", default=os.environ.get("S5_PLAN", "mapping/impix/s5_plan.yaml"))
    ap.add_argument("--repo", default=os.getcwd())
    ap.add_argument("--endpoint", choices=["ontop", "fuseki"], default="fuseki", help="query: 질의할 엔드포인트")
    ap.add_argument("--skip-morph", action="store_true", help="materialize: 이전 N-Quads(out/kg/ksx.nq)를 다시 적재만")
    a = ap.parse_args(argv)
    cfg = load_config(a.plan, a.repo)
    try:
        if a.cmd == "materialize":
            from .materialize import materialize
            return 0 if materialize(cfg, skip_morph=a.skip_morph) else 1
        if a.cmd == "check":
            from .check import check
            return 0 if check(cfg) else 1
        if a.cmd == "query":
            ep = cfg.ontop if a.endpoint == "ontop" else cfg.query
            r = sparql(ep, a.text or sys.stdin.read())
            if r:
                cols = list(r[0])
                print("\t".join(cols))
                for x in r:
                    print("\t".join(x.get(c, "") for c in cols))
            print(f"({len(r)}행)")
            return 0
    except (DbError, SparqlError) as e:
        print("오류:", e, file=sys.stderr)
        return 1
    return 0
