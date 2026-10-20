-- S0: 표준 원장 데이터베이스 초기화
CREATE SCHEMA IF NOT EXISTS stg;     -- 원천 복제
CREATE SCHEMA IF NOT EXISTS ksx;     -- 표준 원장(테이블 76개: ontologies/ddl/ksx.sql)
CREATE SCHEMA IF NOT EXISTS ext;     -- 기업 확장
CREATE SCHEMA IF NOT EXISTS audit;   -- 적재·검증·추론·실행 기록
-- CREATE EXTENSION IF NOT EXISTS age;   -- S8 속성 그래프(AGE가 설치된 이미지에서)

-- 읽기 전용 계정(Ontop·도구용)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ontop_ro') THEN
    CREATE ROLE ontop_ro LOGIN PASSWORD 'CHANGE_ME';   -- 기동 후 ALTER ROLE ontop_ro PASSWORD '<.env의 ONTOP_DB_PASSWORD>';
  END IF;
END $$;
GRANT USAGE ON SCHEMA ksx, ext TO ontop_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA ksx GRANT SELECT ON TABLES TO ontop_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA ext GRANT SELECT ON TABLES TO ontop_ro;

CREATE TABLE IF NOT EXISTS audit.load_log (
  run_id uuid, noun text, rows_src bigint, rows_tgt bigint, failures int, run_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS audit.key_xref (
  src_system text, src_table text, src_key text, noun text, uk jsonb, PRIMARY KEY (src_system, src_table, src_key));
