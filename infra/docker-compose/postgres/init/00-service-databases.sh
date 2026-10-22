#!/usr/bin/env bash
# Airflow·Keycloak 메타데이터 DB (원장 ksx DB와 분리)
set -euo pipefail
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
     -v af_pw="$AIRFLOW_DB_PASSWORD" -v kc_pw="$KEYCLOAK_DB_PASSWORD" <<'SQL'
CREATE ROLE airflow  LOGIN PASSWORD :'af_pw';
CREATE ROLE keycloak LOGIN PASSWORD :'kc_pw';
CREATE DATABASE airflow  OWNER airflow;
CREATE DATABASE keycloak OWNER keycloak;
REVOKE ALL ON DATABASE airflow, keycloak FROM PUBLIC;
-- apache/age 이미지는 search_path 맨 앞에 ag_catalog 를 둔다.
-- AGE 가 없는 서비스 DB 는 public 으로 고정(Keycloak Liquibase 실패 방지)
ALTER DATABASE airflow  SET search_path TO public;
ALTER DATABASE keycloak SET search_path TO public;
SQL
