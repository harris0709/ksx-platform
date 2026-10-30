-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Plant.yaml
-- Plant ← erp.tb_cm_plant (1:1)
select
    cast(xfm.xref('enterprise', (s.comp_cd)::text) as text) as "EnterpriseID",
    cast(xfm.xref('site', (s.bizarea_cd)::text) as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(s.tel_no as text) as "DialNumber",
    cast(s.plant_nm as text) as "PlantName",
    cast(s.addr1 as text) as "BaseAddress"
from {{ source('stg', 'erp__tb_cm_plant') }} s
where (s.use_yn = 'Y')
