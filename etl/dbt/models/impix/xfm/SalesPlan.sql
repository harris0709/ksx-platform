-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/SalesPlan.yaml
-- SalesPlan ← erp.tb_sd_plan (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(concat(s.plan_ym, '_', s.plan_tp, '_', s.plan_ver, '_', s.cust_cd, '_', xfm.upper_trim(s.item_cd)) as text) as "SalesPlanID",
    cast(s.plan_qty as numeric) as "SalesProjection",
    cast(xfm.ym_first(s.plan_ym) as date) as "ProjectionStartDate",
    cast(xfm.ym_last(s.plan_ym) as date) as "ProjectionEndDate",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(xfm.to_ts(s.reg_dt) as timestamp) as "CreationDateTime",
    cast(xfm.code('PLAN_TP', (s.plan_tp)::text) as text) as "SalesPlanType",
    cast(s.plan_tp as text) as "_src__SalesPlanType",
    cast(s.plan_ver as integer) as "SalesPlanVersion",
    cast(s.cust_cd as text) as "CustomerID"
from {{ source('stg', 'erp__tb_sd_plan') }} s
