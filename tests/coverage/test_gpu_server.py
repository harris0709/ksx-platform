"""GPU 서버(infra/gpu/runpod/tei_compat.py) — TEI와 같은 형식으로 답하는지(가짜 모델, GPU 없이)."""
import importlib.util
import json
import os
import threading
import urllib.request
from http.server import ThreadingHTTPServer

HERE = os.path.dirname(__file__)


def _load(tmp_path):
    os.environ["LAST_FILE"] = str(tmp_path / "last")
    spec = importlib.util.spec_from_file_location("tei_compat", os.path.join(HERE, "..", "..", "infra", "gpu", "runpod", "tei_compat.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)

    class Fake:
        def embed(self, texts, normalize=True):
            return [[1.0] + [0.0] * 1023 for _ in texts]

        def rerank(self, query, texts, raw=False):
            s = [len(set(query) & set(t)) / 10 for t in texts]
            return sorted(({"index": i, "score": x} for i, x in enumerate(s)), key=lambda r: -r["score"])
    m.MODELS = Fake()
    return m


def _post(url, obj):
    req = urllib.request.Request(url, data=json.dumps(obj).encode(), method="POST", headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        return e.code, json.load(e)


def test_gpu_server_tei_format(tmp_path):
    m = _load(tmp_path)
    srv = ThreadingHTTPServer(("127.0.0.1", 0), m.Handler)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{srv.server_address[1]}"
    try:
        code, v = _post(base + "/embed", {"inputs": ["금형온도", "품질비용"], "normalize": True, "truncate": True})
        assert code == 200 and len(v) == 2 and len(v[0]) == 1024
        code, r = _post(base + "/rerank", {"query": "금형온도 상한", "texts": ["품질비용", "설비 금형온도"], "truncate": True})
        assert code == 200 and r[0]["index"] == 1 and set(r[0]) == {"index", "score"}
        assert _post(base + "/embed", {"inputs": [1]})[0] == 422
        assert _post(base + "/rerank", {"query": "q", "texts": []}) == (200, [])
        with urllib.request.urlopen(base + "/health") as h:
            assert json.load(h)["embed"] == "BAAI/bge-m3"
        assert os.path.exists(tmp_path / "last")          # 유휴 자동 정지가 보는 마지막 요청 시각

        # ksxkg가 그대로 붙는다
        import sys
        sys.path.insert(0, os.path.join(HERE, "..", "..", "tools", "ksxkg"))
        from ksxkg.sync import Embedder, Reranker
        assert len(Embedder(base, 1024, 16)(["a", "b", "c"])) == 3
        assert len(Reranker({"url": base})("금형", ["금형온도", "품질"])) == 2
    finally:
        srv.shutdown()
