-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/qms/QualityCost.yaml
-- QualityCost ← qms.qm_qcost (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(concat(s.cost_ym, '_', s.cost_cls, '_', xfm.code('COST_ITM', (s.cost_itm)::text)) as text) as "QualityCostID",
    cast(xfm.ym_first(s.cost_ym) as date) as "CostPeriodStartDate",
    cast(xfm.ym_last(s.cost_ym) as date) as "CostPeriodEndDate",
    cast(xfm.code('COST_CLS', (s.cost_cls)::text) as text) as "QualityCostClass",
    cast(s.cost_cls as text) as "_src__QualityCostClass",
    cast(xfm.code('COST_ITM', (s.cost_itm)::text) as text) as "QualityCostItem",
    cast(s.cost_itm as text) as "_src__QualityCostItem",
    cast(s.amount as numeric) as "QualityCostAmount",
    cast('KRW' as text) as "CurrencyCode",
    cast(s.ref_no as text) as "SourceDocumentReference"
from {{ source('stg', 'qms__qm_qcost') }} s
