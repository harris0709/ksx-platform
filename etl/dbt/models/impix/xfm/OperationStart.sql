-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationStart.yaml
-- OperationStart ← mes.tb_trk_in (이력→이벤트)
-- 정제 규칙: R06(Q008 nullify_orphan)
with kept as (
    select m.* from {{ ref('OperationStart__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."OperationStartID" as "OperationStartID",
    m."LotID" as "LotID",
    m."LotCreatedQuantity" as "LotCreatedQuantity",
    m."OperationStartTime" as "OperationStartTime",
    case when (m."PersonnelID" is not null and not exists (select 1 from (select "EnterpriseID", "PersonnelID" from {{ ref('Personnel') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."PersonnelID" = m."PersonnelID")) then null else m."PersonnelID" end as "PersonnelID",
    m."OperationID" as "OperationID",
    m."EquipmentID" as "EquipmentID"
from kept m
