-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ItemMaster.yaml
-- ItemMaster ← erp.tb_mm_item (1:1)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(xfm.code('ITEM_TP', (s.item_tp)::text) as text) as "ItemType",
    cast(s.item_tp as text) as "_src__ItemType",
    cast(xfm.code('ITEM_GRP', (s.item_grp)::text) as text) as "ItemLargeClass",
    cast(s.item_grp as text) as "_src__ItemLargeClass",
    cast(xfm.uom((s.unit)::text) as text) as "ItemUOMCode",
    cast(xfm.uom((s.wgt_unit)::text) as text) as "WeightUOMCode",
    cast(s.safety_qty as numeric) as "SafetyStock",
    cast(xfm.days(s.pur_lt) as interval) as "PurchaseLeadTime",
    cast(xfm.days(s.prd_lt) as interval) as "ProductionLeadTime",
    cast(s.drw_no as text) as "DrawingNumber",
    cast(xfm.yn(s.iqc_yn) as boolean) as "IncomingInspectionIndicator",
    cast(xfm.yn(s.fqc_yn) as boolean) as "FinalInspectionIndicator",
    cast(xfm.yn(s.oqc_yn) as boolean) as "OutgoingInspectionIndicator",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.item_nm as text) as "ItemName",
    cast(s.item_spec as text) as "ItemSpecification",
    cast(s.model_nm as text) as "ModelName",
    cast(s.wgt as numeric) as "Weight",
    cast(xfm.yn(s.lot_yn) as boolean) as "LotControlIndicator",
    cast(s.lot_size as numeric) as "LotSize",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator",
    cast(xfm.to_ts(s.reg_dt) as timestamp) as "CreationDateTime",
    cast(xfm.to_ts(s.upd_dt) as timestamp) as "ModificationDateTime"
from {{ source('stg', 'erp__tb_mm_item') }} s
where (s.item_cd NOT LIKE 'TEST%')
