-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationEnd.yaml
-- OperationEnd ← mes.tb_trk_out (이력→이벤트)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R07b' as rule_id, 'Q009' as issue_id, 'correct' as action, to_jsonb(m) as row_data from {{ ref('OperationEnd__src') }} m where coalesce((m."ProducedQuantity" + m."DefectQuantity" <> (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false)
union all
select 'R08b' as rule_id, 'Q010' as issue_id, 'correct' as action, to_jsonb(m) as row_data from {{ ref('OperationEnd__src') }} m where coalesce((m."OperationEndTime" < (select os."OperationStartTime" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID") and (select max(q.insp_dtm) from {{ source('stg', 'mes__tb_qc_insp') }} q where q.lot_no = m."LotID" and q.proc_cd = m."OperationID") >= (select os."OperationStartTime" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false)
