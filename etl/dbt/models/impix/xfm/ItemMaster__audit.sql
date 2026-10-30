-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/ItemMaster.yaml
-- ItemMaster ← erp.tb_mm_item (1:1)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R01' as rule_id, 'Q001' as issue_id, 'dedupe' as action, to_jsonb(m) - 'rn' as row_data from (
    select k.*, row_number() over (partition by "EnterpriseID", "ItemID" order by "ModificationDateTime" desc nulls last, "UseIndicator" desc nulls last) as rn from {{ ref('ItemMaster__src') }} k
) m where m.rn > 1
