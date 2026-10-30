-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/PurchaseOrderLine.yaml
-- PurchaseOrderLine ← erp.tb_mm_po_d (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.po_no as text) as "PurchaseDocumentNumber",
    cast(s.po_seq as integer) as "PurchaseDocumentSequence",
    cast(s.po_qty as numeric) as "PurchaseOrderQuantity",
    cast(s.unit_prc as numeric) as "PurchaseOrderUnitPrice",
    cast(xfm.to_date8(s.due_dt) as date) as "ExpectedDeliveryDate",
    cast(s.gr_qty as numeric) as "PurchaseGoodsReceiptQuantity",
    cast(xfm.code('PO_STAT', (h.po_stat)::text) as text) as "PurchaseOrderLineStatusCode",
    cast(h.po_stat as text) as "_src__PurchaseOrderLineStatusCode",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID"
from {{ source('stg', 'erp__tb_mm_po_d') }} s
left join {{ source('stg', 'erp__tb_mm_po_h') }} h on s.po_no = h.po_no
