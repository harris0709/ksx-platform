"""S2 매핑 엔진: 매핑 계획(s2_plan.yaml) + S1 추출 + 표준·확장 모델 → 매핑 명세·대응표·검토본·완료 점검.

계획에는 사람이 판단한 것(구조 유형·조인·기본 속성·덮어쓰기·제외·코드·단위·식별 대응)만 적는다.
나머지 컬럼은 결정론 매처가 채우고, 결과마다 매칭 단계와 근거를 남긴다.
"""
from __future__ import annotations

import csv
import json
import os
import re
from collections import OrderedDict, defaultdict
from dataclasses import dataclass, field

import yaml

from . import matcher as M
from .stdmodel import AUDIT, BASE, Std, load_std

FROM_RE = re.compile(r"\b([a-z][a-z0-9_]*)\b")


@dataclass
class AttrMap:
    attr: str
    src: str | None                  # 원천 컬럼(조인 테이블은 별칭.컬럼)
    stage: str                       # exact/normalized/component/korean/manual/const/xref/derived
    status: str                      # draft/reviewed/approved
    code: str | None = None          # 원천 코드 그룹
    uom: str | None = None
    transform: str | None = None
    note: str | None = None
    auto: str | None = None          # 결정론 매처가 낸 후보(덮어쓴 경우 비교용)
    evidence: str | None = None
    layer: str = "core"


@dataclass
class SpecResult:
    spec: dict
    noun: str
    system: str
    table: str
    maps: "OrderedDict[str, AttrMap]" = field(default_factory=OrderedDict)
    excluded: dict = field(default_factory=dict)
    unresolved: dict = field(default_factory=dict)       # column → 후보 목록
    used_cols: set = field(default_factory=set)
    join_cols: set = field(default_factory=set)
    missing: list = field(default_factory=list)          # 필수 속성 미매핑
    aliases: dict = field(default_factory=dict)          # 별칭 → 테이블
    touched: dict = field(default_factory=dict)          # (table, col) → [(판정, 대상/사유)]

    def resolve(self, q: str) -> tuple[str, str]:
        if "." in q:
            a, c = q.split(".", 1)
            if a in self.aliases:
                return self.aliases[a], c
        return self.table, q.split(".")[-1]

    def touch(self, q: str, kind: str, what: str):
        self.touched.setdefault(self.resolve(q), []).append((kind, what))


def _rel(base, p):
    return p if os.path.isabs(p) else os.path.join(base, p)


