-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/GoodsIssue.yaml
-- GoodsIssue ← erp.tb_mm_gi (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.gi_no as text) as "GoodsIssueID",
    cast(xfm.code('GI_TP', (s.gi_tp)::text) as text) as "InventoryTransactionTypeCode",
    cast(s.gi_tp as text) as "_src__InventoryTransactionTypeCode",
    cast(s.gi_qty as numeric) as "ItemUnitQuantity",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.rmk as text) as "Note",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_date8(s.gi_dt) as date) as "InventoryTransactionDate",
    cast(s.mo_no as text) as "ProductionOrderID",
    cast(1 as integer) as "ProductionOrderSequence"
from {{ source('stg', 'erp__tb_mm_gi') }} s
