#!/usr/bin/env bash
# 3.1 절차 6 — 개발용 비밀 생성: .env.example → .env (CHANGE_ME를 무작위 값으로 치환)
#   .env 는 .gitignore 대상. 운영은 같은 키를 Vault/Kubernetes Secret 에 등록한다.
set -euo pipefail
# Windows(Git Bash·MSYS2)에서 /opt/... 같은 컨테이너 경로가 C:/... 로 바뀌지 않게 함
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
DIR="$(cd "$(dirname "$0")/../docker-compose" && pwd)"
SRC="$DIR/.env.example"; DST="$DIR/.env"
if [[ -f "$DST" && "${1:-}" != "--force" ]]; then
  echo "이미 $DST 가 있습니다. 덮어쓰려면 --force (기존 DB 볼륨 비밀번호와 어긋나므로 주의)"; exit 1
fi
rand() { LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-32}"; }
fernet() { head -c 32 /dev/urandom | base64 | tr '+/' '-_'; }
tmp="$(mktemp)"
while IFS= read -r line; do
  case "$line" in
    *=CHANGE_ME_FERNET*) echo "${line%%=*}=$(fernet)" ;;
    *=CHANGE_ME*)        echo "${line%%=*}=$(rand 32)" ;;
    *)                   echo "$line" ;;
  esac
done < "$SRC" > "$tmp"
mv "$tmp" "$DST"; chmod 600 "$DST"
echo "생성: $DST  (커밋 금지)"
grep -n "=CHANGE_ME" "$DST" && { echo "치환되지 않은 값이 있습니다"; exit 1; } || true
