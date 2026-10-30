-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Personnel.yaml
-- Personnel ← erp.tb_hr_emp (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(coalesce(xfm.xref('plant', (s.plant_cd)::text), 'HQ') as text) as "PlantID",
    cast(s.emp_no as text) as "PersonnelID",
    cast(s.email as text) as "PersonInChargeEmail",
    cast(s.hp_no as text) as "PersonInChargeDialNumber",
    cast(xfm.code('RETIRE_YN', (s.retire_yn)::text) as text) as "EmploymentStatusType",
    cast(s.retire_yn as text) as "_src__EmploymentStatusType",
    cast(s.emp_nm as text) as "PersonnelName",
    cast(s.dept_cd as text) as "DepartmentID"
from {{ source('stg', 'erp__tb_hr_emp') }} s
