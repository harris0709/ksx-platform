# GPU 서버 — RunPod (S9 D-1)

S9 개발·검증용 GPU는 RunPod 시간제로 쓴다(`mapping/impix/S9_판단사항_결정카드.md` D-1). GPU 서버는 **계산만** 맡고,
원장 DB·Fuseki·AGE·Qdrant·소스는 PC에 그대로 둔다. PC ↔ GPU는 SSH 터널(공개 포트 없음).

| 항목 | 값 |
|---|---|
| GPU | 개발: 재고 있는 24GB GPU(RTX 3090·4090·L4 등)를 볼륨 없이 Any region / 검증: L40S 48GB(D-1 사용 방식 조정, 2026-11-26) |
| 데이터센터 | US-TX-3 |
| 네트워크 볼륨 | `ksx-models` 100GB($7/월) — /workspace에 붙음: 가상환경 /workspace/venv, 모델 /workspace/hf |
| Pod 템플릿 | RunPod 공식 PyTorch(SSH 내장), 볼륨 `ksx-models`, TCP 22 노출 |
| 서버 | `tei_compat.py` — TEI 형식 /embed(bge-m3)·/rerank(bge-reranker-v2-m3), 127.0.0.1:8082 |
| 안전장치 | 선불(자동 결제 끔)·잔액 알림 $20·유휴 30분 자동 정지(`idle_stop.sh`) |

## 쓰는 순서 (PC, MSYS2 UCRT64, 저장소 최상위)

1. RunPod 콘솔 → Pods → Deploy → 템플릿 **Runpod PyTorch**, Region **Any region**, 볼륨 없음(검증 L40S는 US-TX-3 재고가 있으면 `ksx-models`), GPU 1개, **On-Demand** → Deploy. 계정의 SSH 키가 자동으로 들어간다.
2. Pod → **Connect** → "SSH over exposed TCP"의 `root@<IP> -p <PORT>`를 확인.
3. 설치·예열: `bash infra/gpu/runpod/gpu.sh up <IP> <PORT>` (처음 수 분 — 모델 약 5GB 받기, 이후 1분)
4. 새 창에서 터널: `bash infra/gpu/runpod/gpu.sh tunnel <IP> <PORT>` (열어 둔다)
5. 확인: `bash infra/gpu/runpod/gpu.sh check`
6. 도구가 GPU를 쓰게: `export EMBED_URL=http://host.docker.internal:8082 RERANK_URL=http://host.docker.internal:8082`
   → `cd infra/docker-compose && docker compose --profile tools run --rm -e S5_PLAN -e EMBED_URL -e RERANK_URL s5-tools sync`
7. 끝나면 **⋮ → Terminate Pod**(Stop 아님 — 멈춘 Pod도 디스크 요금이 나간다). 잊어도 30분 유휴면 스스로 멈춘다(그 뒤 Terminate).

## 종료 점검표 (개발·검증 끝날 때 — D-1)
결과가 PC·GitHub에 있는지 → (미세조정했다면) 결과물 내려받기 → Pod 삭제 → 볼륨 `ksx-models` 삭제 → SSH 키 회수(Credentials) → 다음 달 청구서 0 확인.

## 문제 해결
| 증상 | 원인 | 해결 |
|---|---|---|
| Pod를 켤 수 없음(재고 없음) | US-TX-3 L40S 소진(재고 Low) | 잠시 뒤 다시, 또는 볼륨 없이 다른 데이터센터 48GB급 Pod → `gpu.sh up`(모델 새로 받기 5~10분) |
| `gpu.sh up` 접속 거부 | Pod가 아직 뜨는 중 / TCP 22 미노출 | 1~2분 뒤 다시, 템플릿에 TCP 22 노출 확인 |
| 도구에서 `임베딩 서버 접속 실패 host.docker.internal` | 터널이 127.0.0.1에만 열림 | `GPU_BIND=0.0.0.0 bash …/gpu.sh tunnel …`(Windows 방화벽 허용 확인) |
| 30분 뒤 Pod가 멈춤 | 유휴 자동 정지(정상) | 콘솔에서 Start → `gpu.sh up` 다시(1분) |
