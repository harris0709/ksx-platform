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

-- 원장 범위 격리(RLS)는 표준 테이블을 만든 뒤 ksxload ddl이 적용한다(tools/ksxload/ksxload/rls.py, S9 D-5 공장 단위):
--   세션 변수 app.enterprise_id · app.site_id · app.plant_ids 가 없으면 0행(안전 기본값)
RESET ROLE;
