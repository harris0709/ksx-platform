-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/InventorySnapshot.yaml
-- InventorySnapshot ← erp.tb_mm_stock_day (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(xfm.to_date8(s.stk_dt) as date) as "InventorySnapshotDate",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.stk_qty as numeric) as "InventoryQuantity",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'erp__tb_mm_stock_day') }} s
