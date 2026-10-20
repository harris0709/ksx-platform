-- 추론 규칙 시험용 트랜잭션: 수주 1(라인 1) → 생산지시 1 → 생산실적 1(불량률 3%)
BEGIN;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO ksx."SalesOrderHeader" ("EnterpriseID", "SiteID", "PlantID", "SalesDocumentNumber", "SalesDate")
  VALUES ('ACME', 'HQ', 'P1', 'SO-0412', '2026-10-01');
INSERT INTO ksx."SalesOrderLine" ("EnterpriseID", "SiteID", "PlantID", "SalesDocumentNumber", "SalesDocumentSequence", "ItemID", "ItemQuantity", "RequestedDeliveryDate")
  VALUES ('ACME', 'HQ', 'P1', 'SO-0412', 1, 'ITM-A100', 1000, '2026-10-24');
INSERT INTO ksx."ProductionOrder" ("EnterpriseID", "SiteID", "PlantID", "ProductionOrderID", "ProductionOrderSequence", "ItemID", "SalesDocumentNumber", "SalesDocumentSequence", "ProductionOrderQuantity")
  VALUES ('ACME', 'HQ', 'P1', 'PO-1001', 1, 'ITM-A100', 'SO-0412', 1, 1000);
UPDATE ksx."Lot" SET "ProductionOrderID" = 'PO-1001', "ProductionOrderSequence" = 1;
INSERT INTO ksx."ProductionPerformance" ("EnterpriseID", "SiteID", "PlantID", "ProductionPerformanceID", "ProductionPerformanceSequence", "ProductionOrderID", "ProductionOrderSequence", "ItemID", "LotID", "ProducedQuantity", "DefectQuantity", "ProductionPerformanceDate")
  VALUES ('ACME', 'HQ', 'P1', 'PP-5001', 1, 'PO-1001', 1, 'ITM-A100', 'LOT-0731', 1000, 30, '2026-10-19');
COMMIT;
