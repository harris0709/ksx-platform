"""s1profiler 명령행.

  python -m s1profiler all --config mapping/impix/s1/s1_config.yaml
  python -m s1profiler check-conn --config ...
  python -m s1profiler scenarios --config ...   # 시나리오 정의서(docx)·업무 질의서(xlsx)

컨테이너: docker compose --profile tools run --rm s1-tools all --config mapping/impix/s1/s1_config.yaml
"""
from __future__ import annotations

import argparse
import os
import sys
import time

import yaml

from . import core, output


def _load(path):
    with open(path, encoding="utf-8") as f:
        return core.expand_config(yaml.safe_load(f))


def main(argv=None):
    ap = argparse.ArgumentParser(prog="s1profiler", description="S1 원천 분석(스키마·프로파일·코드·관계·품질·인벤토리)")
    ap.add_argument("command", choices=["all", "check-conn", "scenarios"])
    ap.add_argument("--config", required=True)
    ap.add_argument("--repo", default=os.getcwd(), help="저장소 루트(기본: 현재 폴더)")
    a = ap.parse_args(argv)
    cfg = _load(a.config)
    t0 = time.time()
    if a.command == "scenarios":
        from . import scenario_docs
        for p in scenario_docs.build(a.config, a.repo):
            print(f"[산출물] {os.path.relpath(p, a.repo)}")
        return 0

    conns, tables = {}, []
    for s in cfg["sources"]:
        try:
            conns[s["system"]] = core.connect(s["dsn"])
        except Exception as e:  # noqa: BLE001
            print(f"[실패] {s['system']} 접속: {e}", file=sys.stderr)
            return 2
        print(f"[접속] {s['system']} {s['dsn'].get('host')}:{s['dsn'].get('port')}/{s['dsn']['dbname']} ({s['dsn']['user']})")
    if a.command == "check-conn":
        return 0

    for s in cfg["sources"]:
        ts = core.extract_schema(conns[s["system"]], s["system"], s["dsn"]["dbname"], s["schemas"])
        print(f"[4) 스키마 추출] {s['system']}: 테이블 {len(ts)}, 컬럼 {sum(len(t.columns) for t in ts)}")
        core.profile_tables(conns[s["system"]], ts, **cfg.get("profile", {}))
        print(f"[5) 프로파일]   {s['system']}: 행 {sum(t.rows for t in ts):,}")
        tables += ts
    relations = core.find_relations(conns, tables, cfg, a.repo)
    print(f"[7) 암묵 관계]   전체 {len(relations)} (선언 FK {sum(1 for r in relations if r['declared'])}, "
          f"FK 미선언 {sum(1 for r in relations if not r['declared'])})")
    masters, codes = core.collect_codes(conns, tables, cfg, relations)
    print(f"[6) 코드 수집]   코드 마스터 {len(masters)}건, 코드 후보 컬럼 {len(codes)}개")
    issues = core.run_checks(conns, tables, codes, relations, cfg)
    print(f"[품질 점검]      이슈 {len(issues)} (상 {sum(1 for i in issues if i['severity']=='상')}, "
          f"중 {sum(1 for i in issues if i['severity']=='중')}, 하 {sum(1 for i in issues if i['severity']=='하')})")
    inventory = core.build_inventory(tables, issues, relations, cfg)
    out_dir = os.path.join(a.repo, cfg["output_dir"])
    paths = output.write_all(out_dir, cfg, tables, inventory, masters, codes, relations, issues)
    for p in paths:
        print(f"[산출물] {os.path.relpath(p, a.repo)}")
    print(f"[완료] {time.time() - t0:.1f}초")
    return 0
