-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Enterprise.yaml
-- Enterprise ← erp.tb_cm_comp (1:1)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R10' as rule_id, 'S3-01' as issue_id, 'nullify_orphan' as action, to_jsonb(m) as row_data from {{ ref('Enterprise__src') }} m where coalesce((m."CreatorID" is not null and not exists (select 1 from (select "EnterpriseID", "PersonnelID" from {{ ref('Personnel') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."PersonnelID" = m."CreatorID")), false)
