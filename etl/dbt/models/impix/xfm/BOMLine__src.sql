-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/BOMLine.yaml
-- BOMLine ← erp.tb_pp_bom_d (1:1(헤더 참조))
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (h.plant_cd)::text) as text) as "PlantID",
    cast(xfm.upper_trim(s.prnt_item_cd) as text) as "BOMID",
    cast(s.bom_rev as integer) as "BOMRevisionNumber",
    cast(s.seq as integer) as "BOMLineSequence",
    cast(s.req_qty as numeric) as "ActualRequirementQuantity",
    cast(xfm.uom((s.unit)::text) as text) as "ChildItemUOMCode",
    cast(xfm.to_date8(s.valid_fr) as timestamp) as "ValidStartDateTime",
    cast(xfm.to_date8(s.valid_to) as timestamp) as "ValidEndDateTime",
    cast(xfm.upper_trim(s.chld_item_cd) as text) as "ChildItemID",
    cast(s.oper_seq as integer) as "OperationSequence",
    cast(xfm.yn(s.bf_yn) as boolean) as "BackFlushedIndicator"
from {{ source('stg', 'erp__tb_pp_bom_d') }} s
left join {{ source('stg', 'erp__tb_pp_bom_h') }} h on s.prnt_item_cd = h.prnt_item_cd AND s.bom_rev = h.bom_rev
