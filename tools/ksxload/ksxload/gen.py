"""매핑 명세(S2 승인본) + 정제 규칙 → dbt 모델·테스트·seed·적재 목록.

명세 1건 = xfm 모델 1개(뷰). 정제 규칙이 있는 모델은 3개로 나눈다.
  <모델>__src  명세대로 변환한 행(규칙 전)
  <모델>       규칙 적용(격리·중복 정리·고아 참조 비움)
  <모델>__audit 규칙에 걸린 행(publish가 audit.quarantine에 기록)
생성물은 직접 고치지 않는다 — 명세·규칙을 고치고 gen을 다시 실행한다.
"""
from __future__ import annotations

import glob
import os
import re
import shutil
import tempfile

import yaml

from .base import Config, parse_ddl, rel, topo_order
from .dsl import Translator, parse_unpivot

BASE = ("EnterpriseID", "SiteID", "PlantID")
HDR = "-- ksxload gen 생성물 — 직접 수정 금지. 원본: {src}\n"


class GenError(ValueError):
    pass


def _q(c):
    return f'"{c}"'


def load_specs(cfg: Config) -> list[dict]:
    out = []
    for sysdir in ("erp", "mes", "qms"):
        for p in sorted(glob.glob(os.path.join(cfg.mapping_dir, sysdir, "*.yaml"))):
            sp = yaml.safe_load(open(p, encoding="utf-8"))
            sp["_file"] = os.path.relpath(p, cfg.repo)
            sp["_model"] = os.path.splitext(os.path.basename(p))[0]
            out.append(sp)
    return out


