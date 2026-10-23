"""automap 명령행.

  python -m automap run --plan mapping/impix/s2_plan.yaml        # 매칭 → 명세·대응표·검토본·요약
  python -m automap check --plan mapping/impix/s2_plan.yaml      # 완료 기준 점검만(필수 속성 100%, 컬럼 판정 100%, 오류 0)
"""
from __future__ import annotations

import argparse
import os
import sys

from .engine import Engine


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="automap")
    ap.add_argument("cmd", choices=["run", "check"])
    ap.add_argument("--plan", required=True)
    ap.add_argument("--repo", default=os.getcwd())
    a = ap.parse_args(argv)
    eng = Engine(a.plan, a.repo).run()
    judg = eng.judgements()
    m = eng.metrics(judg)
    print(f"automap: 명세 {m['specs']} · 명사 {m['nouns']} · 매핑 {m['mapped']} "
          f"(파생 {m['derived']}, 결정론 {m['det_rate']}%, 검토자 수정 {m['fix_rate']}%, 검토자 매핑 {m['manual']})")
    print(f"  필수 속성 {m['req_rate']}% ({m['req_total'] - m['req_missing']}/{m['req_total']}) · "
          f"컬럼 판정 {m['judge_rate']}% ({m['judged']}/{m['cols']}) · 오류 {m['errors']}")
    if a.cmd == "run":
        from .output import write_all
        out = os.path.join(a.repo, eng.plan.get("out", os.path.dirname(a.plan)))
        for p in write_all(eng, out):
            pass
        print(f"  산출물 → {os.path.relpath(out, a.repo)} (명세 {m['specs']}개, codes/units/xref.csv, S2_매핑정의서, S2_매핑요약)")
    for lv, w, msg in eng.issues[:40]:
        print(f"  {lv} · {w}: {msg}")
    for r in eng.results:
        if r.missing:
            print(f"  필수 누락 · {r.noun} ← {r.table}: {', '.join(r.missing)}")
    und = [j for j in judg if j["kind"] == "미판정"]
    for j in und[:40]:
        print(f"  미판정 · {j['table']}.{j['column']}")
    ok = m["errors"] == 0 and m["req_missing"] == 0 and not und
    if a.cmd == "check":
        stale = _stale(eng, os.path.join(a.repo, eng.plan.get("out", os.path.dirname(a.plan))))
        for x in stale[:20]:
            print(f"  최신 아님 · {x} — automap run 다시 실행")
        ok = ok and not stale
        print("automap check: " + ("통과" if ok else "실패"))
    return 0 if ok or a.cmd == "run" else 1


def _stale(eng, out: str) -> list[str]:
    """계획으로 다시 만든 명세·대응표·요약(텍스트)이 저장소 사본과 같은지 본다(검토본 xlsx는 생성 시각이 있어 제외)."""
    import tempfile
    from .output import write_all
    with tempfile.TemporaryDirectory() as tmp:
        new = {os.path.relpath(p, tmp): open(p, encoding="utf-8").read()
               for p in write_all(eng, tmp) if not p.endswith(".xlsx")}
    bad = []
    for rel, txt in new.items():
        cur = os.path.join(out, rel)
        if not os.path.exists(cur) or open(cur, encoding="utf-8").read() != txt:
            bad.append(rel)
    return bad


if __name__ == "__main__":
    sys.exit(main())
