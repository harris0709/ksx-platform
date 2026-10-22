-- audit 기본 테이블 + 사업장 RLS 도우미 (ksx_owner 소유로 생성)
SET ROLE ksx_owner;

-- 실행 기록: 적재·검증·추론·AI 실행·BOD를 run_id 하나로 연결
CREATE TABLE audit.run (
    run_id        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_run_id uuid        REFERENCES audit.run(run_id),
    stage         text        NOT NULL CHECK (stage ~ '^S([0-9]|1[01])$'),
    job           text        NOT NULL,           -- 예: dbt_run, shacl_validate, rule:R-OTD-01
    actor         text        NOT NULL,           -- 서비스 계정 또는 사용자(sub)
    enterprise_id text,
    site_id       text,
    plant_id      text,
    status        text        NOT NULL DEFAULT 'running'
                  CHECK (status IN ('running','succeeded','failed','cancelled')),
    started_at    timestamptz NOT NULL DEFAULT now(),
    ended_at      timestamptz,
    detail        jsonb       NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX run_stage_started_idx ON audit.run (stage, started_at DESC);
COMMENT ON TABLE audit.run IS '실행 ID 원장 (안내서 15장 감사)';

-- Ontop 부트스트랩 매핑이 읽는 헬스체크 테이블
CREATE TABLE audit.healthcheck (id int PRIMARY KEY, checked_at timestamptz NOT NULL DEFAULT now());
INSERT INTO audit.healthcheck (id) VALUES (1);
RESET ROLE;
GRANT USAGE ON SCHEMA audit TO ksx_reader;
GRANT SELECT ON audit.healthcheck TO ksx_reader;
SET ROLE ksx_owner;

-- S3에서 표준 테이블 생성 후 호출:  SELECT ksx.enable_site_rls('ksx."Lot"');
--   세션 변수 app.enterprise_id / app.site_id 가 없으면 0행(안전 기본값)
CREATE FUNCTION ksx.enable_site_rls(tbl regclass) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', tbl);
  EXECUTE format('DROP POLICY IF EXISTS site_isolation ON %s', tbl);
  EXECUTE format($p$CREATE POLICY site_isolation ON %s
                    USING ("EnterpriseID" = current_setting('app.enterprise_id', true)
                       AND "SiteID"       = current_setting('app.site_id', true))
                    WITH CHECK ("EnterpriseID" = current_setting('app.enterprise_id', true)
                       AND "SiteID"       = current_setting('app.site_id', true))$p$, tbl);
END $$;
COMMENT ON FUNCTION ksx.enable_site_rls(regclass) IS '사업장 격리 RLS 정책 부여 (안내서 15장)';
RESET ROLE;
REVOKE ALL ON FUNCTION ksx.enable_site_rls(regclass) FROM PUBLIC;
