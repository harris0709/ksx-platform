-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ProductIncoming.yaml
-- ProductIncoming ← erp.tb_pp_rcpt (1:1)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.rcpt_no as text) as "ProductIncomingID",
    cast(1 as integer) as "ProductIncomingSequence",
    cast(xfm.to_date8(s.rcpt_dt) as date) as "InventoryTransactionDate",
    cast(s.rcpt_qty as numeric) as "ItemUnitQuantity",
    cast(s.wh_cd as text) as "WarehouseID",
    cast('R200' as text) as "InventoryTransactionTypeCode",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.mo_no as text) as "ProductionOrderID",
    cast(1 as integer) as "ProductionOrderSequence"
from {{ source('stg', 'erp__tb_pp_rcpt') }} s
