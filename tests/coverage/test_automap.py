"""automap 회귀 시험(S2 완료 기준): 필수 속성 100%·컬럼 판정 100%·오류 0·생성물 최신·지표 목표.

pytest 또는 python으로 실행한다.
"""
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "automap"))

from automap import cli  # noqa: E402
from automap import matcher as M  # noqa: E402
from automap.engine import Engine  # noqa: E402
from automap.stdmodel import Attr  # noqa: E402

PLAN = os.path.join(ROOT, "mapping", "impix", "s2_plan.yaml")
_ENG = None


def eng():
    global _ENG
    if _ENG is None:
        _ENG = Engine(PLAN, ROOT).run()
    return _ENG


def test_completion_criteria():
    e = eng()
    j = e.judgements()
    m = e.metrics(j)
    assert m["errors"] == 0, [i for i in e.issues if i[0] == "오류"][:5]
    assert m["req_missing"] == 0, [(r.noun, r.missing) for r in e.results if r.missing]
    assert m["judge_rate"] == 100.0, [f"{x['table']}.{x['column']}" for x in j if x["kind"] == "미판정"][:10]


def test_metric_targets():
    m = eng().metrics(eng().judgements())
    assert m["det_rate"] >= 70.0, m["det_rate"]          # 구현안내서 5.2: 결정론 해소율 70% 이상
    assert m["fix_rate"] < 20.0, m["fix_rate"]           # 검토자 수정 20% 미만


def test_outputs_current():
    e = eng()
    stale = cli._stale(e, os.path.join(ROOT, e.plan["out"]))
    assert not stale, f"automap run 다시 실행 필요: {stale[:5]}"


def test_known_reviewer_corrections():
    """결정론 오매칭을 계획이 바로잡는지 — 대표 사례 고정."""
    by = {(r.noun, a): m for r in eng().results for a, m in r.maps.items()}
    assert by[("EquipmentState", "EquipmentState")].src == "stat_cd"
    assert by[("EquipmentState", "EquipmentStateID")].transform.startswith("concat('ES-'")
    assert by[("Alarm", "ErrorCode")].src == "alm_cd"
    assert ("DeliveryLine", "RequestedDeliveryDate") not in by        # 실제 납품일을 요청납품일로 매핑하지 않는다


def test_extension_attrs_are_mapped():
    by = {(r.noun, a): m for r in eng().results for a, m in r.maps.items()}
    for k in [("GoodsReceipt", "PurchaseDocumentNumber"), ("EquipmentState", "StateStartDateTime"),
              ("TraceParameter", "LotID"), ("ProductionOrder", "ProductionOrderStatusCode")]:
        assert k in by and by[k].layer == "ext", k


def test_filter_columns_checked():
    """filter에 원천에 없는 컬럼을 쓰면 오류(예: mes.tm_param은 use_yn이 아니라 use_flag)."""
    import tempfile
    import yaml
    plan = yaml.safe_load(open(PLAN, encoding="utf-8"))
    sp = next(s for s in plan["specs"] if s["noun"] == "EquipmentParameter")
    sp["filter"] = "use_yn = 'Y' AND e.no_such_col IS NULL"
    with tempfile.NamedTemporaryFile("w", suffix=".yaml", delete=False, encoding="utf-8") as f:
        yaml.safe_dump(plan, f, allow_unicode=True)
    try:
        msgs = [m for lv, w, m in Engine(f.name, ROOT).run().issues if lv == "오류"]
    finally:
        os.unlink(f.name)
    assert any("'use_yn'" in m for m in msgs) and any("'e.no_such_col'" in m for m in msgs), msgs
    assert len(msgs) == 2, msgs                      # 다른 명세의 필터(서브쿼리·함수 포함)는 오류 없음


def test_matcher_stages():
    attrs = [Attr(en, ko, "string", "", False, False, None, None, "", "core", None, None)
             for en, ko in [("ItemID", "품목식별자"), ("DialNumber", "전화번호"), ("PersonnelID", "사원식별자"),
                            ("ItemName", "품목명"), ("UseIndicator", "사용여부")]]
    ab = {"CD": ["ID", "Code"], "NO": ["Number", "ID"], "TEL": "Dial", "EMP": "Personnel", "NM": "Name", "YN": "Indicator"}
    assert M.match("item_cd", None, attrs, ab).attr.en == "ItemID"
    assert M.match("tel_no", None, attrs, ab).attr.en == "DialNumber"
    assert M.match("oper_emp_no", None, attrs, ab).stage == "component"     # 앞 수식 토큰 제거
    assert M.match("use_yn", None, attrs, ab).attr.en == "UseIndicator"
    assert M.match("xyz", None, attrs, ab) is None


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
