-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ProductionPlanning.yaml
-- ProductionPlanning ← erp.tb_pp_plan (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (l.plant_cd)::text) as text) as "PlantID",
    cast(concat(s.plan_dt, '_', s.line_cd, '_', xfm.upper_trim(s.item_cd)) as text) as "ProductionPlanID",
    cast(xfm.to_date8(s.plan_dt) as timestamp) as "ScheduleStartDateTime",
    cast(xfm.to_date8(s.plan_dt) as timestamp) as "ScheduleEndDateTime",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.int(s.plan_qty) as integer) as "ProductionPlanQuantity"
from {{ source('stg', 'erp__tb_pp_plan') }} s
left join {{ source('stg', 'erp__tb_pp_line') }} l on s.line_cd = l.line_cd
where (s.plan_ver = (SELECT max(v.plan_ver) FROM {{ source('stg', 'erp__tb_pp_plan') }} v))