class Gen:
    def __init__(self, cfg: Config):
        self.cfg = cfg
        self.tables = parse_ddl([rel(cfg.repo, p) for p in cfg.raw["ddl"]])
        self.src = {f"{t['schema']}.{t['table']}": t for t in cfg.extract["tables"]}
        self.specs = load_specs(cfg)
        self.by_model = {s["_model"]: s for s in self.specs}
        self.rules = cfg.raw.get("rules", []) or []
        for r in self.rules:
            if r["model"] not in self.by_model:
                raise GenError(f"규칙 {r['id']}: 모델 {r['model']} 없음")
        self.files: dict[str, str] = {}          # 상대 경로 → 내용
        self.manifest = []

    # ------------------------------------------------------------ 공통
    def stg(self, table: str) -> str:
        s, t = table.split(".")
        return f"{{{{ source('stg', '{s}__{t}') }}}}"

    def stg_plain(self, table: str) -> str:
        s, t = table.split(".")
        return f'stg."{s}__{t}"'

    def cols_of(self, table: str) -> set[str]:
        return {c["name"] for c in self.src[table]["columns"]}

    def targets(self, sp) -> tuple:
        noun = sp["noun"]
        core = self.tables.get(f"{'ext' if sp.get('layer') == 'ext' else 'ksx'}.{noun}")
        if core is None:
            raise GenError(f"{sp['_model']}: 대상 테이블 {noun} 없음(DDL)")
        if sp.get("layer") == "ext":                 # 확장 명사: 모든 속성이 ext.<명사> 한 테이블
            return core, None
        ext = self.tables.get(f"ext.{noun}Ext") if sp.get("extension") else None
        if sp.get("extension") and ext is None:
            raise GenError(f"{sp['_model']}: 확장 테이블 {noun}Ext 없음(DDL)")
        return core, ext

    @staticmethod
    def code_group(m):
        c = m.get("code")
        return c.split("->")[0].strip() if c else None

    # ------------------------------------------------------------ 모델 SQL
    def model_sql(self, sp):
        src = sp["source"]
        table = src["table"]
        joins = sp.get("join", []) or []
        aliases = {j["as"] for j in joins}
        attrs = dict(sp.get("attributes") or {})
        ext_attrs = dict(sp.get("extension") or {}) if sp.get("layer") != "ext" else {}
        if sp.get("layer") == "ext":
            attrs.update(sp.get("extension") or {})
        allm = {**attrs, **ext_attrs}
        code_of = {}
        for m in allm.values():
            g = self.code_group(m)
            if g and m.get("from") and "," not in m["from"]:
                code_of[m["from"].split(".")[-1]] = g
        unp = None
        for an, m in allm.items():
            if parse_unpivot(m.get("transform") or ""):
                unp = (an, parse_unpivot(m["transform"]))
        extra = {"ev": "u.ev"} if unp else {}
        tr = Translator(self.cols_of(table), aliases | ({"u"} if unp else set()), code_of, extra)
        core, ext = self.targets(sp)
        types = {**{c: col for c, col in core.cols.items()}, **({c: col for c, col in ext.cols.items()} if ext else {})}

        def expr_for(an, m):
            if unp and an == unp[0]:
                e = "u.ev_ts"
            elif m.get("transform"):
                e = tr.expr(m["transform"])
            elif m.get("from"):
                f = m["from"]
                if "," in f:
                    raise GenError(f"{sp['_model']}.{an}: 여러 컬럼 from에는 transform 필요")
                e = tr.expr(f)
            else:
                e = "null"
            g = self.code_group(m)
            if g:
                e = f"xfm.code('{g}', ({e})::text)"
            elif m.get("uom") and not m.get("transform"):
                e = f"xfm.uom(({e})::text)"
            return e

        sel, out_cols, src_cols = [], [], []
        base = sp.get("base") or {}
        for b in BASE:
            if b in base and b in core.cols:
                sel.append(f"cast({tr.expr(base[b])} as {types[b].base}) as {_q(b)}")
                out_cols.append(b)
        for an, m in allm.items():
            if an in out_cols:
                continue
            if an not in types:
                raise GenError(f"{sp['_model']}.{an}: 대상 테이블에 컬럼 없음")
            sel.append(f"cast({expr_for(an, m)} as {types[an].base}) as {_q(an)}")
            out_cols.append(an)
            if self.code_group(m) and m.get("from") and "," not in m["from"]:
                sel.append(f"cast({tr.expr(m['from'])} as text) as {_q('_src__' + an)}")
                src_cols.append((an, self.code_group(m)))
        frm = [f"from {self.stg(table)} s"]
        for j in joins:
            frm.append(f"left join {self.stg(j['table'])} {j['as']} on {self._sub(tr.expr(j['on']))}")
        if unp:
            vals = ", ".join(f"('{ev}', {tr.expr(c)})" for c, ev in unp[1])
            frm.append(f"cross join lateral (values {vals}) as u(ev, ev_ts)")
        where = []
        if src.get("filter"):
            where.append(f"({self._sub(self._filter_expr(tr, src['filter']))})")
        if unp:
            where.append("u.ev_ts is not null")
        uk = [c for c in core.uk]
        missing = [c for c in uk if c not in out_cols]
        if missing:
            raise GenError(f"{sp['_model']}: UK 컬럼 매핑 없음 {missing}")
        distinct = bool(src.get("distinct"))
        lines = ["select" + (f" distinct on ({', '.join(_q(c) for c in uk)})" if distinct else "")]
        lines.append(",\n".join("    " + s for s in sel))
        lines += frm
        if where:
            lines.append("where " + "\n  and ".join(where))
        if distinct:
            lines.append(f"order by {', '.join(_q(c) for c in uk)}")
        info = dict(core=core, ext=ext, out_cols=out_cols, src_cols=src_cols, uk=uk, tr=tr, unp=unp,
                    distinct=distinct, joins=joins, table=table, ext_attrs=list(ext_attrs), attrs=allm)
        return "\n".join(lines) + "\n", info

    def _filter_expr(self, tr, f):
        # 서브쿼리 별칭(FROM erp.tb_x d)을 번역기에 알린다
        subs = {m.group(2) for m in re.finditer(r"\b(?:FROM|JOIN)\s+(\w+\.\w+)\s+(?:AS\s+)?(\w+)", f, re.I)}
        t2 = Translator(tr.cols, tr.aliases | subs, tr.code_of, tr.extra)
        return t2.expr(f)

    def _sub(self, sql):
        """원천 테이블 이름(erp.tb_x)을 stg 소스로."""
        return re.sub(r"\b(erp|mes|qms)\.((?:tb|tm|qm)_\w+)", lambda m: self.stg(f"{m.group(1)}.{m.group(2)}"), sql)

    # ------------------------------------------------------------ 규칙
    def parent_models(self, noun):
        return [s["_model"] for s in self.specs if s["noun"] == noun]

    def orphan_cond(self, sp, info, cols, parent):
        """cols(모델 컬럼)가 부모 명사의 키에 없는 조건 — DDL FK에서 부모 컬럼을 찾는다."""
        fk = None
        for t in (info["core"], info["ext"]):
            if t is None:
                continue
            for name, cc, ptab, pc in t.fks:
                if ptab.endswith("." + parent) and set(cols) <= set(cc):
                    fk = (cc, pc)
                    break
            if fk:
                break
        if not fk:
            raise GenError(f"{sp['_model']}: {cols} → {parent} FK를 DDL에서 찾지 못함")
        cc, pc = fk
        parts = []
        for pm in self.parent_models(parent):
            parts.append(f"select {', '.join(_q(c) for c in pc)} from {{{{ ref('{pm}') }}}}")
        union = "\n        union all ".join(parts)
        nn = " and ".join(f"m.{_q(c)} is not null" for c in cols)
        eq = " and ".join(f"p.{_q(p)} = m.{_q(c)}" for c, p in zip(cc, pc))
        return f"({nn} and not exists (select 1 from ({union}) p where {eq}))"

    def rule_cond(self, sp, info, r):
        if r.get("orphan"):
            return self.orphan_cond(sp, info, r["orphan"]["columns"], r["orphan"]["parent"])
        if r.get("when"):
            return f"({r['when']})"
        raise GenError(f"규칙 {r['id']}: when 또는 orphan 필요")

    # ------------------------------------------------------------ 생성
    def build(self):
        cfg = self.cfg
        mdir = os.path.relpath(cfg.models_dir, cfg.repo)
        sdir = os.path.relpath(cfg.seeds_dir, cfg.repo)
        schema_models = []
        for sp in self.specs:
            name = sp["_model"]
            body, info = self.model_sql(sp)
            rules = [r for r in self.rules if r["model"] == name]
            hdr = HDR.format(src=sp["_file"]) + f"-- {sp['noun']} ← {info['table']} ({sp.get('structure', '')})\n"
            cols = info["out_cols"] + [f"_src__{a}" for a, _ in info["src_cols"]]
            if rules:
                self.files[f"{mdir}/xfm/{name}__src.sql"] = hdr + "-- 규칙 적용 전(명세대로 변환한 행)\n" + body
                conds = {r["id"]: self.rule_cond(sp, info, r) for r in rules if r["action"] != "dedupe"}
                q = [r for r in rules if r["action"] == "quarantine"]
                d = [r for r in rules if r["action"] == "dedupe"]
                nz = [r for r in rules if r["action"] in ("nullify_orphan", "replace_orphan")]
                ref_src = f"{{{{ ref('{name}__src') }}}}"
                lines = [hdr + "-- 정제 규칙: " + ", ".join(f"{r['id']}({r['issue']} {r['action']})" for r in rules)]
                lines.append("with kept as (")
                lines.append(f"    select m.* from {ref_src} m")
                if q:
                    lines.append("    where " + "\n      and ".join(f"not coalesce({conds[r['id']]}, false)" for r in q))
                lines.append(")")
                inner = "kept"
                if d:
                    if len(d) > 1:
                        raise GenError(f"{name}: dedupe 규칙은 1개만")
                    uk = ", ".join(_q(c) for c in info["uk"])
                    lines.append(f", dedup as (\n    select distinct on ({uk}) * from kept\n    order by {uk}, {d[0]['keep']}\n)")
                    inner = "dedup"
                sel = []
                for c in cols:
                    expr = f"m.{_q(c)}"
                    for r in [x for x in rules if x["action"] == "correct"]:
                        if c in (r.get("set") or {}):
                            expr = f"case when coalesce({conds[r['id']]}, false) then {r['set'][c]} else {expr} end"
                    for r in nz:
                        if c in r["orphan"]["columns"]:
                            new = "null"
                            if r["action"] == "replace_orphan":
                                if c not in (r.get("with") or {}):
                                    raise GenError(f"규칙 {r['id']}: replace_orphan은 with.{c} 필요")
                                new = r["with"][c]
                            expr = f"case when {conds[r['id']]} then {new} else {expr} end"
                    sel.append(f"    {expr} as {_q(c)}")
                lines.append("select\n" + ",\n".join(sel) + f"\nfrom {inner} m\n")
                self.files[f"{mdir}/xfm/{name}.sql"] = "\n".join(lines)
                # 감사 모델
                au = []
                for r in rules:
                    lit = lambda v: "'" + str(v or "").replace("'", "''") + "'"  # noqa: E731
                    head = f"select {lit(r['id'])} as rule_id, {lit(r.get('issue'))} as issue_id, {lit(r['action'])} as action"
                    if r["action"] == "dedupe":
                        uk = ", ".join(_q(c) for c in info["uk"])
                        au.append(f"{head}, to_jsonb(m) - 'rn' as row_data from (\n    select k.*, row_number() over "
                                  f"(partition by {uk} order by {r['keep']}) as rn from {{{{ ref('{name}__src') }}}} k\n) m where m.rn > 1")
                    elif r["action"] == "flag":
                        au.append(f"{head}, to_jsonb(m) as row_data from {{{{ ref('{name}') }}}} m where coalesce({conds[r['id']]}, false)")
                    else:
                        au.append(f"{head}, to_jsonb(m) as row_data from {ref_src} m where coalesce({conds[r['id']]}, false)")
                self.files[f"{mdir}/xfm/{name}__audit.sql"] = hdr + "-- 정제 규칙에 걸린 행(publish → audit.quarantine)\n" + \
                    "\nunion all\n".join(au) + "\n"
            else:
                self.files[f"{mdir}/xfm/{name}.sql"] = hdr + body
            # 테스트(schema.yml)
            req = [c for c in info["out_cols"]
                   if (c in info["core"].cols and info["core"].cols[c].notnull)
                   or (info["ext"] is not None and c in info["ext"].cols and info["ext"].cols[c].notnull)]
            colspec = [{"name": c, "quote": True, "tests": ["not_null"]} for c in req]
            colspec += [{"name": f"_src__{a}", "quote": True, "tests": [{"ksx_code_mapped": {"group": g}}]}
                        for a, g in info["src_cols"]]
            schema_models.append({"name": name, "description": f"{sp['noun']} ← {info['table']} — {sp['_file']}",
                                  "tests": [{"ksx_unique_key": {"columns": info["uk"]}}], "columns": colspec})
            self.manifest.append(self.manifest_entry(sp, info, rules))
        # sources.yml
        srcs = sorted({f"{t['schema']}__{t['table']}" for t in self.cfg.extract["tables"]})
        self.files[f"{mdir}/sources.yml"] = "# ksxload gen 생성물 — 원천 복제(stg)\n" + yaml.safe_dump(
            {"version": 2, "sources": [{"name": "stg", "schema": "stg", "tables": [{"name": n} for n in srcs]}]},
            allow_unicode=True, sort_keys=False)
        self.files[f"{mdir}/schema.yml"] = "# ksxload gen 생성물 — 모델 테스트(UK 유일·필수 값·코드 대응)\n" + yaml.safe_dump(
            {"version": 2, "models": schema_models}, allow_unicode=True, sort_keys=False, width=200)
        # seeds
        for f in ("codes.csv", "units.csv", "xref.csv"):
            self.files[f"{sdir}/{f}"] = open(os.path.join(self.cfg.mapping_dir, f), encoding="utf-8").read()
        seeds = []
        for f in ("codes", "units", "xref"):
            hdrs = self.files[f"{sdir}/{f}.csv"].splitlines()[0].split(",")
            seeds.append({"name": f, "config": {"column_types": {h: "text" for h in hdrs}}})
        self.files[f"{sdir}/seeds.yml"] = "# ksxload gen 생성물 — 대응표 seed(모두 text)\n" + yaml.safe_dump(
            {"version": 2, "seeds": seeds}, allow_unicode=True, sort_keys=False)
        # 적재 목록
        tkeys = sorted({t["table"] for e in self.manifest for t in e["targets"]})
        order = topo_order(self.tables, tkeys)
        pdir = os.path.relpath(os.path.join(self.cfg.dbt_dir, "publish"), self.cfg.repo)   # dbt가 읽지 않는 폴더
        self.files[f"{pdir}/{self.cfg.ent.lower()}.yml"] = "# ksxload gen 생성물 — publish 적재 목록(대상 테이블·컬럼·대사 기준)\n" + yaml.safe_dump(
            {"enterprise": self.cfg.ent, "order": order, "models": self.manifest},
            allow_unicode=True, sort_keys=False, width=200)
        return self.files

    def manifest_entry(self, sp, info, rules):
        core, ext = info["core"], info["ext"]
        tr = info["tr"]
        out_cols = info["out_cols"]
        tgts = [{"table": core.key, "columns": [c for c in out_cols if c in core.cols and c not in info["ext_attrs"]]}]
        if ext is not None:
            tgts.append({"table": ext.key, "columns": [c for c in ext.uk if c in out_cols] +
                         [c for c in out_cols if c in info["ext_attrs"] and c in ext.cols]})
        src = sp["source"]
        frm = f"from {self.stg_plain(info['table'])} s"
        fsql = self._plain(self._filter_expr(tr, src["filter"])) if src.get("filter") else None
        need_join = fsql and any(re.search(rf"\b{j['as']}\.", fsql) for j in info["joins"])
        if need_join:
            for j in info["joins"]:
                frm += f" left join {self.stg_plain(j['table'])} {j['as']} on {self._plain(tr.expr(j['on']))}"
        where = f" where {fsql}" if fsql else ""
        if info["unp"]:
            cnt = " + ".join(f"count({tr.expr(c)})" for c, _ in info["unp"][1])
            expect = f"select {cnt} {frm}{where}"
            kind = "unpivot"
        elif info["distinct"]:
            ids = [tr.expr(info["attrs"][c].get("transform") or info["attrs"][c]["from"]) for c in info["uk"] if c in info["attrs"]]
            expect = f"select count(distinct ({', '.join(ids)})) {frm}{where}"
            kind = "distinct"
        else:
            expect = f"select count(*) {frm}{where}"
            kind = "rows"
        sums = []
        removes = any(r["action"] in ("quarantine", "dedupe") for r in rules)
        corrected = {c for r in rules if r["action"] == "correct" for c in (r.get("set") or {})}
        if kind == "rows" and not removes:
            for an, m in info["attrs"].items():
                f = m.get("from")
                t = (m.get("transform") or "").strip()
                typ = (core.cols.get(an) or (ext.cols.get(an) if ext else None))
                if not f or "," in f or "." in f or m.get("code") or m.get("uom") or typ is None or an in corrected:
                    continue
                if typ.base != "numeric":                   # 수량·금액(NUMERIC)만 — 정수는 순번·횟수
                    continue
                if t and not re.fullmatch(rf"int\({re.escape(f)}\)", t):
                    continue
                sums.append({"column": an, "source": f"select sum(s.{f}::numeric) {frm}{where}"})
        return {"model": sp["_model"], "noun": sp["noun"], "spec": sp["_file"], "kind": kind,
                "targets": tgts, "uk": info["uk"], "expect_sql": expect, "sums": sums,
                "audit": f"{sp['_model']}__audit" if rules else None,
                "rules": [r["id"] for r in rules]}

    def _plain(self, sql):
        return re.sub(r"\b(erp|mes|qms)\.((?:tb|tm|qm)_\w+)", lambda m: self.stg_plain(f"{m.group(1)}.{m.group(2)}"), sql)


