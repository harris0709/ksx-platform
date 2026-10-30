-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/WarehouseLocationHeader.yaml
-- WarehouseLocationHeader ← erp.tb_mm_wh (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(xfm.code('WH_TP', (s.wh_tp)::text) as text) as "WarehouseType",
    cast(s.wh_tp as text) as "_src__WarehouseType",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(s.wh_nm as text) as "WarehouseName",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator"
from {{ source('stg', 'erp__tb_mm_wh') }} s
