-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ProductIncoming.yaml
-- ProductIncoming ← erp.tb_pp_rcpt (1:1)
-- 정제 규칙: R03(Q003 nullify_orphan)
with kept as (
    select m.* from {{ ref('ProductIncoming__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."ProductIncomingID" as "ProductIncomingID",
    m."ProductIncomingSequence" as "ProductIncomingSequence",
    m."InventoryTransactionDate" as "InventoryTransactionDate",
    m."ItemUnitQuantity" as "ItemUnitQuantity",
    m."WarehouseID" as "WarehouseID",
    m."InventoryTransactionTypeCode" as "InventoryTransactionTypeCode",
    m."ItemID" as "ItemID",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderID" end as "ProductionOrderID",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderSequence" end as "ProductionOrderSequence"
from kept m
