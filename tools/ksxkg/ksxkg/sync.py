"""S8 속성 그래프·벡터 인덱스(구현안내서 11장).

  sync           (1) Fuseki의 데이터 그래프(S5)·추론 그래프(S7)를 내보내 Apache AGE 속성 그래프(ksx_graph)에 차이만 반영
                     — 노드 키 = IRI, 노드 라벨 = 클래스, 관계 라벨 = 객체 관계, 코드·단위·리터럴 = 노드 속성.
                     이전 상태는 pgsync.node·pgsync.edge(IRI ↔ AGE id)에 두고, 없어진 것은 지우고 바뀐 것만 고친다.
                 (2) 정합 검사: RDF(SPARQL 집계)와 속성 그래프(라벨 테이블)의 노드·관계 수가 라벨마다 같아야 한다(오차 0).
                 (3) Qdrant 컬렉션 4종(noun_cards·documents·cases·nodes) 색인 — 문장이 바뀐 점만 다시 임베딩한다.
                 (4) 검색 평가(계획의 평가 사례) → recall@k.
  sync --eval    (4)만 — 현재 색인으로 검색 평가.
  search TEXT    컬렉션 하나를 검색(확인용). documents는 status=현행 필터가 기본이다.
리포트: mapping/<기업>/S8_동기화결과.md · 기록: audit.graph_sync, audit.search_eval
"""
from __future__ import annotations

import glob
import hashlib
import json
import math
import os
import re
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

import yaml

from .base import Config, DbError, env, sparql
from .infer import UNION
from .materialize import end_run, start_run

RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
XSD = "http://www.w3.org/2001/XMLSchema#"
INT_T = {XSD + t for t in ("integer", "int", "long", "short", "byte", "nonNegativeInteger", "positiveInteger",
                           "nonPositiveInteger", "negativeInteger", "unsignedInt", "unsignedLong")}
NUM_T = {XSD + t for t in ("decimal", "double", "float")}
QUALITY_VIOLATES = "violates"

AUDIT_SQL = """
create table if not exists audit.graph_sync (
  log_id     bigint generated always as identity primary key,
  run_id     uuid        not null references audit.run(run_id),
  target     text        not null,
  kind       text        not null,
  total      bigint      not null,
  added      bigint      not null default 0,
  updated    bigint      not null default 0,
  removed    bigint      not null default 0,
  seconds    numeric,
  detail     jsonb       not null default '{}'::jsonb,
  logged_at  timestamptz not null default now()
);
comment on table audit.graph_sync is 'S8 동기화 기록(구현안내서 11장) — 속성 그래프(노드·관계)·벡터 컬렉션별 전체·추가·변경·삭제';
create table if not exists audit.search_eval (
  log_id     bigint generated always as identity primary key,
  run_id     uuid        not null references audit.run(run_id),
  case_id    text        not null,
  collection text        not null,
  query      text        not null,
  expected   jsonb       not null,
  got        jsonb       not null,
  recall     numeric     not null,
  logged_at  timestamptz not null default now()
);
comment on table audit.search_eval is 'S8 검색 평가 — 사례별 정답·상위 k 결과·recall@k';
grant select on audit.graph_sync, audit.search_eval to ksx_reader;
"""

PGSYNC_SQL = """
create schema if not exists pgsync;
comment on schema pgsync is 'S8 pg-sync 상태 — 지식 그래프 IRI ↔ 속성 그래프(AGE) id';
create table if not exists pgsync.node (
  graph text not null, iri text not null, label text not null, props jsonb not null, gid ag_catalog.graphid not null,
  primary key (graph, iri));
create table if not exists pgsync.edge (
  graph text not null, s text not null, p text not null, o text not null, props jsonb not null, gid ag_catalog.graphid not null,
  primary key (graph, s, p, o));
grant usage on schema pgsync to ksx_reader;
grant select on pgsync.node, pgsync.edge to ksx_reader;
"""


# ------------------------------------------------------------------ 설정
def settings(cfg: Config) -> dict:
    s = dict(cfg.raw.get("sync") or {})
    s.setdefault("graph", "ksx_graph")
    s.setdefault("site", "HQ")
    s.setdefault("catalog", "ontologies/catalog/nouns")
    s["qdrant"] = env(s.get("qdrant", "${QDRANT_URL:-http://localhost:6333}")).rstrip("/")
    s["qdrant_key"] = env(s.get("qdrant_key", "${QDRANT_API_KEY:-}"))
    s["embed"] = env(s.get("embed", "${EMBED_URL:-http://localhost:8082}")).rstrip("/")
    s.setdefault("model", "BAAI/bge-m3")
    s.setdefault("dim", 1024)
    s.setdefault("batch", 16)
    s.setdefault("collections", {})
    rr = dict(s.get("rerank") or {})                     # 재정렬(D-2): 벡터 상위 top개를 질의–문장 쌍으로 다시 채점
    if rr:
        rr["url"] = env(rr.get("url", "${RERANK_URL:-http://localhost:8083}")).rstrip("/")
        rr.setdefault("top", 20)
        rr.setdefault("collections", ["noun_cards", "nodes", "cases", "documents"])
    s["rerank"] = rr
    ev = dict(cfg.raw.get("search_eval") or {})
    ev.setdefault("k", 5)
    ev.setdefault("threshold", 0.9)
    s["eval"] = ev
    return s


def local(iri: str) -> str:
    return urllib.parse.unquote(re.split(r"[/#]", iri.rstrip("/"))[-1])


def gkey(g: str) -> str:
    return g.split("/graph/", 1)[-1]


# ------------------------------------------------------------------ (1) 내보내기 — Fuseki → 노드·관계
def graph_filter(cfg: Config, var="?g") -> str:
    pre, inf = cfg.data_graph_prefix, cfg.graph(f"inferred/{cfg.ent}/")
    return f'({var} = <{pre}> || STRSTARTS(STR({var}), "{pre}/") || STRSTARTS(STR({var}), "{inf}"))'


def kind_of(cfg: Config, g: str) -> str:
    if g == cfg.graph("quality"):
        return "quality"
    if g.startswith(cfg.graph(f"inferred/{cfg.ent}/")):
        return "inferred"
    return "data"


def scope(cfg: Config, g: str) -> dict:
    """그래프 이름 → 기업·사업장·공장(데이터) / 기업·사업장·규칙 ID(추론)."""
    k = gkey(g).split("/")
    if k[0] == "inferred":
        return {"ent": k[1], "site": k[2], "ruleId": k[3]} if len(k) >= 4 else {"ent": k[1]}
    d = {"ent": k[0]}
    if len(k) > 1:
        d["site"] = k[1]
    if len(k) > 2:
        d["plant"] = k[2]
    return d


def value(b: dict):
    v = b["value"]
    dt = b.get("datatype", "")
    try:
        if dt in INT_T:
            return int(v)
        if dt in NUM_T:
            f = float(v)
            return f if math.isfinite(f) else v
        if dt == XSD + "boolean":
            return v in ("true", "1")
    except ValueError:
        pass
    return v


def fetch(cfg: Config) -> list[tuple]:
    """데이터·추론·위반 표식 그래프의 모든 트리플(그래프 포함)."""
    q = (f"SELECT ?g ?s ?p ?o WHERE {{ GRAPH ?g {{ ?s ?p ?o }} "
         f"FILTER({graph_filter(cfg)} || ?g = <{cfg.graph('quality')}>) }}")
    data = urllib.parse.urlencode({"query": q}).encode()
    req = urllib.request.Request(cfg.query, data=data, method="POST", headers={
        "Accept": "application/sparql-results+json", "Content-Type": "application/x-www-form-urlencoded"})
    with urllib.request.urlopen(req, timeout=1800) as r:
        js = json.load(r)
    return [(b["g"]["value"], b["s"], b["p"]["value"], b["o"]) for b in js["results"]["bindings"]]


def code_labels(cfg: Config) -> dict:
    """코드 IRI → 한국어 레이블(S4 vocab/*.ttl) — 검색 문장에 코드값 대신 뜻을 쓴다(C-LEAK → 누수)."""
    out = {}
    for f in sorted(glob.glob(os.path.join(cfg.onto, "vocab", "*.ttl"))):
        for m in re.finditer(r'^<([^>]+)> a skos:Concept\b[^\n]*?skos:prefLabel "([^"]*)"@ko', open(f, encoding="utf-8").read(), re.M):
            out[m.group(1)] = m.group(2)
    return out


def build(cfg: Config, triples: list[tuple], labels: dict | None = None) -> dict:
    """트리플 → 노드(IRI → 라벨·속성)·관계((s, 라벨, o) → 속성). 지식 그래프가 원본이고 이것은 탐색용 파생본이다."""
    types, home = {}, {}
    for g, s, p, o in triples:
        if p == RDF_TYPE and s["type"] == "uri" and kind_of(cfg, g) != "quality":
            types.setdefault(s["value"], set()).add(o["value"])
            home.setdefault(s["value"], g)
    nodes, multi = {}, []
    for iri, cs in types.items():
        names = sorted({local(c) for c in cs})
        if len(names) > 1:
            multi.append(iri)
        g = home[iri]
        nodes[iri] = {"label": names[0], "props": {"iri": iri, "graph": gkey(g), **scope(cfg, g)}}
    edges, dangling, bnodes, keyns, shown = {}, 0, 0, {}, {}
    for g, s, p, o in triples:
        if p == RDF_TYPE or s["type"] != "uri":
            bnodes += s["type"] != "uri"
            continue
        n = nodes.get(s["value"])
        if n is None:
            continue
        key = local(p)
        keyns.setdefault(key, set()).add(p[: -len(key)] if p.endswith(key) else p)
        k = kind_of(cfg, g)
        if k == "quality":                       # S6 위반 표식(ksxq:violates)은 노드 속성으로
            n["props"].setdefault(QUALITY_VIOLATES, []).append(local(o["value"]))
            continue
        if o["type"] == "uri" and o["value"] in nodes:
            ep = {"graph": gkey(g), "inferred": k == "inferred"}
            if k == "inferred":
                ep["ruleId"] = scope(cfg, g).get("ruleId")
            edges[(s["value"], key, o["value"])] = ep
            continue
        if o["type"] == "uri":
            v = local(o["value"])                # 코드·단위 → 값, 대상 없는 참조는 IRI 그대로
            if labels and o["value"] in labels:
                shown[(key, v)] = labels[o["value"]]
            if o["value"].startswith(cfg.data_ns) and "/codelist/" not in o["value"] and "/uom/" not in o["value"]:
                v, dangling = o["value"], dangling + 1
        elif o["type"] == "bnode":
            bnodes += 1
            continue
        else:
            v = value(o)
        cur = n["props"].get(key)
        if cur is None:
            n["props"][key] = v
        else:
            n["props"][key] = sorted(set((cur if isinstance(cur, list) else [cur]) + [v]), key=str)
    for n in nodes.values():
        if QUALITY_VIOLATES in n["props"]:
            n["props"][QUALITY_VIOLATES] = sorted(set(n["props"][QUALITY_VIOLATES]))
    clash = {k: sorted(v) for k, v in keyns.items() if len(v) > 1}
    return {"nodes": nodes, "edges": edges, "multi": multi, "dangling": dangling, "bnodes": bnodes, "clash": clash,
            "triples": len(triples), "labels": shown}


