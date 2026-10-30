-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/EquipmentState.yaml
-- EquipmentState ← mes.tb_eqp_stat (이력(구간)→이벤트)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (e.fac_id)::text) as text) as "PlantID",
    cast(concat('ES-', s.stat_seq) as text) as "EquipmentStateID",
    cast(xfm.code('EQP_STAT', (s.stat_cd)::text) as text) as "EquipmentState",
    cast(s.stat_cd as text) as "_src__EquipmentState",
    cast(xfm.code('ERR_CD', (s.err_cd)::text) as text) as "ErrorCode",
    cast(s.err_cd as text) as "_src__ErrorCode",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(xfm.code('CTRL_MODE', (s.ctrl_mode)::text) as text) as "EquipmentControlMode",
    cast(s.ctrl_mode as text) as "_src__EquipmentControlMode",
    cast(xfm.code('OPER_MODE', (s.oper_mode)::text) as text) as "EquipmentOperationMode",
    cast(s.oper_mode as text) as "_src__EquipmentOperationMode",
    cast(s.lot_no as text) as "LastProcessedLotID",
    cast(s.rmk as text) as "ErrorMessage",
    cast(xfm.to_ts(s.st_dtm) as timestamp) as "StateStartDateTime",
    cast(xfm.to_ts(s.ed_dtm) as timestamp) as "StateEndDateTime"
from {{ source('stg', 'mes__tb_eqp_stat') }} s
left join {{ source('stg', 'mes__tm_eqp') }} e on s.eqp_id = e.eqp_id
