-- Apache AGE 속성 그래프 스키마(ksxgen 생성물, 구현안내서 11.1) — 노드 라벨 81 · 관계 라벨 70
-- 노드 = 명사 개체(키: iri), 관계 = 객체 관계(ref*·hasLine·lineOf). 코드·단위는 노드 속성으로 둔다.
-- 다시 실행해도 된다(있으면 건너뜀). 이 세션에서만 AGE를 쓴다.
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = 'ksx_graph') THEN
    PERFORM ag_catalog.create_graph('ksx_graph');
  END IF;
END $$;

-- 노드 라벨(명사·라인 구조체·확장 명사)과 관계 라벨(객체 관계) — 없는 것만 만든다
DO $$
DECLARE x text;
BEGIN
  FOREACH x IN ARRAY ARRAY['Site', 'Plant', 'Department', 'Personnel', 'CustomerPartyMaster', 'VendorPartyMaster', 'CommonCodeMaster', 'WorkCalendar', 'UOMGroup', 'UOMGroupLine', 'ItemMaster', 'BOM', 'BOMLine', 'Lot', 'Routing', 'RoutingLine', 'Operation', 'Equipment', 'OperationEquipment', 'Carrier', 'StockerInventory', 'WarehouseLocation', 'WarehouseLocationLine', 'Batch', 'Line', 'Enterprise', 'ProjectMaster', 'EngineeringChangeOrder', 'SalesOrder', 'SalesOrderLine', 'SalesPlan', 'BasePrice', 'PurchaseRequisition', 'PurchaseOrder', 'PurchaseOrderLine', 'MaterialArrival', 'GoodsReceipt', 'GoodsIssue', 'ProductionPlanning', 'ProductionOrder', 'OperationStart', 'OperationEnd', 'TransferCommand', 'TransferStart', 'TransferEnd', 'InTransitLocation', 'EquipmentState', 'Alarm', 'SupplierInspectionPlan', 'SupplierInspectionApplication', 'SupplierInspectionResult', 'CorrectiveActionRequest', 'CorrectiveActionPlan', 'CorrectiveActionResult', 'ProductPacking', 'EquipmentParameter', 'TraceParameter', 'ProductionPerformance', 'ProductionPerformanceItem', 'ProductionPerformancePersonnel', 'ProductionPerformanceEquipment', 'ProductionPerformanceQuality', 'Inventory', 'AvailableInventory', 'StockTransfer', 'InventoryCount', 'ProductIncoming', 'ProductReleaseRequest', 'ProductReleaseRequestLine', 'ProductRelease', 'Delivery', 'DeliveryLine', 'Return', 'ProductTraceParameterOnCustomer', 'AfterSalesServiceRequest', 'AfterSalesServiceRequestResult', 'StandardCost', 'CustomerComplaint', 'QualityCost', 'InventorySnapshot', 'LotInventory'] LOOP
    IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph g ON l.graph = g.graphid
                   WHERE g.name = 'ksx_graph' AND l.name = x) THEN PERFORM ag_catalog.create_vlabel('ksx_graph', x); END IF;
  END LOOP;
  FOREACH x IN ARRAY ARRAY['refEnterprise', 'refCreator', 'refModifier', 'refSite', 'refPlant', 'refParentDepartment', 'refDepartment', 'refCommonCodeMaster', 'hasLine', 'lineOf', 'refMainCustomer', 'refMainVendor', 'refReceiptWarehouse', 'refIssueWarehouse', 'refReplacementItem', 'refItem', 'refRouting', 'refChildItem', 'refParentLot', 'refChildLot', 'refCarrier', 'refProductionOrder', 'refCurrentOperation', 'refNextOperation', 'refPersonnel', 'refOperation', 'refParentEquipment', 'refDepartmentInCharge', 'refPersonInCharge', 'refEquipment', 'refLot', 'refAlternateStocker', 'refParentBatch', 'refBOM', 'refParentLine', 'refCalendar', 'refParentEnterprise', 'refResponsibleDepartment', 'refSalesOrderLine', 'refDivision', 'refCustomer', 'refVendor', 'refRequesterDepartment', 'refRequesterPersonnel', 'refPurchaseOrderLine', 'refWarehouse', 'refLine', 'refTransferCommand', 'refLastProcessedLot', 'refLastProcessedOperation', 'refProject', 'refBatch', 'refInspectionPlan', 'refApplicationPersonnel', 'refInspectionApplication', 'refCorrectiveActionRequestIssuer', 'refCorrectiveActionRequest', 'refCorrectiveActionPlan', 'refCorrectiveActionConfirmor', 'refParameter', 'refRoutingToRoutingLine', 'refProductionPerformance', 'refReplacementChildItem', 'refWarehouseToWarehouseLocationLine', 'refProductReleaseRequest', 'refProductRelease', 'refAfterSalesServiceRequest', 'refCauseOperation', 'refGoodsReceipt', 'refInspectionResult'] LOOP
    IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph g ON l.graph = g.graphid
                   WHERE g.name = 'ksx_graph' AND l.name = x) THEN PERFORM ag_catalog.create_elabel('ksx_graph', x); END IF;
  END LOOP;
END $$;

