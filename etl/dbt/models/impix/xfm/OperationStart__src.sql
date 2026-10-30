-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationStart.yaml
-- OperationStart ← mes.tb_trk_in (이력→이벤트)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.fac_id)::text) as text) as "PlantID",
    cast(concat('TI-', s.trk_in_id) as text) as "OperationStartID",
    cast(s.lot_no as text) as "LotID",
    cast(s.in_qty as numeric) as "LotCreatedQuantity",
    cast(xfm.to_ts14(s.trk_in_dtm) as timestamp) as "OperationStartTime",
    cast(s.oper_emp_no as text) as "PersonnelID",
    cast(s.proc_cd as text) as "OperationID",
    cast(s.eqp_id as text) as "EquipmentID"
from {{ source('stg', 'mes__tb_trk_in') }} s
