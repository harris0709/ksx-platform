"""xfm 뷰 → 표준 원장(ksx·ext) 적재 + 대사(구현안내서 6.6 표 15).

한 트랜잭션 안에서: FK 지연 → 대상 테이블 비우기 → FK 순서대로 INSERT → FK 고아·행 수 집계 → 커밋.
FK 고아가 있으면 커밋이 실패해 원장은 그대로 남는다(전부 또는 전무). --dry-run은 검사 후 되돌린다.
대사·정제 결과는 audit.run·audit.load_log·audit.quarantine에 남긴다(적재 성공·실패와 관계없이).
"""
from __future__ import annotations

import json
import os
import subprocess

import yaml

from .base import Config, DbError, parse_ddl, rel, rows, scalar
from .load import end_run, log, start_run


def _q(c):
    return f'"{c}"'


def _fq(key):
    s, t = key.split(".")
    return f'{s}."{t}"'


def load_manifest(cfg: Config) -> dict:
    return yaml.safe_load(open(os.path.join(cfg.dbt_dir, "publish", f"{cfg.ent.lower()}.yml"), encoding="utf-8"))


def precheck(cfg: Config, man: dict) -> list[dict]:
    """모델별 원천 기대 행 수·모델 행 수·규칙 처리 행 수·합계."""
    out = []
    for m in man["models"]:
        name = m["model"]
        expect = scalar(cfg.loader, m["expect_sql"])
        n = scalar(cfg.loader, f'select count(*) from xfm."{name}"')
        acts = {}
        if m.get("audit"):
            for r in rows(cfg.loader, f'select rule_id, action, count(*) n from xfm."{m["audit"]}" group by 1, 2'):
                acts[(r["rule_id"], r["action"])] = r["n"]
        removed = sum(v for (rid, a), v in acts.items() if a in ("quarantine", "dedupe"))
        sums = []
        for s in m.get("sums", []):
            a = scalar(cfg.loader, s["source"])
            b = scalar(cfg.loader, f'select sum("{s["column"]}") from xfm."{name}"')
            sums.append({"column": s["column"], "source": a, "target": b, "ok": (a or 0) == (b or 0)})
        out.append({"model": name, "noun": m["noun"], "kind": m["kind"], "expect": expect, "rows": n, "removed": removed,
                    "rules": {f"{rid}:{a}": v for (rid, a), v in acts.items()}, "sums": sums,
                    "ok": n + removed == expect})
    return out


def build_script(man: dict, tables: dict, dry_run: bool) -> str:
    order = man["order"]
    by_table: dict[str, list] = {k: [] for k in order}
    for m in man["models"]:
        for t in m["targets"]:
            by_table[t["table"]].append((m["model"], t["columns"]))
    L = ["\\set ON_ERROR_STOP 1", "begin;", "set constraints all deferred;",
         "truncate " + ", ".join(_fq(k) for k in order) + " cascade;"]
    for k in order:
        for model, cols in by_table[k]:
            cl = ", ".join(_q(c) for c in cols)
            if k.startswith("ext.") and k.endswith("Ext"):
                L.append(f"insert into {_fq(k)} ({cl}) select {cl} from xfm.\"{model}\";")
            else:
                L.append(f"insert into {_fq(k)} ({cl}) select {cl} from xfm.\"{model}\";")
    # 검사: FK 고아(대상 테이블의 모든 FK), 테이블 행 수
    chk = []
    for k in order:
        t = tables[k]
        for name, cc, ptab, pc in t.fks:
            nn = " and ".join(f"c.{_q(c)} is not null" for c in cc)
            eq = " and ".join(f"p.{_q(p)} = c.{_q(c)}" for c, p in zip(cc, pc))
            chk.append(f"select '{k}' tbl, '{name}' fk, '{'+'.join(cc)} → {ptab}' ref, count(*) n "
                       f"from {_fq(k)} c where {nn} and not exists (select 1 from {_fq(ptab)} p where {eq})")
    L.append("\\pset tuples_only on\n\\pset format unaligned")
    L.append("select 'PUB|fk|' || coalesce(jsonb_agg(to_jsonb(f))::text, '[]') from (\n" + "\nunion all\n".join(chk) + "\n) f where n > 0;")
    cnt = " union all ".join(f"select '{k}' t, count(*) n from {_fq(k)}" for k in order)
    L.append(f"select 'PUB|rows|' || jsonb_object_agg(t, n)::text from ({cnt}) x;")
    L.append("rollback;" if dry_run else "commit;")
    return "\n".join(L) + "\n"


