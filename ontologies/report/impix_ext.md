# IMPIX 기업 확장 생성 리포트 (ksxgen)

| 항목 | 값 |
|---|---|
| 확장 명사(클래스) | 5 — StandardCost, CustomerComplaint, QualityCost, InventorySnapshot, LotInventory |
| 확장 속성 테이블(대상 Core 명사) | 17 — SalesPlan, SalesOrderLine, AvailableInventory, ProductionPerformance, SupplierInspectionResult, CorrectiveActionRequest, Equipment, EquipmentState, ProductionOrder, Alarm, CustomerPartyMaster, GoodsReceipt, GoodsIssue, ProductIncoming, TraceParameter, EquipmentParameter, Lot |
| 확장 컬럼 | 95 |
| 속성: 표준 공유 재사용 / 신규 | 45 / 47 |
| 관계(물리 FK) | 63 |
| 확장 코드 그룹 / 코드 | 15 / 52 |
| 판정 기록 | 46 |
| 오류 / 경고 | 0 / 0 |

## 속성 대응(확장 컬럼 → 온톨로지 속성)

| 테이블 | 컬럼 | 속성 | 구분 |
|---|---|---|---|
| StandardCost | StandardCostID | `impix:standardCostID` | 신규 |
| StandardCost | ItemID | `ksx:itemID` | 표준 재사용 |
| StandardCost | OperationID | `ksx:operationID` | 표준 재사용 |
| StandardCost | CostPeriodStartDate | `impix:costPeriodStartDate` | 신규 |
| StandardCost | CostPeriodEndDate | `impix:costPeriodEndDate` | 신규 |
| StandardCost | StandardCostAmount | `impix:standardCostAmount` | 신규 |
| StandardCost | MaterialCostAmount | `impix:materialCostAmount` | 신규 |
| StandardCost | LaborCostAmount | `impix:laborCostAmount` | 신규 |
| StandardCost | OverheadCostAmount | `impix:overheadCostAmount` | 신규 |
| StandardCost | CurrencyCode | `ksx:currencyCode` | 표준 재사용 |
| StandardCost | ItemUOMCode | `ksx:itemUOMCode` | 표준 재사용 |
| CustomerComplaint | CustomerComplaintID | `impix:customerComplaintID` | 신규 |
| CustomerComplaint | CustomerID | `ksx:customerID` | 표준 재사용 |
| CustomerComplaint | ItemID | `ksx:itemID` | 표준 재사용 |
| CustomerComplaint | LotID | `ksx:lotID` | 표준 재사용 |
| CustomerComplaint | CustomerComplaintType | `impix:customerComplaintType` | 신규 |
| CustomerComplaint | OccurrenceDate | `impix:occurrenceDate` | 신규 |
| CustomerComplaint | ComplaintReceiptDate | `impix:complaintReceiptDate` | 신규 |
| CustomerComplaint | DefectTypeCode | `ksx:defectTypeCode` | 표준 재사용 |
| CustomerComplaint | DefectTypeDetailCode | `ksx:defectTypeDetailCode` | 표준 재사용 |
| CustomerComplaint | ComplaintQuantity | `impix:complaintQuantity` | 신규 |
| CustomerComplaint | ItemUOMCode | `ksx:itemUOMCode` | 표준 재사용 |
| CustomerComplaint | ResponseDueDate | `impix:responseDueDate` | 신규 |
| CustomerComplaint | ResponseDate | `impix:responseDate` | 신규 |
| CustomerComplaint | CloseDate | `impix:closeDate` | 신규 |
| CustomerComplaint | CustomerComplaintStatusCode | `impix:customerComplaintStatusCode` | 신규 |
| CustomerComplaint | ComplaintAmount | `impix:complaintAmount` | 신규 |
| CustomerComplaint | CurrencyCode | `ksx:currencyCode` | 표준 재사용 |
| CustomerComplaint | CauseOperationID | `impix:causeOperationID` | 신규 |
| CustomerComplaint | ComplaintDescription | `impix:complaintDescription` | 신규 |
| QualityCost | QualityCostID | `impix:qualityCostID` | 신규 |
| QualityCost | CostPeriodStartDate | `impix:costPeriodStartDate` | 신규 |
| QualityCost | CostPeriodEndDate | `impix:costPeriodEndDate` | 신규 |
| QualityCost | QualityCostClass | `impix:qualityCostClass` | 신규 |
| QualityCost | QualityCostItem | `impix:qualityCostItem` | 신규 |
| QualityCost | QualityCostAmount | `impix:qualityCostAmount` | 신규 |
| QualityCost | CurrencyCode | `ksx:currencyCode` | 표준 재사용 |
| QualityCost | SourceDocumentReference | `impix:sourceDocumentReference` | 신규 |
| InventorySnapshot | InventorySnapshotDate | `impix:inventorySnapshotDate` | 신규 |
| InventorySnapshot | WarehouseID | `ksx:warehouseID` | 표준 재사용 |
| InventorySnapshot | ItemID | `ksx:itemID` | 표준 재사용 |
| InventorySnapshot | InventoryQuantity | `ksx:inventoryQuantity` | 표준 재사용 |
| InventorySnapshot | ItemUOMCode | `ksx:itemUOMCode` | 표준 재사용 |
| LotInventory | WarehouseID | `ksx:warehouseID` | 표준 재사용 |
| LotInventory | ItemID | `ksx:itemID` | 표준 재사용 |
| LotInventory | LotID | `ksx:lotID` | 표준 재사용 |
| LotInventory | GoodsReceiptDate | `ksx:goodsReceiptDate` | 표준 재사용 |
| LotInventory | InventoryQuantity | `ksx:inventoryQuantity` | 표준 재사용 |
| LotInventory | ItemUOMCode | `ksx:itemUOMCode` | 표준 재사용 |
| SalesPlanExt | SalesPlanType | `impix:salesPlanType` | 신규 |
| SalesPlanExt | CustomerID | `ksx:customerID` | 표준 재사용 |
| SalesPlanExt | SalesPlanVersion | `impix:salesPlanVersion` | 신규 |
| SalesOrderLineExt | UnitPrice | `ksx:unitPrice` | 표준 재사용 |
| SalesOrderLineExt | CurrencyCode | `ksx:currencyCode` | 표준 재사용 |
| SalesOrderLineExt | SalesAmount | `impix:salesAmount` | 신규 |
| AvailableInventoryExt | ProductionOrderID | `ksx:productionOrderID` | 표준 재사용 |
| AvailableInventoryExt | ProductionOrderSequence | `ksx:productionOrderSequence` | 표준 재사용 |
| AvailableInventoryExt | AvailabilityCheckDateTime | `impix:availabilityCheckDateTime` | 신규 |
| AvailableInventoryExt | ShortageQuantity | `impix:shortageQuantity` | 신규 |
| AvailableInventoryExt | MaterialRequirementQuantity | `impix:materialRequirementQuantity` | 신규 |
| ProductionPerformanceExt | InspectionResult | `ksx:inspectionResult` | 표준 재사용 |
| ProductionPerformanceExt | InspectionQuantity | `ksx:inspectionQuantity` | 표준 재사용 |
| SupplierInspectionResultExt | GoodsReceiptID | `ksx:goodsReceiptID` | 표준 재사용 |
| SupplierInspectionResultExt | GoodsReceiptSequence | `ksx:goodsReceiptSequence` | 표준 재사용 |
| SupplierInspectionResultExt | DefectQuantity | `ksx:defectQuantity` | 표준 재사용 |
| SupplierInspectionResultExt | DefectTypeCode | `ksx:defectTypeCode` | 표준 재사용 |
| SupplierInspectionResultExt | DefectTypeDetailCode | `ksx:defectTypeDetailCode` | 표준 재사용 |
| CorrectiveActionRequestExt | DetectionLocationType | `impix:detectionLocationType` | 신규 |
| CorrectiveActionRequestExt | DefectQuantity | `ksx:defectQuantity` | 표준 재사용 |
| CorrectiveActionRequestExt | DefectTypeCode | `ksx:defectTypeCode` | 표준 재사용 |
| CorrectiveActionRequestExt | DefectTypeDetailCode | `ksx:defectTypeDetailCode` | 표준 재사용 |
| CorrectiveActionRequestExt | CorrectiveActionDueDate | `impix:correctiveActionDueDate` | 신규 |
| CorrectiveActionRequestExt | OccurrenceDate | `impix:occurrenceDate` | 신규 |
| CorrectiveActionRequestExt | InspectionResultID | `ksx:inspectionResultID` | 표준 재사용 |
| EquipmentExt | StandardUnitsPerMinute | `impix:standardUnitsPerMinute` | 신규 |
| EquipmentStateExt | StateStartDateTime | `impix:stateStartDateTime` | 신규 |
| EquipmentStateExt | StateEndDateTime | `impix:stateEndDateTime` | 신규 |
| EquipmentStateExt | EquipmentIdleReasonCode | `impix:equipmentIdleReasonCode` | 신규 |
| ProductionOrderExt | ProductionOrderStatusCode | `impix:productionOrderStatusCode` | 신규 |
| AlarmExt | AlarmSeverityCode | `impix:alarmSeverityCode` | 신규 |
| CustomerPartyMasterExt | CustomerGroupCode | `impix:customerGroupCode` | 신규 |
| GoodsReceiptExt | PurchaseDocumentNumber | `ksx:purchaseDocumentNumber` | 표준 재사용 |
| GoodsReceiptExt | PurchaseDocumentSequence | `ksx:purchaseDocumentSequence` | 표준 재사용 |
| GoodsReceiptExt | LotID | `ksx:lotID` | 표준 재사용 |
| GoodsIssueExt | InventoryTransactionDate | `ksx:inventoryTransactionDate` | 표준 재사용 |
| GoodsIssueExt | ProductionOrderID | `ksx:productionOrderID` | 표준 재사용 |
| GoodsIssueExt | ProductionOrderSequence | `ksx:productionOrderSequence` | 표준 재사용 |
| ProductIncomingExt | ProductionOrderID | `ksx:productionOrderID` | 표준 재사용 |
| ProductIncomingExt | ProductionOrderSequence | `ksx:productionOrderSequence` | 표준 재사용 |
| TraceParameterExt | LotID | `ksx:lotID` | 표준 재사용 |
| EquipmentParameterExt | LCL | `impix:lcl` | 신규 |
| EquipmentParameterExt | UCL | `impix:ucl` | 신규 |
| LotExt | LotOriginType | `impix:lotOriginType` | 신규 |
| LotExt | VendorID | `ksx:vendorID` | 표준 재사용 |
| LotExt | VendorLotNumber | `impix:vendorLotNumber` | 신규 |

## 검사 결과

- 오류·경고 없음