def _write(files: dict, root: str, clean_dirs: list[str]):
    for d in clean_dirs:
        p = os.path.join(root, d)
        if os.path.isdir(p):
            shutil.rmtree(p)
    for relp, txt in files.items():
        p = os.path.join(root, relp)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(txt)


def generate(cfg: Config, out=print):
    g = Gen(cfg)
    files = g.build()
    mdir = os.path.relpath(cfg.models_dir, cfg.repo)
    sdir = os.path.relpath(cfg.seeds_dir, cfg.repo)
    _write(files, cfg.repo, [mdir, sdir])   # publish/<기업>.yml은 덮어쓴다
    n_models = sum(1 for k in files if k.endswith(".sql"))
    n_rules = sum(1 for k in files if k.endswith("__audit.sql"))
    out(f"ksxload gen: 명세 {len(g.specs)} → 모델 {n_models}개(규칙 적용 {n_rules}), 대상 테이블 "
        f"{len({t['table'] for e in g.manifest for t in e['targets']})}개, 규칙 {len(g.rules)} → {mdir}")
    return files


def stale(cfg: Config) -> list[str]:
    files = Gen(cfg).build()
    bad = []
    for relp, txt in files.items():
        p = os.path.join(cfg.repo, relp)
        if not os.path.exists(p) or open(p, encoding="utf-8").read() != txt:
            bad.append(relp)
    mdir = os.path.join(cfg.repo, os.path.relpath(cfg.models_dir, cfg.repo))
    for p in glob.glob(os.path.join(mdir, "**", "*"), recursive=True):
        if os.path.isfile(p) and os.path.relpath(p, cfg.repo) not in files:
            bad.append(os.path.relpath(p, cfg.repo) + " (남은 파일)")
    return bad
