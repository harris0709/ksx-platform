#!/usr/bin/env bash
# GPU 서버(RunPod Pod)에서 실행 — gpu.sh up이 PC에서 복사해 부른다.
#   /workspace(네트워크 볼륨 ksx-models)에 가상환경·모델을 두므로 두 번째부터는 설치·다운로드 없이 1분 안에 뜬다.
set -euo pipefail
W=/workspace/ksx-gpu
export HF_HOME=/workspace/hf
mkdir -p "$W" "$HF_HOME"
cd "$W"
if [ ! -x /workspace/venv/bin/python ]; then
  echo "[setup] 가상환경 만들기(처음 1회, 수 분)"
  python3 -m venv --system-site-packages /workspace/venv   # 템플릿의 torch(CUDA)를 그대로 쓴다
  /workspace/venv/bin/pip install -q "sentence-transformers>=3.2,<6"
fi
/workspace/venv/bin/python -c "import torch, sentence_transformers as s; print('[setup] torch', torch.__version__, 'cuda', torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else '-', 'sentence-transformers', s.__version__)"
pkill -f tei_compat.py 2>/dev/null || true
pkill -f idle_stop.sh 2>/dev/null || true
nohup env HF_HOME="$HF_HOME" LAST_FILE="$W/last_request" /workspace/venv/bin/python "$W/tei_compat.py" --port 8082 --warmup > "$W/server.log" 2>&1 &
nohup bash "$W/idle_stop.sh" > "$W/idle.log" 2>&1 &
echo "[setup] 모델 예열 중(처음은 모델 받기 약 5GB, 수 분) — 진행: tail -f $W/server.log"
for i in $(seq 1 120); do
  if curl -fsS http://127.0.0.1:8082/health >/dev/null 2>&1; then echo "[setup] 준비됨: $(curl -fsS http://127.0.0.1:8082/health)"; exit 0; fi
  if ! pgrep -f tei_compat.py >/dev/null; then echo "[setup] 서버가 멈춤:"; tail -20 "$W/server.log"; exit 1; fi
  sleep 10
done
echo "[setup] 20분 안에 준비되지 않음:"; tail -20 "$W/server.log"; exit 1
