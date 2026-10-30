-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/TraceParameter.yaml
-- TraceParameter ← mes.tb_param_val (이력→이벤트)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (e.fac_id)::text) as text) as "PlantID",
    cast(concat(s.param_id, '_', to_char(s.coll_dtm, 'YYYYMMDDHH24MISS')) as text) as "TraceParameterID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(s.param_id as text) as "ParameterID",
    cast(xfm.to_ts(s.coll_dtm) as timestamp) as "EventDateTime",
    cast(s.val as numeric) as "ParameterValue",
    cast(xfm.uom((p.unit)::text) as text) as "ParameterUOMCode",
    cast(CASE WHEN s.val > p.usl THEN 'OVER_USL' WHEN s.val < p.lsl THEN 'UNDER_LSL' ELSE 'NORMAL' END as text) as "ValidationResultCode",
    cast(s.lot_no as text) as "LotID"
from {{ source('stg', 'mes__tb_param_val') }} s
left join {{ source('stg', 'mes__tm_eqp') }} e on s.eqp_id = e.eqp_id
left join {{ source('stg', 'mes__tm_param') }} p on s.param_id = p.param_id