# ------------------------------------------------------------------ (1) 반영 — AGE 라벨 테이블에 차이만
def _copy(v: str) -> str:
    return v.replace("\\", "\\\\").replace("\t", "\\t").replace("\n", "\\n").replace("\r", "\\r")


def _j(d: dict) -> str:
    return json.dumps(d, ensure_ascii=False, sort_keys=True)


APPLY_SQL = r"""
SELECT set_config('pgsync.graph', :'graph', true) \gset
DO $$
DECLARE
  g text := current_setting('pgsync.graph');
  r record;
  missing text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ag_catalog.ag_graph WHERE name = g) THEN
    RAISE EXCEPTION '속성 그래프 % 가 없습니다 — ontologies/graph/age_schema.sql을 관리자 계정으로 먼저 적용', g;
  END IF;
  SELECT string_agg(DISTINCT x.l, ', ') INTO missing FROM (
      SELECT label AS l, 'v' AS k FROM n_new UNION SELECT p, 'e' FROM e_new) x
    WHERE NOT EXISTS (SELECT 1 FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid
                      WHERE gg.name = g AND l.name = x.l AND l.kind::text = x.k);
  IF missing IS NOT NULL THEN
    RAISE EXCEPTION '속성 그래프 라벨 없음: % — ksxgen build로 age_schema.sql을 다시 만들어 적용', missing;
  END IF;

  -- 없어진 노드(또는 라벨이 바뀐 노드)와, 없어진 관계·그 노드에 걸린 관계
  CREATE TEMP TABLE n_del ON COMMIT DROP AS
    SELECT o.iri, o.label, o.gid FROM pgsync.node o LEFT JOIN n_new n ON n.iri = o.iri
    WHERE o.graph = g AND (n.iri IS NULL OR n.label <> o.label);
  CREATE TEMP TABLE e_del ON COMMIT DROP AS
    SELECT o.s, o.p, o.o, o.gid FROM pgsync.edge o LEFT JOIN e_new n ON (n.s, n.p, n.o) = (o.s, o.p, o.o)
    WHERE o.graph = g AND (n.s IS NULL OR o.s IN (SELECT iri FROM n_del) OR o.o IN (SELECT iri FROM n_del));
  FOR r IN SELECT p, array_agg(gid) AS ids FROM e_del GROUP BY p LOOP
    EXECUTE format('DELETE FROM %I.%I WHERE id = ANY($1)', g, r.p) USING r.ids;
  END LOOP;
  DELETE FROM pgsync.edge o USING e_del d WHERE o.graph = g AND (o.s, o.p, o.o) = (d.s, d.p, d.o);
  FOR r IN SELECT label, array_agg(gid) AS ids FROM n_del GROUP BY label LOOP
    EXECUTE format('DELETE FROM %I.%I WHERE id = ANY($1)', g, r.label) USING r.ids;
  END LOOP;
  DELETE FROM pgsync.node o USING n_del d WHERE o.graph = g AND o.iri = d.iri;

  -- 속성이 바뀐 노드·관계
  CREATE TEMP TABLE n_upd ON COMMIT DROP AS
    SELECT o.label, o.gid, n.props FROM pgsync.node o JOIN n_new n ON n.iri = o.iri WHERE o.graph = g AND o.props <> n.props;
  FOR r IN SELECT label, array_agg(gid) AS ids, array_agg(props::text) AS ps FROM n_upd GROUP BY label LOOP
    EXECUTE format('UPDATE %I.%I t SET properties = x.p::ag_catalog.agtype FROM unnest($1, $2) AS x(id, p) WHERE t.id = x.id',
                   g, r.label) USING r.ids, r.ps;
  END LOOP;
  UPDATE pgsync.node o SET props = n.props FROM n_new n WHERE o.graph = g AND o.iri = n.iri AND o.props <> n.props;
  CREATE TEMP TABLE e_upd ON COMMIT DROP AS
    SELECT o.p, o.gid, n.props FROM pgsync.edge o JOIN e_new n ON (n.s, n.p, n.o) = (o.s, o.p, o.o)
    WHERE o.graph = g AND o.props <> n.props;
  FOR r IN SELECT p, array_agg(gid) AS ids, array_agg(props::text) AS ps FROM e_upd GROUP BY p LOOP
    EXECUTE format('UPDATE %I.%I t SET properties = x.p::ag_catalog.agtype FROM unnest($1, $2) AS x(id, p) WHERE t.id = x.id',
                   g, r.p) USING r.ids, r.ps;
  END LOOP;
  UPDATE pgsync.edge o SET props = n.props FROM e_new n
    WHERE o.graph = g AND (n.s, n.p, n.o) = (o.s, o.p, o.o) AND o.props <> n.props;

  -- 새 노드: 라벨의 id 순번으로 AGE id를 먼저 정해 pgsync와 라벨 테이블에 같은 id로 넣는다
  CREATE TEMP TABLE n_ins ON COMMIT DROP AS
    SELECT n.iri, n.label, n.props, NULL::ag_catalog.graphid AS gid FROM n_new n
    WHERE NOT EXISTS (SELECT 1 FROM pgsync.node o WHERE o.graph = g AND o.iri = n.iri);
  FOR r IN SELECT l.id AS lid, l.name, l.seq_name FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid
           WHERE gg.name = g AND l.kind = 'v' AND l.name IN (SELECT DISTINCT label FROM n_ins) LOOP
    UPDATE n_ins SET gid = ag_catalog._graphid(r.lid, nextval(format('%I.%I', g, r.seq_name)::regclass)) WHERE label = r.name;
    EXECUTE format('INSERT INTO %I.%I(id, properties) SELECT gid, props::text::ag_catalog.agtype FROM n_ins WHERE label = $1',
                   g, r.name) USING r.name;
  END LOOP;
  INSERT INTO pgsync.node(graph, iri, label, props, gid) SELECT g, iri, label, props, gid FROM n_ins;

  -- 새 관계: 양 끝 노드의 AGE id로 잇는다
  CREATE TEMP TABLE e_ins ON COMMIT DROP AS
    SELECT n.s, n.p, n.o, n.props, NULL::ag_catalog.graphid AS gid, a.gid AS sid, b.gid AS tid FROM e_new n
    LEFT JOIN pgsync.node a ON a.graph = g AND a.iri = n.s
    LEFT JOIN pgsync.node b ON b.graph = g AND b.iri = n.o
    WHERE NOT EXISTS (SELECT 1 FROM pgsync.edge o WHERE o.graph = g AND (o.s, o.p, o.o) = (n.s, n.p, n.o));
  IF EXISTS (SELECT 1 FROM e_ins WHERE sid IS NULL OR tid IS NULL) THEN
    RAISE EXCEPTION '관계의 끝 노드가 속성 그래프에 없습니다(%건)', (SELECT count(*) FROM e_ins WHERE sid IS NULL OR tid IS NULL);
  END IF;
  FOR r IN SELECT l.id AS lid, l.name, l.seq_name FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid
           WHERE gg.name = g AND l.kind = 'e' AND l.name IN (SELECT DISTINCT p FROM e_ins) LOOP
    UPDATE e_ins SET gid = ag_catalog._graphid(r.lid, nextval(format('%I.%I', g, r.seq_name)::regclass)) WHERE p = r.name;
    EXECUTE format('INSERT INTO %I.%I(id, start_id, end_id, properties) '
                   'SELECT gid, sid, tid, props::text::ag_catalog.agtype FROM e_ins WHERE p = $1', g, r.name) USING r.name;
  END LOOP;
  INSERT INTO pgsync.edge(graph, s, p, o, props, gid) SELECT g, s, p, o, props, gid FROM e_ins;
END $$;
SELECT json_build_object(
  'nodes', json_build_object('added', (SELECT count(*) FROM n_ins), 'updated', (SELECT count(*) FROM n_upd),
                             'removed', (SELECT count(*) FROM n_del), 'total', (SELECT count(*) FROM pgsync.node WHERE graph = :'graph')),
  'edges', json_build_object('added', (SELECT count(*) FROM e_ins), 'updated', (SELECT count(*) FROM e_upd),
                             'removed', (SELECT count(*) FROM e_del), 'total', (SELECT count(*) FROM pgsync.edge WHERE graph = :'graph')));
"""


def psql_at(cfg: Config, sql: str, variables: dict | None = None, dsn=None) -> str:
    """psql 한 번(기본 소유자 계정, dsn=cfg.reader면 조회 계정)."""
    dsn = dsn or cfg.owner
    args = ["psql", *dsn.args(), "-q", "-A", "-t"]
    for k, v in (variables or {}).items():
        args += ["-v", f"{k}={v}"]
    e = dsn.environ()
    # graphid 연산자(=, 비교)가 ag_catalog에 있다 — 표 이름 해석에 영향이 없도록 검색 경로 맨 뒤에 둔다
    e["PGOPTIONS"] = (e.get("PGOPTIONS", "") + " -c search_path=ksx,ext,stg,audit,public,ag_catalog").strip()
    p = subprocess.run(args + ["-f", "-"], input=sql, capture_output=True, text=True, env=e)
    if p.returncode != 0:
        raise DbError((p.stderr or p.stdout).strip()[-2000:])
    return p.stdout


def apply_age(cfg: Config, s: dict, kg: dict) -> dict:
    try:
        psql_at(cfg, f"SELECT 1 FROM ag_catalog.ag_graph WHERE name = '{s['graph']}'")
        psql_at(cfg, PGSYNC_SQL)
    except DbError as e:
        raise DbError(f"{e}\n→ AGE 확장·속성 그래프·권한이 없습니다. 관리자(postgres)로 ontologies/graph/age_schema.sql을 먼저 적용하세요.") from e
    lines = ["BEGIN;",
             "CREATE TEMP TABLE n_new(iri text PRIMARY KEY, label text NOT NULL, props jsonb NOT NULL) ON COMMIT DROP;",
             "COPY n_new FROM STDIN;"]
    lines += [f"{_copy(i)}\t{_copy(n['label'])}\t{_copy(_j(n['props']))}" for i, n in sorted(kg["nodes"].items())]
    lines += ["\\.",
              "CREATE TEMP TABLE e_new(s text, p text, o text, props jsonb NOT NULL, PRIMARY KEY (s, p, o)) ON COMMIT DROP;",
              "COPY e_new FROM STDIN;"]
    lines += [f"{_copy(a)}\t{_copy(p)}\t{_copy(b)}\t{_copy(_j(ep))}" for (a, p, b), ep in sorted(kg["edges"].items())]
    lines += ["\\.", APPLY_SQL, "COMMIT;"]
    out = psql_at(cfg, "\n".join(lines) + "\n", {"graph": s["graph"]})
    return json.loads([x for x in out.splitlines() if x.startswith("{")][-1])


