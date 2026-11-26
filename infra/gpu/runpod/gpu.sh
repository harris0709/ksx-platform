#!/usr/bin/env bash
# PC(MSYS2 UCRT64)에서 GPU 서버(RunPod Pod) 다루기 — Windows OpenSSH를 쓴다.
#   bash infra/gpu/runpod/gpu.sh up     <IP> <PORT>   # 서버 파일 복사 → 설치·예열(처음 수 분, 이후 1분)
#   bash infra/gpu/runpod/gpu.sh tunnel <IP> <PORT>   # PC 127.0.0.1:8082 → Pod 8082 (창을 열어 둔다, Ctrl+C로 끊음)
#   bash infra/gpu/runpod/gpu.sh check                # 터널로 /health·임베딩·재정렬 한 번씩
#   bash infra/gpu/runpod/gpu.sh log    <IP> <PORT>   # 서버·유휴 정지 로그
# IP·PORT: RunPod 콘솔 → Pod → Connect → "SSH over exposed TCP"의 root@<IP> -p <PORT>
set -euo pipefail
OSSH=/c/Windows/System32/OpenSSH
SSH="$OSSH/ssh.exe"; SCP="$OSSH/scp.exe"
[ -x "$SSH" ] || { SSH=ssh; SCP=scp; }
KEY="${RUNPOD_KEY:-${USERPROFILE:-$HOME}/.ssh/runpod_ed25519}"
HERE="$(cd "$(dirname "$0")" && pwd)"
LPORT="${GPU_LOCAL_PORT:-8082}"
BIND="${GPU_BIND:-127.0.0.1}"   # 도커 컨테이너가 host.docker.internal로 못 붙으면 GPU_BIND=0.0.0.0 (방화벽 확인)
opts=(-i "$KEY" -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=30)
cmd="${1:-}"; ip="${2:-}"; port="${3:-}"
need() { [ -n "$ip" ] && [ -n "$port" ] || { echo "사용: $0 $cmd <IP> <PORT>"; exit 2; }; }
case "$cmd" in
  up)
    need
    "$SSH" "${opts[@]}" -p "$port" "root@$ip" "mkdir -p /workspace/ksx-gpu"
    "$SCP" "${opts[@]}" -P "$port" "$HERE/tei_compat.py" "$HERE/setup.sh" "$HERE/idle_stop.sh" "root@$ip:/workspace/ksx-gpu/"
    "$SSH" "${opts[@]}" -p "$port" "root@$ip" "bash /workspace/ksx-gpu/setup.sh"
    echo "다음: bash $0 tunnel $ip $port  (새 창에서, 열어 둔 채로)";;
  tunnel)
    need
    echo "터널 $BIND:$LPORT → Pod 8082 (Ctrl+C로 끊음). 도구는 EMBED_URL=http://host.docker.internal:$LPORT 로 붙는다"
    exec "$SSH" "${opts[@]}" -N -L "$BIND:$LPORT:127.0.0.1:8082" -p "$port" "root@$ip";;
  check)   # 본문의 한글은 \u 표기 — Windows curl이 명령줄 한글을 UTF-8이 아닌 코드페이지로 보내 400이 났다
    curl -fsS "http://127.0.0.1:$LPORT/health"; echo
    curl -fsS -H 'Content-Type: application/json' -d '{"inputs":["\uae08\ud615\uc628\ub3c4 \uc0c1\ud55c \ucd08\uacfc"]}' "http://127.0.0.1:$LPORT/embed" \
      | python -c "import json,sys; v=json.load(sys.stdin); print('임베딩', len(v), 'x', len(v[0]))"
    curl -fsS -H 'Content-Type: application/json' -d '{"query":"\uae08\ud615\uc628\ub3c4 \uc0c1\ud55c","texts":["\uc124\ube44 \ud30c\ub77c\ubbf8\ud130 \uae08\ud615\uc628\ub3c4","\ud488\uc9c8\ube44\uc6a9"]}' "http://127.0.0.1:$LPORT/rerank"; echo;;
  log)
    need
    "$SSH" "${opts[@]}" -p "$port" "root@$ip" "tail -20 /workspace/ksx-gpu/server.log; echo ---; tail -5 /workspace/ksx-gpu/idle.log; nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv";;
  *) sed -n '2,8p' "$0"; exit 2;;
esac
