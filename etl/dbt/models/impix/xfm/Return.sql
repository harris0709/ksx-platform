-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/Return.yaml
-- Return ← qms.qm_claim (1:1(필드 반송분))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.claim_no as text) as "ReturnID",
    cast(1 as integer) as "ReturnSequence",
    cast(xfm.to_date8(s.rcv_dt) as timestamp) as "ReturnDateTime",
    cast(s.claim_qty as numeric) as "ReturnQuantity",
    cast(s.lot_no as text) as "LotID",
    cast('SAL-DEF' as text) as "ReturnType",
    cast(s.cust_cd as text) as "CustomerID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'qms__qm_claim') }} s
where (s.claim_tp = 'FR')