# ------------------------------------------------------------------ (2) 정합 검사 — RDF vs 속성 그래프
def rdf_counts(cfg: Config) -> dict:
    gf = graph_filter(cfg)
    nodes = sparql(cfg.query, f"SELECT ?c (COUNT(DISTINCT ?s) AS ?n) WHERE {{ GRAPH ?g {{ ?s a ?c }} FILTER({gf}) FILTER(isIRI(?s)) }} GROUP BY ?c")
    multi = sparql(cfg.query, f"SELECT (COUNT(*) AS ?n) WHERE {{ SELECT ?s WHERE {{ GRAPH ?g {{ ?s a ?c }} FILTER({gf}) }} "
                              "GROUP BY ?s HAVING (COUNT(DISTINCT ?c) > 1) }")
    edges = sparql(cfg.query, f"""SELECT ?p (COUNT(*) AS ?n) WHERE {{ SELECT DISTINCT ?s ?p ?o WHERE {{
        GRAPH ?g {{ ?s ?p ?o }} FILTER({gf}) FILTER(isIRI(?s) && isIRI(?o) && ?p != <{RDF_TYPE}>)
        FILTER EXISTS {{ GRAPH ?g1 {{ ?s a ?c1 }} FILTER({graph_filter(cfg, '?g1')}) }}
        FILTER EXISTS {{ GRAPH ?g2 {{ ?o a ?c2 }} FILTER({graph_filter(cfg, '?g2')}) }} }} }} GROUP BY ?p""")
    v, e = {}, {}
    for r in nodes:
        v[local(r["c"])] = v.get(local(r["c"]), 0) + int(r["n"])
    for r in edges:
        e[local(r["p"])] = e.get(local(r["p"]), 0) + int(r["n"])
    return {"v": v, "e": e, "multi": int(multi[0]["n"]) if multi else 0}


def age_counts(cfg: Config, s: dict) -> dict:
    g = s["graph"]
    labels = [x.split("|") for x in psql_at(cfg, (
        "SELECT l.name || '|' || l.kind::text FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid "
        f"WHERE gg.name = '{g}' AND l.name NOT LIKE '\\_ag\\_label\\_%' ORDER BY 1")).split()]
    if not labels:
        return {"v": {}, "e": {}, "broken": 0}
    q = " UNION ALL ".join(f"SELECT '{n}|{k}|' || count(*) FROM {g}.\"{n}\"" for n, k in labels)
    v, e = {}, {}
    for line in psql_at(cfg, q).split():
        n, k, c = line.split("|")
        if int(c):
            (v if k == "v" else e)[n] = int(c)
    broken = int(psql_at(cfg, f"SELECT count(*) FROM {g}._ag_label_edge x WHERE NOT EXISTS "
                              f"(SELECT 1 FROM {g}._ag_label_vertex a WHERE a.id = x.start_id) OR NOT EXISTS "
                              f"(SELECT 1 FROM {g}._ag_label_vertex b WHERE b.id = x.end_id)").strip())
    return {"v": v, "e": e, "broken": broken}


def consistency(cfg: Config, s: dict) -> dict:
    r, a = rdf_counts(cfg), age_counts(cfg, s)
    rows = []
    for kind in ("v", "e"):
        for k in sorted(set(r[kind]) | set(a[kind])):
            rows.append({"kind": "노드" if kind == "v" else "관계", "label": k, "rdf": r[kind].get(k, 0), "age": a[kind].get(k, 0)})
    err = sum(abs(x["rdf"] - x["age"]) for x in rows)
    return {"rows": rows, "error": err, "multi": r["multi"], "broken": a["broken"],
            "rdf_v": sum(r["v"].values()), "rdf_e": sum(r["e"].values()),
            "age_v": sum(a["v"].values()), "age_e": sum(a["e"].values()),
            "ok": err == 0 and r["multi"] == 0 and a["broken"] == 0}


def graph_checks(cfg: Config, s: dict, dsn=None) -> list[dict]:
    """계획의 탐색 확인(cypher) — 서비스 계정 세션에서 LOAD 없이(session_preload_libraries) 실행된다."""
    res = []
    for c in s.get("checks") or []:
        q = (f"SET search_path = ag_catalog, \"$user\", public;\n"
             f"SELECT x FROM cypher('{s['graph']}', $q$ {c['cypher']} $q$) AS (x agtype);")
        try:
            got = sorted({line.strip().strip('"') for line in psql_at(cfg, q, dsn=dsn).splitlines() if line.strip()})
            err = ""
        except DbError as e:
            got, err = [], str(e)[-300:]
        exp = sorted(str(x) for x in c["expected"])
        res.append({"id": c["id"], "desc": c.get("desc", ""), "cypher": c["cypher"], "expected": exp, "got": got,
                    "ok": got == exp, "error": err})
    return res


def reader_checks(cfg: Config, s: dict) -> dict:
    """조회 계정(ksx_reader — S9 MCP 도구·GraphRAG가 쓸 계정): 탐색 cypher가 같은 답을 내고, 쓰기는 거부되어야 한다."""
    checks = graph_checks(cfg, s, dsn=cfg.reader)
    g = s["graph"]
    lab = next((x for x in (psql_at(cfg, (
        "SELECT l.name FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid "
        f"WHERE gg.name = '{g}' AND l.kind = 'v' AND l.name NOT LIKE '\\_ag\\_label\\_%' ORDER BY 1 LIMIT 1")).split()) if x), None)
    writes = []
    for wid, sql in (("cypher CREATE", f"SELECT x FROM cypher('{g}', $q$ CREATE (n:{lab} {{iri: 'urn:ksx:s8:reader-write-test'}}) RETURN n $q$) AS (x agtype);"),
                     ("SQL UPDATE", f'UPDATE {g}."{lab}" SET properties = properties WHERE false;'),
                     ("pgsync DELETE", "DELETE FROM pgsync.node WHERE false;")):
        q = f"BEGIN;\nSET search_path = ag_catalog, \"$user\", public;\n{sql}\nROLLBACK;"
        try:
            psql_at(cfg, q, dsn=cfg.reader)
            writes.append({"id": wid, "denied": False, "error": ""})
        except DbError as e:
            msg = str(e)
            writes.append({"id": wid, "denied": "permission denied" in msg or "권한" in msg, "error": msg.splitlines()[0][:160]})
    ok = all(c["ok"] for c in checks) and all(w["denied"] for w in writes)
    return {"user": cfg.reader.user, "checks": checks, "writes": writes, "ok": ok}


# ------------------------------------------------------------------ (2-1) 전수 비교 — 노드·관계·속성 값 하나하나
def _agtype(text: str):
    """agtype 출력 → 파이썬 값(숫자 형 표기 ::numeric 등 제거)."""
    return json.loads(re.sub(r"::(numeric|float|integer)\b", "", text))


def age_dump(cfg: Config, s: dict) -> dict:
    """속성 그래프의 노드(iri → 라벨·속성)·관계((s iri, 라벨, o iri) → 속성) 전부."""
    g = s["graph"]
    labels = [x.split("|") for x in psql_at(cfg, (
        "SELECT l.name || '|' || l.kind::text FROM ag_catalog.ag_label l JOIN ag_catalog.ag_graph gg ON l.graph = gg.graphid "
        f"WHERE gg.name = '{g}' AND l.name NOT LIKE '\\_ag\\_label\\_%' ORDER BY 1")).split()]
    vl = [n for n, k in labels if k == "v"]
    el = [n for n, k in labels if k == "e"]
    nodes, ids, dup = {}, {}, []
    if vl:
        q = " UNION ALL ".join(f"SELECT json_build_array('{n}', id::text, properties::text)::text FROM ONLY {g}.\"{n}\"" for n in vl)
        for line in psql_at(cfg, q).splitlines():
            if not line.strip():
                continue
            lab, gid, props = json.loads(line)
            pr = _agtype(props)
            iri = pr.get("iri")
            ids[gid] = iri
            if iri in nodes:
                dup.append(iri)
            nodes[iri] = {"label": lab, "props": pr}
    edges, orphan = {}, 0
    if el:
        q = " UNION ALL ".join(f"SELECT json_build_array('{n}', start_id::text, end_id::text, properties::text)::text FROM ONLY {g}.\"{n}\"" for n in el)
        for line in psql_at(cfg, q).splitlines():
            if not line.strip():
                continue
            lab, a, b, props = json.loads(line)
            if a not in ids or b not in ids:
                orphan += 1
                continue
            k = (ids[a], lab, ids[b])
            if k in edges:
                dup.append("|".join(k))
            edges[k] = _agtype(props)
    return {"nodes": nodes, "edges": edges, "dup": dup, "orphan": orphan}


def vtype(v) -> str:
    if isinstance(v, bool):
        return "참거짓"
    if isinstance(v, int):
        return "정수"
    if isinstance(v, float):
        return "실수"
    if isinstance(v, list):
        return "목록"
    if isinstance(v, str) and re.match(r"^\d{4}-\d{2}-\d{2}", v):
        return "날짜·시각"
    return "문자·코드"


def _same(a, b) -> bool:
    if isinstance(a, (int, float)) and isinstance(b, (int, float)) and not isinstance(a, bool) and not isinstance(b, bool):
        return math.isclose(a, b, rel_tol=1e-12, abs_tol=0.0)
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(_same(x, y) for x, y in zip(a, b))
    return a == b


def compare(kg: dict, dump: dict, samples: int = 5) -> dict:
    """지식 그래프에서 만든 노드·관계(기대)와 속성 그래프에 실제로 있는 것을 하나하나 비교."""
    want_n = {i: {"label": n["label"], "props": json.loads(_j(n["props"]))} for i, n in kg["nodes"].items()}
    want_e = {k: json.loads(_j(v)) for k, v in kg["edges"].items()}
    got_n, got_e = dump["nodes"], dump["edges"]
    miss_n = sorted(set(want_n) - set(got_n))
    extra_n = sorted(set(got_n) - set(want_n))
    label_diff, prop_diff, types = [], [], {}
    for iri in sorted(set(want_n) & set(got_n)):
        w, a = want_n[iri], got_n[iri]
        if w["label"] != a["label"]:
            label_diff.append(f"{iri} {w['label']}→{a['label']}")
        for k in sorted(set(w["props"]) | set(a["props"])):
            t = vtype(w["props"].get(k, a["props"].get(k)))
            st = types.setdefault(t, {"values": 0, "diff": 0})
            st["values"] += 1
            if k not in w["props"] or k not in a["props"] or not _same(w["props"][k], a["props"][k]):
                st["diff"] += 1
                prop_diff.append(f"{iri} {k}: {w['props'].get(k, '∅')!r} ≠ {a['props'].get(k, '∅')!r}")
    miss_e = sorted(set(want_e) - set(got_e))
    extra_e = sorted(set(got_e) - set(want_e))
    eprop_diff, ekeys = [], 0
    for k in sorted(set(want_e) & set(got_e)):
        ekeys += len(set(want_e[k]) | set(got_e[k]))
        if not all(_same(want_e[k].get(x), got_e[k].get(x)) for x in set(want_e[k]) | set(got_e[k])):
            eprop_diff.append(f"{'|'.join(k)}: {want_e[k]} ≠ {got_e[k]}")
    counts = {"nodes": len(want_n), "edges": len(want_e), "age_nodes": len(got_n), "age_edges": len(got_e),
              "node_values": sum(x["values"] for x in types.values()), "edge_values": ekeys,
              "miss_nodes": len(miss_n), "extra_nodes": len(extra_n), "label_diff": len(label_diff), "prop_diff": len(prop_diff),
              "miss_edges": len(miss_e), "extra_edges": len(extra_e), "edge_prop_diff": len(eprop_diff),
              "dup": len(dump.get("dup") or []), "orphan": dump.get("orphan", 0)}
    err = sum(v for k, v in counts.items() if k not in ("nodes", "edges", "age_nodes", "age_edges", "node_values", "edge_values"))
    fmt_e = lambda k: "|".join(k)  # noqa: E731
    return {**counts, "error": err, "ok": err == 0, "types": types,
            "samples": {"miss_nodes": miss_n[:samples], "extra_nodes": extra_n[:samples], "label_diff": label_diff[:samples],
                        "prop_diff": prop_diff[:samples], "miss_edges": [fmt_e(k) for k in miss_e[:samples]],
                        "extra_edges": [fmt_e(k) for k in extra_e[:samples]], "edge_prop_diff": eprop_diff[:samples],
                        "dup": (dump.get("dup") or [])[:samples]}}


