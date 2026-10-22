#!/usr/bin/env bash
# 3.1 절차 5 확인 — Keycloak 토큰 클레임으로 OPA 사업장 경계 정책 평가
#   사용법: ./check-opa.sh [사용자=dev-data]
set -euo pipefail
# Windows(Git Bash·MSYS2)에서 /opt/... 같은 컨테이너 경로가 C:/... 로 바뀌지 않게 함
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
# Python 찾기: Windows 설치판은 python3 대신 python·py 만 제공(Store 바로가기 python3 는 실행 안 됨)
PY=""
for c in python3 python py; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" >/dev/null 2>&1; then PY="$c"; break; fi
done
[[ -n "$PY" ]] || { echo "Python 3.8 이상을 찾지 못했습니다. python --version 으로 확인하세요."; exit 1; }
export PYTHONUTF8=1 PYTHONIOENCODING=utf-8
DIR="$(cd "$(dirname "$0")/../docker-compose" && pwd)"
set -a; source "$DIR/.env"; set +a
KC="${KC_URL:-http://localhost:8180}/realms/ksx/protocol/openid-connect/token"
OPA="${OPA_URL:-http://localhost:8181}"
tok=$(curl -fsS -d grant_type=password -d client_id=ksx-cli -d scope=openid -d username="${1:-dev-data}" \
      --data-urlencode password="$KSX_DEV_USER_PASSWORD" "$KC" | "$PY" -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
claims=$(printf '%s' "$tok" | cut -d. -f2 | "$PY" -c 'import sys,json,base64;p=sys.stdin.read().strip();p+="="*(-len(p)%4);print(json.dumps(json.loads(base64.urlsafe_b64decode(p))))')
echo "■ 허용 Named Graph / 접두 / 원장 세션 변수"
for rule in graphs graph_prefixes ledger_session; do
  printf '%s: ' "$rule"
  curl -fsS -X POST "$OPA/v1/data/ksx/authz/$rule" -H 'Content-Type: application/json' \
       -d "{\"input\":{\"claims\":$claims}}" | "$PY" -c 'import sys,json;print(json.dumps(json.load(sys.stdin).get("result"),ensure_ascii=False))'
done
echo "■ 경계 시험"
# 파일은 bash(cat)가 읽고 Python 에는 내용만 전달 — Windows python.exe 는 /c/... 경로를 못 읽음
base=$(cat "$DIR/opa/policies/ksx/config/data.json" | "$PY" -c 'import sys,json;print(json.load(sys.stdin)["graph_base"])')
for g in "${base}ACME/HQ/P1" "${base}ACME/HQ/P2" "${base}ACME/BR/P1" "${base}bod/BOD-0001"; do
  r=$(curl -fsS -X POST "$OPA/v1/data/ksx/authz/allow_graph" -H 'Content-Type: application/json' \
       -d "{\"input\":{\"claims\":$claims,\"graph\":\"$g\"}}" | "$PY" -c 'import sys,json;print(json.load(sys.stdin).get("result"))')
  printf '  %-6s %s\n' "$r" "$g"
done
