"""E2E 최소 시험: DDL → 시드 적재 → OBDA 실행 → SHACL → 추론 규칙.

PostgreSQL 접속 인자를 환경변수 KSX_TEST_PSQL로 준다(빈 DB 권장). 예:
  KSX_TEST_PSQL="-h localhost -p 5432 -U ksx_admin -d ksx_test" python tests/regression/test_e2e_minimal.py
rdflib, pyshacl이 필요하다.
"""
import io
import os
import shlex
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tests", "e2e"))
sys.path.insert(0, os.path.join(ROOT, "services", "rule-runner"))
CONN = os.environ.get("KSX_TEST_PSQL")


def psql_file(path):
    subprocess.run(["psql", *shlex.split(CONN), "-v", "ON_ERROR_STOP=1", "-q", "-c", "SET client_min_messages = warning", "-f", path], check=True)


def test_e2e_minimal():
    if not CONN:
        print("KSX_TEST_PSQL 미설정 — E2E 시험 생략")
        return
    import obda_exec
    import rdflib
    import pyshacl
    import runner

    subprocess.run(["psql", *shlex.split(CONN), "-q", "-c", "SET client_min_messages = warning; DROP SCHEMA IF EXISTS ksx CASCADE"], check=True)
    for f in ("infra/postgres/init.sql", "ontologies/ddl/ksx.sql", "tests/e2e/seed_minimal.sql", "tests/e2e/seed_transactions.sql"):
        psql_file(os.path.join(ROOT, f))
    buf, old = io.StringIO(), sys.stdout
    sys.stdout = buf
    try:
        obda_exec.main(os.path.join(ROOT, "ontologies/mappings/ksx9101.obda"), CONN)
    finally:
        sys.stdout = old
    data = rdflib.Graph()
    data.parse(data=buf.getvalue(), format="nt")
    data.parse(os.path.join(ROOT, "ontologies/vocab/codelist.ttl"))
    shapes = rdflib.Graph().parse(os.path.join(ROOT, "ontologies/shapes/ksx9101_conformance.ttl"))
    ok, _, txt = pyshacl.validate(data, shacl_graph=shapes, inference="none")
    assert ok, txt[:1500]

    KSX = rdflib.Namespace("https://ontology.impix.co.kr/ksx9101/1.0/")
    bad = rdflib.Graph()
    bad += data
    for t in list(bad.triples((None, KSX.hasLine, None))):
        bad.remove(t)
    assert not pyshacl.validate(bad, shacl_graph=shapes, inference="none")[0], "위반 주입이 검출되지 않음"

    b = runner.Local([])
    b.g += data
    p = runner.load_params(os.path.join(ROOT, "ontologies/rules"))
    p["today"] = "2026-10-20"
    rows = {r["rule"]: r["triples"] for r in runner.run(b, os.path.join(ROOT, "ontologies/rules"), "ACME", "HQ", p, log=io.StringIO())}
    assert rows["R-001"] == 1 and rows["R-003"] >= 1 and rows["R-010"] == 2 and rows["R-100"] >= 1, rows


if __name__ == "__main__":
    test_e2e_minimal()
    print("PASS test_e2e_minimal")
