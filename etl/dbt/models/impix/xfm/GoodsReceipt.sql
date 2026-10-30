-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/GoodsReceipt.yaml
-- GoodsReceipt ← erp.tb_mm_gr (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.gr_no as text) as "GoodsReceiptID",
    cast(1 as integer) as "GoodsReceiptSequence",
    cast(xfm.to_date8(s.gr_dt) as date) as "GoodsReceiptDate",
    cast(s.gr_qty as numeric) as "GoodsReceiptQuantity",
    cast(s.wh_cd as text) as "WarehouseID",
    cast(xfm.yn(s.iqc_yn) as boolean) as "IncomingInspectionIndicator",
    cast(CASE WHEN s.iqc_stat IN('10', '30') THEN s.gr_qty ELSE 0 END as numeric) as "IncomingInspectionAcceptedQuantity",
    cast(CASE WHEN s.iqc_stat = '20' THEN s.gr_qty ELSE 0 END as numeric) as "IncomingInspectionRejectedQuantity",
    cast(s.vend_cd as text) as "VendorID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.po_no as text) as "PurchaseDocumentNumber",
    cast(s.po_seq as integer) as "PurchaseDocumentSequence",
    cast(xfm.mat_lot(s.vend_lot, s.item_cd) as text) as "LotID"
from {{ source('stg', 'erp__tb_mm_gr') }} s
