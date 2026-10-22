#!/usr/bin/env bash
# 3.1 절차 4 확인 — 토큰에 enterpriseId·siteId·plantId·plants·roles 클레임이 들어가는지
#   사용법: ./check-claims.sh [사용자=dev-data]          (ksx-cli, 개발 전용)
#           ./check-claims.sh --service ksx-mcp            (client credentials)
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
if [[ "${1:-}" == "--service" ]]; then
  cid="${2:-ksx-mcp}"
  case "$cid" in ksx-mcp) sec="$KSX_MCP_CLIENT_SECRET";; ksx-bod-gateway) sec="$KSX_BOD_CLIENT_SECRET";; *) echo "unknown client"; exit 1;; esac
  resp=$(curl -fsS -d grant_type=client_credentials -d client_id="$cid" -d client_secret="$sec" "$KC")
else
  resp=$(curl -fsS -d grant_type=password -d client_id=ksx-cli -d scope=openid \
         -d username="${1:-dev-data}" --data-urlencode password="$KSX_DEV_USER_PASSWORD" "$KC")
fi
tok=$(printf '%s' "$resp" | "$PY" -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
payload=$(printf '%s' "$tok" | cut -d. -f2)
"$PY" - "$payload" <<'PY'
import sys, json, base64
p = sys.argv[1]; p += "=" * (-len(p) % 4)
c = json.loads(base64.urlsafe_b64decode(p))
keys = ["sub", "preferred_username", "azp", "enterpriseId", "siteId", "plantId", "plants", "roles"]
print(json.dumps({k: c.get(k) for k in keys}, ensure_ascii=False, indent=2))
missing = [k for k in ("enterpriseId", "siteId", "plantId", "roles") if not c.get(k)]
print("클레임 확인:", "OK" if not missing else f"누락 {missing}")
sys.exit(1 if missing else 0)
PY
