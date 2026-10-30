-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationEnd.yaml
-- OperationEnd ← mes.tb_trk_out (이력→이벤트)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (i.fac_id)::text) as text) as "PlantID",
    cast(concat('TO-', s.trk_out_id) as text) as "OperationEndID",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.to_ts14(s.trk_out_dtm) as timestamp) as "OperationEndTime",
    cast(s.oper_emp_no as text) as "PersonnelID",
    cast(s.proc_cd as text) as "OperationID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(s.good_qty as numeric) as "ProducedQuantity",
    cast(s.ng_qty as numeric) as "DefectQuantity"
from {{ source('stg', 'mes__tb_trk_out') }} s
left join {{ source('stg', 'mes__tb_trk_in') }} i on s.trk_in_id = i.trk_in_id
