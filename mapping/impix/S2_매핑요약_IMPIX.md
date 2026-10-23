# S2 표준 매핑 요약 — IMPIX

| 항목 | 값 |
|---|---|
| 매핑 명세 / 대상 명사 | 55 / 54 |
| 매핑 속성(컬럼 1개) / 파생(여러 컬럼) | 416 / 12 |
| 결정론 해소율 | 71.9% (목표 70% 이상) |
| 검토자 수정 비율 | 2.0% (목표 20% 미만) |
| 필수 속성 매핑 | 100.0% (259/259) |
| 대상 컬럼 판정 | 100.0% (452/452) |
| 판정 분포 | 매핑 319, 미판정 0, 식별 대응 9, 제외 40, 조인 원천 4, 조인 키 7, 코드 원천 16, 확장 57 |
| 검사 오류 | 0 |

## 명세

| 명사 | 원천 | 구조 | 매핑 | 필수 누락 |
|---|---|---|---|---|
| Enterprise | erp.tb_cm_comp | 1:1 | 13 | — |
| Site | erp.tb_cm_bizarea | 1:1 | 7 | — |
| Plant | erp.tb_cm_plant | 1:1 | 6 | — |
| Department | erp.tb_cm_dept | 1:1 | 6 | — |
| Personnel | erp.tb_hr_emp | 1:1 | 9 | — |
| ItemMaster | erp.tb_mm_item | 1:1 | 24 | — |
| BOMHeader | erp.tb_pp_bom_h | 1:1 | 10 | — |
| BOMLine | erp.tb_pp_bom_d | 1:1(헤더 참조) | 13 | — |
| RoutingHeader | erp.tb_pp_rout_h | 1:1 | 7 | — |
| RoutingLine | erp.tb_pp_rout_d | 1:1(헤더 참조) | 10 | — |
| Operation | mes.tm_proc | N→1(MES 공정 + ERP 작업장) | 7 | — |
| Line | erp.tb_pp_line | 1:1 | 10 | — |
| WarehouseLocationHeader | erp.tb_mm_wh | 1:1 | 7 | — |
| Equipment | mes.tm_eqp | 1:1 | 15 | — |
| OperationEquipment | mes.tm_eqp | 파생(설비→공정 배정) | 6 | — |
| CustomerPartyMaster | erp.tb_sd_cust | 1:1 | 11 | — |
| VendorPartyMaster | erp.tb_mm_vend | 1:1 | 9 | — |
| BasePrice | erp.tb_mm_price | 1:1 | 6 | — |
| StandardCost | erp.tb_co_std_cost | 1:1 | 12 | — |
| EquipmentParameter | mes.tm_param | 1:1 | 15 | — |
| SalesPlan | erp.tb_sd_plan | 1:1 | 10 | — |
| SalesOrderHeader | erp.tb_sd_so_h | 1:1 | 9 | — |
| SalesOrderLine | erp.tb_sd_so_d | 1:1 | 11 | — |
| ProductRelease | erp.tb_sd_dlv | 1:1 | 14 | — |
| DeliveryHeader | erp.tb_sd_dlv | 1→헤더·라인(헤더) | 6 | — |
| DeliveryLine | erp.tb_sd_dlv | 1→헤더·라인(라인) | 12 | — |
| PurchaseOrderHeader | erp.tb_mm_po_h | 1:1 | 8 | — |
| PurchaseOrderLine | erp.tb_mm_po_d | 1:1 | 11 | — |
| GoodsReceipt | erp.tb_mm_gr | 1:1 | 16 | — |
| GoodsIssue | erp.tb_mm_gi | 1:1 | 12 | — |
| ProductionPlanning | erp.tb_pp_plan | 1:1 | 7 | — |
| ProductionOrder | erp.tb_pp_mo | 1:1 | 19 | — |
| ProductIncoming | erp.tb_pp_rcpt | 1:1 | 12 | — |
| AvailableInventory | erp.tb_pp_mat_chk | 1:1 | 11 | — |
| Inventory | erp.tb_mm_stock_day | 이력→현재(마지막 기준일) | 6 | — |
| InventorySnapshot | erp.tb_mm_stock_day | 1:1 | 7 | — |
| LotInventory | erp.tb_mm_stock_lot | 1:1 | 8 | — |
| InventoryCount | erp.tb_mm_cnt | 1:1 | 9 | — |
| Lot | mes.tb_lot | 1:1 | 22 | — |
| OperationStart | mes.tb_trk_in | 이력→이벤트 | 10 | — |
| OperationEnd | mes.tb_trk_out | 이력→이벤트 | 11 | — |
| ProductionPerformance | mes.tb_trk_out | N→1(완공+착공+LOT+검사) | 18 | — |
| ProductionPerformanceEquipment | mes.tb_trk_out | 1:1(생산실적 설비) | 13 | — |
| ProductionPerformanceQuality | mes.tb_qc_defect | N→1(검사+불량) | 12 | — |
| ProductionPerformanceItem | mes.tb_lot_link | 1:1(LOT 소비 → 투입품목) | 11 | — |
| EquipmentState | mes.tb_eqp_stat | 이력(구간)→이벤트 | 13 | — |
| Alarm | mes.tb_alarm | 이력(발생·해제)→이벤트 2행 | 10 | — |
| TraceParameter | mes.tb_param_val | 이력→이벤트 | 11 | — |
| CustomerComplaint | qms.qm_claim | 1:1 | 21 | — |
| Return | qms.qm_claim | 1:1(필드 반송분) | 11 | — |
| SupplierInspectionResult | qms.qm_iqc | 1:1 | 16 | — |
| CorrectiveActionRequest | qms.qm_vend_ncr | 1:1 | 13 | — |
| CorrectiveActionResult | qms.qm_vend_ncr | 1:1 | 9 | — |
| GoodsIssue | qms.qm_scrap | 1:1(폐기 출고) | 9 | — |
| QualityCost | qms.qm_qcost | 1:1 | 11 | — |

## 검사

- 경고 · 단위 N·m: 표준 단위코드 N.m 없음 — 확장 단위 후보(단위그룹 확장)
- 경고 · 단위 cc/min: 표준 단위코드 cm3/min 없음 — 확장 단위 후보(단위그룹 확장)
