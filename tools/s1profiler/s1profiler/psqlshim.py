"""psql 명령으로 동작하는 대체 드라이버(psycopg를 설치할 수 없는 환경용).

S1_DB_DRIVER=psql 로 켠다. 각 질의를 row_to_json 으로 감싸 psql 로 실행하고 JSON 으로 받는다.
읽기 전용 분석 질의 전용이며 성능은 psycopg 보다 느리다.
"""
from __future__ import annotations

import json
import os
import subprocess


def _lit(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (list, tuple)):
        return "ARRAY[" + ",".join(_lit(x) for x in v) + "]::text[]"
    return "'" + str(v).replace("'", "''") + "'"


class _Cursor:
    def __init__(self, rows):
        self._rows = rows

    def fetchall(self):
        return self._rows

    def fetchone(self):
        return self._rows[0] if self._rows else None


class Connection:
    def __init__(self, host=None, port=None, dbname=None, user=None, password=None, **_):
        self.args = ["psql", "-X", "-A", "-t", "-q", "-v", "ON_ERROR_STOP=1"]
        for flag, val in (("-h", host), ("-p", port), ("-d", dbname), ("-U", user)):
            if val:
                self.args += [flag, str(val)]
        self.env = dict(os.environ, PGPASSWORD=password or "", PGOPTIONS="-c default_transaction_read_only=on")
        self.execute("SELECT 1")

    def execute(self, query, params=None):
        q = str(query)
        if params:
            q = q % tuple(_lit(p) for p in params)
        body = q.strip().rstrip(";")
        if body.split(None, 1)[0].upper() in ("SET", "ANALYZE"):
            return _Cursor([])
        wrapped = f"SELECT row_to_json(_q) FROM ({body}) _q"
        r = subprocess.run(self.args + ["-c", wrapped], env=self.env, capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError(r.stderr.strip())
        rows = []
        for line in r.stdout.splitlines():
            if line.strip():
                rows.append(tuple(v for _, v in json.loads(line, object_pairs_hook=lambda p: p)))
        return _Cursor(rows)

    def close(self):
        pass


def connect(**dsn):
    dsn.pop("autocommit", None)
    return Connection(**dsn)