def publish(cfg: Config, dry_run=False, out=print) -> bool:
    man = load_manifest(cfg)
    tables = parse_ddl([rel(cfg.repo, p) for p in cfg.raw["ddl"]])
    run_id = start_run(cfg, "publish" + (":dry-run" if dry_run else ""))
    # 1) 사전 대사(모델 단위)
    pre = precheck(cfg, man)
    bad_rows = [p for p in pre if not p["ok"]]
    bad_sums = [(p["model"], s) for p in pre for s in p["sums"] if not s["ok"]]
    for p in pre:
        log(cfg, run_id, "check", f"xfm.{p['model']}", p["expect"], p["rows"], "ok" if p["ok"] else "fail",
            {"kind": p["kind"], "removed_by_rules": p["removed"], "rules": p["rules"], "sums": p["sums"]},
            failed=0 if p["ok"] else abs(p["expect"] - p["rows"] - p["removed"]))
    # 2) 정제 규칙 기록(격리·중복·참조 비움·표시)
    nq = 0
    for m in man["models"]:
        if m.get("audit"):
            from .base import psql
            psql(cfg.owner, f"insert into audit.quarantine(run_id, rule_id, issue_id, action, model, row_data) "
                            f"select '{run_id}', rule_id, issue_id, action, '{m['model']}', row_data from xfm.\"{m['audit']}\"")
            nq += scalar(cfg.owner, f'select count(*) from xfm."{m["audit"]}"')
    # 3) 적재(한 트랜잭션)
    script = build_script(man, tables, dry_run)
    p = subprocess.run(["psql", *cfg.loader.args(), "-q"], input=script, capture_output=True, text=True,
                       env=cfg.loader.environ())
    res = {}
    for line in p.stdout.splitlines():
        if line.startswith("PUB|"):
            _, k, js = line.split("|", 2)
            res[k] = json.loads(js)
    fk = res.get("fk", [])
    counts = res.get("rows", {})
    committed = p.returncode == 0 and not dry_run
    err = (p.stderr or "").strip()
    for k, n in sorted(counts.items()):
        log(cfg, run_id, "publish", k, None, n, "ok" if committed or dry_run else "fail")
    for f in fk:
        log(cfg, run_id, "check", f"{f['tbl']}:{f['fk']}", None, None, "fail", {"ref": f["ref"]}, failed=f["n"])
    ok = p.returncode == 0 and not fk and not bad_rows
    end_run(cfg, run_id, ok and not bad_sums, {"dry_run": dry_run, "committed": committed, "tables": len(counts),
                                               "rows": sum(counts.values()), "fk_orphans": sum(f["n"] for f in fk),
                                               "row_mismatch": [b["model"] for b in bad_rows],
                                               "sum_mismatch": [f"{m}.{s['column']}" for m, s in bad_sums],
                                               "rules_logged": nq, "error": err[-500:] if p.returncode else ""})
    # 4) 보고
    out(f"  행 수 대사(원천 → 모델 + 규칙 처리): {len(pre) - len(bad_rows)}/{len(pre)} 일치")
    for b in bad_rows:
        out(f"    불일치 {b['model']}: 원천 {b['expect']} ≠ 모델 {b['rows']} + 규칙 처리 {b['removed']}")
    ns = sum(len(p['sums']) for p in pre)
    out(f"  합계 대사(수량·금액): {ns - len(bad_sums)}/{ns} 일치")
    for m, s in bad_sums:
        out(f"    불일치 {m}.{s['column']}: 원천 {s['source']} ≠ 모델 {s['target']}")
    acts = {}
    for p_ in pre:
        for k, v in p_["rules"].items():
            a = k.split(":")[1]
            acts[a] = acts.get(a, 0) + v
    out("  정제 규칙: " + (", ".join(f"{a} {v}행" for a, v in sorted(acts.items())) or "없음") + f" → audit.quarantine {nq}행")
    out(f"  FK 고아: {sum(f['n'] for f in fk)}건" + ("" if not fk else ""))
    for f in fk[:30]:
        out(f"    {f['tbl']} {f['ref']} ({f['fk']}): {f['n']}건")
    if p.returncode and not fk:
        out(f"  적재 오류: {err.splitlines()[-1] if err else p.returncode}")
    total = sum(counts.values())
    state = "되돌림(dry-run)" if dry_run else ("커밋" if committed else "실패 — 원장 변경 없음")
    out(f"ksxload publish: 대상 테이블 {len(counts)}개, 적재 {total:,}행 — {state} (run {run_id})")
    return ok
