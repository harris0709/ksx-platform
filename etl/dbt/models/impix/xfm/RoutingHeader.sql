-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/RoutingHeader.yaml
-- RoutingHeader ← erp.tb_pp_rout_h (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(s.rout_cd as text) as "RoutingID",
    cast(s.rout_nm as text) as "RoutingName",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator"
from {{ source('stg', 'erp__tb_pp_rout_h') }} s
