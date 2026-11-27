#!/usr/bin/env bash
# S9 D-5 원장 범위 격리(RLS) 계약 시험 — 조회 계정(ksx_reader)이 세션 범위의 행만 보는지, 적재 계정 기준값과 대조.
#   필요: PGHOST·PGPORT, KSX_READER_PASSWORD, KSX_LOADER_PASSWORD (적재·ddl 이후 실행)
#   사용: bash tests/e2e/check_scope_rls.sh [기업=IMPIX] [사업장=HQ]
set -euo pipefail
ENT=${1:-IMPIX}; SITE=${2:-HQ}; DB=${KSX_DB_NAME:-ksx}
R() { PGPASSWORD="$KSX_READER_PASSWORD" psql -X -q -At -U ksx_reader -d "$DB" -v ON_ERROR_STOP=1 "$@"; }
L() { PGPASSWORD="$KSX_LOADER_PASSWORD" psql -X -q -At -U ksx_loader -d "$DB" -v ON_ERROR_STOP=1 -c "$1"; }
as() {  # as <공장 목록> <SQL> — 범위 세션 변수를 걸고 조회 계정으로 실행
  R -c "BEGIN; SET LOCAL app.enterprise_id = '$ENT'; SET LOCAL app.site_id = '$SITE'; SET LOCAL app.plant_ids = '$1'; $2; COMMIT;" | grep -v -e '^BEGIN' -e '^SET' -e '^COMMIT' | tail -1
}
fail=0
ok() { if [ "$2" = "$3" ]; then echo "  OK   $1: $2"; else echo "  실패 $1: 기대 $3 · 결과 $2"; fail=1; fi; }

echo "■ 세션 변수 없음 → 0행(기본 거부)"
ok "Lot(변수 없음)" "$(R -c 'select count(*) from ksx."Lot"')" 0
ok "ItemMaster(변수 없음)" "$(R -c 'select count(*) from ksx."ItemMaster"')" 0

echo "■ 공장 범위"
for P in P1 P2 "P1,P2"; do
  in=$(echo "$P" | sed "s/,/','/g")
  ok "Lot [$P]" "$(as "$P" 'select count(*) from ksx."Lot"')" "$(L "select count(*) from ksx.\"Lot\" where \"EnterpriseID\"='$ENT' and \"SiteID\"='$SITE' and (\"PlantID\" = \"SiteID\" or \"PlantID\" in ('$in'))")"
  ok "TraceParameter [$P]" "$(as "$P" 'select count(*) from ksx."TraceParameter"')" "$(L "select count(*) from ksx.\"TraceParameter\" where \"EnterpriseID\"='$ENT' and \"SiteID\"='$SITE' and (\"PlantID\" = \"SiteID\" or \"PlantID\" in ('$in'))")"
  ok "LotExt(부모 행) [$P]" "$(as "$P" 'select count(*) from ext."LotExt"')" "$(L "select count(*) from ext.\"LotExt\" e join ksx.\"Lot\" l using (\"EnterpriseID\", \"LotID\") where l.\"SiteID\"='$SITE' and (l.\"PlantID\" = l.\"SiteID\" or l.\"PlantID\" in ('$in'))")"
  ok "ItemMaster(기업 공통) [$P]" "$(as "$P" 'select count(*) from ksx."ItemMaster"')" "$(L "select count(*) from ksx.\"ItemMaster\" where \"EnterpriseID\"='$ENT'")"
done
ok "P1 계정에 P2 Lot" "$(as P1 "select count(*) from ksx.\"Lot\" where \"PlantID\" = 'P2'")" 0
ok "P2 계정에 P1 설비" "$(as P2 "select count(*) from ksx.\"Equipment\" where \"PlantID\" = 'P1'")" 0
ok "다른 사업장 변수" "$(R -c "BEGIN; SET LOCAL app.enterprise_id='$ENT'; SET LOCAL app.site_id='XX'; SET LOCAL app.plant_ids='P1'; select count(*) from ksx.\"Lot\"; COMMIT;" | grep -v -e BEGIN -e SET -e COMMIT | tail -1)" 0

echo "■ 우회 경로 차단"
ok "원천 복제(stg) 스키마 사용 권한" "$(R -c "select has_schema_privilege('stg', 'USAGE')")" f
ok "변환 뷰(xfm) 스키마 사용 권한" "$(R -c "select has_schema_privilege('xfm', 'USAGE')")" f
ok "RLS 적용 테이블(ksx·ext)" "$(L "select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname in ('ksx','ext') and c.relkind = 'r' and c.relrowsecurity")" "$(L "select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname in ('ksx','ext') and c.relkind = 'r'")"
if R -c "BEGIN; SET LOCAL app.enterprise_id='$ENT'; SET LOCAL app.site_id='$SITE'; SET LOCAL app.plant_ids='P1'; update ksx.\"Lot\" set \"Note\" = \"Note\" where false; COMMIT;" >/dev/null 2>&1; then
  echo "  실패 쓰기 허용됨"; fail=1; else echo "  OK   쓰기 거부(읽기 전용)"; fi
[ $fail = 0 ] && echo "원장 범위 격리: 충족" || { echo "원장 범위 격리: 미충족"; exit 1; }
