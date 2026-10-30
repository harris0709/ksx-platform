-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Site.yaml
-- Site ← erp.tb_cm_bizarea (1:1)
select
    cast(xfm.xref('enterprise', (s.comp_cd)::text) as text) as "EnterpriseID",
    cast(xfm.xref('site', (s.bizarea_cd)::text) as text) as "SiteID",
    cast(s.biz_reg_no as text) as "BusinessRegistrationNumber",
    cast(s.tel_no as text) as "DialNumber",
    cast(s.bizarea_nm as text) as "SiteName",
    cast(s.addr1 as text) as "BaseAddress",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator"
from {{ source('stg', 'erp__tb_cm_bizarea') }} s
