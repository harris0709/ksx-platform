-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/InventoryCount.yaml
-- InventoryCount ← erp.tb_mm_cnt (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.cnt_no as text) as "InventoryCountDocumentNumber",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.book_qty as numeric) as "InventoryQuantity",
    cast(xfm.to_date8(s.cnt_dt) as timestamp) as "InventoryCountDateTime",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.cnt_qty as numeric) as "InventoryCountQuantity"
from {{ source('stg', 'erp__tb_mm_cnt') }} s
