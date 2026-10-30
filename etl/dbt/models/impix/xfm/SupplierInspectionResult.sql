-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/SupplierInspectionResult.yaml
-- SupplierInspectionResult ← qms.qm_iqc (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (g.wh_cd)::text) as text) as "PlantID",
    cast(s.iqc_no as text) as "InspectionResultID",
    cast(xfm.mat_lot(s.vend_lot, s.item_cd) as text) as "LotID",
    cast(s.smpl_qty as numeric) as "InspectionQuantity",
    cast(xfm.code('IQC_JUDGE', (s.judge)::text) as text) as "InspectionResult",
    cast(s.judge as text) as "_src__InspectionResult",
    cast(s.insp_emp as text) as "Inspector",
    cast(s.vend_cd as text) as "VendorID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_date8(s.insp_dt) as date) as "InspectionDate",
    cast(s.gr_no as text) as "GoodsReceiptID",
    cast(1 as integer) as "GoodsReceiptSequence",
    cast(xfm.code('IQC_DEFECT:TYPE', (s.defect_cd)::text) as text) as "DefectTypeCode",
    cast(s.defect_cd as text) as "_src__DefectTypeCode",
    cast(xfm.code('IQC_DEFECT', (s.defect_cd)::text) as text) as "DefectTypeDetailCode",
    cast(s.defect_cd as text) as "_src__DefectTypeDetailCode",
    cast(s.ng_qty as numeric) as "DefectQuantity"
from {{ source('stg', 'qms__qm_iqc') }} s
left join {{ source('stg', 'erp__tb_mm_gr') }} g on s.gr_no = g.gr_no
