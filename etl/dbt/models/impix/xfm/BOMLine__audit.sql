-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/BOMLine.yaml
-- BOMLine ← erp.tb_pp_bom_d (1:1(헤더 참조))
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R02' as rule_id, 'Q002' as issue_id, 'quarantine' as action, to_jsonb(m) as row_data from {{ ref('BOMLine__src') }} m where coalesce((m."ChildItemID" is not null and not exists (select 1 from (select "EnterpriseID", "ItemID" from {{ ref('ItemMaster') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."ItemID" = m."ChildItemID")), false)
