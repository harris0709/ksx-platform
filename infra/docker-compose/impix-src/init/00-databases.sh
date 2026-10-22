#!/usr/bin/env bash
# IMPIX 가상 원천 시스템(S1~S3 실습용) — ERP·MES 두 시스템을 DB 2개로 흉내 낸다.
#   impix_erp : 레거시 ERP (스키마 erp)
#   impix_mes : 레거시 MES (스키마 mes)
#   impix_qms : 품질경영시스템 QMS (스키마 qms)
#   s1_reader : 원천 분석용 읽기 전용 계정(고객사가 S1에 내주는 계정에 해당)
set -euo pipefail
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres -v rd_pw="$IMPIX_SRC_READER_PASSWORD" <<'SQL'
CREATE ROLE s1_reader LOGIN PASSWORD :'rd_pw';
CREATE DATABASE impix_erp;
CREATE DATABASE impix_mes;
CREATE DATABASE impix_qms;
SQL
