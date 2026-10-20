-- 최소 시드 데이터: 회사 1, 사업장 1, 공장 1, 사원 1, 품목 2, 로트 2(모·자), 자재명세서 1(라인 2)
BEGIN;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO ksx."Enterprise" ("EnterpriseID", "EnterpriseName") VALUES ('ACME', '에이크미');
INSERT INTO ksx."Site" ("EnterpriseID", "SiteID", "SiteName") VALUES ('ACME', 'HQ', '본사');
INSERT INTO ksx."Plant" ("EnterpriseID", "SiteID", "PlantID", "PlantName") VALUES ('ACME', 'HQ', 'P1', '1공장');
INSERT INTO ksx."Personnel" ("EnterpriseID", "SiteID", "PlantID", "PersonnelID", "PersonnelName")
  VALUES ('ACME', 'HQ', 'P1', 'E001', '홍길동');
INSERT INTO ksx."ItemMaster" ("EnterpriseID", "SiteID", "PlantID", "ItemID", "ItemName", "CreatorID", "CreationDateTime")
  VALUES ('ACME', 'HQ', 'P1', 'ITM-A100', '제품 A', 'E001', '2026-10-01T09:00:00+09:00'),
         ('ACME', 'HQ', 'P1', 'ITM-C200', '부품 C', 'E001', '2026-10-01T09:00:00+09:00');
INSERT INTO ksx."Lot" ("EnterpriseID", "SiteID", "PlantID", "LotID", "ItemID", "LotState", "ProducedQuantity")
  VALUES ('ACME', 'HQ', 'P1', 'LOT-0712', 'ITM-A100', 'START', 1000),
         ('ACME', 'HQ', 'P1', 'LOT-0731', 'ITM-A100', 'HOLD', 980);
UPDATE ksx."Lot" SET "ParentLotID" = 'LOT-0712' WHERE "LotID" = 'LOT-0731';
INSERT INTO ksx."BOMHeader" ("EnterpriseID", "SiteID", "PlantID", "BOMID", "BOMRevisionNumber", "ItemID")
  VALUES ('ACME', 'HQ', 'P1', 'BOM-A100', 2, 'ITM-A100');
INSERT INTO ksx."BOMLine" ("EnterpriseID", "SiteID", "PlantID", "BOMID", "BOMRevisionNumber", "BOMLineSequence", "ChildItemID")
  VALUES ('ACME', 'HQ', 'P1', 'BOM-A100', 2, 10, 'ITM-C200'),
         ('ACME', 'HQ', 'P1', 'BOM-A100', 2, 20, 'ITM-C200');
COMMIT;
