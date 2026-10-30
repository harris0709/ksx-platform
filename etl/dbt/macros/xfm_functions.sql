{#
  S2 변환 어휘(s2_plan.yaml 머리말)의 SQL 구현 — dbt on-run-start에서 xfm 스키마에 만든다.
  매핑 명세의 transform은 ksxload gen이 이 함수 호출로 옮긴다(예: to_date8(x) → xfm.to_date8(s.x)).
  코드·식별·단위 대응은 seed(xfm.codes·xfm.xref·xfm.units)를 읽는다(plpgsql: 생성 시 본문 검사 안 함).
#}
{% macro ksx_xfm_functions() %}
create schema if not exists xfm;

-- 공백 제거 + 대문자(품목코드 중복 이슈 Q001)
create or replace function xfm.upper_trim(v text) returns text
  language sql immutable as $f$ select nullif(upper(trim(v)), '') $f$;

-- 'YYYYMMDD' → date. 무기한 표기(99991231)·빈 값은 NULL
create or replace function xfm.to_date8(v text) returns date
  language sql immutable as $f$
  select case when v is null or trim(v) = '' or trim(v) = '99991231' then null
              else to_date(trim(v), 'YYYYMMDD') end $f$;

-- 'YYYYMMDDHH24MISS' → timestamp(Asia/Seoul 현지 시각, 시간대 없이 저장)
create or replace function xfm.to_ts14(v text) returns timestamp
  language sql immutable as $f$
  select case when v is null or trim(v) = '' then null
              else to_timestamp(trim(v), 'YYYYMMDDHH24MISS')::timestamp end $f$;

-- timestamp·date → timestamp(KS X ISO 8601, 현지 시각)
create or replace function xfm.to_ts(v timestamp) returns timestamp language sql immutable as $f$ select v $f$;
create or replace function xfm.to_ts(v date) returns timestamp language sql immutable as $f$ select v::timestamp $f$;
create or replace function xfm.to_ts(v text) returns timestamp language sql immutable as $f$
  select case when length(trim(v)) = 8 then xfm.to_date8(v)::timestamp
              when length(trim(v)) = 14 then xfm.to_ts14(v)
              else nullif(trim(v), '')::timestamp end $f$;

-- timestamp → date
create or replace function xfm.to_date(v timestamp) returns date language sql immutable as $f$ select v::date $f$;

-- 'YYYYMM' → 월 첫날·말일
create or replace function xfm.ym_first(v text) returns date language sql immutable as $f$
  select to_date(trim(v) || '01', 'YYYYMMDD') $f$;
create or replace function xfm.ym_last(v text) returns date language sql immutable as $f$
  select (to_date(trim(v) || '01', 'YYYYMMDD') + interval '1 month' - interval '1 day')::date $f$;

-- 'Y'/'N'(·'1'/'0') → boolean. 그 밖의 값은 NULL
create or replace function xfm.yn(v text) returns boolean language sql immutable as $f$
  select case upper(trim(v)) when 'Y' then true when '1' then true when 'N' then false when '0' then false end $f$;

-- 정수 변환(반올림)
create or replace function xfm.int(v numeric) returns integer language sql immutable as $f$ select round(v)::integer $f$;
create or replace function xfm.int(v text) returns integer language sql immutable as $f$
  select round(nullif(trim(v), '')::numeric)::integer $f$;

-- 기간(duration) → interval
create or replace function xfm.seconds(v numeric) returns interval language sql immutable as $f$ select v * interval '1 second' $f$;
create or replace function xfm.minutes(v numeric) returns interval language sql immutable as $f$ select v * interval '1 minute' $f$;
create or replace function xfm.days(v numeric)    returns interval language sql immutable as $f$ select v * interval '1 day' $f$;

-- 구매 자재 LOT 식별자: 공급사 LOT('V###-…')는 품목과 결합(번호가 품목 간 중복), 그 밖은 그대로
create or replace function xfm.mat_lot(lot text, item text) returns text language sql immutable as $f$
  select case when lot ~ '^V[0-9]{3}-' then lot || '_' || xfm.upper_trim(item) else lot end $f$;

-- 코드 대응(seed codes): 원천 코드 → 표준·확장 코드. '-'(상세 없음)·미대응은 NULL
create or replace function xfm.code(grp text, v text) returns text language plpgsql stable as $f$
declare r text;
begin
  if v is null then return null; end if;
  select c.ksx_code into r from xfm.codes c where c.src_group = grp and c.src_code = v limit 1;
  return nullif(r, '-');
end $f$;

-- 식별 대응(seed xref): 원천 코드 → 표준 식별자(회사·사업장·공장)
create or replace function xfm.xref(name text, v text) returns text language plpgsql stable as $f$
declare r text;
begin
  if v is null then return null; end if;
  select x.ksx into r from xfm.xref x where x.xref = name and x.src = v limit 1;
  return r;
end $f$;

-- 단위 대응(seed units): 원천 단위 → 표준 단위코드
create or replace function xfm.uom(v text) returns text language plpgsql stable as $f$
declare r text;
begin
  if v is null then return null; end if;
  select u.ksx_uom into r from xfm.units u where u.src_unit = v limit 1;
  return r;
end $f$;
{% endmacro %}
