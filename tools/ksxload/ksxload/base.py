"""설정·DB 접속(psql)·DDL 해석.

DB 접속은 psql 클라이언트만 쓴다(psycopg 불필요). Docker s3-tools 이미지·CI·로컬 모두 psql이 있다.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
from dataclasses import dataclass, field

import yaml


def env(v):
    """'${VAR:-기본값}' 치환."""
    if not isinstance(v, str):
        return v
    return re.sub(r"\$\{(\w+)(?::-([^}]*))?\}", lambda m: os.environ.get(m.group(1), m.group(2) or ""), v)


def rel(repo, p):
    return p if os.path.isabs(p) else os.path.join(repo, p)


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

    def label(self):
        return f"{self.user}@{self.host or 'local'}:{self.port}/{self.dbname}"


class DbError(RuntimeError):
    pass


def psql(dsn: Dsn, sql: str | None = None, file: str | None = None, quiet=True) -> str:
    cmd = ["psql", *dsn.args(), "-q" if quiet else "-e"]
    if file:
        cmd += ["-f", file]
    else:
        cmd += ["-c", sql]
    p = subprocess.run(cmd, capture_output=True, text=True, env=dsn.environ())
    if p.returncode != 0:
        raise DbError((p.stderr or p.stdout).strip()[-2000:])
    return p.stdout


def rows(dsn: Dsn, sql: str) -> list[list]:
    """SELECT 결과를 JSON 행 목록으로(값 타입 보존)."""
    q = f"select coalesce(json_agg(row_to_json(__r)), '[]') from ({sql}) __r"
    out = psql(dsn, None) if False else subprocess.run(
        ["psql", *dsn.args(), "-A", "-t", "-c", q], capture_output=True, text=True, env=dsn.environ())
    if out.returncode != 0:
        raise DbError((out.stderr or out.stdout).strip()[-2000:])
    return json.loads(out.stdout.strip() or "[]")


def scalar(dsn: Dsn, sql: str):
    r = rows(dsn, sql)
    return next(iter(r[0].values())) if r else None


# ====================================================================== 설정
@dataclass
class Config:
    repo: str
    path: str
    raw: dict
    s2: dict
    sources: dict                 # system → (Dsn, schemas)
    owner: Dsn
    loader: Dsn
    admin: Dsn | None = None
    extract: dict = field(default_factory=dict)

    @property
    def ent(self):
        return self.raw["enterprise"]

    @property
    def dbt_dir(self):
        return rel(self.repo, self.raw["dbt"]["project"])

    @property
    def models_dir(self):
        return os.path.join(self.dbt_dir, self.raw["dbt"]["models"])

    @property
    def seeds_dir(self):
        return os.path.join(self.dbt_dir, self.raw["dbt"]["seeds"])

    @property
    def mapping_dir(self):
        return rel(self.repo, self.s2.get("out", os.path.dirname(self.raw["s2_plan"])))


def load_config(path: str, repo: str) -> Config:
    raw = yaml.safe_load(open(rel(repo, path), encoding="utf-8"))
    s2 = yaml.safe_load(open(rel(repo, raw["s2_plan"]), encoding="utf-8"))
    s1 = yaml.safe_load(open(rel(repo, raw["s1_config"]), encoding="utf-8"))
    sources = {}
    for s in s1["sources"]:
        d = {k: env(v) for k, v in s["dsn"].items()}
        sources[s["system"]] = (Dsn(d.get("host", ""), d.get("port", ""), d["dbname"], d["user"], d.get("password", "")),
                                s.get("schemas", []))
    t = raw["target"]
    host, port, db = env(t["host"]), env(t["port"]), env(t["dbname"])
    owner = Dsn(host, port, db, env(t["owner"]["user"]), env(t["owner"].get("password", "")))
    loader = Dsn(host, port, db, env(t["loader"]["user"]), env(t["loader"].get("password", "")))
    admin = Dsn(host, port, db, env(t["admin"]["user"]), env(t["admin"].get("password", ""))) if t.get("admin") else None
    ext = json.load(open(rel(repo, raw["s1_extract"]), encoding="utf-8"))
    return Config(repo, path, raw, s2, sources, owner, loader, admin, ext)


# ====================================================================== DDL 해석
@dataclass
class Col:
    name: str
    type: str          # VARCHAR(50) 등 원문
    notnull: bool
    identity: bool

    @property
    def base(self):
        t = self.type.upper()
        if t.startswith("VARCHAR") or t.startswith("CHAR"):
            return "text"
        if t.startswith("NUMERIC"):
            return "numeric"
        return t.lower()


@dataclass
class Table:
    schema: str
    name: str
    cols: dict
    uk: list
    uk_name: str
    fks: list = field(default_factory=list)      # (이름, [자식 컬럼], 부모 schema.name, [부모 컬럼])

    @property
    def fq(self):
        return f'{self.schema}."{self.name}"'

    @property
    def key(self):
        return f"{self.schema}.{self.name}"


def parse_ddl(paths: list[str]) -> dict[str, Table]:
    tables: dict[str, Table] = {}
    for p in paths:
        txt = open(p, encoding="utf-8").read()
        for m in re.finditer(r'CREATE TABLE (\w+)\."(\w+)" \((.*?)\n\);', txt, re.S):
            sch, name, body = m.groups()
            cols, uk, ukn = {}, [], ""
            for line in body.splitlines():
                line = re.sub(r"\s+--.*$", "", line).strip().rstrip(",")
                cm = re.match(r'"(\w+)" ([A-Z]+(?:\([\d,]+\))?)(.*)', line)
                if cm:
                    cols[cm.group(1)] = Col(cm.group(1), cm.group(2), "NOT NULL" in cm.group(3) or "PRIMARY KEY" in cm.group(3),
                                            "IDENTITY" in cm.group(3))
                um = re.match(r'CONSTRAINT "(\w+)" UNIQUE \((.*)\)', line)
                if um:
                    ukn, uk = um.group(1), re.findall(r'"(\w+)"', um.group(2))
            tables[f"{sch}.{name}"] = Table(sch, name, cols, uk, ukn)
        for m in re.finditer(r'ALTER TABLE (\w+)\."(\w+)" ADD CONSTRAINT "(\w+)" FOREIGN KEY \((.*?)\) REFERENCES (\w+)\."(\w+)" \((.*?)\)', txt):
            sch, name, fkn, cc, psch, pname, pc = m.groups()
            t = tables.get(f"{sch}.{name}")
            if t is not None:
                t.fks.append((fkn, re.findall(r'"(\w+)"', cc), f"{psch}.{pname}", re.findall(r'"(\w+)"', pc)))
    return tables


def topo_order(tables: dict[str, Table], keys: list[str]) -> list[str]:
    """FK 의존 순서(부모 먼저). keys에 없는 부모는 무시."""
    ks = set(keys)
    # 등록자·수정자(→사원) 참조는 거의 모든 테이블에 있어 순환을 만든다 — 순서 계산에서는 뺀다(FK는 지연 검사)
    deps = {k: {p for _, cc, p, _ in tables[k].fks if p in ks and p != k and not {"CreatorID", "ModifierID"} & set(cc)}
            for k in keys}
    out, done = [], set()
    while len(out) < len(keys):
        ready = sorted(k for k in keys if k not in done and deps[k] <= done)
        if not ready:                                  # 순환(예: 사원↔부서) — 남은 의존이 가장 적은 1개만 먼저
            ready = [min((k for k in keys if k not in done), key=lambda k: (len(deps[k] - done), k))]
        for k in ready:
            out.append(k)
            done.add(k)
    return out
