"""ksxgen 명령행.

  python -m ksxgen build --std standards --out ontologies [--config ksxgen.yaml]
  python -m ksxgen check --std standards --out ontologies      # 커버리지 + 생성물 최신 여부
  python -m ksxgen build --std standards --ext extensions/impix --out ontologies   # + 기업 확장
  python -m ksxgen ext-template --out extensions/{기업}/확장정의서.xlsx          # 빈 확장 정의서 양식
  python -m ksxgen ext-sync extensions/{기업}/확장정의서.xlsx --std standards     # 파생 행·시트 채움 + 검사
  python -m ksxgen verify --out ontologies                                       # 문법·DL 선언·일관성(OWL RL)·셰이프·매핑 검증
"""
from __future__ import annotations

import argparse
import glob
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
    cfg["_dir"] = os.path.dirname(os.path.abspath(path)) if path else os.getcwd()
    if path and os.path.exists(path):
        try:
            import yaml  # 있으면 사용(선택 의존성)
            cfg.update(yaml.safe_load(open(path, encoding="utf-8")) or {})
        except ImportError:
            cfg.update(_simple_yaml(path))
    return cfg


def common_nouns(cfg: dict) -> set[str]:
    """기업 공통 그래프에 둘 기준정보 명사(S5 결정 D-2). PyYAML 없이 읽으면 '[A, B]' 문자열이다."""
    v = cfg.get("common_graph_nouns") or []
    if isinstance(v, str):
        v = [x.strip() for x in v.strip("[]").split(",") if x.strip()]
    return set(v)


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
    w(os.path.join(out, "vocab", "uom.ttl"), emit.uom(m, cfg))
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
    ok = derived(m, v, cfg, out, quiet) and ok
    return ok


def derived(m, v, cfg: dict, out: str, quiet: bool) -> bool:
    """OBDA·모델에서 파생: 물질화 매핑, 속성 그래프 스키마, 도구 스키마, 자동 전이 규칙(구현안내서 7.1)."""
    from . import derive
    w = emit._w
    obdas = [os.path.join(out, "mappings", "ksx9101.obda")] + sorted(
        p for p in glob.glob(os.path.join(out, "mappings", "*_ext.obda")))
    texts = [open(p, encoding="utf-8").read() for p in obdas]
    n = 0
    idx = derive.site_index(texts)
    for t in texts:
        for fn, txt in derive.rml(t, idx, common_nouns(cfg)).items():
            w(os.path.join(out, "mappings", "rml", fn), txt)
            n += 1
    w(os.path.join(out, "tbox", "catalog-v001.xml"), derive.import_catalog(out))
    ttls = [os.path.join(out, "tbox", "ksx9101_core.ttl")] + sorted(glob.glob(os.path.join(out, "tbox", "*_ext.ttl")))
    ob, tt = derive.ontop_files(texts, [open(p, encoding="utf-8").read() for p in ttls])
    w(os.path.join(out, "ontop", "ksx.obda"), ob)
    w(os.path.join(out, "ontop", "ksx.ttl"), tt)
    w(os.path.join(out, "graph", "age_schema.sql"), derive.age_schema(texts, cfg.get("graph", "ksx_graph")))
    for fn, txt in derive.tools(out, m).items():
        w(os.path.join(out, "catalog", "tools", fn), txt)
    rdir = os.path.join(cfg.get("_dir", "."), cfg.get("business_rules", "ontologies/rules"))
    skip = derive.business_closures(rdir)
    rules = derive.auto_rules(m, v, skip)
    for old in glob.glob(os.path.join(out, "rules", "A-*.rq")):   # 번호가 바뀌면 이전 생성물이 남지 않게
        os.remove(old)
    for fn, txt in rules.items():
        w(os.path.join(out, "rules", fn), txt)
    if not quiet:
        print(f"ksxgen 파생: 물질화 매핑 {n} · 속성 그래프 스키마 · 도구 스키마 2 · 자동 전이 규칙 {len(rules)}"
              + (f"(업무 규칙이 맡은 {len(skip)} 제외: " + ", ".join(f"{k}←{f}" for k, f in skip.items()) + ")" if skip else "")
              + " · 단위 vocab/uom.ttl")
    return True


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
    ap.add_argument("cmd", choices=["build", "check", "verify", "ext-template", "ext-sync"])
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
    if a.cmd == "verify":
        from .verify import verify
        return 0 if verify(a.out) else 1
    with tempfile.TemporaryDirectory() as tmp:
        ok = build(a.std, tmp, cfg, quiet=True, exts=a.ext)
        new, cur = _digest(tmp), _digest(a.out)
        stale = sorted(k for k in new if cur.get(k) != new[k])
    print("커버리지:", "OK" if ok else "실패")
    print("생성물 최신 여부:", "OK" if not stale else "다시 생성 필요 → " + ", ".join(stale[:10]))
    return 0 if ok and not stale else 1


if __name__ == "__main__":
    sys.exit(main())