def compare_line(f: dict) -> str:
    return (f"  전수 비교: 노드 {f['nodes']:,}(속성 값 {f['node_values']:,}) · 관계 {f['edges']:,}(속성 값 {f['edge_values']:,}) → "
            f"누락 {f['miss_nodes']}/{f['miss_edges']} · 초과 {f['extra_nodes']}/{f['extra_edges']} · 라벨 {f['label_diff']} · "
            f"속성 {f['prop_diff']}/{f['edge_prop_diff']} · 중복 {f['dup']} · 끊김 {f['orphan']} {'OK' if f['ok'] else '불일치'}")


# ------------------------------------------------------------------ (3) 벡터 — 임베딩·Qdrant(REST)
class Embedder:
    """TEI 호환 임베딩 서버(POST /embed {inputs}) — 기본 bge-m3(1024차원, 한·영). url이 'hash:'면 시험용 결정적 벡터."""

    def __init__(self, url: str, dim: int, batch: int):
        self.url, self.dim, self.batch = url, dim, batch

    def __call__(self, texts: list[str]) -> list[list[float]]:
        out = []
        for i in range(0, len(texts), self.batch):
            part = texts[i:i + self.batch]
            if self.url.startswith("hash:"):
                out += [hash_vector(t, self.dim) for t in part]
                continue
            body = json.dumps({"inputs": part, "normalize": True, "truncate": True}).encode()
            req = urllib.request.Request(self.url + "/embed", data=body, method="POST",
                                         headers={"Content-Type": "application/json"})
            for attempt in range(5):
                try:
                    with urllib.request.urlopen(req, timeout=600) as r:
                        vs = json.load(r)
                    break
                except urllib.error.HTTPError as e:
                    if e.code in (424, 429, 503) and attempt < 4:
                        time.sleep(2 * (attempt + 1))
                        continue
                    raise RuntimeError(f"임베딩 {self.url} {e.code}: {e.read().decode(errors='replace')[:300]}") from e
                except urllib.error.URLError as e:
                    raise RuntimeError(f"임베딩 서버 접속 실패 {self.url}: {e.reason}") from e
            if vs and len(vs[0]) != self.dim:
                raise RuntimeError(f"임베딩 차원 {len(vs[0])} ≠ 계획 {self.dim}")
            out += vs
        return out


def hash_vector(text: str, dim: int) -> list[float]:
    v = [0.0] * dim
    t = re.sub(r"\s+", " ", text.lower())
    for n in (2, 3):
        for i in range(max(1, len(t) - n + 1)):
            h = int.from_bytes(hashlib.md5(t[i:i + n].encode()).digest()[:4], "little")
            v[h % dim] += 1.0 if h & 1 else -1.0
    norm = math.sqrt(sum(x * x for x in v)) or 1.0
    return [x / norm for x in v]


class Reranker:
    """TEI 호환 재정렬 서버(POST /rerank {query, texts}) — 기본 bge-reranker-v2-m3. url이 'hash:'면 시험용(글자 겹침)."""

    def __init__(self, conf: dict):
        self.url, self.top, self.collections = conf.get("url", ""), int(conf.get("top", 20)), set(conf.get("collections") or [])

    def __call__(self, query: str, texts: list[str]) -> list[float]:
        if not texts:
            return []
        if self.url.startswith("hash:"):
            qs = set(query)
            return [len(qs & set(t)) / (len(qs) or 1) for t in texts]
        body = json.dumps({"query": query, "texts": [t[:1200] for t in texts], "truncate": True}).encode()
        req = urllib.request.Request(self.url + "/rerank", data=body, method="POST", headers={"Content-Type": "application/json"})
        for attempt in range(5):
            try:
                with urllib.request.urlopen(req, timeout=600) as r:
                    res = json.load(r)
                break
            except urllib.error.HTTPError as e:
                if e.code in (424, 429, 503) and attempt < 4:
                    time.sleep(2 * (attempt + 1))
                    continue
                raise RuntimeError(f"재정렬 {self.url} {e.code}: {e.read().decode(errors='replace')[:300]}") from e
            except urllib.error.URLError as e:
                raise RuntimeError(f"재정렬 서버 접속 실패 {self.url}: {e.reason}") from e
        sc = [0.0] * len(texts)
        for x in res:
            sc[x["index"]] = x["score"]
        return sc


def retrieve(q, rr, collection: str, vector: list[float], query: str, k: int, flt: dict | None) -> list[dict]:
    """벡터 검색(상위 max(k, rr.top)) → 재정렬(설정된 컬렉션)."""
    use = rr is not None and collection in rr.collections
    hits = q.search(collection, vector, max(k, rr.top) if use else k, flt)
    if use and hits:
        sc = rr(query, [h["payload"].get("text", "") for h in hits])
        for h, x in zip(hits, sc):
            h["vector_score"], h["score"] = h.get("score"), x
        hits = sorted(hits, key=lambda h: -h["score"])
    return hits


class Qdrant:
    def __init__(self, url: str, key: str = ""):
        self.url, self.key = url, key

    def req(self, method: str, path: str, body=None, ok404=False):
        data = json.dumps(body).encode() if body is not None else None
        h = {"Content-Type": "application/json"}
        if self.key:
            h["api-key"] = self.key
        req = urllib.request.Request(self.url + path, data=data, method=method, headers=h)
        try:
            with urllib.request.urlopen(req, timeout=600) as r:
                return json.load(r).get("result")
        except urllib.error.HTTPError as e:
            if ok404 and e.code == 404:
                return None
            raise RuntimeError(f"Qdrant {method} {path} {e.code}: {e.read().decode(errors='replace')[:300]}") from e
        except urllib.error.URLError as e:
            raise RuntimeError(f"Qdrant 접속 실패 {self.url}: {e.reason}") from e

    def ensure(self, name: str, dim: int, keyword_fields: list[str]):
        info = self.req("GET", f"/collections/{name}", ok404=True)
        if info is None:
            self.req("PUT", f"/collections/{name}", {"vectors": {"size": dim, "distance": "Cosine"}})
        else:
            size = info["config"]["params"]["vectors"]["size"]
            if size != dim:
                raise RuntimeError(f"Qdrant {name} 벡터 크기 {size} ≠ 계획 {dim} — 컬렉션을 지우고 다시 색인")
        for f in keyword_fields:
            self.req("PUT", f"/collections/{name}/index?wait=true", {"field_name": f, "field_schema": "keyword"})

    def hashes(self, name: str) -> dict:
        out, off = {}, None
        while True:
            body = {"limit": 1000, "with_payload": ["hash"], "with_vector": False}
            if off is not None:
                body["offset"] = off
            r = self.req("POST", f"/collections/{name}/points/scroll", body)
            for p in r["points"]:
                out[str(p["id"])] = (p.get("payload") or {}).get("hash")
            off = r.get("next_page_offset")
            if off is None:
                return out

    def upsert(self, name: str, points: list[dict]):
        for i in range(0, len(points), 256):
            self.req("PUT", f"/collections/{name}/points?wait=true", {"points": points[i:i + 256]})

    def delete(self, name: str, ids: list[str]):
        for i in range(0, len(ids), 1000):
            self.req("POST", f"/collections/{name}/points/delete?wait=true", {"points": ids[i:i + 1000]})

    def count(self, name: str) -> int:
        return self.req("POST", f"/collections/{name}/points/count", {"exact": True})["count"]

    def search(self, name: str, vector: list[float], k: int, flt: dict | None = None) -> list[dict]:
        body = {"vector": vector, "limit": k, "with_payload": True}
        if flt:
            body["filter"] = flt
        return self.req("POST", f"/collections/{name}/points/search", body)


def point_id(collection: str, key: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, f"ksx:{collection}:{key}"))


# ------------------------------------------------------------------ (3) 색인 대상 — 표 28
def load_cards(cfg: Config, s: dict) -> dict:
    """명사 카드 → {클래스 로컬명: 카드}. 헤더·라인 구조체는 라인 클래스도 같은 카드를 가리킨다."""
    cards = {}
    for f in sorted(glob.glob(os.path.join(cfg.repo, s["catalog"], "*.json"))):
        c = json.load(open(f, encoding="utf-8"))
        c["_name"] = c["noun"].split(":")[-1]
        cards[c["_name"]] = c
        if c.get("struct"):
            cards.setdefault(c["struct"]["line"], c)
    return cards


def card_attrs(card: dict, label: str) -> list[dict]:
    st = card.get("struct")
    if not st:
        return card["attributes"]
    table = st["line"] if label == st["line"] else st["header"]
    return [a for a in card["attributes"] if a.get("in") == table]


def prop_key(a: dict) -> str:
    return (a.get("property") or "").split(":")[-1]


def fmt(v, key: str = "", labels: dict | None = None) -> str:
    if isinstance(v, list):
        return ", ".join(fmt(x, key, labels) for x in v)
    if labels and (key, v) in labels:
        return f"{labels[(key, v)]}({v})"
    if isinstance(v, bool):
        return "예" if v else "아니오"
    if isinstance(v, float) and v.is_integer():
        return str(int(v))
    return str(v)


def identity(card: dict, label: str, props: dict) -> list[str]:
    attrs = card_attrs(card, label)
    keys = [a for a in attrs if a["en"] in (card.get("identity") or [])] or [a for a in attrs if a["type"] == "ID"]
    vals = []
    for a in keys:
        v = props.get(prop_key(a))
        if v is not None and fmt(v) not in vals:
            vals.append(fmt(v))
    return vals


