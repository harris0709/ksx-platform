-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Enterprise.yaml
-- Enterprise ← erp.tb_cm_comp (1:1)
-- 정제 규칙: R10(S3-01 nullify_orphan)
with kept as (
    select m.* from {{ ref('Enterprise__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."DialNumber" as "DialNumber",
    m."BaseCurrencyCode" as "BaseCurrencyCode",
    m."EnterpriseName" as "EnterpriseName",
    m."BusinessRegistrationNumber" as "BusinessRegistrationNumber",
    m."CorporateRegistrationNumber" as "CorporateRegistrationNumber",
    m."RepresentativeName" as "RepresentativeName",
    m."PostalCode" as "PostalCode",
    m."BaseAddress" as "BaseAddress",
    m."DetailAddress" as "DetailAddress",
    m."UseIndicator" as "UseIndicator",
    m."CreationDateTime" as "CreationDateTime",
    case when (m."CreatorID" is not null and not exists (select 1 from (select "EnterpriseID", "PersonnelID" from {{ ref('Personnel') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."PersonnelID" = m."CreatorID")) then null else m."CreatorID" end as "CreatorID",
    m."_src__BaseCurrencyCode" as "_src__BaseCurrencyCode"
from kept m
