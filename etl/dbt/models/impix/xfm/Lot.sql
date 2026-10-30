-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Lot.yaml
-- Lot ← mes.tb_lot (1:1)
-- 정제 규칙: R04(Q005 nullify_orphan)
with kept as (
    select m.* from {{ ref('Lot__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."LotID" as "LotID",
    m."LotType" as "LotType",
    m."LotState" as "LotState",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderID" end as "ProductionOrderID",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderSequence" end as "ProductionOrderSequence",
    m."ProducedQuantity" as "ProducedQuantity",
    m."CurrentOperationID" as "CurrentOperationID",
    m."LotPriority" as "LotPriority",
    m."CreatorID" as "CreatorID",
    m."ItemID" as "ItemID",
    m."LotCreatedQuantity" as "LotCreatedQuantity",
    m."DefectQuantity" as "DefectQuantity",
    m."NextOperationID" as "NextOperationID",
    m."HoldIndicator" as "HoldIndicator",
    m."HotIndicator" as "HotIndicator",
    m."ReworkCount" as "ReworkCount",
    m."ScheduledDueDate" as "ScheduledDueDate",
    m."CreationDateTime" as "CreationDateTime",
    m."ModificationDateTime" as "ModificationDateTime",
    m."LotOriginType" as "LotOriginType",
    m."_src__LotType" as "_src__LotType",
    m."_src__LotState" as "_src__LotState"
from kept m
