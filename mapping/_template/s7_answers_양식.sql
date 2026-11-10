-- S7 정답(수작업 판정) 산출 쿼리 — <기업> · 양식
--   복사: mapping/_template/s7_answers_양식.sql → mapping/<기업 소문자>/s7_answers.sql
--   원천 DB(또는 S3 원장 ksx 스키마)에서 직접 만든다 — 지식 그래프(SPARQL)를 쓰지 않는다(다른 경로여야 정답이 된다).
--   결과는 s7_plan.yaml evaluate.cases의 expected로 옮기고, ?x와 같은 형식(예: '산출<-투입', 'LOT@설비')으로 만든다.
--   쿼리마다 [DB] 표시와 대응 규칙·사례 ID를 적는다. 원천 결함(고아·중복)이 답을 바꾸면 그 처리(S3 정제 규칙)를 주석으로.

-- [<원천 DB>] A01 <규칙 ID> <무엇> — 사례 <E-nn>
select <산출> || '<-' || <투입> from <스키마>.<테이블> where <조건> order by 1;

-- [<원천 DB>] A02 <규칙 ID> <무엇> — 사례 <E-nn>
-- select …;
