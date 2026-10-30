-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Lot_material.yaml
-- Lot ← erp.tb_mm_gr (1:1(입고 → 구매 자재 LOT))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(xfm.mat_lot(s.vend_lot, s.item_cd) as text) as "LotID",
    cast(s.gr_qty as numeric) as "LotCreatedQuantity",
    cast(xfm.to_date8(s.gr_dt) as timestamp) as "CreationDateTime",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast('PURCHASE' as text) as "LotOriginType",
    cast(s.vend_lot as text) as "VendorLotNumber",
    cast(s.vend_cd as text) as "VendorID"
from {{ source('stg', 'erp__tb_mm_gr') }} s
where (s.vend_lot IS NOT NULL)
