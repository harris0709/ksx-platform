#!/usr/bin/env bash
# 유휴 자동 정지(D-1 안전장치) — 마지막 요청 뒤 IDLE_MIN분(기본 30) 동안 요청이 없으면 Pod를 멈춘다.
#   멈춤(stop)은 GPU 과금을 끊고 /workspace(네트워크 볼륨)는 남긴다. 실패하면 로그만 남기고 잔액 알림($20)에 맡긴다.
IDLE_MIN=${IDLE_MIN:-30}
LAST=${LAST_FILE:-/workspace/ksx-gpu/last_request}
while true; do
  sleep 60
  now=$(date +%s); last=$(stat -c %Y "$LAST" 2>/dev/null || echo "$now")
  idle=$(( (now - last) / 60 ))
  if [ "$idle" -ge "$IDLE_MIN" ]; then
    echo "$(date -Is) 유휴 ${idle}분 — Pod 정지 요청(${RUNPOD_POD_ID:-?})"
    if command -v runpodctl >/dev/null && [ -n "${RUNPOD_POD_ID:-}" ] && runpodctl stop pod "$RUNPOD_POD_ID"; then exit 0; fi
    echo "$(date -Is) 정지 실패 — runpodctl·RUNPOD_POD_ID 확인 필요. 콘솔에서 직접 멈추세요"; sleep 600
  fi
done
