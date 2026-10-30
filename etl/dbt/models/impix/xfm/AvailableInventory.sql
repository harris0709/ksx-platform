-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/AvailableInventory.yaml
-- AvailableInventory ← erp.tb_pp_mat_chk (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (o.plant_cd)::text) as text) as "PlantID",
    cast(concat(s.chk_dt, '_', s.mo_no, '_', xfm.upper_trim(s.comp_cd)) as text) as "AvailableInventoryID",
    cast(xfm.upper_trim(s.comp_cd) as text) as "ItemID",
    cast(s.avail_qty as numeric) as "AvailableInventoryQuantity",
    cast(s.mo_no as text) as "ProductionOrderID",
    cast(1 as integer) as "ProductionOrderSequence",
    cast(xfm.to_ts(xfm.to_date8(s.chk_dt) + time '06:00') as timestamp) as "AvailabilityCheckDateTime",
    cast(s.req_qty as numeric) as "MaterialRequirementQuantity",
    cast(s.short_qty as numeric) as "ShortageQuantity"
from {{ source('stg', 'erp__tb_pp_mat_chk') }} s
left join {{ source('stg', 'erp__tb_pp_mo') }} o on s.mo_no = o.mo_no