# ------------------------------------------------------------------ 업무 용어(S8 D-1) — 명사 카드 ↔ 현장 말
def _xlsx_rows(path: str, sheet: str) -> list[tuple]:
    try:
        import openpyxl
    except ImportError:                                  # 이미지에 없으면 S1 원천은 건너뛴다(리포트에 표시)
        return []
    if not os.path.exists(path):
        return []
    wb = openpyxl.load_workbook(path, read_only=True)
    if sheet not in wb.sheetnames:
        return []
    return [r for i, r in enumerate(wb[sheet].iter_rows(values_only=True)) if i and any(r)]


def business_terms(cfg: Config, s: dict, cards: dict, kg: dict) -> dict:
    """명사마다 업무 용어를 이미 승인된 산출물에서 모은다 — 평가 질문(S1 업무 질의서)은 쓰지 않는다.
      원천: S2 매핑의 원천 테이블 업무 의미·컬럼 주석(S1 원천인벤토리), 지식 그래프의 참조 개체 이름(파라미터명·공정명 …),
            코드 레이블(S4 vocab), S1 KPI정의서의 KPI명, 계획 sync.terms(현업이 더하는 말)."""
    limit = int(s.get("terms_max_values", 40))
    out = {}

    def add(noun, term, src):
        term = str(term or "").strip()
        if noun in cards and term and len(term) <= 60 and re.search(r"[가-힣]", term):   # 한글 없는 형식 주석(YYYYMMDD 등) 제외
            d = out.setdefault(cards[noun]["_name"], {})
            d.setdefault(term, src)
    s1 = os.path.join(cfg.mapping_dir(), "s1")
    inv = os.path.join(s1, f"S1_원천인벤토리_{cfg.ent}.xlsx")
    meaning = {f"{r[1]}.{r[2]}": r[3] for r in _xlsx_rows(inv, "원천인벤토리") if r[1] and r[2] and r[3]}
    colnote = {(f"{r[1]}.{r[2]}", r[4]): r[9] for r in _xlsx_rows(inv, "컬럼목록") if r[9]}
    for f in sorted(glob.glob(os.path.join(cfg.mapping_dir(), "*", "*.yaml"))):        # (1) S2 매핑 → 원천 업무 의미·컬럼 주석
        try:
            m = yaml.safe_load(open(f, encoding="utf-8"))
        except yaml.YAMLError:
            continue
        if not isinstance(m, dict) or "noun" not in m or not isinstance(m.get("source"), dict):
            continue
        noun = m["noun"].split(":")[-1]
        tab = m["source"].get("table", "")
        add(noun, meaning.get(tab), "원천 업무 의미")
        for spec in (m.get("attributes") or {}).values():
            for col in re.findall(r"[a-z_][a-z0-9_]*", str((spec or {}).get("from", ""))):
                add(noun, colnote.get((tab, col)), "원천 컬럼 주석")
    names_by_key = {}                                    # (2) 참조 개체 이름: 식별 속성 값 → 이름(TraceParameter.parameterID → 금형온도)
    for n in kg["nodes"].values():
        c = cards.get(n["label"])
        if not c:
            continue
        nm = [n["props"][prop_key(a)] for a in name_attrs(c, n["label"]) if isinstance(n["props"].get(prop_key(a)), str)]
        if not nm:
            continue
        for a in card_attrs(c, n["label"]):
            if a["en"] in (c.get("identity") or []) and isinstance(n["props"].get(prop_key(a)), str):
                names_by_key.setdefault(prop_key(a), {})[n["props"][prop_key(a)]] = nm[0]
    seen = {}
    for n in kg["nodes"].values():
        if n["label"] not in cards:
            continue
        for k, v in n["props"].items():
            for x in (v if isinstance(v, list) else [v]):
                if k in names_by_key and x in names_by_key[k]:
                    seen.setdefault((n["label"], "참조 개체 이름", k), set()).add(names_by_key[k][x])
                elif (k, x) in kg["labels"]:                                         # (3) 코드 레이블
                    seen.setdefault((n["label"], "코드 레이블", k), set()).add(kg["labels"][(k, x)])
    for lab, c in cards.items():                         # 카드가 식별값으로 참조하는 개체의 이름 전부(데이터가 적게 물질화돼도 — TraceParameter.ParameterID → 파라미터명)
        for a in card_attrs(c, lab):
            k = prop_key(a)
            if a["type"] == "IDREF" and k in names_by_key:
                seen.setdefault((c["_name"], "참조 개체 이름", k), set()).update(names_by_key[k].values())
    for (lab, src, k), vals in sorted(seen.items()):
        if len(vals) <= limit:                           # 값이 너무 많은 것(품목명 수백 개 등)은 넣지 않는다
            for v in sorted(vals):
                add(lab, v, src)
    kpi = os.path.join(s1, f"S1_KPI정의서_{cfg.ent}.xlsx")
    for r in _xlsx_rows(kpi, "KPI정의서"):              # (4) KPI명 ↔ 표준 명사
        if len(r) > 11 and r[3] and r[11]:
            for noun in re.split(r"[,\s]+", str(r[11])):
                add(noun.strip(), r[3], "KPI")
    spread = {}                                          # 여러 카드에 두루 붙는 말(사업장·공장·품목명 등)은 명사를 가르지 못한다
    for d in out.values():
        for t in d:
            spread[t] = spread.get(t, 0) + 1
    most = int(s.get("terms_max_cards", 3))
    out = {n: {t: src for t, src in d.items() if spread[t] <= most or src == "KPI"} for n, d in out.items()}   # KPI는 여러 명사로 산출
    for noun, terms in (s.get("terms") or {}).items():  # (5) 현업이 더하는 말 — 거르지 않는다
        for t in terms or []:
            add(noun, t, "현업")
    return {n: d for n, d in out.items() if d}


def extension_answers(cfg: Config, cards: dict) -> dict:
    """S1 KPI정의서의 '원천 공백·Extension'이 S2 확장 명사를 가리키면, 그 KPI의 관련 질의에 확장 명사를 정답으로 더한다.
    (S1 업무 질의서의 필요 명사는 Core만 — 확장 명사는 S2에서 생겼다.) 'XX와 같음'은 그 KPI를 따른다."""
    rows = _xlsx_rows(os.path.join(cfg.mapping_dir(), "s1", f"S1_KPI정의서_{cfg.ent}.xlsx"), "KPI정의서")
    ext = {c["_name"]: c["ko"].replace(" ", "") for c in cards.values() if c.get("layer") != "core"}
    kpi = {r[0]: (str(r[14] or ""), str(r[16] or "")) for r in rows if r and r[0] and len(r) > 16}

    def nouns(kid, depth=0):
        gap = kpi.get(kid, ("", ""))[0]
        found = {n for n, ko in ext.items() if re.search(rf"\b{n}\b", gap) or ko in gap.replace(" ", "")}   # 영문 이름 또는 한글 이름(일별재고)
        for ref in re.findall(r"([A-Z]{2}\d{2})(?:과|와)? 같음", gap):
            if depth < 3 and ref != kid:
                found |= nouns(ref, depth + 1)
        return found
    out = {}
    for kid, (_, qs) in kpi.items():
        for q in re.findall(r"Q-[A-Z0-9-]+", qs):
            out.setdefault(q, set()).update(nouns(kid))
    return {q: sorted(v) for q, v in out.items() if v}


def noun_card_items(cfg: Config, s: dict, cards: dict, terms: dict | None = None) -> dict:
    ver = yaml.safe_load(open(os.path.join(cfg.repo, cfg.raw.get("ksxgen", "ksxgen.yaml")), encoding="utf-8")).get("version", "")
    items = {}
    for name, c in cards.items():
        if name != c["_name"]:
            continue
        ident = [a["ko"] for a in c["attributes"] if a["en"] in (c.get("identity") or [])]
        attrs = list(dict.fromkeys(a["ko"] for a in c["attributes"]))
        refs = [r.get("ko") or r.get("target") or r.get("noun") or str(r) for r in (c.get("references") or []) if isinstance(r, dict)]
        codes = [x.get("ko") or x.get("en") or str(x) for x in (c.get("codes") or []) if isinstance(x, dict)]
        st = c.get("struct")
        compact = ((s["collections"].get("noun_cards") or {}).get("text") == "compact")   # 속성 목록이 길면 뜻이 묻힌다
        text = "\n".join(x for x in [
            f"{c['ko']} ({c['_name']}) — {c.get('definition', '')}",
            f"영역: {c.get('area', '')} · KS X 9101 {c.get('clause', '')} {c.get('table', '')}",
            f"구조: 헤더 {st['header']} · 라인 {st['line']}" if st else "",
            "식별: " + ", ".join(ident) if ident else "",
            "" if compact else "속성: " + ", ".join(attrs),
            "참조: " + ", ".join(dict.fromkeys(refs)) if refs else "",
            "코드: " + ", ".join(dict.fromkeys(codes)) if codes else "",
            "업무 용어: " + ", ".join((terms or {}).get(name, {})) if (terms or {}).get(name) else ""] if x)
        items[name] = {"text": text, "payload": {"noun": name, "ko": c["ko"], "layer": "core" if c.get("layer") == "core" else "ext",
                                                 "ksx_version": ver, "clause": c.get("clause", ""), "key": name,
                                                 "terms": list((terms or {}).get(name, {}))}}
    return items


def name_attrs(card: dict, label: str) -> list[dict]:
    """개체 자신의 이름·설명(ItemMaster.ItemName, Equipment.EquipmentName …). 참조 대상의 이름(수주의 ItemName 등)은 뺀다."""
    out = []
    for a in card_attrs(card, label):
        m = re.match(r"^(\w+?)(Name|Description)$", a["en"])
        if a["type"] == "string" and m and m.group(1) in label:
            out.append(a)
    return out


def node_items(cfg: Config, s: dict, cards: dict, kg: dict) -> dict:
    """주요 개체(이름이 있는 개체)의 라벨·식별 속성 텍스트(표 28 nodes). 범위는 계획 collections.nodes."""
    conf = s["collections"].get("nodes") or {}
    include, exclude = set(conf.get("include") or []), set(conf.get("exclude") or [])
    items = {}
    for iri, n in kg["nodes"].items():
        lab, p = n["label"], n["props"]
        c = cards.get(lab)
        if c is None or lab in exclude:
            continue
        names = [fmt(p[prop_key(a)]) for a in name_attrs(c, lab) if p.get(prop_key(a)) not in (None, "")]
        if not names and lab not in include:
            continue
        ids = identity(c, lab, p)
        key = f"{lab}:{'/'.join(ids)}" if ids else iri
        ko = c["ko"] + ("라인" if c.get("struct") and lab == c["struct"]["line"] else "")
        text = f"{ko}({lab}) {' '.join(ids)} — {' · '.join(dict.fromkeys(names))}".strip(" —")
        pl = {"iri": iri, "noun": lab, "key": key, "name": names[0] if names else ""}
        pl.update({k: p[k] for k in ("ent", "site", "plant") if k in p})
        items[iri] = {"text": text, "payload": pl}
    return items


