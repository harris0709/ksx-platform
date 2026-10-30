-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationEquipment.yaml
-- OperationEquipment ← mes.tm_eqp (파생(설비→공정 배정))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.fac_id)::text) as text) as "PlantID",
    cast(s.eqp_id as text) as "EquipmentID",
    cast(s.eqp_nm as text) as "EquipmentName",
    cast(s.proc_cd as text) as "OperationID"
from {{ source('stg', 'mes__tm_eqp') }} s
