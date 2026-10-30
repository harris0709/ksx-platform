-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ProductRelease.yaml
-- ProductRelease ← erp.tb_sd_dlv (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.dlv_no as text) as "ProductReleaseID",
    cast(1 as integer) as "ProductReleaseSequence",
    cast(s.so_no as text) as "SalesDocumentNumber",
    cast(s.so_seq as integer) as "SalesDocumentSequence",
    cast(s.dlv_qty as numeric) as "SalesQuantity",
    cast(xfm.to_date8(s.dlv_dt) as date) as "InventoryTransactionDate",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.yn(s.rtn_yn) as boolean) as "ReturnIndicator",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.cust_cd as text) as "CustomerID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'erp__tb_sd_dlv') }} s
