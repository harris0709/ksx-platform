# 추론 규칙 (S7, 구현안내서 10장)

`A-*.rq`는 ksxgen이 만드는 자동 전이 규칙(자기 참조 관계의 닫힘, `inf:{관계}Closure`)이고, `R-*.rq`는 사람이 작성하는 업무 규칙입니다. 파일명 순서대로 실행되며, 앞 규칙의 결과를 뒤 규칙이 쓸 수 있습니다(실행 중 추론 그래프가 합집합에 들어감).

업무 규칙이 이미 전개하는 관계는 자동 규칙을 만들지 않습니다(S4 결정 D-3). 예: 모로트 닫힘은 A-* 대신 R-001의 `inf:derivedFrom` 하나로만 만듭니다.

| 파일 | 유형(표 26) | 결과 | 답하는 업무 질의(S1) |
|---|---|---|---|
| R-001_lot_genealogy.rq | 전이 | `inf:consumedLot`(투입 LOT, 직접) · `inf:derivedFrom`(계보 전체) — 생산실적투입품목 경유 + 표준 모로트 참조 | Q-SC02-06, Q-SC06-03 |
| R-002_bom_direct.rq | 체인 | `inf:directComponent` — 기준일에 유효한 BOM 라인만 | Q-SC01-01 |
| R-003_bom_explosion.rq | 전이 | `inf:component` — 다단 전개(R-002 결과 사용) | Q-SC01-08 |
| R-005_lot_equipment.rq | 체인 | `inf:processedOn` — LOT이 거친 설비(생산실적설비 경유) | Q-SC02-06, Q-SC06-03 |
| R-010_affected_sales_order.rq | 체인 | `inf:affectedSalesOrderLine` · `inf:affectedSalesOrder` — 생산실적 → 생산지시 → 수주 | Q-SC05-06 |
| R-020_specout_lot.rq | 이벤트 | `inf:SpecOutLotEvent` — 파라미터 규격 이탈 중 가공된 LOT(설비·파라미터·이탈 건수) | Q-SC03-02 |
| R-030_held_lot_order.rq | 체인 | `inf:hasHeldLot` — 보류 LOT이 걸린 생산지시 | Q-SC05-06, Q-SC02-04 |
| R-100_otd_risk.rq | 업무 규칙 | `inf:OTDRiskEvent` — 불량률·납기 기준 수주라인 납기 리스크(원인 생산실적·생산지시) | Q-SC02-04 |

- 파라미터(`${name}`)는 `params.yaml`에서 채웁니다(현업 조정 대상). `today`(기준일)는 실행 계획(`s7_plan.yaml`)이 정하고, `due_limit` = 기준일 + `due_within_days`는 실행기가 계산합니다.
- 모든 규칙은 `ksxq:violates` 표식이 있는 개체를 제외합니다(S6).
- 실행: `ksxkg infer`(Fuseki, 결과는 `graph/inferred/{기업}/{사업장}/{규칙 ID}`를 통째로 교체, 기록은 `audit.rule_run`). 시험용 로컬 실행은 `services/rule-runner/runner.py --local`.
- 정확도 평가: `ksxkg infer --eval` — 계획의 정답 사례(S1 업무 질의서 답)와 비교해 정밀도·재현율.
