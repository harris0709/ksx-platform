-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/BOMHeader.yaml
-- BOMHeader ← erp.tb_pp_bom_h (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(xfm.upper_trim(s.prnt_item_cd) as text) as "BOMID",
    cast(xfm.upper_trim(s.prnt_item_cd) as text) as "ItemID",
    cast(xfm.code('BOM_TP', (s.bom_tp)::text) as text) as "BOMType",
    cast(s.bom_tp as text) as "_src__BOMType",
    cast(s.base_qty as numeric) as "BOMQuantity",
    cast(xfm.uom((s.unit)::text) as text) as "ItemUOMCode",
    cast(s.bom_rev as integer) as "BOMRevisionNumber",
    cast(s.rout_cd as text) as "RoutingID"
from {{ source('stg', 'erp__tb_pp_bom_h') }} s
