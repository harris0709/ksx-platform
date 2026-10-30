-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/VendorPartyMaster.yaml
-- VendorPartyMaster ← erp.tb_mm_vend (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.biz_reg_no as text) as "BusinessRegistrationNumber",
    cast(s.vend_cd as text) as "VendorID",
    cast(s.vend_nm as text) as "VendorName",
    cast(s.chrg_nm as text) as "PersonInChargeName",
    cast(s.chrg_email as text) as "PersonInChargeEmail",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator"
from {{ source('stg', 'erp__tb_mm_vend') }} s
