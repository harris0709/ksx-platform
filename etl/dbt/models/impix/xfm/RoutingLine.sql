-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/RoutingLine.yaml
-- RoutingLine ← erp.tb_pp_rout_d (1:1(헤더 참조))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (h.plant_cd)::text) as text) as "PlantID",
    cast(s.rout_cd as text) as "RoutingID",
    cast(p.proc_cd as text) as "OperationID",
    cast(xfm.minutes(s.setup_min) as interval) as "SetupTime",
    cast(xfm.seconds(s.run_sec) as interval) as "RunTime",
    cast(xfm.minutes(s.move_min) as interval) as "MoveTime",
    cast(s.oper_seq as integer) as "OperationSequence",
    cast(xfm.yn(s.last_yn) as boolean) as "LastOperationIndicator"
from {{ source('stg', 'erp__tb_pp_rout_d') }} s
left join {{ source('stg', 'erp__tb_pp_rout_h') }} h on s.rout_cd = h.rout_cd
left join {{ source('stg', 'mes__tm_proc') }} p on s.wc_cd = p.erp_wc_cd
