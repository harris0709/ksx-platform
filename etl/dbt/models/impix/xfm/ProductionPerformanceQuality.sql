-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformanceQuality.yaml
-- ProductionPerformanceQuality ← mes.tb_qc_defect (N→1(검사+불량))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (l.fac_id)::text) as text) as "PlantID",
    cast(concat('PP-', o.trk_out_id) as text) as "ProductionPerformanceID",
    cast(1 as integer) as "ProductionPerformanceSequence",
    cast(xfm.code('DEFECT_CD:TYPE', (s.defect_cd)::text) as text) as "DefectTypeCode",
    cast(s.defect_cd as text) as "_src__DefectTypeCode",
    cast(xfm.code('DEFECT_CD', (s.defect_cd)::text) as text) as "DefectTypeDetailCode",
    cast(s.defect_cd as text) as "_src__DefectTypeDetailCode",
    cast(q.proc_cd as text) as "OperationID",
    cast(q.lot_no as text) as "LotID",
    cast(xfm.upper_trim(l.item_cd) as text) as "ItemID",
    cast(l.mo_no as text) as "ProductionOrderID",
    cast(xfm.int(s.defect_qty) as integer) as "DefectTypeQuantity"
from {{ source('stg', 'mes__tb_qc_defect') }} s
left join {{ source('stg', 'mes__tb_qc_insp') }} q on s.insp_no = q.insp_no
left join {{ source('stg', 'mes__tb_lot') }} l on q.lot_no = l.lot_no
left join {{ source('stg', 'mes__tb_trk_out') }} o on q.lot_no = o.lot_no AND q.proc_cd = o.proc_cd
