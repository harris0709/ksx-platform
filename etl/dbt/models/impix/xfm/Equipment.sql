-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Equipment.yaml
-- Equipment ← mes.tm_eqp (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.fac_id)::text) as text) as "PlantID",
    cast(xfm.code('EQP_KIND', (s.eqp_kind)::text) as text) as "EquipmentType",
    cast(s.eqp_kind as text) as "_src__EquipmentType",
    cast(xfm.code('EQP_GRP', (s.eqp_grp)::text) as text) as "EquipmentLargeClass",
    cast(s.eqp_grp as text) as "_src__EquipmentLargeClass",
    cast(s.maker as text) as "Manufacturer",
    cast(s.model_no as text) as "ModelNumber",
    cast(s.serial_no as text) as "SerialNumber",
    cast(xfm.to_date8(s.install_dt) as date) as "AcquisitionDate",
    cast(s.plc_ip as text) as "DAQDevice",
    cast(s.mgr_emp_no as text) as "PersonInChargeID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(s.eqp_nm as text) as "EquipmentName",
    cast(s.proc_cd as text) as "OperationID",
    cast(xfm.yn(s.use_flag) as boolean) as "UseIndicator"
from {{ source('stg', 'mes__tm_eqp') }} s
