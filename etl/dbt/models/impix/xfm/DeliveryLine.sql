-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/DeliveryLine.yaml
-- DeliveryLine ← erp.tb_sd_dlv (1→헤더·라인(라인))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.dlv_no as text) as "DeliveryID",
    cast(1 as integer) as "DeliveryLineSequence",
    cast(s.dlv_no as text) as "ProductReleaseID",
    cast(1 as integer) as "ProductReleaseSequence",
    cast(s.so_no as text) as "SalesDocumentNumber",
    cast(s.so_seq as integer) as "SalesDocumentSequence",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.dlv_qty as numeric) as "ProductDeliveryQuantity"
from {{ source('stg', 'erp__tb_sd_dlv') }} s
