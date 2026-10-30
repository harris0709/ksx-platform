-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Lot.yaml
-- Lot ← mes.tb_lot (1:1)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R04' as rule_id, 'Q005' as issue_id, 'nullify_orphan' as action, to_jsonb(m) as row_data from {{ ref('Lot__src') }} m where coalesce((m."ProductionOrderID" is not null and m."ProductionOrderSequence" is not null and not exists (select 1 from (select "EnterpriseID", "ProductionOrderID", "ProductionOrderSequence" from {{ ref('ProductionOrder') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ProductionOrderID" = m."ProductionOrderID" and p."ProductionOrderSequence" = m."ProductionOrderSequence")), false)
