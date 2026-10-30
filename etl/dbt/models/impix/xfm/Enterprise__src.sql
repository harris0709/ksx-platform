-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Enterprise.yaml
-- Enterprise ← erp.tb_cm_comp (1:1)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast(xfm.xref('enterprise', (s.comp_cd)::text) as text) as "EnterpriseID",
    cast(s.tel_no as text) as "DialNumber",
    cast(xfm.code('CURR', (s.curr_cd)::text) as text) as "BaseCurrencyCode",
    cast(s.curr_cd as text) as "_src__BaseCurrencyCode",
    cast(s.comp_nm as text) as "EnterpriseName",
    cast(s.biz_reg_no as text) as "BusinessRegistrationNumber",
    cast(s.corp_reg_no as text) as "CorporateRegistrationNumber",
    cast(s.ceo_nm as text) as "RepresentativeName",
    cast(s.zip_cd as text) as "PostalCode",
    cast(s.addr1 as text) as "BaseAddress",
    cast(s.addr2 as text) as "DetailAddress",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator",
    cast(xfm.to_ts(s.reg_dt) as timestamp) as "CreationDateTime",
    cast(s.reg_id as text) as "CreatorID"
from {{ source('stg', 'erp__tb_cm_comp') }} s
