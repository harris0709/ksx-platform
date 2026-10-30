-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformance.yaml
-- ProductionPerformance ← mes.tb_trk_out (N→1(완공+착공+LOT+검사))
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R09' as rule_id, 'Q005' as issue_id, 'nullify_orphan' as action, to_jsonb(m) as row_data from {{ ref('ProductionPerformance__src') }} m where coalesce((m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")), false)
union all
select 'R07' as rule_id, 'Q009' as issue_id, 'correct' as action, to_jsonb(m) as row_data from {{ ref('ProductionPerformance__src') }} m where coalesce((m."ProducedQuantity" + m."DefectQuantity" <> (select os."LotCreatedQuantity" from {{ ref('OperationStart__src') }} os where os."LotID" = m."LotID" and os."OperationID" = m."OperationID")), false)
union all
select 'R08' as rule_id, 'Q010' as issue_id, 'flag' as action, to_jsonb(m) as row_data from {{ ref('ProductionPerformance') }} m where coalesce((m."ExecutionEndDateTime" < m."ExecutionStartDateTime"), false)
