-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformance.yaml
-- ProductionPerformance ← mes.tb_trk_out (N→1(완공+착공+LOT+검사))
-- 정제 규칙: R09(Q005 nullify_orphan), R07(Q009 correct), R08(Q010 flag)
with kept as (
    select m.* from {{ ref('ProductionPerformance__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."ProductionPerformanceID" as "ProductionPerformanceID",
    m."ProductionPerformanceSequence" as "ProductionPerformanceSequence",
    m."LotID" as "LotID",
    m."OperationID" as "OperationID",
    m."ItemID" as "ItemID",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderID" end as "ProductionOrderID",
    case when (m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")) then null else m."ProductionOrderSequence" end as "ProductionOrderSequence",
    m."ExecutionStartDateTime" as "ExecutionStartDateTime",
    m."ExecutionEndDateTime" as "ExecutionEndDateTime",
    m."ProductionPerformanceDate" as "ProductionPerformanceDate",
    m."PersonnelID" as "PersonnelID",
    case when coalesce((m."ProducedQuantity" + m."DefectQuantity" <> (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false) then (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID") - m."DefectQuantity" else m."ProducedQuantity" end as "ProducedQuantity",
    m."DefectQuantity" as "DefectQuantity",
    m."InspectionResult" as "InspectionResult",
    m."InspectionQuantity" as "InspectionQuantity",
    m."_src__InspectionResult" as "_src__InspectionResult"
from kept m