def case_items(cfg: Config, s: dict, cards: dict, kg: dict) -> dict:
    """원인–조치 이력(표 28 cases): 고객 클레임·시정조치 등. 승인(종결) 여부는 payload approved."""
    conf = s["collections"].get("cases") or {}
    nouns = conf.get("nouns") or []
    approved = conf.get("approved") or {}
    related = set(conf.get("related") or [])
    incoming = {}
    for (a, p, b) in kg["edges"]:
        incoming.setdefault(b, []).append(a)
    items = {}
    for iri, n in kg["nodes"].items():
        lab, p = n["label"], n["props"]
        if lab not in nouns or lab not in cards:
            continue
        c = cards[lab]
        lines = [f"{c['ko']}({lab}) {' '.join(identity(c, lab, p))}"]
        for a in card_attrs(c, lab):
            v = p.get(prop_key(a))
            if v not in (None, "") and a["type"] != "ID":
                lines.append(f"{a['ko']}: {fmt(v, prop_key(a), kg['labels'])}")
        for src in sorted(incoming.get(iri, [])):            # 조치 계획·결과 등 이 이력을 가리키는 개체
            m = kg["nodes"][src]
            if m["label"] in related and m["label"] in cards:
                mc = cards[m["label"]]
                vals = [f"{a['ko']} {fmt(m['props'][prop_key(a)], prop_key(a), kg['labels'])}" for a in card_attrs(mc, m["label"])
                        if m["props"].get(prop_key(a)) not in (None, "") and a["type"] != "ID"]
                lines.append(f"{mc['ko']}: " + ", ".join(vals))
        iris = sorted({b for (a, _, b) in kg["edges"] if a == iri} | {iri})
        rule = dict(approved.get(lab) or {})
        rel = rule.pop("related", None)                      # 예: 시정조치요청은 결과(종결)가 있으면 승인
        ok = all(fmt(p.get(k, "")) in [str(x) for x in v] for k, v in rule.items())
        if rel:
            ok = ok and any(kg["nodes"][x]["label"] == rel for x in incoming.get(iri, []))
        cid = (identity(c, lab, p) or [iri])[0]
        pl = {"case_id": cid, "key": cid, "noun": lab, "iris": iris, "approved": "Y" if ok else "N"}
        pl.update({k: p[k] for k in ("ent", "site", "plant") if k in p})
        items[iri] = {"text": "\n".join(lines), "payload": pl}
    return items


def front_matter(text: str) -> tuple[dict, str]:
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    return (yaml.safe_load(m.group(1)) or {}, text[m.end():]) if m else ({}, text)


def chunks(body: str, lo: int, hi: int) -> list[tuple[str, str]]:
    """문단을 차례로 모아 lo자를 넘기면 끊는다(hi자 이하). 절이 바뀌면 [절 제목]을 넣는다. (첫 절 제목, 본문)."""
    units, sec = [], ""
    for block in re.split(r"\n\s*\n", body):
        b = block.strip()
        if not b:
            continue
        if b.startswith("#"):
            first, _, b = b.partition("\n")
            sec, b = first.lstrip("# ").strip(), b.strip()
            if not b:
                continue
        for piece in ([b] if len(b) <= hi else re.split(r"(?<=[.다요])\s+", b)):
            while len(piece) > hi:                         # 문장 하나가 너무 길면 자른다
                units.append((sec, piece[:hi]))
                piece = piece[hi:]
            units.append((sec, piece))
    out = []
    for sec, t in units:
        if out:
            head, cur, last = out[-1]
            add = (f"[{sec}]\n" if sec != last else "") + t
            if len(cur) < lo and len(cur) + 1 + len(add) <= hi:
                out[-1] = (head, cur + "\n" + add, sec)
                continue
        out.append((sec, t, sec))
    if len(out) > 1 and len(out[-1][1]) < lo // 2:       # 짧은 끝 청크는 들어가면 앞 청크에 붙인다
        head, cur, last = out[-2]
        add = (f"[{out[-1][0]}]\n" if out[-1][0] != last else "") + out[-1][1]
        if len(cur) + 1 + len(add) <= hi:
            out[-2:] = [(head, cur + "\n" + add, out[-1][2])]
    return [(h, t) for h, t, _ in out]


def resolve_links(links: list[str], kg: dict, cards: dict) -> tuple[list[str], list[str]]:
    """'라벨:식별값'(예 Equipment:DCM-02) → 노드 IRI."""
    idx = {}
    for iri, n in kg["nodes"].items():
        c = cards.get(n["label"])
        if c:
            for v in identity(c, n["label"], n["props"]):
                idx.setdefault((n["label"], v), []).append(iri)
    iris, missing = [], []
    for ln in links or []:
        lab, _, v = str(ln).partition(":")
        hit = idx.get((lab, v))
        if hit:
            iris += hit
        else:
            missing.append(ln)
    return sorted(set(iris)), missing


def document_items(cfg: Config, s: dict, cards: dict, kg: dict) -> tuple[dict, list[dict]]:
    conf = s["collections"].get("documents") or {}
    lo, hi = conf.get("chunk", [500, 800])
    items, docs = {}, []
    for f in sorted(glob.glob(os.path.join(cfg.repo, conf.get("dir", "documents"), "*.md"))):
        meta, body = front_matter(open(f, encoding="utf-8").read())
        if not meta.get("doc_id"):
            continue
        iris, missing = resolve_links(meta.get("links"), kg, cards)
        parts = chunks(body, lo, hi)
        docs.append({"file": os.path.relpath(f, cfg.repo), "doc_id": meta["doc_id"], "version": str(meta.get("version", "")),
                     "status": meta.get("status", ""), "title": meta.get("title", ""), "chunks": len(parts),
                     "sizes": [len(t) for _, t in parts], "iris": len(iris), "missing": missing})
        for i, (sec, t) in enumerate(parts, 1):
            key = f"{meta['doc_id']}@{meta.get('version', '')}#{i}"
            head = f"[{meta.get('title', '')} {meta['doc_id']} v{meta.get('version', '')}{' · ' + sec if sec else ''}]"
            items[key] = {"text": head + "\n" + t, "payload": {
                "doc_id": meta["doc_id"], "version": str(meta.get("version", "")), "status": meta.get("status", ""),
                "title": meta.get("title", ""), "section": sec, "chunk": i, "iris": iris,
                "nouns": meta.get("nouns") or [], "site": meta.get("site", s["site"]), "key": meta["doc_id"],
                "doc_version": f"{meta['doc_id']}@{meta.get('version', '')}"}}
    return items, docs


KEYWORDS = {"noun_cards": ["noun", "layer"], "nodes": ["iri", "noun", "key", "plant"],
            "cases": ["case_id", "approved", "site"], "documents": ["doc_id", "status", "doc_version"]}


def index(q: Qdrant, emb: Embedder, s: dict, name: str, items: dict, out=print) -> dict:
    t0 = time.time()
    q.ensure(name, s["dim"], KEYWORDS.get(name, []))
    have = q.hashes(name)
    want, todo = {}, []
    for key, it in items.items():
        pid = point_id(name, key)
        h = hashlib.sha1((s["model"] + "\n" + it["text"] + "\n" + _j(it["payload"])).encode("utf-8")).hexdigest()
        want[pid] = h
        if have.get(pid) != h:
            todo.append((pid, it, h))
    stale = [pid for pid in have if pid not in want]
    if todo:
        vecs = emb([it["text"] for _, it, _ in todo])
        q.upsert(name, [{"id": pid, "vector": v, "payload": {**it["payload"], "text": it["text"], "hash": h}}
                        for (pid, it, h), v in zip(todo, vecs)])
    if stale:
        q.delete(name, stale)
    added = sum(1 for pid, _, _ in todo if pid not in have)
    st = {"total": q.count(name), "added": added, "updated": len(todo) - added, "removed": len(stale),
          "seconds": round(time.time() - t0, 2)}
    out(f"  {name:11} {st['total']:>6,}개 (추가 {st['added']:,} · 변경 {st['updated']:,} · 삭제 {st['removed']:,}) {st['seconds']}초")
    return st


# ------------------------------------------------------------------ (4) 검색·평가
def default_filter(collection: str, flt: dict | None) -> dict | None:
    must = [{"key": k, "match": {"value": v}} for k, v in (flt or {}).items()]
    if collection == "documents" and not any(m["key"] == "status" for m in must):
        must.append({"key": "status", "match": {"value": "현행"}})    # 폐기·초안 문서를 현행으로 오인하지 않게(11.2)
    return {"must": must} if must else None


def search(q: Qdrant, emb: Embedder, collection: str, text: str, k: int, flt: dict | None = None, rr=None) -> list[dict]:
    return retrieve(q, rr, collection, emb([text])[0], text, k * 4, default_filter(collection, flt))[:k * 4]


def top_hits(hits: list[dict], k: int) -> list[dict]:
    out, seen = [], set()
    for h in hits:
        key = h["payload"].get("key")
        if key not in seen:
            seen.add(key)
            out.append(h)
    return out[:k]


def top_keys(hits: list[dict], k: int) -> list[str]:
    keys = []
    for h in hits:
        key = h["payload"].get("key")
        if key not in keys:
            keys.append(key)
    return keys[:k]


