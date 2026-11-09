-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/WarehouseLocationLine.yaml
-- WarehouseLocationLine ← erp.tb_mm_wh (1→헤더·라인(라인))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(s.wh_cd as text) as "WarehouseID",
    cast('00' as text) as "WarehouseSection",
    cast('전체' as text) as "WarehouseSectionName"
from {{ source('stg', 'erp__tb_mm_wh') }} s
