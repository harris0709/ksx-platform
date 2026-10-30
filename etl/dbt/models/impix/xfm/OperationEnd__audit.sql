-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationEnd.yaml
-- OperationEnd ← mes.tb_trk_out (이력→이벤트)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R07b' as rule_id, 'Q009' as issue_id, 'correct' as action, to_jsonb(m) as row_data from {{ ref('OperationEnd__src') }} m where coalesce((m."ProducedQuantity" + m."DefectQuantity" <> (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false)
