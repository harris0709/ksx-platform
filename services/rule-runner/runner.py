"""rule-runner (S7): 추론 규칙(CONSTRUCT)을 순서대로 실행하고 규칙별 추론 그래프를 교체한다.

운영(Fuseki):
  python services/rule-runner/runner.py --fuseki http://localhost:3030/ksx \
      --ent ACME --site HQ --rules ontologies/rules
  - 데이터셋은 unionDefaultGraph=true로 구성(infra/docker/fuseki/config.ttl) → 기본 그래프 = 모든 Named Graph 합집합
  - 결과는 graph:inferred/{Ent}/{Site}/{RuleID}에 PUT(통째 교체) → 재실행해도 결과가 같다

시험(로컬 파일, rdflib 필요):
  python services/rule-runner/runner.py --local out/seed.nt ontologies/vocab/codelist.ttl --rules ontologies/rules
"""
from __future__ import annotations

import argparse
import datetime as dt
import glob
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

INFERRED = "https://data.impix.co.kr/graph/inferred/{ent}/{site}/{rule}"


def load_params(rules_dir: str) -> dict:
    p = os.path.join(rules_dir, "params.yaml")
    out = {}
    if os.path.exists(p):
        for line in open(p, encoding="utf-8"):
            m = re.match(r"^\s*([A-Za-z_]\w*)\s*:\s*([^#\n]+)", line)
            if m:
                out[m.group(1)] = m.group(2).strip()
    out.setdefault("today", dt.date.today().isoformat())
    return out


def derive(params: dict) -> dict:
    """계산 파라미터: due_limit = today + due_within_days (SPARQL 엔진 간 날짜 연산 차이를 피함)."""
    p = dict(params)
    if "due_within_days" in p:
        p["due_limit"] = (dt.date.fromisoformat(p["today"]) + dt.timedelta(days=int(p["due_within_days"]))).isoformat()
    return p


def render(q: str, params: dict) -> str:
    def sub(m):
        if m.group(1) not in params:
            raise KeyError(f"규칙 파라미터 누락: {m.group(1)}")
        return str(params[m.group(1)])
    return re.sub(r"\$\{(\w+)\}", sub, q)


class Fuseki:
    def __init__(self, url: str):
        self.url = url.rstrip("/")

    def construct(self, q: str) -> bytes:
        req = urllib.request.Request(self.url + "/query", data=urllib.parse.urlencode({"query": q}).encode(),
                                     headers={"Accept": "application/n-triples",
                                              "Content-Type": "application/x-www-form-urlencoded"})
        return urllib.request.urlopen(req, timeout=600).read()

    def put_graph(self, graph: str, nt: bytes) -> None:
        req = urllib.request.Request(self.url + "/data?" + urllib.parse.urlencode({"graph": graph}), data=nt,
                                     method="PUT", headers={"Content-Type": "application/n-triples"})
        urllib.request.urlopen(req, timeout=600).read()


class Local:
    def __init__(self, files: list[str]):
        import rdflib
        self.g = rdflib.Graph()
        for f in files:
            self.g.parse(f)

    def construct(self, q: str) -> bytes:
        res = self.g.query(q).graph
        return res.serialize(format="nt", encoding="utf-8")

    def put_graph(self, graph: str, nt: bytes) -> None:
        self.g.parse(data=nt.decode("utf-8"), format="nt")   # 다음 규칙이 결과를 쓸 수 있게 합침


def run(backend, rules_dir: str, ent: str, site: str, params: dict, log=sys.stdout) -> list[dict]:
    params = derive(params)
    rows = []
    for path in sorted(glob.glob(os.path.join(rules_dir, "*.rq"))):
        rid = os.path.basename(path).split("_", 1)[0]
        t0 = time.time()
        nt = backend.construct(render(open(path, encoding="utf-8").read(), params))
        backend.put_graph(INFERRED.format(ent=ent, site=site, rule=rid), nt)
        row = {"rule": rid, "file": os.path.basename(path), "triples": nt.count(b"\n"),
               "seconds": round(time.time() - t0, 2), "run_at": dt.datetime.now().isoformat(timespec="seconds")}
        rows.append(row)
        log.write(json.dumps(row, ensure_ascii=False) + "\n")
    return rows


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="KS X 9101 추론 규칙 실행기")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--fuseki", help="Fuseki 데이터셋 URL (예: http://localhost:3030/ksx)")
    g.add_argument("--local", nargs="+", help="시험용 RDF 파일들")
    ap.add_argument("--rules", default="ontologies/rules")
    ap.add_argument("--ent", default="ACME")
    ap.add_argument("--site", default="HQ")
    ap.add_argument("--today", help="기준일(YYYY-MM-DD). 기본: 오늘")
    a = ap.parse_args(argv)
    params = load_params(a.rules)
    if a.today:
        params["today"] = a.today
    backend = Fuseki(a.fuseki) if a.fuseki else Local(a.local)
    run(backend, a.rules, a.ent, a.site, params)
    return 0


if __name__ == "__main__":
    sys.exit(main())
