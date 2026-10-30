-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/SalesOrderLine.yaml
-- SalesOrderLine ← erp.tb_sd_so_d (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.so_no as text) as "SalesDocumentNumber",
    cast(s.so_seq as integer) as "SalesDocumentSequence",
    cast(s.so_qty as numeric) as "ItemQuantity",
    cast(xfm.uom((s.unit)::text) as text) as "ItemUOMCode",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_date8(s.req_dlv_dt) as date) as "RequestedDeliveryDate",
    cast('KRW' as text) as "CurrencyCode",
    cast(s.so_qty * s.unit_prc as numeric) as "SalesAmount",
    cast(s.unit_prc as numeric) as "UnitPrice"
from {{ source('stg', 'erp__tb_sd_so_d') }} s
