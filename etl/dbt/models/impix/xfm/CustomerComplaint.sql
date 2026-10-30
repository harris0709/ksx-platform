-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/CustomerComplaint.yaml
-- CustomerComplaint ← qms.qm_claim (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.claim_no as text) as "CustomerComplaintID",
    cast(xfm.code('CLAIM_TP', (s.claim_tp)::text) as text) as "CustomerComplaintType",
    cast(s.claim_tp as text) as "_src__CustomerComplaintType",
    cast(xfm.to_date8(s.resp_due_dt) as date) as "ResponseDueDate",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.to_date8(s.rcv_dt) as date) as "ComplaintReceiptDate",
    cast(xfm.code('CLAIM_DEFECT:TYPE', (s.defect_cd)::text) as text) as "DefectTypeCode",
    cast(s.defect_cd as text) as "_src__DefectTypeCode",
    cast(xfm.code('CLAIM_DEFECT', (s.defect_cd)::text) as text) as "DefectTypeDetailCode",
    cast(s.defect_cd as text) as "_src__DefectTypeDetailCode",
    cast(s.claim_qty as numeric) as "ComplaintQuantity",
    cast(xfm.to_date8(s.resp_dt) as date) as "ResponseDate",
    cast(xfm.code('CLAIM_STAT', (s.status)::text) as text) as "CustomerComplaintStatusCode",
    cast(s.status as text) as "_src__CustomerComplaintStatusCode",
    cast(s.claim_amt as numeric) as "ComplaintAmount",
    cast('KRW' as text) as "CurrencyCode",
    cast(s.cause_proc as text) as "CauseOperationID",
    cast(s.descr as text) as "ComplaintDescription",
    cast(s.cust_cd as text) as "CustomerID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_date8(s.occur_dt) as date) as "OccurrenceDate",
    cast(xfm.to_date8(s.close_dt) as date) as "CloseDate"
from {{ source('stg', 'qms__qm_claim') }} s
