# ksxgen 커버리지 리포트

| 항목 | 표준·정의서 | 생성 | 결과 |
|---|---|---|---|
| 명사 | 68 | 68 | OK |
| 라인 구조체 | 8 | 8 | OK |
| 클래스 | 76 | 76 | OK |
| 속성(PK 제외 컬럼) | 1534 | 1534 | OK |
| 물리 FK → 관계 | 609 | 609 | OK |
| 논리 관계(주석·도구 처리) | 59 | — | 참고 |
| 공통코드 그룹 / 코드 / 단위 | 79 / 568 / 47 | 동일 | OK |

## 정의 충돌

- 없음

## 논리 관계(물리 FK 아님)

| 자식 | 컬럼 | 부모 | 구분 |
|---|---|---|---|
| OperationEquipment | OperationName | Operation | 사본 참조 |
| OperationEquipment | EquipmentName | Equipment | 사본 참조 |
| SalesOrderLine | ItemName | ItemMaster | 사본 참조 |
| SalesPlan | ItemName | ItemMaster | 사본 참조 |
| PurchaseRequisition | ItemName | ItemMaster | 사본 참조 |
| PurchaseRequisition | VendorName | VendorPartyMaster | 사본 참조 |
| PurchaseOrderLine | ItemName | ItemMaster | 사본 참조 |
| PurchaseOrderLine | IncomingInspectionIndicator | ItemMaster | 사본 참조 |
| GoodsReceipt | ItemName | ItemMaster | 사본 참조 |
| GoodsReceipt | IncomingInspectionIndicator | ItemMaster | 사본 참조 |
| OperationStart | LotName | Lot | 사본 참조 |
| OperationStart | LotDescription | Lot | 사본 참조 |
| OperationStart | LotCreatedQuantity | Lot | 사본 참조 |
| OperationEnd | LotName | Lot | 사본 참조 |
| OperationEnd | LotDescription | Lot | 사본 참조 |
| OperationEnd | LotCreatedQuantity | Lot | 사본 참조 |
| TransferCommand | LotName | Lot | 사본 참조 |
| TransferCommand | LotDescription | Lot | 사본 참조 |
| TransferCommand | SourceID | Operation / Equipment / StockerInventory / Carrier | 다형 참조 |
| TransferCommand | DestinationID | Operation / Equipment / StockerInventory / Carrier | 다형 참조 |
| TransferStart | LotName | Lot | 사본 참조 |
| TransferStart | LotDescription | Lot | 사본 참조 |
| TransferStart | DestinationID | Operation / Equipment / StockerInventory / Carrier | 다형 참조 |
| TransferStart | DestinationName | TransferCommand | 사본 참조 |
| TransferEnd | LotName | Lot | 사본 참조 |
| TransferEnd | LotDescription | Lot | 사본 참조 |
| TransferEnd | DestinationID | Operation / Equipment / StockerInventory / Carrier | 다형 참조 |
| TransferEnd | DestinationName | TransferCommand | 사본 참조 |
| InTransitLocation | LotName | Lot | 사본 참조 |
| InTransitLocation | LotDescription | Lot | 사본 참조 |
| SupplierInspectionPlan | ItemName | ItemMaster | 사본 참조 |
| SupplierInspectionPlan | PurchaseOrderQuantity | PurchaseOrderLine | 사본 참조 |
| SupplierInspectionPlan | ExpectedDeliveryDate | PurchaseOrderLine | 사본 참조 |
| SupplierInspectionApplication | ItemName | ItemMaster | 사본 참조 |
| SupplierInspectionApplication | InspectionName | SupplierInspectionPlan | 사본 참조 |
| SupplierInspectionApplication | InspectionLocation | SupplierInspectionPlan | 사본 참조 |
| SupplierInspectionApplication | ExpectedInspectionDate | SupplierInspectionPlan | 사본 참조 |
| SupplierInspectionResult | ItemName | ItemMaster | 사본 참조 |
| SupplierInspectionResult | InspectionLocation | SupplierInspectionApplication | 사본 참조 |
| SupplierInspectionResult | InspectionQuantity | SupplierInspectionApplication | 사본 참조 |
| CorrectiveActionRequest | ItemName | ItemMaster | 사본 참조 |
| CorrectiveActionPlan | ItemName | ItemMaster | 사본 참조 |
| CorrectiveActionResult | ItemName | ItemMaster | 사본 참조 |
| AvailableInventory | ItemName | ItemMaster | 사본 참조 |
| ProductIncoming | LotControlIndicator | ItemMaster | 사본 참조 |
| ProductReleaseRequestLine | ItemName | ItemMaster | 사본 참조 |
| ProductRelease | ItemName | ItemMaster | 사본 참조 |
| DeliveryHeader | DepartmentInChargeName | Department | 사본 참조 |
| DeliveryHeader | PersonInChargeName | Personnel | 사본 참조 |
| DeliveryHeader | PersonInChargeDialNumber | Personnel | 사본 참조 |
| DeliveryLine | ItemName | ItemMaster | 사본 참조 |
| DeliveryLine | RequestedDeliveryDate | SalesOrderLine | 사본 참조 |
| ProductTraceParameterOnCustomer | SerialNumber | 고객 설치 제품(제조번호 단위) | 표준 외 대상 |
| AfterSalesServiceRequest | ItemName | ItemMaster | 사본 참조 |
| AfterSalesServiceRequest | SerialNumber | 고객 설치 제품(제조번호 단위) | 표준 외 대상 |
| AfterSalesServiceRequestResult | ItemName | ItemMaster | 사본 참조 |
| AfterSalesServiceRequestResult | SerialNumber | 고객 설치 제품(제조번호 단위) | 표준 외 대상 |
| AfterSalesServiceRequestResult | ItemSpecification | ItemMaster | 사본 참조 |
| BOMLine | OperationSequence | RoutingLine | 헤더 경유 참조 |
