-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformanceEquipment.yaml
-- ProductionPerformanceEquipment ← mes.tb_trk_out (1:1(생산실적 설비))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (i.fac_id)::text) as text) as "PlantID",
    cast(concat('PP-', s.trk_out_id) as text) as "ProductionPerformanceID",
    cast(1 as integer) as "ProductionPerformanceSequence",
    cast(l.mo_no as text) as "ProductionOrderID",
    cast(xfm.to_ts14(i.trk_in_dtm) as timestamp) as "ExecutionStartDateTime",
    cast(xfm.to_ts14(s.trk_out_dtm) as timestamp) as "ExecutionEndDateTime",
    cast(s.oper_emp_no as text) as "PersonnelID",
    cast(s.proc_cd as text) as "OperationID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(s.good_qty as numeric) as "ProducedQuantity",
    cast(s.ng_qty as numeric) as "DefectQuantity"
from {{ source('stg', 'mes__tb_trk_out') }} s
left join {{ source('stg', 'mes__tb_trk_in') }} i on s.trk_in_id = i.trk_in_id
left join {{ source('stg', 'mes__tb_lot') }} l on s.lot_no = l.lot_no
