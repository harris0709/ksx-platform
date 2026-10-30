-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/CorrectiveActionResult.yaml
-- CorrectiveActionResult ← qms.qm_vend_ncr (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(concat(s.ncr_no, '-R') as text) as "CorrectiveActionResultID",
    cast(s.ncr_no as text) as "CorrectiveActionRequestID",
    cast(xfm.to_date8(s.car_cls_dt) as timestamp) as "CorrectiveActionDateTime",
    cast('COMPLETED' as text) as "CorrectiveActionStatusCode",
    cast(s.vend_cd as text) as "VendorID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'qms__qm_vend_ncr') }} s
where (s.car_cls_dt IS NOT NULL)
