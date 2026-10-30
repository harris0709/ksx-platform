-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Lot_legacy.yaml
-- Lot ← erp.tb_mm_stock_lot (1:1(기초·이관 재고 LOT — 입고 이력 이전))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(xfm.mat_lot(s.lot_no, s.item_cd) as text) as "LotID",
    cast(s.stk_qty as numeric) as "LotCreatedQuantity",
    cast(xfm.to_date8(s.rcv_dt) as timestamp) as "CreationDateTime",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast('LEGACY' as text) as "LotOriginType"
from {{ source('stg', 'erp__tb_mm_stock_lot') }} s
where (s.rcv_dt < '20260801')
