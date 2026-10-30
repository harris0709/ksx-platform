-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Inventory.yaml
-- Inventory ← erp.tb_mm_stock_day (이력→현재(마지막 기준일))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.stk_qty as numeric) as "InventoryQuantity",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'erp__tb_mm_stock_day') }} s
where (s.stk_dt = (SELECT max(d.stk_dt) FROM {{ source('stg', 'erp__tb_mm_stock_day') }} d))
