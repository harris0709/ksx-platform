-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/EquipmentParameter.yaml
-- EquipmentParameter ← mes.tm_param (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (e.fac_id)::text) as text) as "PlantID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(xfm.code('PARAM_KIND', (s.param_kind)::text) as text) as "ParameterType",
    cast(s.param_kind as text) as "_src__ParameterType",
    cast(xfm.code('PARAM_GRADE', (s.grade)::text) as text) as "ParameterGrade",
    cast(s.grade as text) as "_src__ParameterGrade",
    cast(xfm.uom((s.unit)::text) as text) as "ParameterUOMCode",
    cast(xfm.seconds(s.coll_cycle_sec) as interval) as "DataCollectionPeriod",
    cast(CASE WHEN s.coll_cycle_sec > 0 THEN true ELSE false END as boolean) as "PeriodicDataCollectionIndicator",
    cast(s.param_id as text) as "ParameterID",
    cast(s.param_nm as text) as "ParameterName",
    cast(s.lsl as numeric) as "LSL",
    cast(s.usl as numeric) as "USL",
    cast(s.lcl as numeric) as "LCL",
    cast(s.ucl as numeric) as "UCL"
from {{ source('stg', 'mes__tm_param') }} s
left join {{ source('stg', 'mes__tm_eqp') }} e on s.eqp_id = e.eqp_id
where (s.use_flag = 'Y')