-- 노드 속성 인덱스(iri·식별 속성 조회)
CREATE INDEX IF NOT EXISTS "ix_Site_props" ON ksx_graph."Site" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Plant_props" ON ksx_graph."Plant" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Department_props" ON ksx_graph."Department" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Personnel_props" ON ksx_graph."Personnel" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CustomerPartyMaster_props" ON ksx_graph."CustomerPartyMaster" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_VendorPartyMaster_props" ON ksx_graph."VendorPartyMaster" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CommonCodeMaster_props" ON ksx_graph."CommonCodeMaster" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_WorkCalendar_props" ON ksx_graph."WorkCalendar" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_UOMGroup_props" ON ksx_graph."UOMGroup" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_UOMGroupLine_props" ON ksx_graph."UOMGroupLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ItemMaster_props" ON ksx_graph."ItemMaster" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_BOM_props" ON ksx_graph."BOM" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_BOMLine_props" ON ksx_graph."BOMLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Lot_props" ON ksx_graph."Lot" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Routing_props" ON ksx_graph."Routing" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_RoutingLine_props" ON ksx_graph."RoutingLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Operation_props" ON ksx_graph."Operation" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Equipment_props" ON ksx_graph."Equipment" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_OperationEquipment_props" ON ksx_graph."OperationEquipment" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Carrier_props" ON ksx_graph."Carrier" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_StockerInventory_props" ON ksx_graph."StockerInventory" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_WarehouseLocation_props" ON ksx_graph."WarehouseLocation" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_WarehouseLocationLine_props" ON ksx_graph."WarehouseLocationLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Batch_props" ON ksx_graph."Batch" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Line_props" ON ksx_graph."Line" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Enterprise_props" ON ksx_graph."Enterprise" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProjectMaster_props" ON ksx_graph."ProjectMaster" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_EngineeringChangeOrder_props" ON ksx_graph."EngineeringChangeOrder" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SalesOrder_props" ON ksx_graph."SalesOrder" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SalesOrderLine_props" ON ksx_graph."SalesOrderLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SalesPlan_props" ON ksx_graph."SalesPlan" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_BasePrice_props" ON ksx_graph."BasePrice" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_PurchaseRequisition_props" ON ksx_graph."PurchaseRequisition" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_PurchaseOrder_props" ON ksx_graph."PurchaseOrder" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_PurchaseOrderLine_props" ON ksx_graph."PurchaseOrderLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_MaterialArrival_props" ON ksx_graph."MaterialArrival" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_GoodsReceipt_props" ON ksx_graph."GoodsReceipt" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_GoodsIssue_props" ON ksx_graph."GoodsIssue" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPlanning_props" ON ksx_graph."ProductionPlanning" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionOrder_props" ON ksx_graph."ProductionOrder" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_OperationStart_props" ON ksx_graph."OperationStart" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_OperationEnd_props" ON ksx_graph."OperationEnd" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_TransferCommand_props" ON ksx_graph."TransferCommand" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_TransferStart_props" ON ksx_graph."TransferStart" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_TransferEnd_props" ON ksx_graph."TransferEnd" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_InTransitLocation_props" ON ksx_graph."InTransitLocation" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_EquipmentState_props" ON ksx_graph."EquipmentState" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Alarm_props" ON ksx_graph."Alarm" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SupplierInspectionPlan_props" ON ksx_graph."SupplierInspectionPlan" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SupplierInspectionApplication_props" ON ksx_graph."SupplierInspectionApplication" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_SupplierInspectionResult_props" ON ksx_graph."SupplierInspectionResult" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CorrectiveActionRequest_props" ON ksx_graph."CorrectiveActionRequest" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CorrectiveActionPlan_props" ON ksx_graph."CorrectiveActionPlan" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CorrectiveActionResult_props" ON ksx_graph."CorrectiveActionResult" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductPacking_props" ON ksx_graph."ProductPacking" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_EquipmentParameter_props" ON ksx_graph."EquipmentParameter" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_TraceParameter_props" ON ksx_graph."TraceParameter" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPerformance_props" ON ksx_graph."ProductionPerformance" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPerformanceItem_props" ON ksx_graph."ProductionPerformanceItem" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPerformancePersonnel_props" ON ksx_graph."ProductionPerformancePersonnel" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPerformanceEquipment_props" ON ksx_graph."ProductionPerformanceEquipment" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductionPerformanceQuality_props" ON ksx_graph."ProductionPerformanceQuality" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Inventory_props" ON ksx_graph."Inventory" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_AvailableInventory_props" ON ksx_graph."AvailableInventory" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_StockTransfer_props" ON ksx_graph."StockTransfer" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_InventoryCount_props" ON ksx_graph."InventoryCount" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductIncoming_props" ON ksx_graph."ProductIncoming" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductReleaseRequest_props" ON ksx_graph."ProductReleaseRequest" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductReleaseRequestLine_props" ON ksx_graph."ProductReleaseRequestLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductRelease_props" ON ksx_graph."ProductRelease" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Delivery_props" ON ksx_graph."Delivery" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_DeliveryLine_props" ON ksx_graph."DeliveryLine" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_Return_props" ON ksx_graph."Return" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_ProductTraceParameterOnCustomer_props" ON ksx_graph."ProductTraceParameterOnCustomer" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_AfterSalesServiceRequest_props" ON ksx_graph."AfterSalesServiceRequest" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_AfterSalesServiceRequestResult_props" ON ksx_graph."AfterSalesServiceRequestResult" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_StandardCost_props" ON ksx_graph."StandardCost" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_CustomerComplaint_props" ON ksx_graph."CustomerComplaint" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_QualityCost_props" ON ksx_graph."QualityCost" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_InventorySnapshot_props" ON ksx_graph."InventorySnapshot" USING gin (properties);
CREATE INDEX IF NOT EXISTS "ix_LotInventory_props" ON ksx_graph."LotInventory" USING gin (properties);
