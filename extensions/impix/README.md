# IMPIX 기업 확장(Extension)

S1 원천 분석에서 찾은 공백을 S2 판정(구현안내서 5.6)으로 정리한 확장 정의서입니다. 생성물은 `ontologies/`의 `*impix*` 파일입니다.

| 구분 | 내용 |
|---|---|
| 확장 명사 5 | StandardCost(표준원가), CustomerComplaint(고객클레임), QualityCost(품질비용), InventorySnapshot(일별재고), LotInventory(로트별재고) |
| 확장 속성 8 | SalesPlan, SalesOrderLine, AvailableInventory, ProductionPerformance, SupplierInspectionResult, CorrectiveActionRequest, Equipment(후보), EquipmentState(후보) |
| 확장 코드 | 신규 그룹 7(SalesPlanType, CustomerComplaintType, CustomerComplaintStatusCode, QualityCostClass, QualityCostItem, DetectionLocationType, EquipmentIdleReasonCode), 표준 그룹 하위 확장 1(DefectTypeDetailCode: MAT-POR 기공, MAT-SHT 미성형, ASSY-SLD 납땜 불량) — 코드 33 |
| 판정 기록 | 28건(확장 외 표준 매핑·코드 대응·S3 처리·제외 포함) |
| 온톨로지 | 속성 74(표준 공유 재사용 38, 신규 `impix:` 36), 관계 47, 클래스 5 |

S1에서 Extension 후보로 적었던 항목 중 표준으로 해결되는 것은 판정목록에 '코드 대응'으로 남겼습니다.
- 수입검사 판정(A/R/S)은 표준 `InspectionResult`(PASS/FAIL/CONDITIONAL)에 대응합니다.
- 설비 상태 1~6은 표준 `EquipmentState` 코드에 대응합니다.
- 고객 불량코드(C-*)는 표준 `DefectTypeDetailCode`에 대응합니다.
