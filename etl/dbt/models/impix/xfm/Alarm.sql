-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Alarm.yaml
-- Alarm ← mes.tb_alarm (이력(발생·해제)→이벤트 2행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (e.fac_id)::text) as text) as "PlantID",
    cast(concat('AL-', s.alm_seq, '-', u.ev) as text) as "AlarmID",
    cast(u.ev_ts as timestamp) as "EventDateTime",
    cast(CASE WHEN u.ev='ON' THEN 'ALARM' ELSE 'NORMAL' END as text) as "AlarmState",
    cast(xfm.code('ALM_CD', (s.alm_cd)::text) as text) as "ErrorCode",
    cast(s.alm_cd as text) as "_src__ErrorCode",
    cast(s.alm_msg as text) as "ErrorMessage",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(xfm.code('ALM_LVL', (s.alm_lvl)::text) as text) as "AlarmSeverityCode",
    cast(s.alm_lvl as text) as "_src__AlarmSeverityCode"
from {{ source('stg', 'mes__tb_alarm') }} s
left join {{ source('stg', 'mes__tm_eqp') }} e on s.eqp_id = e.eqp_id
cross join lateral (values ('ON', s.occur_dtm), ('OFF', s.clear_dtm)) as u(ev, ev_ts)
where u.ev_ts is not null
