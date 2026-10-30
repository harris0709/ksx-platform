-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/CorrectiveActionRequest.yaml
-- CorrectiveActionRequest ← qms.qm_vend_ncr (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.ncr_no as text) as "CorrectiveActionRequestID",
    cast(s.vend_cd as text) as "VendorID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.code('FOUND_AT', (s.found_at)::text) as text) as "DetectionLocationType",
    cast(s.found_at as text) as "_src__DetectionLocationType",
    cast(s.iqc_no as text) as "InspectionResultID",
    cast(xfm.to_date8(s.occur_dt) as date) as "OccurrenceDate",
    cast(xfm.code('IQC_DEFECT:TYPE', (s.defect_cd)::text) as text) as "DefectTypeCode",
    cast(s.defect_cd as text) as "_src__DefectTypeCode",
    cast(xfm.code('IQC_DEFECT', (s.defect_cd)::text) as text) as "DefectTypeDetailCode",
    cast(s.defect_cd as text) as "_src__DefectTypeDetailCode",
    cast(xfm.to_date8(s.car_due_dt) as date) as "CorrectiveActionDueDate",
    cast(s.ng_qty as numeric) as "DefectQuantity"
from {{ source('stg', 'qms__qm_vend_ncr') }} s
