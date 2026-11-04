"""설정·원장(psql)·SPARQL(HTTP) 접속.

원장 접속은 ksxload와 같이 psql 클라이언트만 쓴다. SPARQL은 표준 라이브러리(urllib)만 쓴다.
"""
from __future__ import annotations

import glob
import json
import os
import re
import subprocess
import urllib.parse
import urllib.request
from dataclasses import dataclass

import yaml


def env(v):
    """'${VAR:-기본값}' 치환."""
    if not isinstance(v, str):
        return v
    return re.sub(r"\$\{(\w+)(?::-([^}]*))?\}", lambda m: os.environ.get(m.group(1), m.group(2) or ""), v)


@dataclass
class Dsn:
    host: str
    port: str
    dbname: str
    user: str
    password: str = ""

    def args(self):
        a = ["-X", "-v", "ON_ERROR_STOP=1", "-d", self.dbname, "-U", self.user]
        if self.host:
            a += ["-h", self.host]
        if self.port:
            a += ["-p", str(self.port)]
        return a

    def environ(self):
        e = dict(os.environ)
        if self.password:
            e["PGPASSWORD"] = self.password
        e.setdefault("PGCONNECT_TIMEOUT", "10")
        return e

    def url(self):
        """SQLAlchemy URL(Morph-KGC)."""
        pw = urllib.parse.quote(self.password, safe="")
        return f"postgresql+psycopg2://{self.user}:{pw}@{self.host or 'localhost'}:{self.port or 5432}/{self.dbname}"


class DbError(RuntimeError):
    pass


def psql(dsn: Dsn, sql: str) -> str:
    p = subprocess.run(["psql", *dsn.args(), "-q", "-c", sql], capture_output=True, text=True, env=dsn.environ())
    if p.returncode != 0:
        raise DbError((p.stderr or p.stdout).strip()[-2000:])
    return p.stdout


def rows(dsn: Dsn, sql: str) -> list[dict]:
    q = f"select coalesce(json_agg(row_to_json(__r)), '[]') from ({sql}) __r"
    p = subprocess.run(["psql", *dsn.args(), "-A", "-t", "-c", q], capture_output=True, text=True, env=dsn.environ())
    if p.returncode != 0:
        raise DbError((p.stderr or p.stdout).strip()[-2000:])
    return json.loads(p.stdout.strip() or "[]")


# ---------------------------------------------------------------- SPARQL
class SparqlError(RuntimeError):
    pass


def sparql(endpoint: str, query: str, timeout=300) -> list[dict]:
    """SELECT 결과를 {변수: 값(문자)} 목록으로."""
    data = urllib.parse.urlencode({"query": query}).encode()
    req = urllib.request.Request(endpoint, data=data, method="POST", headers={
        "Accept": "application/sparql-results+json", "Content-Type": "application/x-www-form-urlencoded"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            js = json.load(r)
    except urllib.error.HTTPError as e:
        raise SparqlError(f"{endpoint} {e.code}: {e.read().decode(errors='replace')[:800]}") from e
    except urllib.error.URLError as e:
        raise SparqlError(f"{endpoint} 접속 실패: {e.reason}") from e
    return [{k: v["value"] for k, v in b.items()} for b in js["results"]["bindings"]]


def update(endpoint: str, text: str, timeout=600):
    data = urllib.parse.urlencode({"update": text}).encode()
    req = urllib.request.Request(endpoint, data=data, method="POST",
                                 headers={"Content-Type": "application/x-www-form-urlencoded"})
    try:
        urllib.request.urlopen(req, timeout=timeout).read()
    except urllib.error.HTTPError as e:
        raise SparqlError(f"{endpoint} {e.code}: {e.read().decode(errors='replace')[:800]}") from e


def put_graph(gsp: str, graph: str, path: str, ctype: str, timeout=1800):
    """Graph Store Protocol PUT — 그래프 단위 교체(다시 실행해도 결과가 같다, 구현안내서 8.5)."""
    size = os.path.getsize(path)
    with open(path, "rb") as f:
        req = urllib.request.Request(f"{gsp}?graph={urllib.parse.quote(graph, safe='')}", data=f, method="PUT",
                                     headers={"Content-Type": ctype, "Content-Length": str(size)})
        try:
            urllib.request.urlopen(req, timeout=timeout).read()
        except urllib.error.HTTPError as e:
            raise SparqlError(f"PUT {graph} {e.code}: {e.read().decode(errors='replace')[:800]}") from e


# ---------------------------------------------------------------- 설정
@dataclass
class Config:
    repo: str
    raw: dict
    ent: str
    data_ns: str
    ns: str
    onto: str
    reader: Dsn
    owner: Dsn
    fuseki: str
    ontop: str
    out: str

    @property
    def query(self):
        return self.fuseki.rstrip("/") + "/query"

    @property
    def update(self):
        return self.fuseki.rstrip("/") + "/update"

    @property
    def gsp(self):
        return self.fuseki.rstrip("/") + "/data"

    def graph(self, key: str) -> str:
        return f"{self.data_ns}graph/{key}"

    @property
    def data_graph_prefix(self):
        return self.graph(self.ent)

    def rml_files(self):
        return sorted(glob.glob(os.path.join(self.onto, "mappings", "rml", "*.rml.ttl")))

    def mapping_dir(self):
        return os.path.join(self.repo, "mapping", self.ent.lower())


def load_config(path: str, repo: str) -> Config:
    p = path if os.path.isabs(path) else os.path.join(repo, path)
    raw = yaml.safe_load(open(p, encoding="utf-8"))
    gen = yaml.safe_load(open(os.path.join(repo, raw.get("ksxgen", "ksxgen.yaml")), encoding="utf-8"))
    t = raw["ledger"]
    host, port, db = env(t["host"]), env(t["port"]), env(t["dbname"])
    rd = Dsn(host, port, db, env(t["reader"]["user"]), env(t["reader"].get("password", "")))
    ow = Dsn(host, port, db, env(t["owner"]["user"]), env(t["owner"].get("password", "")))
    onto = os.path.join(repo, raw.get("ontologies", "ontologies"))
    out = os.path.join(repo, env(raw.get("out", "out/kg")))
    return Config(repo, raw, raw["enterprise"], gen["data_ns"], gen["ns"], onto, rd, ow,
                  env(raw["fuseki"]), env(raw["ontop"]), out)
