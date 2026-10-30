-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/DeliveryHeader.yaml
-- DeliveryHeader ← erp.tb_sd_dlv (1→헤더·라인(헤더))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.dlv_no as text) as "DeliveryID",
    cast(s.cust_cd as text) as "CustomerID",
    cast(xfm.to_date8(s.dlv_dt) as timestamp) as "DeliveryDateTime"
from {{ source('stg', 'erp__tb_sd_dlv') }} s
