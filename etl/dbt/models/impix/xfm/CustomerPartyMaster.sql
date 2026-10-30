-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/CustomerPartyMaster.yaml
-- CustomerPartyMaster ← erp.tb_sd_cust (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.biz_reg_no as text) as "BusinessRegistrationNumber",
    cast(xfm.code('NATION', (s.nation_cd)::text) as text) as "CountryID",
    cast(s.nation_cd as text) as "_src__CountryID",
    cast(s.cust_cd as text) as "CustomerID",
    cast(s.cust_nm as text) as "CustomerName",
    cast(s.chrg_nm as text) as "PersonInChargeName",
    cast(s.chrg_email as text) as "PersonInChargeEmail",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator",
    cast(xfm.code('CUST_GRP', (s.cust_grp)::text) as text) as "CustomerGroupCode",
    cast(s.cust_grp as text) as "_src__CustomerGroupCode"
from {{ source('stg', 'erp__tb_sd_cust') }} s
