"""ksxload 회귀 시험(S3): 변환 어휘 번역·생성물 최신·적재 목록·규칙. DB 없이 실행한다.

DB를 쓰는 전체 적재(ddl → stage → dbt → publish)는 CI의 s3-load 작업이 실제 dbt로 확인한다.
"""
import os
import re
import sys

import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "ksxload"))

from ksxload.base import load_config, parse_ddl, topo_order  # noqa: E402
from ksxload.dsl import VOCAB, DslError, Translator, parse_unpivot  # noqa: E402
from ksxload.gen import stale  # noqa: E402

PLAN = "mapping/impix/s3_plan.yaml"


def cfg():
    return load_config(PLAN, ROOT)


def test_dsl_translation():
    t = Translator({"item_cd", "val", "iqc_stat", "gr_qty", "cost_itm", "cost_ym"}, {"p", "o"},
                   {"cost_itm": "COST_ITM"}, {"ev": "u.ev"})
    assert t.expr("upper_trim(item_cd)") == "xfm.upper_trim(s.item_cd)"
    assert t.expr("case(val > p.usl, OVER_USL, NORMAL)") == "CASE WHEN s.val > p.usl THEN 'OVER_USL' ELSE 'NORMAL' END"
    assert t.expr("const(SAL-DEF)") == "'SAL-DEF'" and t.expr("const(1)") == "1" and t.expr("const(true)") == "true"
    assert t.expr("xref(plant, o.fac_id)") == "xfm.xref('plant', (o.fac_id)::text)"
    assert "xfm.code('COST_ITM'" in t.expr("concat(cost_ym,'_',code(cost_itm))")
    assert t.expr("case(ev='ON', ALARM, NORMAL)").startswith("CASE WHEN u.ev='ON'")
    assert parse_unpivot("unpivot(occur_dtm→ON, clear_dtm→OFF)") == [("occur_dtm", "ON"), ("clear_dtm", "OFF")]
    try:
        t.expr("upper_trim(no_such_col)")
        raise AssertionError("없는 컬럼이 통과함")
    except DslError:
        pass


def test_vocab_functions_exist():
    txt = open(os.path.join(ROOT, "etl", "dbt", "macros", "xfm_functions.sql"), encoding="utf-8").read()
    for f in VOCAB:
        assert re.search(rf"function xfm\.{f}\(", txt), f


def test_generated_current():
    bad = stale(cfg())
    assert not bad, f"ksxload gen 다시 실행 필요: {bad[:5]}"


def test_manifest():
    c = cfg()
    man = yaml.safe_load(open(os.path.join(c.dbt_dir, "publish", "impix.yml"), encoding="utf-8"))
    assert len(man["models"]) == 59
    tables = {t["table"] for m in man["models"] for t in m["targets"]}
    assert len(tables) == len(man["order"]) == 70
    lots = [m["model"] for m in man["models"] if m["noun"] == "Lot"]
    assert sorted(lots) == ["Lot", "Lot_legacy", "Lot_material", "Lot_shipped"]
    alarm = next(m for m in man["models"] if m["model"] == "Alarm")
    assert alarm["kind"] == "unpivot" and "count(s.occur_dtm) + count(s.clear_dtm)" in alarm["expect_sql"]
    ship = next(m for m in man["models"] if m["model"] == "Lot_shipped")
    assert ship["kind"] == "distinct"
    # 대상 테이블 순서: 부모가 자식보다 먼저
    o = man["order"]
    assert o.index("ksx.ProductionOrder") < o.index("ksx.Lot") < o.index("ext.LotExt")


def test_rules_cover_s1_high_issues():
    c = cfg()
    covered = {r["issue"] for r in c.raw["rules"]}
    # S1 '상' 11건: Q004·Q011은 S2 로트 A안, Q007은 테이블 제외로 처리 — 나머지는 S3 규칙
    assert {"Q001", "Q002", "Q003", "Q005", "Q006", "Q008", "Q009", "Q010"} <= covered
    sch = yaml.safe_load(open(os.path.join(c.models_dir, "schema.yml"), encoding="utf-8"))
    names = {m["name"] for m in sch["models"]}
    for r in c.raw["rules"]:
        assert os.path.exists(os.path.join(c.models_dir, "xfm", f"{r['model']}__audit.sql")), r["id"]
        assert r["model"] in names


def test_review_decisions():
    """정제 규칙마다 현업 검토 결정이 있다(구현안내서 6.7) — 파생 규칙(R07b)은 앞 규칙(R07)을 따른다."""
    from ksxload.review import ACTION_KO, _parent_review
    c = cfg()
    rv = c.raw.get("review", {})
    for r in c.raw["rules"]:
        assert r["action"] in ACTION_KO, r["id"]
        d, of = _parent_review(r["id"], rv)
        assert d.get("decision") and d.get("decided"), f"{r['id']}: review.decision 없음"
    assert set(rv) <= {r["id"] for r in c.raw["rules"]}
    assert c.raw["approval"]["status"] in ("approved", "conditional", "rejected")
    for x in c.raw.get("s2_regressions", []):
        assert x.get("decision"), x.get("id")


def test_topo_order():
    t = parse_ddl([os.path.join(ROOT, "ontologies", "ddl", "ksx.sql"), os.path.join(ROOT, "ontologies", "ddl", "ext_impix.sql")])
    o = topo_order(t, list(t))
    assert o[:3] == ["ksx.Enterprise", "ksx.Site", "ksx.Plant"]
    assert o.index("ksx.Alarm") < o.index("ext.AlarmExt")


if __name__ == "__main__":
    fails = 0
    for name, fn in sorted(globals().items()):
        if name.startswith("test_") and callable(fn):
            try:
                fn()
                print(f"통과 {name}")
            except AssertionError as ex:
                fails += 1
                print(f"실패 {name}: {ex}")
    sys.exit(1 if fails else 0)
