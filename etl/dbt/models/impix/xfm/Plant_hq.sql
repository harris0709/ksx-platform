-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Plant_hq.yaml
-- Plant ← erp.tb_cm_comp (1:1(본사 — 생산하지 않는 조직 단위, S3 검토에서 추가))
select
    cast(xfm.xref('enterprise', (s.comp_cd)::text) as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('HQ' as text) as "PlantID",
    cast('본사' as text) as "PlantName",
    cast(s.tel_no as text) as "DialNumber",
    cast(s.addr1 as text) as "BaseAddress",
    cast(s.addr2 as text) as "DetailAddress",
    cast(s.zip_cd as text) as "PostalCode"
from {{ source('stg', 'erp__tb_cm_comp') }} s
