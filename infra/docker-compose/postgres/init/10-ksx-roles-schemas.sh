#!/usr/bin/env bash
# 원장 DB(ksx): 서비스 계정 5종 + 스키마 4개(stg·ksx·ext·audit) — 안내서 3.1 절차 3, 15장
set -euo pipefail
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d ksx \
     -v owner_pw="$KSX_OWNER_PASSWORD"   -v loader_pw="$KSX_LOADER_PASSWORD" \
     -v reader_pw="$KSX_READER_PASSWORD" -v bod_pw="$KSX_BOD_PASSWORD" \
     -v audit_pw="$KSX_AUDIT_PASSWORD" <<'SQL'
-- ---------------------------------------------------------------
-- 1. 계정
--   ksx_owner  : 스키마·테이블 소유자. S3 DDL(ksxgen ddl/ksx.sql, ddl/ext.sql) 적용
--   ksx_loader : dbt·Airflow 적재. 전 사업장 일괄 적재이므로 BYPASSRLS
--   ksx_reader : Ontop·MCP 도구. 읽기 전용, RLS 적용(사업장 세션 변수 필수)
--   ksx_bod    : BOD Gateway. 런타임 원장 쓰기의 유일 계정, RLS 적용
--   ksx_audit  : 실행·적재·검증·추론·AI 실행 기록
-- ---------------------------------------------------------------
CREATE ROLE ksx_owner  LOGIN PASSWORD :'owner_pw'  NOBYPASSRLS;
CREATE ROLE ksx_loader LOGIN PASSWORD :'loader_pw' BYPASSRLS;
CREATE ROLE ksx_reader LOGIN PASSWORD :'reader_pw' NOBYPASSRLS;
CREATE ROLE ksx_bod    LOGIN PASSWORD :'bod_pw'    NOBYPASSRLS;
CREATE ROLE ksx_audit  LOGIN PASSWORD :'audit_pw'  NOBYPASSRLS;

REVOKE ALL ON DATABASE ksx FROM PUBLIC;
GRANT CONNECT ON DATABASE ksx TO ksx_owner, ksx_loader, ksx_reader, ksx_bod, ksx_audit;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- ---------------------------------------------------------------
-- 2. 스키마 4개
-- ---------------------------------------------------------------
CREATE SCHEMA stg   AUTHORIZATION ksx_owner;  -- 원천 복제(Debezium·배치)
CREATE SCHEMA ksx   AUTHORIZATION ksx_owner;  -- 표준 원장(테이블 76개)
CREATE SCHEMA ext   AUTHORIZATION ksx_owner;  -- 기업 확장
CREATE SCHEMA audit AUTHORIZATION ksx_owner;  -- 실행·적재 기록
COMMENT ON SCHEMA stg   IS '원천 복제 (S3)';
COMMENT ON SCHEMA ksx   IS 'KS X 9101 표준 원장 (S3)';
COMMENT ON SCHEMA ext   IS '기업 확장 (S2 확장 판정, S3)';
COMMENT ON SCHEMA audit IS '실행·적재·검증·추론·AI·BOD 기록 (실행 ID로 연결)';

-- ---------------------------------------------------------------
-- 3. 권한 (현재 + 앞으로 ksx_owner가 만들 객체)
-- ---------------------------------------------------------------
GRANT USAGE ON SCHEMA stg            TO ksx_loader;
GRANT USAGE ON SCHEMA ksx, ext       TO ksx_loader, ksx_reader, ksx_bod;
GRANT USAGE ON SCHEMA audit          TO ksx_loader, ksx_bod, ksx_audit;

ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA stg
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO ksx_loader;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA ksx, ext
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO ksx_loader;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA ksx, ext
  GRANT SELECT ON TABLES TO ksx_reader;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA ksx, ext
  GRANT SELECT, INSERT, UPDATE ON TABLES TO ksx_bod;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA stg, ksx, ext
  GRANT USAGE, SELECT ON SEQUENCES TO ksx_loader;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA ksx, ext
  GRANT USAGE, SELECT ON SEQUENCES TO ksx_bod;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA audit
  GRANT SELECT, INSERT ON TABLES TO ksx_loader, ksx_bod, ksx_audit;
ALTER DEFAULT PRIVILEGES FOR ROLE ksx_owner IN SCHEMA audit
  GRANT UPDATE ON TABLES TO ksx_audit;

ALTER ROLE ksx_reader SET search_path = ksx, ext;
ALTER ROLE ksx_bod    SET search_path = ksx, ext;
ALTER ROLE ksx_loader SET search_path = ksx, ext, stg;
ALTER ROLE ksx_owner  SET search_path = ksx, ext, stg, audit;
-- 읽기 계정의 장기 질의 차단(생성 질의 폭주 방지, S9)
ALTER ROLE ksx_reader SET statement_timeout = '60s';
ALTER ROLE ksx_reader SET default_transaction_read_only = on;
SQL