def evaluate(cfg: Config, s: dict, q: Qdrant, emb: Embedder, rid: str | None, out=print, rr=None) -> dict:
    """사례마다 recall@k(정답 중 상위 k에 든 비율)와 적중@k(정답이 하나라도 들었나)를 잰다.
    완료 판정은 컬렉션마다 계획 metric(recall | hit, 기본 recall)으로 한다(S8 D-1: 명사 카드 = 출발점 명사 적중,
    질의에 필요한 명사 전부 찾기는 S9 GraphRAG 평가)."""
    ev = s["eval"]
    k = int(ev["k"])
    metric = ev.get("metric") or {}
    cases = ev.get("cases") or []
    res = []
    vecs = emb([c["query"] for c in cases]) if cases else []
    for c, v in zip(cases, vecs):
        col = c["collection"]
        hits = retrieve(q, rr, col, v, c["query"], k * 4, default_filter(col, c.get("filter")))   # 문서는 청크가 여러 개 — 문서 단위 상위 k
        keys = top_keys(hits, k)
        exp = [str(x) for x in c["expected"]]
        alt = [x for x in (s.get("ext_answers") or {}).get(c.get("source", ""), []) if x not in exp] if col == "noun_cards" else []
        if ev.get("extension_answers") and alt:          # D-2: S1 KPI정의서의 S2 확장 명사도 정답(원래 S1 정답은 expected에 그대로)
            exp, alt = exp + alt, []
        tp = [x for x in exp if x in keys]
        rec = len(tp) / min(len(exp), k) if exp else 1.0
        bad = [h["payload"].get("doc_version") or h["payload"].get("key") for h in hits[:k]
               if (h["payload"].get("doc_version") in (c.get("must_not") or [])) or (h["payload"].get("key") in (c.get("must_not") or []))]
        hit = bool(tp) and not bad
        if bad:
            rec = 0.0
        m = metric.get(col, "recall")
        alt_hit = bool(tp) or any(x in keys for x in alt)
        res.append({"id": c["id"], "collection": col, "query": c["query"], "expected": exp, "got": keys, "ext": alt, "alt_hit": alt_hit and not bad,
                    "recall": round(min(rec, 1.0), 4), "hit": hit, "metric": m,
                    "score": float(hit) if m == "hit" else round(min(rec, 1.0), 4), "must_not": bad, "source": c.get("source", "")})
    by = {}
    for r in res:
        a = by.setdefault(r["collection"], {"cases": 0, "recall": 0.0, "hit": 0, "score": 0.0, "metric": r["metric"]})
        a["cases"] += 1
        a["recall"] += r["recall"]
        a["hit"] += r["hit"]
        a["score"] += r["score"]
    for a in by.values():
        for x in ("recall", "hit", "score"):
            a[x] = round(a[x] / a["cases"], 4)
    nc = [r for r in res if r["collection"] == "noun_cards"]
    alt_hit = round(sum(r["alt_hit"] for r in nc) / len(nc), 4) if nc else None      # 참고: S2 확장 명사를 정답에 더하면(D-2)
    tot = round(sum(r["recall"] for r in res) / len(res), 4) if res else 0.0
    hit = round(sum(r["hit"] for r in res) / len(res), 4) if res else 0.0
    for col, a in sorted(by.items()):
        out(f"  {col:11} 사례 {a['cases']:>4} · recall@{k} {a['recall']:.3f} · 적중@{k} {a['hit']:.3f} → 판정({a['metric']}) {a['score']:.3f}")
    if alt_hit is not None and not ev.get("extension_answers"):
        out(f"  (참고) 명사 카드 적중@{k} — S2 확장 명사를 정답에 더하면 {alt_hit:.3f} ({sum(1 for r in nc if r['ext'])}건에 확장 명사)")
    ok = bool(res) and all(a["score"] >= ev["threshold"] for a in by.values()) and not any(r["must_not"] for r in res)
    if rid and res:
        vals = ", ".join(
            "('{}', '{}', '{}', '{}', '{}'::jsonb, '{}'::jsonb, {})".format(
                rid, r["id"], r["collection"], r["query"].replace("'", "''"),
                json.dumps(r["expected"], ensure_ascii=False).replace("'", "''"),
                json.dumps(r["got"], ensure_ascii=False).replace("'", "''"), r["recall"]) for r in res)
        psql_at(cfg, f"insert into audit.search_eval(run_id, case_id, collection, query, expected, got, recall) values {vals}")
    return {"cases": res, "by": by, "recall": tot, "hit": hit, "k": k, "threshold": ev["threshold"], "ok": ok, "alt_hit": alt_hit,
            "ext_on": bool(ev.get("extension_answers")), "rerank": sorted(rr.collections) if rr else []}


# ------------------------------------------------------------------ 진입점
def log(cfg: Config, rid: str, target: str, kind: str, st: dict, detail: dict | None = None):
    psql_at(cfg, "insert into audit.graph_sync(run_id, target, kind, total, added, updated, removed, seconds, detail) values "
                 f"('{rid}', '{target}', '{kind}', {st.get('total', 0)}, {st.get('added', 0)}, {st.get('updated', 0)}, "
                 f"{st.get('removed', 0)}, {st.get('seconds') or 'null'}, "
                 f"'{json.dumps(detail or {}, ensure_ascii=False).replace(chr(39), chr(39) * 2)}'::jsonb)")


def graph_ok(res: dict) -> bool:
    """속성 그래프 판정 — 라벨별 수 정합 + 전수 비교 + 탐색 확인 + 조회 계정."""
    return (res["consistency"]["ok"] and res["full"]["ok"] and all(g["ok"] for g in res["checks"]) and res["reader"]["ok"])


def sync(cfg: Config, eval_only=False, skip_vectors=False, out=print) -> bool:
    s = settings(cfg)
    psql_at(cfg, "select 1")
    rid = start_run(cfg, "kg_search_eval" if eval_only else "kg_sync", stage="S8")
    psql_at(cfg, AUDIT_SQL)
    q, emb = Qdrant(s["qdrant"], s["qdrant_key"]), Embedder(s["embed"], int(s["dim"]), int(s["batch"]))
    out(f"S8 동기화 run_id={rid} (속성 그래프 {s['graph']}, Qdrant {s['qdrant']}, 임베딩 {s['model']} {s['dim']}차원"
        + (f", 재정렬 {s['rerank'].get('model', '')} 상위 {s['rerank']['top']}" if s["rerank"] and s["rerank"]["collections"] else "") + ")")
    res = {"rid": rid, "s": s}
    try:
        if not eval_only:
            t0 = time.time()
            kg = build(cfg, fetch(cfg), code_labels(cfg))
            res["kg"] = {k: kg[k] for k in ("triples", "dangling", "bnodes", "clash")} | {
                "nodes": len(kg["nodes"]), "edges": len(kg["edges"]), "multi": len(kg["multi"])}
            out(f"  내보내기: 트리플 {kg['triples']:,} → 노드 {len(kg['nodes']):,} · 관계 {len(kg['edges']):,} "
                f"(대상 없는 참조 {kg['dangling']} · 빈 노드 {kg['bnodes']} · 다중 클래스 {len(kg['multi'])}) {round(time.time() - t0, 1)}초")
            bad = {k: v for k, v in kg["clash"].items() if k in {p for _, p, _ in kg["edges"]}}
            if bad:
                raise RuntimeError(f"서로 다른 어휘의 같은 로컬 이름 — 관계 라벨 충돌: {bad}")
            t1 = time.time()
            age = apply_age(cfg, s, kg)
            age["seconds"] = round(time.time() - t1, 2)
            res["age"] = age
            for k in ("nodes", "edges"):
                a = age[k]
                out(f"  속성 그래프 {'노드' if k == 'nodes' else '관계'} {a['total']:>7,} (추가 {a['added']:,} · 변경 {a['updated']:,} · 삭제 {a['removed']:,})"
                    + (f" {age['seconds']}초" if k == "edges" else ""))
                log(cfg, rid, s["graph"], k, {**a, "seconds": age["seconds"]})
            c = consistency(cfg, s)
            res["consistency"] = c
            out(f"  정합: RDF 노드 {c['rdf_v']:,} · 관계 {c['rdf_e']:,} / AGE 노드 {c['age_v']:,} · 관계 {c['age_e']:,} → 오차 {c['error']} "
                f"(다중 클래스 {c['multi']} · 끊긴 관계 {c['broken']}) {'OK' if c['ok'] else '불일치'}")
            log(cfg, rid, s["graph"], "consistency", {"total": c["age_v"] + c["age_e"]},
                {"error": c["error"], "multi": c["multi"], "broken": c["broken"]})
            t2 = time.time()
            f = compare(kg, age_dump(cfg, s))
            f["seconds"] = round(time.time() - t2, 1)
            res["full"] = f
            out(compare_line(f) + f" {f['seconds']}초")
            for k, v in f["samples"].items():
                if v:
                    out(f"    {k}: {v}")
            log(cfg, rid, s["graph"], "full_compare", {"total": f["nodes"] + f["edges"]},
                {k: f[k] for k in ("error", "miss_nodes", "extra_nodes", "label_diff", "prop_diff", "miss_edges", "extra_edges", "edge_prop_diff")})
            res["checks"] = graph_checks(cfg, s)
            for g in res["checks"]:
                out(f"  탐색 {g['id']} {'OK' if g['ok'] else '불일치'} — {g['desc']} {g['got'][:5]}{' ' + g['error'] if g['error'] else ''}")
            rd = reader_checks(cfg, s)
            res["reader"] = rd
            out(f"  조회 계정 {rd['user']}: 탐색 {sum(c['ok'] for c in rd['checks'])}/{len(rd['checks'])} 같은 답 · "
                f"쓰기 거부 {sum(w['denied'] for w in rd['writes'])}/{len(rd['writes'])} {'OK' if rd['ok'] else '불일치'}")
            for w in rd["writes"]:
                if not w["denied"]:
                    out(f"    {w['id']}: 거부되지 않음 {w['error']}")
            if not skip_vectors:
                cards = load_cards(cfg, s)
                docs_items, docs = document_items(cfg, s, cards, kg)
                res["docs"] = docs
                res["vectors"] = {}
                terms = business_terms(cfg, s, cards, kg)
                res["terms"] = terms
                for name, items in (("noun_cards", noun_card_items(cfg, s, cards, terms)), ("nodes", node_items(cfg, s, cards, kg)),
                                    ("cases", case_items(cfg, s, cards, kg)), ("documents", docs_items)):
                    st = index(q, emb, s, name, items, out)
                    res["vectors"][name] = st
                    log(cfg, rid, name, "vector", st)
        if skip_vectors and not eval_only:               # 속성 그래프만 — 리포트(S8_동기화결과.md)는 덮어쓰지 않는다
            ok = graph_ok(res)
            end_run(cfg, rid, ok, {"error": res["consistency"]["error"], "vectors": "skipped"})
            out(f"ksxkg sync --skip-vectors: 속성 그래프 {'완료' if ok else '완료 기준 미충족'} (벡터 색인·검색 평가는 건너뜀)")
            return ok
        s["ext_answers"] = extension_answers(cfg, load_cards(cfg, s))
        rr = Reranker(s["rerank"]) if s["rerank"] and s["rerank"]["collections"] else None
        ev = evaluate(cfg, s, q, emb, rid, out, rr)
        res["eval"] = ev
        out(f"  검색 평가: 컬렉션마다 판정 지표 ≥ {ev['threshold']} → {'충족' if ev['ok'] else '미충족'} "
            f"(전체 recall@{ev['k']} {ev['recall']:.3f} · 적중 {ev['hit']:.3f})")
        ok = ev["ok"] and (eval_only or (graph_ok(res)
                                         and not any(d["missing"] for d in res.get("docs", []))))
        report(cfg, res, eval_only)
        end_run(cfg, rid, ok, {"recall": ev["recall"], **({"error": res["consistency"]["error"]} if not eval_only else {})})
        out(f"ksxkg sync: {'완료' if ok else '완료 기준 미충족'}")
        return ok
    except Exception as e:
        end_run(cfg, rid, False, {"error": str(e)[:500]})
        raise


def search_cli(cfg: Config, collection: str, text: str, k: int, flt: dict | None = None, out=print) -> int:
    s = settings(cfg)
    q, emb = Qdrant(s["qdrant"], s["qdrant_key"]), Embedder(s["embed"], int(s["dim"]), int(s["batch"]))
    rr = Reranker(s["rerank"]) if s["rerank"] and s["rerank"]["collections"] else None
    for i, h in enumerate(top_hits(search(q, emb, collection, text, k, flt, rr), k), 1):
        p = h["payload"]
        out(f"{i}. {h['score']:.3f}  {p.get('key')}  {p.get('doc_version', '')} {p.get('status', '')}  "
            f"{(p.get('text') or '').splitlines()[0][:90]}")
    return 0


