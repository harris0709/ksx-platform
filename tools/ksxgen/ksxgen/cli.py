"""ksxgen 명령행.

  python -m ksxgen build --std standards --out ontologies [--config ksxgen.yaml]
  python -m ksxgen check --std standards --out ontologies      # 커버리지 + 생성물 최신 여부
  python -m ksxgen build --std standards --ext extensions/impix --out ontologies   # + 기업 확장
  python -m ksxgen ext-template --out extensions/{기업}/확장정의서.xlsx          # 빈 확장 정의서 양식
  python -m ksxgen ext-sync extensions/{기업}/확장정의서.xlsx --std standards     # 파생 행·시트 채움 + 검사
"""
from __future__ import annotations

import argparse
import hashlib
import os
import sys
import tempfile

from . import emit, vocab
from .model import load

DEFAULTS = {
    "ns": "https://ontology.impix.co.kr/ksx9101/1.0/",
    "data_ns": "https://data.impix.co.kr/",
    "version": "KS X 9101-1:2025 개정안 v1.0",
    "schema": "ksx",
}


def _cfg(path: str | None) -> dict:
    cfg = dict(DEFAULTS)
    if path and os.path.exists(path):
        try:
            import yaml  # 있으면 사용(선택 의존성)
            cfg.update(yaml.safe_load(open(path, encoding="utf-8")) or {})
        except ImportError:
            cfg.update(_simple_yaml(path))
    return cfg


def _simple_yaml(path: str) -> dict:
    """PyYAML이 없을 때: 'key: value' 한 줄 형식만 읽는다(ksxgen.yaml 형식)."""
    out = {}
    for line in open(path, encoding="utf-8"):
        line = line.split("#", 1)[0].strip() if not line.lstrip().startswith("#") else ""
        if ":" in line:
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def build(std: str, out: str, cfg: dict, quiet: bool = False, exts: list[str] | None = None) -> bool:
    m = load(std)
    v = vocab.build(m)
    w = emit._w
    w(os.path.join(out, "tbox", "ksx9101_core.ttl"), emit.tbox(m, v, cfg))
    w(os.path.join(out, "shapes", "ksx9101_conformance.ttl"), emit.shapes(m, v, cfg))
    w(os.path.join(out, "mappings", "ksx9101.obda"), emit.obda(m, v, cfg))
    w(os.path.join(out, "ddl", "ksx.sql"), emit.ddl(m, v, cfg))
    w(os.path.join(out, "vocab", "codelist.ttl"), emit.codelist(m, cfg))
    emit.catalog(m, v, out)
    order, cyc = emit.load_order(m)
    w(os.path.join(out, "load_order.txt"), "# FK 위상 정렬 적재 순서 (ksxgen 생성물)\n" + "\n".join(order) + "\n"
      + ("# 순환으로 정렬되지 않은 테이블: " + ", ".join(cyc) + "\n" if cyc else ""))
    rep, ok = emit.coverage(m, v)
    w(os.path.join(out, "report", "coverage.md"), rep)
    if not quiet:
        print(f"ksxgen: 테이블 {len(m.tables)} · 명사 {m.noun_count} · 속성 {len(v.props)} · "
              f"관계 {sum(len(x) for x in v.refs.values())}+헤더·라인 {len(v.lines)} · 코드 {len(m.codes)} → {out}")
        print("커버리지:", "OK" if ok else "실패 (report/coverage.md 확인)")
    for d in exts or []:
        from . import ext as X
        ok = X.build(d, m, v, cfg, out, quiet) and ok
    return ok


def _digest(root: str) -> dict[str, str]:
    d = {}
    for base, _, files in os.walk(root):
        for f in files:
            if f == ".gitkeep":
                continue
            p = os.path.join(base, f)
            data = open(p, "rb").read().replace(b"\r\n", b"\n")   # 윈도우 CRLF 체크아웃도 같은 내용으로 본다
            d[os.path.relpath(p, root).replace(os.sep, "/")] = hashlib.sha256(data).hexdigest()
    return d


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="ksxgen", description="KS X 9101 표준 컴파일러")
    ap.add_argument("cmd", choices=["build", "check", "ext-template", "ext-sync"])
    ap.add_argument("path", nargs="?", help="ext-sync: 확장 정의서 파일")
    ap.add_argument("--ext", action="append", default=[], help="기업 확장 폴더(extensions/{기업}), 여러 번 지정 가능")
    ap.add_argument("--std", default="standards")
    ap.add_argument("--out", default="ontologies")
    ap.add_argument("--config", default="ksxgen.yaml")
    a = ap.parse_args(argv)
    cfg = _cfg(a.config)
    if a.cmd == "ext-template":
        from . import extform
        out = a.out if a.out.endswith(".xlsx") else os.path.join(a.out, "확장정의서.xlsx")
        print("양식:", extform.template(out))
        return 0
    if a.cmd == "ext-sync":
        from . import ext as X
        if not a.path:
            ap.error("ext-sync 에는 확장 정의서 경로가 필요합니다")
        e, issues = X.sync(a.path, a.std, X.ext_config(os.path.dirname(os.path.abspath(a.path))))
        ne = sum(1 for x in issues if x.level == "오류")
        print(f"ext-sync: {a.path} — 테이블 {len(e.tables)}, 컬럼 {sum(len(t.t.columns) for t in e.tables.values())}, "
              f"관계 {len(e.relations)}, 코드 {len(e.codes)}, 판정 {len(e.judgements)} · 오류 {ne}, 경고 {len(issues) - ne}")
        for x in issues:
            print(f"  {x.level} · {x.where}: {x.msg}")
        return 1 if ne else 0
    if a.cmd == "build":
        return 0 if build(a.std, a.out, cfg, exts=a.ext) else 1
    with tempfile.TemporaryDirectory() as tmp:
        ok = build(a.std, tmp, cfg, quiet=True, exts=a.ext)
        new, cur = _digest(tmp), _digest(a.out)
        stale = sorted(k for k in new if cur.get(k) != new[k])
    print("커버리지:", "OK" if ok else "실패")
    print("생성물 최신 여부:", "OK" if not stale else "다시 생성 필요 → " + ", ".join(stale[:10]))
    return 0 if ok and not stale else 1


if __name__ == "__main__":
    sys.exit(main())
