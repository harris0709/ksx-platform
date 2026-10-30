-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Line.yaml
-- Line ← erp.tb_pp_line (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.plant_cd)::text) as text) as "PlantID",
    cast(xfm.code('LINE_TP', (s.line_tp)::text) as text) as "LineType",
    cast(s.line_tp as text) as "_src__LineType",
    cast(s.capa_qty as numeric) as "StandardCapacity",
    cast('EA/d' as text) as "CapacityUOMCode",
    cast(s.line_cd as text) as "LineID",
    cast(s.line_nm as text) as "LineName",
    cast(s.shift_cnt as integer) as "ShiftCount",
    cast(xfm.yn(s.use_yn) as boolean) as "UseIndicator"
from {{ source('stg', 'erp__tb_pp_line') }} s