def report(cfg: Config, res: dict, eval_only: bool):
    s, ev = res["s"], res["eval"]
    md = [f"# S8 속성 그래프·벡터 인덱스 결과 ({cfg.ent}) — ksxkg sync", "",
          f"- 실행: `{res['rid']}` · 속성 그래프 `{s['graph']}` · 임베딩 {s['model']}({s['dim']}차원, 코사인) · "
          f"검색 평가 상위 {ev['k']}" + (f" · 재정렬 {s['rerank'].get('model', '')}(벡터 상위 {s['rerank']['top']} → {', '.join(ev.get('rerank') or [])})" if ev.get("rerank") else " · 재정렬 끔(D-3)")
          + (" · 명사 카드 정답에 S2 확장 명사 포함(D-2)" if ev.get("ext_on") else ""), ""]
    p = os.path.join(cfg.mapping_dir(), "S8_동기화결과.md")
    if eval_only and os.path.exists(p):                 # 평가만 다시 — 앞부분(동기화)은 그대로 두고 평가 절만 바꾼다
        old = open(p, encoding="utf-8").read()
        md = old.split("\n## 검색 평가", 1)[0].rstrip("\n").split("\n")
        md.append("")
    elif not eval_only:
        c, kg, age = res["consistency"], res["kg"], res["age"]
        md += ["## 완료 기준 (표 27)", "", "| 기준 | 결과 | 판정 |", "|---|---|---|",
               f"| RDF와 속성 그래프의 노드·관계 수 정합 오차 0 | RDF 노드 {c['rdf_v']:,} · 관계 {c['rdf_e']:,} / "
               f"AGE 노드 {c['age_v']:,} · 관계 {c['age_e']:,} · 오차 **{c['error']}** (다중 클래스 {c['multi']} · 끊긴 관계 {c['broken']}) | "
               f"{'충족' if c['ok'] else '미충족'} |",
               f"| 전수 비교(노드·관계·속성 값 하나하나, 라벨 변경·삭제 포함) | 노드 {res['full']['nodes']:,}(값 {res['full']['node_values']:,}) · "
               f"관계 {res['full']['edges']:,}(값 {res['full']['edge_values']:,}) · 차이 **{res['full']['error']}** | {'충족' if res['full']['ok'] else '미충족'} |",
               f"| 조회 계정({res['reader']['user']}) 탐색·쓰기 거부 | 탐색 {sum(c['ok'] for c in res['reader']['checks'])}/{len(res['reader']['checks'])} · "
               f"쓰기 거부 {sum(w['denied'] for w in res['reader']['writes'])}/{len(res['reader']['writes'])} | {'충족' if res['reader']['ok'] else '미충족'} |",
               f"| 검색 평가셋 recall@{ev['k']} ≥ {ev['threshold']} (명사 카드는 적중@{ev['k']}, D-1) | " +
               ", ".join(f"{k} {a['score']:.3f}({'적중' if a['metric'] == 'hit' else 'recall'})" for k, a in sorted(ev['by'].items())) + " | "
               f"{'충족' if ev['ok'] else '미충족'} |",
               f"| 현행 문서 필터(부록 A) | documents 검색 기본 필터 status=현행 · 폐기 판 노출 "
               f"{sum(1 for r in ev['cases'] if r['must_not'])}건 | "
               f"{'충족' if not any(r['must_not'] for r in ev['cases']) else '미충족'} |", "",
               "## 속성 그래프 (Apache AGE)", "",
               f"내보내기: 데이터 그래프(S5)·추론 그래프(S7) 트리플 {kg['triples']:,} → 노드 {kg['nodes']:,} · 관계 {kg['edges']:,}. "
               f"대상 없는 참조 {kg['dangling']}(노드 속성으로 둠) · 빈 노드 {kg['bnodes']} · 다중 클래스 {kg['multi']}.", "",
               "| 구분 | 전체 | 추가 | 변경 | 삭제 |", "|---|---:|---:|---:|---:|",
               *[f"| {'노드' if k == 'nodes' else '관계'} | {age[k]['total']:,} | {age[k]['added']:,} | {age[k]['updated']:,} | {age[k]['removed']:,} |"
                 for k in ("nodes", "edges")], "",
               f"반영 {age['seconds']}초(차이만 — pgsync.node·pgsync.edge에 IRI ↔ AGE id).", "",
               "### 라벨별 정합 (RDF = SPARQL 집계, AGE = 라벨 테이블 행 수)", "",
               "| 구분 | 라벨 | RDF | AGE | 차이 |", "|---|---|---:|---:|---:|"]
        md += [f"| {r['kind']} | {r['label']} | {r['rdf']:,} | {r['age']:,} | {r['age'] - r['rdf']} |" for r in c["rows"]]
        f = res["full"]
        md += ["", "### 전수 비교 (지식 그래프에서 만든 기대값 ↔ 속성 그래프 실제값)", "",
               "| 항목 | 노드 | 관계 |", "|---|---:|---:|",
               f"| 대상 | {f['nodes']:,} | {f['edges']:,} |", f"| 비교한 속성 값 | {f['node_values']:,} | {f['edge_values']:,} |",
               f"| 누락(RDF에만) | {f['miss_nodes']} | {f['miss_edges']} |", f"| 초과(AGE에만) | {f['extra_nodes']} | {f['extra_edges']} |",
               f"| 라벨 다름 | {f['label_diff']} | — |", f"| 속성 값 다름 | {f['prop_diff']} | {f['edge_prop_diff']} |",
               f"| 중복·끊긴 관계 | {f['dup']} | {f['orphan']} |", "",
               "| 속성 값 유형 | 비교 값 | 다름 |", "|---|---:|---:|"]
        md += [f"| {k} | {v['values']:,} | {v['diff']} |" for k, v in sorted(f["types"].items())]
        md += [f"", f"차이 예시: " + ("; ".join(f"{k} {v}" for k, v in f["samples"].items() if v) or "없음")]
        md += ["", "### 탐색 확인 (cypher, 서비스 계정 세션)", "", "| ID | 내용 | 기대 | 결과 | 판정 |", "|---|---|---|---|---|"]
        md += [f"| {g['id']} | {g['desc']} | {', '.join(g['expected'])} | {', '.join(g['got']) or g['error'][:80]} | {'✔' if g['ok'] else '✘'} |"
               for g in res["checks"]]
        rd = res["reader"]
        md += ["", f"### 조회 계정({rd['user']}) — S9 MCP 도구가 쓸 계정", "", "| 확인 | 결과 | 판정 |", "|---|---|---|"]
        md += [f"| 탐색 {c['id']} | {', '.join(c['got']) or c['error'][:80]} | {'✔' if c['ok'] else '✘'} |" for c in rd["checks"]]
        md += [f"| 쓰기 {w['id']} | {w['error'] or '실행됨'} | {'✔ 거부' if w['denied'] else '✘ 허용'} |" for w in rd["writes"]]
        if res.get("terms") is not None:
            tt = res["terms"]
            md += ["", "### 명사 카드 업무 용어 (D-1 — 승인된 산출물에서 모음, 평가 질문은 쓰지 않음)", "",
                   f"용어가 붙은 명사 {len(tt)}개 · 용어 {sum(len(v) for v in tt.values())}개. 출처: 원천 업무 의미·컬럼 주석(S1), "
                   "참조 개체 이름·코드 레이블(지식 그래프), KPI명(S1 KPI정의서), 현업(계획 sync.terms).", "",
                   "| 명사 | 용어 수 | 용어(출처) |", "|---|---:|---|"]
            md += [f"| {n} | {len(v)} | " + ", ".join(f"{t}({src})" for t, src in list(v.items())[:25]) + (" …" if len(v) > 25 else "") + " |"
                   for n, v in sorted(tt.items())]
        if res.get("vectors"):
            md += ["", "## 벡터 인덱스 (Qdrant)", "", "| 컬렉션 | 점 | 추가 | 변경 | 삭제 | 소요(초) |", "|---|---:|---:|---:|---:|---:|"]
            md += [f"| {k} | {v['total']:,} | {v['added']:,} | {v['updated']:,} | {v['removed']:,} | {v['seconds']} |"
                   for k, v in res["vectors"].items()]
            md += ["", "### 문서 (documents — 청크 500~800자)", "", "| 문서 | 판 | 상태 | 제목 | 청크 | 길이 | 연결 IRI | 못 찾은 연결 |",
                   "|---|---|---|---|---:|---|---:|---|"]
            md += [f"| {d['doc_id']} | {d['version']} | {d['status']} | {d['title']} | {d['chunks']} | "
                   f"{min(d['sizes']) if d['sizes'] else 0}~{max(d['sizes']) if d['sizes'] else 0} | {d['iris']} | {', '.join(d['missing']) or '—'} |"
                   for d in res.get("docs", [])]
        md.append("")
    md += [f"## 검색 평가 (상위 {ev['k']})", "",
           f"사례마다 recall@{ev['k']} = 상위 {ev['k']}개(문서는 문서 단위)에 든 정답 수 ÷ min(정답 수, {ev['k']}), "
           f"적중@{ev['k']} = 정답이 하나라도 들었나. 판정은 컬렉션마다 계획의 지표로 ≥ {ev['threshold']} → **{'충족' if ev['ok'] else '미충족'}**", "",
           f"명사 카드의 판정 지표는 적중(검색은 질의의 출발점 명사를 찾는다). 질의에 필요한 명사 전부를 찾는 recall은 S9 GraphRAG 평가 기준선으로 넘긴다(S8 D-1).", "",
           "| 컬렉션 | 사례 | recall@k | 적중@k | 판정 지표 | 판정 값 |", "|---|---:|---:|---:|---|---:|"]
    md += [f"| {k} | {a['cases']} | {a['recall']:.3f} | {a['hit']:.3f} | {'적중' if a['metric'] == 'hit' else 'recall'} | {a['score']:.3f} |"
           for k, a in sorted(ev["by"].items())]
    miss = [r for r in ev["cases"] if r["score"] < 1.0]
    md += ["", f"### 판정 지표에서 놓친 사례 ({len(miss)}건)", "", "| 사례 | 컬렉션 | 질의 | 정답 | 상위 결과 | recall |", "|---|---|---|---|---|---:|"]
    md += [f"| {r['id']} | {r['collection']} | {r['query']} | {', '.join(r['expected'])}{' (+확장 ' + ', '.join(r['ext']) + ')' if r.get('ext') else ''} | "
           f"{', '.join(r['got'])} | {r['recall']:.2f} |" for r in miss]
    if ev.get("alt_hit") is not None and not ev.get("ext_on"):
        md += ["", f"참고: S1 KPI정의서의 확장 명사(S2)를 해당 질의의 정답에 더하면 명사 카드 적중@{ev['k']} = **{ev['alt_hit']:.3f}**."]
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md) + "\n")
