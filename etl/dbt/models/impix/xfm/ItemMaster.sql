-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ItemMaster.yaml
-- ItemMaster ← erp.tb_mm_item (1:1)
-- 정제 규칙: R01(Q001 dedupe)
with kept as (
    select m.* from {{ ref('ItemMaster__src') }} m
)
, dedup as (
    select distinct on ("EnterpriseID", "ItemID") * from kept
    order by "EnterpriseID", "ItemID", "ModificationDateTime" desc nulls last, "UseIndicator" desc nulls last
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."ItemType" as "ItemType",
    m."ItemLargeClass" as "ItemLargeClass",
    m."ItemUOMCode" as "ItemUOMCode",
    m."WeightUOMCode" as "WeightUOMCode",
    m."SafetyStock" as "SafetyStock",
    m."PurchaseLeadTime" as "PurchaseLeadTime",
    m."ProductionLeadTime" as "ProductionLeadTime",
    m."DrawingNumber" as "DrawingNumber",
    m."IncomingInspectionIndicator" as "IncomingInspectionIndicator",
    m."FinalInspectionIndicator" as "FinalInspectionIndicator",
    m."OutgoingInspectionIndicator" as "OutgoingInspectionIndicator",
    m."ItemID" as "ItemID",
    m."ItemName" as "ItemName",
    m."ItemSpecification" as "ItemSpecification",
    m."ModelName" as "ModelName",
    m."Weight" as "Weight",
    m."LotControlIndicator" as "LotControlIndicator",
    m."LotSize" as "LotSize",
    m."UseIndicator" as "UseIndicator",
    m."CreationDateTime" as "CreationDateTime",
    m."ModificationDateTime" as "ModificationDateTime",
    m."_src__ItemType" as "_src__ItemType",
    m."_src__ItemLargeClass" as "_src__ItemLargeClass"
from dedup m
