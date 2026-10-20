"""ksxgen 회귀 시험: 커버리지·생성물 최신 여부·Turtle 문법. pytest 또는 python으로 실행."""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "ksxgen"))

from ksxgen import cli, emit, vocab  # noqa: E402
from ksxgen.model import load  # noqa: E402

STD = os.path.join(ROOT, "standards")


def test_counts_and_coverage():
    m = load(STD)
    v = vocab.build(m)
    assert len(m.tables) == 76 and m.noun_count == 68
    assert sum(t.role == "line" for t in m.tables.values()) == 8
    assert sum(len(x) for x in v.refs.values()) + len(v.lines) == sum(r.physical for r in m.relations) == 609
    _, ok = emit.coverage(m, v)
    assert ok and not v.issues


def test_generated_files_are_current():
    with tempfile.TemporaryDirectory() as tmp:
        cli.build(STD, tmp, cli._cfg(os.path.join(ROOT, "ksxgen.yaml")), quiet=True)
        new, cur = cli._digest(tmp), cli._digest(os.path.join(ROOT, "ontologies"))
        stale = [k for k in new if cur.get(k) != new[k]]
    assert not stale, f"ksxgen build 다시 실행 필요: {stale[:5]}"


def test_turtle_parses():
    try:
        import rdflib
    except ImportError:
        print("rdflib 없음 — Turtle 문법 시험 생략")
        return
    for f in ("tbox/ksx9101_core.ttl", "shapes/ksx9101_conformance.ttl", "vocab/codelist.ttl"):
        g = rdflib.Graph()
        g.parse(os.path.join(ROOT, "ontologies", f), format="turtle")
        assert len(g) > 1000, f


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_"):
            fn()
            print("PASS", name)
