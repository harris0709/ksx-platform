-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/TraceParameter.yaml
-- TraceParameter ← mes.tb_param_val (이력→이벤트)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R05' as rule_id, 'Q006' as issue_id, 'quarantine' as action, to_jsonb(m) as row_data from {{ ref('TraceParameter__src') }} m where coalesce((m."ParameterValue" > 10 * (select p."USL" from {{ ref('EquipmentParameter') }} p where p."ParameterID" = m."ParameterID")), false)
