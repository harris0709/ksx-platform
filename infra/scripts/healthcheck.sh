#!/usr/bin/env bash
# 부록 A S0 체크: 서비스 헬스체크 / 스키마 4개 / realm·클레임 / OPA 기본 정책 / 비밀 저장소
set -uo pipefail
# Windows(Git Bash·MSYS2)에서 /opt/... 같은 컨테이너 경로가 C:/... 로 바뀌지 않게 함
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
DIR="$(cd "$(dirname "$0")/../docker-compose" && pwd)"
cd "$DIR"
set -a; source .env; set +a
ok=0; fail=0
pass() { printf '  [OK]   %s\n' "$1"; ok=$((ok+1)); }
bad()  { printf '  [FAIL] %s\n' "$1"; fail=$((fail+1)); }
chk()  { local name="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$name"; else bad "$name"; fi; }

echo "1) 컨테이너 상태"
for s in postgres kafka airflow-webserver airflow-scheduler fuseki ontop qdrant keycloak opa; do
  st=$(docker compose ps --format '{{.Health}}' "$s" 2>/dev/null)
  [[ "$st" == "healthy" ]] && pass "$s ($st)" || bad "$s (${st:-not running})"
done

echo "2) 엔드포인트"
chk "PostgreSQL 5432"    docker compose exec -T postgres pg_isready -U postgres -d ksx
chk "Kafka 29092"        docker compose exec -T kafka /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
chk "Airflow :8080"      curl -fsS http://localhost:8080/health
chk "Fuseki :3030/ksx"   curl -fsS "http://localhost:3030/ksx/query?query=ASK%7B%7D"
chk "Ontop :8081/sparql" curl -fsS "http://localhost:8081/sparql?query=ASK%7B%3Fs%20%3Fp%20%3Fo%7D"
chk "Qdrant :6333"       curl -fsS -H "api-key: $QDRANT_API_KEY" http://localhost:6333/collections
chk "Keycloak ready"     sh -c "curl -fsS http://localhost:9000/health/ready | grep -q UP"
chk "Keycloak realm ksx" curl -fsS http://localhost:8180/realms/ksx/.well-known/openid-configuration
chk "OPA :8181"          curl -fsS http://localhost:8181/health

echo "3) 스키마 4개 (stg·ksx·ext·audit)"
n=$(docker compose exec -T postgres psql -U postgres -d ksx -tAc \
  "select count(*) from pg_namespace where nspname in ('stg','ksx','ext','audit')" 2>/dev/null | tr -d '[:space:]')
[[ "$n" == "4" ]] && pass "스키마 4개" || bad "스키마 ${n:-?}개"

echo "4) 비밀 저장소(.env)"
[[ -f .env ]] && pass ".env 존재" || bad ".env 없음 (../scripts/gen-secrets.sh 실행)"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) pass ".env 권한 (Windows NTFS: chmod 미적용, 확인 생략)" ;;
  *) [[ "$(stat -c %a .env 2>/dev/null || stat -f %Lp .env)" == "600" ]] && pass ".env 권한 600" || bad ".env 권한 (chmod 600 .env)" ;;
esac
# 현재 폴더(cd "$DIR" 완료) 기준으로 확인 — Windows git.exe 에 /c/... 경로를 넘기지 않음
git check-ignore -q .env && pass ".env Git 제외" || bad ".env 가 .gitignore 에 없음"

echo; echo "결과: OK $ok / FAIL $fail"
[[ $fail -eq 0 ]]
