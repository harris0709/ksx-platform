-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/GoodsIssue_scrap.yaml
-- GoodsIssue ← qms.qm_scrap (1:1(폐기 출고))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(s.scrap_no as text) as "GoodsIssueID",
    cast('I800' as text) as "InventoryTransactionTypeCode",
    cast(s.lot_no as text) as "LotID",
    cast(s.scrap_qty as numeric) as "ItemUnitQuantity",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_date8(s.scrap_dt) as date) as "InventoryTransactionDate"
from {{ source('stg', 'qms__qm_scrap') }} s
