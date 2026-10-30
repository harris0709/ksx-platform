-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ProductionOrder.yaml
-- ProductionOrder ← erp.tb_pp_mo (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(s.mo_no as text) as "ProductionOrderID",
    cast(s.mo_seq as integer) as "ProductionOrderSequence",
    cast(xfm.int(s.mo_qty) as integer) as "ProductionOrderQuantity",
    cast(xfm.uom((s.unit)::text) as text) as "ItemUOMCode",
    cast(xfm.to_date8(s.plan_st_dt) as timestamp) as "ScheduleStartDateTime",
    cast(xfm.to_date8(s.plan_ed_dt) as timestamp) as "ScheduleEndDateTime",
    cast(s.so_no as text) as "SalesDocumentNumber",
    cast(s.so_seq as integer) as "SalesDocumentSequence",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.line_cd as text) as "LineID",
    cast(s.rout_cd as text) as "RoutingID",
    cast(s.bom_rev as integer) as "BOMRevisionNumber",
    cast(xfm.to_date8(s.due_dt) as timestamp) as "ProductionDueDateTime",
    cast(xfm.to_ts(s.reg_dt) as timestamp) as "CreationDateTime",
    cast(s.reg_id as text) as "CreatorID",
    cast(xfm.code('MO_STAT', (s.mo_stat)::text) as text) as "ProductionOrderStatusCode",
    cast(s.mo_stat as text) as "_src__ProductionOrderStatusCode"
from {{ source('stg', 'erp__tb_pp_mo') }} s
