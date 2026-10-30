-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationEnd.yaml
-- OperationEnd ← mes.tb_trk_out (이력→이벤트)
-- 정제 규칙: R07b(Q009 correct), R08b(Q010 correct)
with kept as (
    select m.* from {{ ref('OperationEnd__src') }} m
)
select
    m."EnterpriseID" as "EnterpriseID",
    m."SiteID" as "SiteID",
    m."PlantID" as "PlantID",
    m."OperationEndID" as "OperationEndID",
    m."LotID" as "LotID",
    case when coalesce((m."OperationEndTime" < (select os."OperationStartTime" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID") and (select max(q.insp_dtm) from {{ source('stg', 'mes__tb_qc_insp') }} q where q.lot_no = m."LotID" and q.proc_cd = m."OperationID") >= (select os."OperationStartTime" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false) then (select max(q.insp_dtm) from {{ source('stg', 'mes__tb_qc_insp') }} q where q.lot_no = m."LotID" and q.proc_cd = m."OperationID") else m."OperationEndTime" end as "OperationEndTime",
    m."PersonnelID" as "PersonnelID",
    m."OperationID" as "OperationID",
    m."EquipmentID" as "EquipmentID",
    case when coalesce((m."ProducedQuantity" + m."DefectQuantity" <> (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false) then (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID") - m."DefectQuantity" else m."ProducedQuantity" end as "ProducedQuantity",
    m."DefectQuantity" as "DefectQuantity"
from kept m
