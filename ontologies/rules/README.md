# 추론 규칙 (S7, 구현안내서 10장)

`A-*.rq`는 ksxgen이 만드는 자동 전이 규칙(자기 참조 관계의 닫힘, `inf:{관계}Closure`)이고, `R-*.rq`는 사람이 작성하는 업무 규칙입니다. 파일명 순서대로 실행되며, 앞 규칙의 결과를 뒤 규칙이 쓸 수 있습니다(실행 중 추론 그래프가 합집합에 들어감).

## 규칙 ID 체계

파일명은 `{ID}_{영문 소문자 이름}.rq`(예: `R-020_specout_lot.rq`)이고, 실행 순서는 파일명 순서다(A → R, 번호 오름차순). 뒤 규칙은 앞 규칙의 결과를 쓸 수 있으므로, 결과를 쓰는 규칙이 더 큰 번호를 갖는다.

| 범위 | 구분 | 작성 | 결과 이름 | 예(IMPIX) |
|---|---|---|---|---|
| A-001~A-999 | 자동 전이(자기 참조 관계의 닫힘) | ksxgen 생성 — 직접 고치지 않는다 | `inf:{관계}Closure` | A-001 상위 부서 |
| R-001~R-009 | 구조·계보 전개(체인·전이): LOT 계보, BOM, LOT 공정 설비 | 작성 | `inf:` 관계(camelCase) | R-001 계보, R-002·003 BOM, R-005 설비 |
| R-010~R-019 | 영향 전개(체인): 실적·LOT → 오더·수주·고객 | 작성 | `inf:affected…` | R-010 영향 수주 |
| R-020~R-029 | 이상·품질 이벤트: 규격 이탈, 불량 집중 등 | 작성 | `inf:…Event` + `inf:ruleId` | R-020 스펙아웃 LOT |
| R-030~R-039 | 상태 기반 영향: 보류·격리·특채 등 | 작성 | `inf:` 관계 | R-030 보류 LOT 생산지시 |
| R-040~R-099 | 예비(같은 원칙으로 범위를 정해 쓴다) | — | — | — |
| R-100~R-199 | 업무 판단·리스크 이벤트 — 임계값 파라미터(`params.yaml`)를 현업이 조정 | 작성 | `inf:…RiskEvent` + `inf:ruleId` | R-100 납기 리스크 |
| R-200~R-299 | (예약) KPI·집계 파생 | — | — | — |

- ID는 한 번 쓰면 다시 쓰지 않는다. 규칙을 없애도 번호는 비워 둔다(이전 실행 기록 `audit.rule_run`과 AI 답변 근거가 ID로 남는다).
- 규칙을 고치면 ID는 그대로이고 버전(파일 해시)이 바뀐다 — `audit.rule_run.version`.
- 새 규칙에는 평가 사례(`mapping/<기업>/s7_plan.yaml` evaluate.cases)를 함께 추가한다(S7 D-2).
- 이벤트 규칙은 이벤트 노드에 `inf:ruleId`를 단다.

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
