-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformanceEquipment.yaml
-- ProductionPerformanceEquipment ← mes.tb_trk_out (1:1(생산실적 설비))
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R07c' as rule_id, 'Q009' as issue_id, 'correct' as action, to_jsonb(m) as row_data from {{ ref('ProductionPerformanceEquipment__src') }} m where coalesce((m."ProducedQuantity" <> (select pp."ProducedQuantity" from {{ ref('ProductionPerformance') }} pp where pp."ProductionPerformanceID" = m."ProductionPerformanceID")), false)
