-- 원천 분석 계정(s1_reader): 두 시스템 모두 읽기 전용
\connect impix_erp
GRANT CONNECT ON DATABASE impix_erp TO s1_reader;
GRANT USAGE ON SCHEMA erp TO s1_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA erp TO s1_reader;
ALTER ROLE s1_reader SET default_transaction_read_only = on;
ANALYZE;
\connect impix_mes
GRANT CONNECT ON DATABASE impix_mes TO s1_reader;
GRANT USAGE ON SCHEMA mes TO s1_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA mes TO s1_reader;
ANALYZE;
\connect impix_qms
GRANT CONNECT ON DATABASE impix_qms TO s1_reader;
GRANT USAGE ON SCHEMA qms TO s1_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA qms TO s1_reader;
ANALYZE;
