-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/TraceParameter.yaml
-- TraceParameter ← mes.tb_param_val (이력→이벤트)
-- 정제 규칙: R05(Q006 quarantine)
with kept as (
    select m.* from {{ ref('TraceParameter__src') }} m
    where not coalesce((m."ParameterValue" > 10 * (select p."USL" from {{ ref('EquipmentParameter') }} p where p."ParameterID" = m."ParameterID")), false)
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."TraceParameterID" as "TraceParameterID",
    m."EquipmentID" as "EquipmentID",
    m."ParameterID" as "ParameterID",
    m."EventDateTime" as "EventDateTime",
    m."ParameterValue" as "ParameterValue",
    m."ParameterUOMCode" as "ParameterUOMCode",
    m."ValidationResultCode" as "ValidationResultCode",
    m."LotID" as "LotID"
from kept m
