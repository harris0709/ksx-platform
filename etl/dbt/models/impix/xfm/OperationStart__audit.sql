-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/OperationStart.yaml
-- OperationStart ← mes.tb_trk_in (이력→이벤트)
-- 정제 규칙에 걸린 행(publish → audit.quarantine)
select 'R06' as rule_id, 'Q008' as issue_id, 'replace_orphan' as action, to_jsonb(m) as row_data from {{ ref('OperationStart__src') }} m where coalesce((m."PersonnelID" is not null and not exists (select 1 from (select "EnterpriseID", "PersonnelID" from {{ ref('Personnel') }}) p where p."EnterpriseID" = m."EnterpriseID" and p."PersonnelID" = m."PersonnelID")), false)
