-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformance.yaml
-- ProductionPerformance ← mes.tb_trk_out (N→1(완공+착공+LOT+검사))
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (i.fac_id)::text) as text) as "PlantID",
    cast(concat('PP-', s.trk_out_id) as text) as "ProductionPerformanceID",
    cast(1 as integer) as "ProductionPerformanceSequence",
    cast(s.lot_no as text) as "LotID",
    cast(s.proc_cd as text) as "OperationID",
    cast(xfm.upper_trim(l.item_cd) as text) as "ItemID",
    cast(l.mo_no as text) as "ProductionOrderID",
    cast(l.mo_seq as integer) as "ProductionOrderSequence",
    cast(xfm.to_ts14(i.trk_in_dtm) as timestamp) as "ExecutionStartDateTime",
    cast(xfm.to_ts14(s.trk_out_dtm) as timestamp) as "ExecutionEndDateTime",
    cast(xfm.to_date(xfm.to_ts14(s.trk_out_dtm)) as date) as "ProductionPerformanceDate",
    cast(s.oper_emp_no as text) as "PersonnelID",
    cast(s.good_qty as numeric) as "ProducedQuantity",
    cast(s.ng_qty as numeric) as "DefectQuantity",
    cast(xfm.code('QC_JUDGE', (q.judge)::text) as text) as "InspectionResult",
    cast(q.judge as text) as "_src__InspectionResult",
    cast(q.insp_qty as numeric) as "InspectionQuantity"
from {{ source('stg', 'mes__tb_trk_out') }} s
left join {{ source('stg', 'mes__tb_trk_in') }} i on s.trk_in_id = i.trk_in_id
left join {{ source('stg', 'mes__tb_lot') }} l on s.lot_no = l.lot_no
left join {{ source('stg', 'mes__tb_qc_insp') }} q on s.lot_no = q.lot_no AND s.proc_cd = q.proc_cd
