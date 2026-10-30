-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Department.yaml
-- Department ← erp.tb_cm_dept (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(coalesce(xfm.xref('plant', (s.plant_cd)::text), 'P2') as text) as "PlantID",
    cast(s.dept_cd as text) as "DepartmentID",
    cast(s.dept_nm as text) as "DepartmentName",
    cast(s.upper_dept_cd as text) as "ParentDepartmentID"
from {{ source('stg', 'erp__tb_cm_dept') }} s
where (s.use_yn = 'Y')
