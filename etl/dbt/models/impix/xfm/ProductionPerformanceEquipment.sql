-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformanceEquipment.yaml
-- ProductionPerformanceEquipment ← mes.tb_trk_out (1:1(생산실적 설비))
-- 정제 규칙: R07c(Q009 correct), R08c(Q010 correct)
with kept as (
    select m.* from {{ ref('ProductionPerformanceEquipment__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."ProductionPerformanceID" as "ProductionPerformanceID",
    m."ProductionPerformanceSequence" as "ProductionPerformanceSequence",
    m."ProductionOrderID" as "ProductionOrderID",
    m."ExecutionStartDateTime" as "ExecutionStartDateTime",
    case when coalesce((m."ExecutionEndDateTime" < m."ExecutionStartDateTime"), false) then (select pp."ExecutionEndDateTime" from {{ ref('ProductionPerformance') }} pp where pp."ProductionPerformanceID" = m."ProductionPerformanceID") else m."ExecutionEndDateTime" end as "ExecutionEndDateTime",
    m."PersonnelID" as "PersonnelID",
    m."OperationID" as "OperationID",
    m."EquipmentID" as "EquipmentID",
    case when coalesce((m."ProducedQuantity" <> (select pp."ProducedQuantity" from {{ ref('ProductionPerformance') }} pp where pp."ProductionPerformanceID" = m."ProductionPerformanceID")), false) then (select pp."ProducedQuantity" from {{ ref('ProductionPerformance') }} pp where pp."ProductionPerformanceID" = m."ProductionPerformanceID") else m."ProducedQuantity" end as "ProducedQuantity",
    m."DefectQuantity" as "DefectQuantity"
from kept m