class Engine:
    def __init__(self, plan_path: str, repo: str):
        self.repo = repo
        self.plan = yaml.safe_load(open(plan_path, encoding="utf-8"))
        P = self.plan
        for s in P.get("specs", []):              # YAML 1.1: 'on' 키가 True로 읽힌다
            for j in s.get("join", []) or []:
                if True in j:
                    j["on"] = j.pop(True)
        self.std: Std = load_std(_rel(repo, P.get("std", "standards")), _rel(repo, P["ext"]) if P.get("ext") else None)
        self.abbrev = yaml.safe_load(open(_rel(repo, P["abbrev"]), encoding="utf-8")) or {}
        bad = [k for k in self.abbrev if not isinstance(k, str)]
        if bad:                                   # YAML 1.1: NO·YES·ON 같은 키는 따옴표 필요
            raise SystemExit(f"automap: 약어 사전 키가 문자열이 아님(따옴표 필요): {bad}")
        self.ko_syn = self.abbrev.pop("_ko", {}) if isinstance(self.abbrev, dict) else {}
        ext = json.load(open(_rel(repo, P["s1_extract"]), encoding="utf-8"))
        self.src = {f"{t['schema']}.{t['table']}": t for t in ext["tables"]}
        self.values = {}
        for c in ext["codes"]["candidates"]:
            self.values[(c["table"], c["column"])] = list(c["values"].keys())
        for t in ext["tables"]:
            for c in t["columns"]:
                k = (f"{t['schema']}.{t['table']}", c["name"])
                if k not in self.values and c.get("profile") and c["profile"].get("top"):
                    self.values[k] = [v for v, _ in c["profile"]["top"]]
        self.system_of = {f"{t['schema']}.{t['table']}": t["system"] for t in ext["tables"]}
        self.results: list[SpecResult] = []
        self.issues: list[tuple[str, str, str]] = []           # (수준, 위치, 내용)

    # ------------------------------------------------------------------ 컬럼 정보
    def cols(self, table: str) -> list[dict]:
        return self.src[table]["columns"] if table in self.src else []

    def col(self, table: str, name: str) -> dict | None:
        return next((c for c in self.cols(table) if c["name"] == name), None)

    def samples(self, table: str, name: str, n=5) -> str:
        c = self.col(table, name)
        if not c or not c.get("profile"):
            return ""
        return ", ".join(str(v) for v, _ in (c["profile"].get("top") or [])[:n])

    # ------------------------------------------------------------------ 실행
    def run(self):
        defaults = self.plan.get("defaults", {})
        accept = bool(self.plan.get("accept_auto"))
        for sp in self.plan["specs"]:
            noun = self.std.nouns.get(sp["noun"])
            if noun is None:
                self.issues.append(("오류", sp["noun"], "표준·확장 명사에 없음"))
                continue
            table = sp["source"]
            if table not in self.src:
                self.issues.append(("오류", f"{sp['noun']} ← {table}", "S1 추출에 없는 원천 테이블"))
                continue
            r = SpecResult(sp, noun.name, self.system_of[table], table)
            srccols = [(None, c["name"], c.get("comment"), table) for c in self.cols(table)]
            for j in sp.get("join", []):
                a = j.get("as") or j["table"].split(".")[-1]
                r.aliases[a] = j["table"]
                srccols += [(a, c["name"], c.get("comment"), j["table"]) for c in self.cols(j["table"])]
                for x in re.findall(r"\b(?:(\w+)\.)?([a-z][a-z0-9_]*)\b", j.get("on", "")):
                    q = f"{x[0]}.{x[1]}" if x[0] else x[1]
                    r.join_cols.add(q)
                    r.touch(q, "조인 키", f"{sp['noun']} 조인")
                for c, why in (j.get("exclude") or {}).items():
                    r.excluded[f"{a}.{c}"] = why
            self._check_filter(sp, r)
            attrs = [a for a in noun.attrs.values()]
            # 1) 계획의 덮어쓰기·상수·파생
            base = dict(defaults.get("base", {}))
            base.update(sp.get("base", {}))
            for an, expr in base.items():
                if an not in noun.attrs:
                    continue
                stage = "const" if str(expr).startswith("const(") else ("xref" if str(expr).startswith("xref(") else "derived")
                src = None
                m = re.match(r"xref\(\w+,\s*([\w.]+)\)", str(expr))
                if m:
                    src = m.group(1)
                    r.used_cols.add(src.split(".")[-1])
                r.maps[an] = AttrMap(an, src, stage, "reviewed", transform=str(expr), layer=noun.attrs[an].layer)
            for an, v in (sp.get("map") or {}).items():
                if an not in noun.attrs:
                    self.issues.append(("오류", f"{sp['noun']}.{an}", f"표준·확장 속성에 없음({table})"))
                    continue
                v = {"from": v} if isinstance(v, str) else dict(v)
                src = v.get("from")
                if src and not re.search(r"[,+ ]", src):    # 조합(여러 컬럼)에 쓰인 컬럼은 단독 매칭도 계속 받는다
                    r.used_cols.add(src.split(".")[-1])
                stage = "manual" if src else ("const" if "const" in str(v.get("transform", "")) else "derived")
                r.maps[an] = AttrMap(an, src, stage, v.get("status", "reviewed"), v.get("code"), v.get("uom"),
                                     v.get("transform"), v.get("note"), layer=noun.attrs[an].layer)
            for c, why in (sp.get("exclude") or {}).items():
                r.excluded[c] = why
            # 2) 결정론 매칭(모든 원천 컬럼) — 덮어쓴 경우에도 비교용으로 계산
            taken = {m.attr for m in r.maps.values()}
            for al, cname, comment, tb in srccols:
                q = f"{al}.{cname}" if al else cname
                free = [a for a in attrs if a.en not in BASE]
                hit = M.match(cname, comment, free, self.abbrev, self.ko_syn)
                mapped_here = [m for m in r.maps.values() if m.src and q in re.split(r"[,+ ]+", m.src)
                               and m.stage not in ("const", "xref")]
                in_combo = False
                if mapped_here:
                    singles = []
                    for m in mapped_here:
                        if re.search(r"[,+ ]", m.src):      # 여러 컬럼 조합(식별자 생성·계산) = 검토자 파생
                            m.stage, m.evidence = "derived", m.evidence or "여러 컬럼 조합 — 검토자 파생"
                            in_combo = True
                            continue
                        singles.append(m)
                    for m in singles:
                        if hit and hit.attr.en == m.attr:
                            m.stage, m.evidence = hit.stage, hit.evidence
                        elif hit:
                            m.auto, m.evidence = hit.attr.en, f"결정론 후보 {hit.attr.en}({hit.stage}) → 검토자 수정"
                        else:
                            m.evidence = m.evidence or "결정론 미해소 → 검토자 판단"
                    if singles:
                        continue
                if q in r.excluded or q in r.join_cols or (al is None and cname in r.used_cols):
                    continue
                if al is not None:          # 조인 테이블 컬럼은 계획에 명시한 것만 쓴다(자동 매칭 안 함)
                    continue
                if hit and hit.attr.en not in taken:
                    a = hit.attr
                    r.maps[a.en] = AttrMap(a.en, q, hit.stage, "reviewed" if accept else "draft", evidence=hit.evidence,
                                           layer=a.layer)
                    taken.add(a.en)
                    r.used_cols.add(cname)
                elif not in_combo:                  # 조합에만 쓰인 컬럼은 이미 판정됨(매핑)
                    r.unresolved[q] = M.candidates(cname, comment, attrs, self.abbrev)
            if sp.get("rest"):                     # 파생 명세: 남은 원천 컬럼은 주 명세에서 판정
                for q in list(r.unresolved):
                    r.excluded[q] = sp["rest"]
                    del r.unresolved[q]
            self._infer_transforms(r, noun)
            for m in r.maps.values():
                for x in re.split(r"[,+ ]+", m.src or ""):
                    if x:
                        r.touch(x, "확장" if m.layer == "ext" else "매핑", f"{r.noun}.{m.attr}")
            for c, why in r.excluded.items():
                r.touch(c, "제외", why)
            # 3) 필수 속성(UK·NOT NULL·기본 3종)
            for a in noun.attrs.values():
                if a.required and a.en not in r.maps:
                    r.missing.append(a.en)
            self.results.append(r)
        self._check_codes_units_xref()
        ap = self.plan.get("approval") or {}
        if ap.get("status") == "approved":            # 업무 승인(⑦) — 계획의 승인 기록으로 모든 매핑을 approved로
            for r in self.results:
                for m in r.maps.values():
                    m.status = "approved"
        return self

    # ------------------------------------------------------------------ 필터 점검
    _SQL_WORDS = {"and", "or", "not", "in", "is", "null", "like", "between", "select", "from", "where", "true", "false",
                  "current_date", "current_timestamp", "case", "when", "then", "else", "end", "as", "distinct"}

    def _check_filter(self, sp, r):
        """filter의 컬럼이 원천(주 테이블·조인 별칭)에 있는지 본다 — 함수·SQL 예약어·따옴표 문자열·스키마 이름은 건너뛴다."""
        f = sp.get("filter")
        if not f:
            return
        txt = re.sub(r"'[^']*'", "''", f)
        schemas = {t.split(".")[0] for t in self.src}
        names = {c["name"] for c in self.cols(r.table)}
        for m in re.finditer(r"\b(?:(\w+)\.)?([A-Za-z_][A-Za-z0-9_]*)\b(\s*\()?", txt):
            q, c, fn = m.group(1), m.group(2), m.group(3)
            if fn or c.lower() in self._SQL_WORDS or c in schemas or q in schemas or c.isdigit():
                continue
            if q:
                tb = r.aliases.get(q)
                ok = tb is not None and c in {x["name"] for x in self.cols(tb)}
            else:
                ok = c in names
            if not ok:
                self.issues.append(("오류", f"{sp['noun']} ← {r.table}",
                                    f"filter의 컬럼 '{(q + '.') if q else ''}{c}'이(가) 원천에 없음: {f}"))

    # ------------------------------------------------------------------ 변환 추론
    def _src_col(self, r, q):
        al, _, c = q.rpartition(".")
        return self.col(r.aliases.get(al, r.table) if al else r.table, c) or {}

    def _infer_transforms(self, r, noun):
        """원천 형식·표준 자료형으로 변환을 정한다(계획에 transform이 있으면 그대로)."""
        bycol = (self.plan.get("defaults") or {}).get("transform_by_column", {})
        for m in r.maps.values():
            if m.transform or not m.src or re.search(r"[,+ ]", m.src):
                continue
            c = m.src.split(".")[-1]
            if c in bycol:
                m.transform = f"{bycol[c]}({m.src})"
                continue
            dt = noun.attrs[m.attr].dtype
            ty = (self._src_col(r, m.src).get("type") or "")
            vals = self.values.get((r.aliases.get(m.src.rpartition(".")[0], r.table) if "." in m.src else r.table, c), [])
            if dt in ("date", "dateTime"):
                if ty.endswith("(8)"):
                    m.transform = f"to_date8({m.src})"
                elif ty.endswith("(14)"):
                    m.transform = f"to_ts14({m.src})"
                elif ty.startswith("timestamp"):
                    m.transform = f"to_ts({m.src})" if dt == "dateTime" else f"to_date({m.src})"
                elif ty.endswith("(6)"):
                    m.transform = f"ym_first({m.src})"
            elif dt == "boolean" and set(map(str, vals)) <= {"Y", "N", "1", "0"}:
                m.transform = f"yn({m.src})"
            elif dt == "int" and ty.startswith("numeric"):
                m.transform = f"int({m.src})"

    # ------------------------------------------------------------------ 코드·단위·식별 대응 점검
    def code_rows(self) -> list[dict]:
        rows = []
        for g in self.plan.get("codes", []):
            for sc, kc in g["map"].items():
                rows.append({"src_system": g["system"], "src_group": g["group"], "src_code": str(sc),
                             "ksx_group": g["ksx_group"], "ksx_code": kc, "rule": g.get("rule", {}).get(str(sc), "equal")
                             if isinstance(g.get("rule"), dict) else g.get("rule", "equal"), "note": g.get("note", "")})
        return rows

    def _check_codes_units_xref(self):
        groups = {(g["system"], g["group"]): g for g in self.plan.get("codes", [])}
        for g in self.plan.get("codes", []):
            known = self.std.codes.get(g["ksx_group"])
            if known is None:
                self.issues.append(("오류", f"코드 {g['group']}", f"표준·확장 코드 그룹 {g['ksx_group']} 없음"))
                continue
            for sc, kc in g["map"].items():
                if kc not in known and kc != "-":
                    self.issues.append(("오류", f"코드 {g['group']}/{sc}", f"{g['ksx_group']}에 코드 {kc} 없음"))
        units = {str(u["src_unit"]): u for u in self.plan.get("units", [])}
        for u in units.values():
            if u["ksx_uom"] not in self.std.uoms:
                lv = "경고" if u.get("ext") else "오류"
                self.issues.append((lv, f"단위 {u['src_unit']}", f"표준 단위코드 {u['ksx_uom']} 없음"
                                    + (" — 확장 단위 후보(단위그룹 확장)" if u.get("ext") else "")))
        xref = self.plan.get("xref", {})
        for r in self.results:
            for m in r.maps.values():
                tb = r.table
                col = (m.src or "").split(".")[-1] if m.src and "," not in (m.src or "") else None
                if m.src and "." in m.src:
                    al = m.src.split(".")[0]
                    tb = next((j["table"] for j in r.spec.get("join", []) if (j.get("as") or j["table"].split(".")[-1]) == al), tb)
                if m.code and col:
                    g = groups.get((r.system if tb == r.table else self.system_of.get(tb, r.system), m.code)) or \
                        next((x for (s, gr), x in groups.items() if gr == m.code), None)
                    if g is None:
                        self.issues.append(("오류", f"{r.noun}.{m.attr}", f"코드 대응 그룹 {m.code} 없음"))
                    else:
                        attr = self.std.nouns[r.noun].attrs[m.attr]
                        if attr.code_group and g["ksx_group"] != attr.code_group:
                            self.issues.append(("오류", f"{r.noun}.{m.attr}",
                                                f"코드 그룹 불일치: 속성 {attr.code_group}, 대응표 {g['ksx_group']}"))
                        for v in self.values.get((tb, col), []):
                            if str(v) not in {str(k) for k in g["map"]} and str(v).strip():
                                self.issues.append(("오류", f"{r.noun}.{m.attr}", f"원천 값 '{v}'({tb}.{col})의 대응 없음 — {m.code}"))
                if m.uom and col:
                    ucol = m.uom.split("from:")[-1].strip() if "from:" in str(m.uom) else None
                    if ucol is None and not str(m.uom).startswith("const("):
                        ucol = m.uom
                    if ucol:
                        for v in self.values.get((tb, ucol), []):
                            if str(v) not in units:
                                self.issues.append(("오류", f"{r.noun}.{m.attr}", f"단위 '{v}'({tb}.{ucol}) 대응 없음"))
                for xm in re.finditer(r"xref\((\w+),\s*([\w.]+)\)", m.transform or ""):
                    name, c = xm.group(1), xm.group(2).split(".")[-1]
                    if name not in xref:
                        self.issues.append(("오류", f"{r.noun}.{m.attr}", f"식별 대응표 {name} 없음"))
                        continue
                    have = {str(x["src"]) for x in xref[name]}
                    for v in self.values.get((tb, c), []):
                        if str(v) not in have and str(v).strip():
                            self.issues.append(("오류", f"{r.noun}.{m.attr}", f"식별 대응 {name}: 원천 값 '{v}' 없음"))

    # ------------------------------------------------------------------ 판정·지표
    def judgements(self) -> list[dict]:
        """대상 테이블의 모든 컬럼 판정(매핑·확장·제외·조인 키·테이블 판정·미판정)."""
        tbl = self.plan.get("tables", {})
        sc = self.plan.get("scope_tables")
        scope = sorted(self.src) if sc == "all" else (sc or sorted({r.table for r in self.results} | set(tbl)))
        touched = defaultdict(list)
        for r in self.results:
            for k, v in r.touched.items():
                touched[k] += v
        order = {"매핑": 0, "확장": 1, "조인 키": 2, "제외": 3}
        out = []
        for t in scope:
            td = tbl.get(t, {})
            for c in self.cols(t):
                n = c["name"]
                ts = touched.get((t, n), [])
                kinds = sorted({k for k, _ in ts}, key=lambda k: order[k])
                if "매핑" in kinds or "확장" in kinds:
                    kind = "매핑" if "매핑" in kinds else "확장"
                elif kinds:
                    kind = kinds[0]
                elif n in (td.get("exclude") or {}):
                    kind, ts = "제외", [("제외", td["exclude"][n])]
                elif td.get("disposition"):
                    kind, ts = td["disposition"], [(td["disposition"], td.get("note", ""))]
                else:
                    kind = "미판정"
                tg = [w for k, w in ts if k in ("매핑", "확장", "조인 키")]
                rs = [w for k, w in ts if k not in ("매핑", "확장", "조인 키")]
                out.append({"table": t, "column": n, "comment": c.get("comment") or "", "kind": kind,
                            "targets": ", ".join(dict.fromkeys(tg)), "reason": " / ".join(dict.fromkeys(x for x in rs if x)),
                            "samples": self.samples(t, n)})
        return out

    def metrics(self, judg) -> dict:
        # 결정론 해소율의 분모 = 원천 컬럼 1개 ↔ 표준 속성 1개 매핑(식별자 생성·계산 같은 여러 컬럼 파생은 따로 센다)
        maps = [m for r in self.results for m in r.maps.values() if m.src and m.stage not in ("const", "xref", "derived")]
        derived = [m for r in self.results for m in r.maps.values() if m.stage == "derived"]
        det = [m for m in maps if m.stage in ("exact", "normalized", "component", "korean")]
        corrected = [m for m in maps if m.auto]
        manual = [m for m in maps if m.stage == "manual"]
        req_total = sum(sum(1 for a in self.std.nouns[r.noun].attrs.values() if a.required) for r in self.results)
        req_miss = sum(len(r.missing) for r in self.results)
        jc = defaultdict(int)
        for j in judg:
            jc[j["kind"]] += 1
        return {"specs": len(self.results), "nouns": len({r.noun for r in self.results}),
                "mapped": len(maps), "derived": len(derived), "deterministic": len(det), "corrected": len(corrected), "manual": len(manual),
                "det_rate": round(100 * len(det) / len(maps), 1) if maps else 0,
                "fix_rate": round(100 * len(corrected) / (len(det) + len(corrected)), 1) if det or corrected else 0,
                "req_total": req_total, "req_missing": req_miss,
                "req_rate": round(100 * (req_total - req_miss) / req_total, 1) if req_total else 0,
                "cols": len(judg), "judged": len(judg) - jc["미판정"],
                "judge_rate": round(100 * (len(judg) - jc["미판정"]) / len(judg), 1) if judg else 0,
                "by_kind": dict(jc), "errors": sum(1 for i in self.issues if i[0] == "오류")}
