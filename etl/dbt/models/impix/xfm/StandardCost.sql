-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/StandardCost.yaml
-- StandardCost ← erp.tb_co_std_cost (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (i.plant_cd)::text) as text) as "PlantID",
    cast(concat(xfm.upper_trim(s.item_cd), '_', s.cost_ym) as text) as "StandardCostID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.ym_first(s.cost_ym) as date) as "CostPeriodStartDate",
    cast(xfm.ym_last(s.cost_ym) as date) as "CostPeriodEndDate",
    cast(s.std_cost as numeric) as "StandardCostAmount",
    cast(s.mat_cost as numeric) as "MaterialCostAmount",
    cast(s.lab_cost as numeric) as "LaborCostAmount",
    cast(s.ovh_cost as numeric) as "OverheadCostAmount",
    cast(xfm.code('CURR', (s.curr_cd)::text) as text) as "CurrencyCode",
    cast(s.curr_cd as text) as "_src__CurrencyCode"
from {{ source('stg', 'erp__tb_co_std_cost') }} s
left join {{ source('stg', 'erp__tb_mm_item') }} i on s.item_cd = i.item_cd
