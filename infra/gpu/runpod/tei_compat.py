"""GPU 서버(RunPod)용 TEI 호환 임베딩·재정렬 서버 — ksxkg(Embedder·Reranker)가 그대로 붙는다.

  POST /embed  {"inputs": [..], "normalize": true, "truncate": true}  → [[float × 1024], ..]
  POST /rerank {"query": "..", "texts": [..], "raw_scores": false}     → [{"index": i, "score": s}, ..] (점수 내림차순)
  GET  /health                                                         → {"embed": 모델, "rerank": 모델, "idle_seconds": n}

  python tei_compat.py --port 8082                       # 모델: EMBED_MODEL(BAAI/bge-m3) · RERANK_MODEL(BAAI/bge-reranker-v2-m3)
  모델 파일은 HF_HOME(/workspace/hf — 네트워크 볼륨)에 받아 두고 다시 켤 때 재사용한다.
  공개 포트로 열지 않는다(127.0.0.1) — PC에서 SSH 터널로만 접속(D-1).
  마지막 요청 시각을 LAST_FILE에 남겨 idle_stop.sh가 유휴 자동 정지를 판단한다.

TEI 대신 이 서버를 쓰는 이유: RunPod 공식 PyTorch 템플릿(SSH 내장)에서 바로 돌릴 수 있고, TEI 이미지는 ENTRYPOINT가 고정돼
SSH 데몬과 두 모델을 한 Pod에 함께 띄우기 어렵다. 출력 형식은 TEI와 같다(정규화 벡터, 재정렬 점수는 시그모이드).
"""
from __future__ import annotations

import argparse
import json
import os
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

EMBED_MODEL = os.environ.get("EMBED_MODEL", "BAAI/bge-m3")
RERANK_MODEL = os.environ.get("RERANK_MODEL", "BAAI/bge-reranker-v2-m3")
LAST_FILE = os.environ.get("LAST_FILE", "/workspace/ksx-gpu/last_request")
MAX_INPUTS = int(os.environ.get("MAX_INPUTS", "256"))


class Models:
    """처음 요청 때 불러온다(시험에서는 가짜 모델로 바꿔 끼운다)."""

    def __init__(self):
        self._lock = threading.Lock()
        self.embedder = None
        self.reranker = None

    def embed(self, texts, normalize=True):
        with self._lock:
            if self.embedder is None:
                from sentence_transformers import SentenceTransformer
                self.embedder = SentenceTransformer(EMBED_MODEL, device="cuda")
            m = self.embedder
        vs = m.encode(texts, batch_size=32, normalize_embeddings=normalize, convert_to_numpy=True)
        return [[float(x) for x in v] for v in vs]

    def rerank(self, query, texts, raw=False):
        with self._lock:
            if self.reranker is None:
                from sentence_transformers import CrossEncoder
                self.reranker = CrossEncoder(RERANK_MODEL, device="cuda", max_length=512)
            m = self.reranker
        import math
        logits = m.predict([(query, t) for t in texts], batch_size=32, activation_fn=None, convert_to_numpy=True)
        scores = [float(x) for x in logits] if raw else [1.0 / (1.0 + math.exp(-float(x))) for x in logits]
        return sorted(({"index": i, "score": s} for i, s in enumerate(scores)), key=lambda r: -r["score"])


MODELS = Models()
STARTED = time.time()


def touch():
    try:
        os.makedirs(os.path.dirname(LAST_FILE), exist_ok=True)
        with open(LAST_FILE, "w") as f:
            f.write(str(int(time.time())))
    except OSError:
        pass


def idle_seconds() -> int:
    try:
        return int(time.time() - os.path.getmtime(LAST_FILE))
    except OSError:
        return int(time.time() - STARTED)


class Handler(BaseHTTPRequestHandler):
    server_version = "ksx-tei-compat/0.1"

    def _send(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):  # 요청 본문(업무 문장)은 남기지 않는다
        pass

    def do_GET(self):
        if self.path == "/health":
            return self._send(200, {"embed": EMBED_MODEL, "rerank": RERANK_MODEL, "idle_seconds": idle_seconds()})
        self._send(404, {"error": "not found"})

    def do_POST(self):
        try:
            n = int(self.headers.get("Content-Length") or 0)
            req = json.loads(self.rfile.read(n) or b"{}")
        except (ValueError, json.JSONDecodeError):
            return self._send(400, {"error": "JSON 본문이 아닙니다"})
        touch()
        try:
            if self.path == "/embed":
                xs = req.get("inputs")
                xs = [xs] if isinstance(xs, str) else xs
                if not isinstance(xs, list) or not xs or not all(isinstance(x, str) for x in xs):
                    return self._send(422, {"error": "inputs는 문자열 목록이어야 합니다"})
                if len(xs) > MAX_INPUTS:
                    return self._send(413, {"error": f"inputs {len(xs)} > {MAX_INPUTS}"})
                return self._send(200, MODELS.embed(xs, normalize=bool(req.get("normalize", True))))
            if self.path == "/rerank":
                q, ts = req.get("query"), req.get("texts")
                if not isinstance(q, str) or not isinstance(ts, list) or not all(isinstance(t, str) for t in ts):
                    return self._send(422, {"error": "query는 문자열, texts는 문자열 목록이어야 합니다"})
                if len(ts) > MAX_INPUTS:
                    return self._send(413, {"error": f"texts {len(ts)} > {MAX_INPUTS}"})
                return self._send(200, MODELS.rerank(q, ts, raw=bool(req.get("raw_scores", False))) if ts else [])
            return self._send(404, {"error": "not found"})
        except Exception as e:  # noqa: BLE001 — 모델 오류는 503으로(ksxkg가 다시 시도)
            return self._send(503, {"error": str(e)[:300]})


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8082)
    ap.add_argument("--warmup", action="store_true", help="시작할 때 두 모델을 미리 불러온다")
    a = ap.parse_args()
    if a.warmup:
        MODELS.embed(["예열"])
        MODELS.rerank("예열", ["예열"])
    touch()
    print(f"tei_compat {a.host}:{a.port} embed={EMBED_MODEL} rerank={RERANK_MODEL}", flush=True)
    ThreadingHTTPServer((a.host, a.port), Handler).serve_forever()


if __name__ == "__main__":
    main()
