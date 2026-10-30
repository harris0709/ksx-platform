-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/PurchaseOrderHeader.yaml
-- PurchaseOrderHeader ← erp.tb_mm_po_h (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.po_no as text) as "PurchaseDocumentNumber",
    cast(xfm.to_date8(s.po_dt) as date) as "PurchaseOrderDate",
    cast(s.emp_no as text) as "PersonnelID",
    cast((s.po_stat = '40') as boolean) as "PurchaseOrderClosingIndicator",
    cast(s.vend_cd as text) as "VendorID"
from {{ source('stg', 'erp__tb_mm_po_h') }} s
