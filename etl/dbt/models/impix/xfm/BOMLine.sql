-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/BOMLine.yaml
-- BOMLine ← erp.tb_pp_bom_d (1:1(헤더 참조))
-- 정제 규칙: R02(Q002 quarantine)
with kept as (
    select m.* from {{ ref('BOMLine__src') }} m
    where not coalesce((m."ChildItemID" is not null and not exists (select 1 from (select "EnterpriseID", "ItemID" from {{ ref('ItemMaster') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ItemID" = m."ChildItemID")), false)
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."BOMID" as "BOMID",
    m."BOMRevisionNumber" as "BOMRevisionNumber",
    m."BOMLineSequence" as "BOMLineSequence",
    m."ActualRequirementQuantity" as "ActualRequirementQuantity",
    m."ChildItemUOMCode" as "ChildItemUOMCode",
    m."ValidStartDateTime" as "ValidStartDateTime",
    m."ValidEndDateTime" as "ValidEndDateTime",
    m."ChildItemID" as "ChildItemID",
    m."OperationSequence" as "OperationSequence",
    m."BackFlushedIndicator" as "BackFlushedIndicator"
from kept m
