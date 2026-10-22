#!/usr/bin/env bash
# 3.1 절차 6 — 개발용 비밀 생성: .env.example → .env (CHANGE_ME를 무작위 값으로 치환)
#   .env 는 .gitignore 대상. 운영은 같은 키를 Vault/Kubernetes Secret 에 등록한다.
set -euo pipefail
# Windows(Git Bash·MSYS2)에서 /opt/... 같은 컨테이너 경로가 C:/... 로 바뀌지 않게 함
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL="*"
DIR="$(cd "$(dirname "$0")/../docker-compose" && pwd)"
SRC="$DIR/.env.example"; DST="$DIR/.env"
rand() { LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c "${1:-32}"; }
fernet() { head -c 32 /dev/urandom | base64 | tr '+/' '-_'; }
# --add-missing: 기존 .env 는 그대로 두고 .env.example 에 새로 생긴 키만 추가(기존 비밀번호 유지)
if [[ -f "$DST" && "${1:-}" == "--add-missing" ]]; then
  added=0
  while IFS= read -r line; do
    [[ "$line" =~ ^[A-Z_][A-Z0-9_]*= ]] || continue
    key="${line%%=*}"
    grep -q "^${key}=" "$DST" && continue
    case "$line" in
      *=CHANGE_ME_FERNET*) echo "${key}=$(fernet)" >> "$DST" ;;
      *=CHANGE_ME*)        echo "${key}=$(rand 32)" >> "$DST" ;;
      *)                   echo "${line%%  #*}" >> "$DST" ;;
    esac
    echo "  추가: ${key}"; added=$((added+1))
  done < "$SRC"
  echo "새 키 ${added}개 추가: $DST"; exit 0
fi
if [[ -f "$DST" && "${1:-}" != "--force" ]]; then
  echo "이미 $DST 가 있습니다. 새 키만 추가하려면 --add-missing, 덮어쓰려면 --force (기존 DB 볼륨 비밀번호와 어긋나므로 주의)"; exit 1
fi
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
