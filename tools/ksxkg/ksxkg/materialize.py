"""물질화(구현안내서 8.5): 원장 → Morph-KGC(R2RML) → 사업장 Named Graph → Fuseki.

  1. Morph-KGC로 물질화 매핑 전체를 실행해 N-Quads 한 파일을 만든다(그래프는 매핑의 rr:graphMap이 정함)
  2. 그래프별 N-Triples로 나누고 중복을 없앤다
  3. 그래프별 반영 — 다시 실행해도 결과가 같다. 이번에 만들지 않은 기업 데이터 그래프는 지운다
       · 비어 있는 그래프: 추가(POST)
       · 지난번 적재본(out/kg/loaded/)과 Fuseki 트리플 수가 같음: 차이만 반영(DELETE DATA·POST) — 대용량 삭제를 피함
       · 그 밖(적재본 없음·수 불일치·--full): 그래프 단위 교체(PUT)
  4. T-Box·확장 T-Box·셰이프·코드 그래프도 같은 방식으로 교체(구현안내서 8.2 표 21)
  5. 그래프별 트리플 수를 audit.kg_load에 남긴다
"""
from __future__ import annotations

import glob
import json
import os
import re
import subprocess
import sys
import shutil
import time
import uuid

from .base import Config, post_graph, put_graph, psql, sparql, update

AUDIT_SQL = """
create table if not exists audit.kg_load (
  log_id     bigint generated always as identity primary key,
  run_id     uuid        not null references audit.run(run_id),
  graph      text        not null,
  kind       text        not null check (kind in ('data','vocab','check')),
  triples    bigint,
  expected   bigint,
  status     text        not null check (status in ('ok','warn','fail')),
  detail     jsonb       not null default '{}'::jsonb,
  logged_at  timestamptz not null default now()
);
comment on table audit.kg_load is 'S5 지식 그래프 물질화·검사 기록(구현안내서 8.5)';
grant select on audit.kg_load to ksx_reader;
"""

QUAD_RE = re.compile(r" <([^>]*)> \.\s*$")


def start_run(cfg: Config, job: str) -> str:
    rid = str(uuid.uuid4())
    psql(cfg.owner, AUDIT_SQL)
    psql(cfg.owner, f"insert into audit.run(run_id, stage, job, actor, enterprise_id) values "
                    f"('{rid}', 'S5', '{job}', current_user, '{cfg.ent}')")
    return rid


def end_run(cfg: Config, rid: str, ok: bool, detail: dict):
    js = json.dumps(detail, ensure_ascii=False).replace("'", "''")
    psql(cfg.owner, f"update audit.run set status = '{'succeeded' if ok else 'failed'}', ended_at = now(), "
                    f"detail = '{js}'::jsonb where run_id = '{rid}'")


def log(cfg: Config, rid, graph, kind, triples, expected, status, detail=None):
    js = json.dumps(detail or {}, ensure_ascii=False).replace("'", "''")
    n = lambda v: "null" if v is None else str(int(v))  # noqa: E731
    psql(cfg.owner, f"insert into audit.kg_load(run_id, graph, kind, triples, expected, status, detail) values "
                    f"('{rid}', '{graph}', '{kind}', {n(triples)}, {n(expected)}, '{status}', '{js}'::jsonb)")


def morph_kgc(cfg: Config, nq: str, out=print):
    """Morph-KGC는 여러 프로세스가 한 출력 파일에 이어 쓴다. 윈도우 Docker의 저장소 마운트(/repo)에서는 이 이어 쓰기가
    원자적이지 않아 줄이 섞이므로(실행마다 다른 위치에서 줄이 끊김), 컨테이너 안 임시 폴더에 쓴 뒤 옮긴다."""
    import tempfile
    tmp = tempfile.mkdtemp(prefix="ksxkg-")
    final, nq = nq, os.path.join(tmp, os.path.basename(nq))
    ini = os.path.join(tmp, "morph_kgc.ini")
    maps = []                                       # 물질화 필터(D-3)를 적용한 매핑 사본 — S4 생성물은 그대로
    for i, (f, text) in enumerate(sorted(cfg.rml_texts().items())):
        maps.append(os.path.join(tmp, f"{i:03d}_" + os.path.basename(f)))
        with open(maps[-1], "w", encoding="utf-8") as w:
            w.write(text)
    with open(ini, "w", encoding="utf-8") as f:
        f.write("[CONFIGURATION]\n"
                f"output_file={nq}\n"
                "output_format=N-QUADS\n"
                # 빈 문자열·NULL 표기는 값 없음으로(정수·일시 리터럴에 'None'이 생기지 않게)
                "na_values=,None,NULL,null,NaN,nan,<NA>,NaT\n"
                "[ksx]\n"
                f"mappings={','.join(maps)}\n"
                f"db_url={cfg.reader.url()}\n")
    out(f"  Morph-KGC: 물질화 매핑 {len(maps)}개 실행 …"
        + (f" (물질화 필터: {', '.join(f'{k} — {v}' for k, v in cfg.filters.items())})" if cfg.filters else ""))
    p = subprocess.run([sys.executable, "-m", "morph_kgc", ini], capture_output=True, text=True)
    os.remove(ini)                                     # 접속 비밀번호가 든 파일을 남기지 않는다
    if p.returncode != 0:
        shutil.rmtree(tmp, ignore_errors=True)
        raise RuntimeError("Morph-KGC 실패:\n" + (p.stderr or p.stdout)[-3000:])
    shutil.move(nq, final)
    shutil.rmtree(tmp, ignore_errors=True)


def split(nq: str, outdir: str, out=print) -> dict[str, tuple[str, int]]:
    """N-Quads → 그래프별 N-Triples(중복 제거). {그래프 IRI: (파일, 트리플 수)}

    줄은 '\n'으로만 나눈다. 원장 문자값에 캐리지 리턴(\r)이 그대로 들어 있으면(윈도우에서 만든 원천 등)
    Morph-KGC가 이스케이프하지 않은 채 쓰므로, N-Triples 규칙대로 '\\r'로 바꾼다."""
    handles, files, fixed = {}, {}, []
    with open(nq, encoding="utf-8", newline="\n") as f:
        for line in f:
            if not line.strip():
                continue
            if "\r" in line:
                line = line.rstrip("\n").rstrip("\r").replace("\r", "\\r") + "\n"
                fixed.append(line.split(" ", 1)[0])
            m = QUAD_RE.search(line)
            if not m:
                raise RuntimeError(f"그래프 없는 트리플(매핑의 rr:graphMap 확인): {line[:200]}")
            g = m.group(1)
            if g not in handles:
                key = re.sub(r"[^A-Za-z0-9]+", "_", g.split("/graph/", 1)[-1]).strip("_")
                files[g] = os.path.join(outdir, f"data_{key}.nt")
                handles[g] = open(files[g] + ".tmp", "w", encoding="utf-8")
            handles[g].write(line[:m.start()] + " .\n")
    if fixed:
        out(f"  주의: 문자값에 캐리지 리턴(\\r)이 든 트리플 {len(fixed):,}개를 이스케이프함 — 예: {', '.join(sorted(set(fixed))[:3])}")
    res = {}
    for g, h in handles.items():
        h.close()
        subprocess.run(["sort", "-u", "-o", files[g], files[g] + ".tmp"], check=True,
                       env={**os.environ, "LC_ALL": "C"})
        os.remove(files[g] + ".tmp")
        res[g] = (files[g], _lines(files[g]))
    return res


def vocab_graphs(cfg: Config) -> dict[str, list[str]]:
    o = cfg.onto
    ext = sorted(glob.glob(os.path.join(o, "tbox", "*_ext.ttl")))
    g = {cfg.graph("tbox/ksx9101"): [os.path.join(o, "tbox", "ksx9101_core.ttl")]}
    for e in ext:                                   # tbox/impix_ext.ttl → graph/tbox/ext/IMPIX
        name = os.path.basename(e)[:-len("_ext.ttl")]
        g[cfg.graph(f"tbox/ext/{cfg.ent if name == cfg.ent.lower() else name.upper()}")] = [e]
    g[cfg.graph("shapes")] = sorted(glob.glob(os.path.join(o, "shapes", "*.ttl")))
    g[cfg.graph("codelist")] = sorted(glob.glob(os.path.join(o, "vocab", "*.ttl")))
    return g


def count(cfg: Config, g: str) -> int:
    return int(sparql(cfg.query, f"SELECT (COUNT(*) AS ?n) WHERE {{ GRAPH <{g}> {{ ?s ?p ?o }} }}")[0]["n"])


def _lines(path):
    return sum(1 for _ in open(path, encoding="utf-8", newline="\n"))


def _comm(flag: str, a: str, b: str, dst: str) -> int:
    with open(dst, "w", encoding="utf-8") as f:
        subprocess.run(["comm", flag, a, b], stdout=f, check=True, env={**os.environ, "LC_ALL": "C"})
    return _lines(dst)


def delete_data(cfg: Config, g: str, path: str, batch=5000):
    """N-Triples 파일의 트리플을 그래프에서 지운다(DELETE DATA, 묶음 단위)."""
    buf = []

    def flush():
        if buf:
            update(cfg.update, f"DELETE DATA {{ GRAPH <{g}> {{\n" + "".join(buf) + "} }")   # 뒤쪽은 f-문자열이 아님
            buf.clear()
    for line in open(path, encoding="utf-8", newline="\n"):
        buf.append(line)
        if len(buf) >= batch:
            flush()
    flush()


def load_graph(cfg: Config, g: str, path: str, n: int, full=False) -> tuple[str, dict]:
    """그래프 하나를 새 파일(path, 정렬·중복 제거된 N-Triples)과 같게 만든다. (방식, 세부)"""
    key = os.path.basename(path)
    prev = os.path.join(cfg.out, "loaded", key)
    os.makedirs(os.path.dirname(prev), exist_ok=True)
    cur = count(cfg, g)
    if cur == 0 and not full:
        post_graph(cfg.gsp, g, path, "application/n-triples")
        mode, d = "추가", {}
    elif not full and os.path.exists(prev) and _lines(prev) == cur:
        add = _comm("-13", prev, path, path + ".add")
        rem = _comm("-23", prev, path, path + ".del")
        if rem:
            delete_data(cfg, g, path + ".del")
        if add:
            post_graph(cfg.gsp, g, path + ".add", "application/n-triples")
        os.remove(path + ".add")
        os.remove(path + ".del")
        mode, d = ("변경 없음" if not add and not rem else "차이 반영"), {"added": add, "deleted": rem}
    else:
        put_graph(cfg.gsp, g, path, "application/n-triples")
        mode, d = "전체 교체", {"before": cur}
    after = count(cfg, g)
    if after != n:
        raise RuntimeError(f"{g}: 적재 후 트리플 {after:,} ≠ 물질화 {n:,} ({mode}) — --full로 다시 실행")
    shutil.copyfile(path, prev)
    return mode, d


def existing_graphs(cfg: Config) -> list[str]:
    r = sparql(cfg.query, "SELECT DISTINCT ?g WHERE { GRAPH ?g { ?s ?p ?o } }")
    return sorted(x["g"] for x in r)


def materialize(cfg: Config, out=print, skip_morph=False, full=False) -> bool:
    os.makedirs(cfg.out, exist_ok=True)
    rid = start_run(cfg, "kg_materialize")
    out(f"S5 물질화 run_id={rid}")
    ok, detail = True, {}
    try:
        nq = os.path.join(cfg.out, "ksx.nq")
        if not skip_morph or not os.path.exists(nq):
            morph_kgc(cfg, nq, out)
        parts = split(nq, cfg.out, out)
        total = sum(n for _, n in parts.values())
        out(f"  트리플 {total:,} → 데이터 그래프 {len(parts)}개")
        # 데이터 그래프
        for g, (path, n) in sorted(parts.items()):
            t0 = time.time()
            mode, d = load_graph(cfg, g, path, n, full)
            d.update(mode=mode, seconds=round(time.time() - t0, 1))
            log(cfg, rid, g, "data", n, n, "ok", d)
            extra = f" +{d['added']:,} −{d['deleted']:,}" if "added" in d else ""
            out(f"  {g}  {n:,} — {mode}{extra} ({d['seconds']}초)")
        # 이번 물질화에 없는 기업 데이터 그래프(이전 실행의 사업장 등)는 지운다 — 추론·BOD 그래프는 건드리지 않음
        pre = cfg.data_graph_prefix
        stale = [g for g in existing_graphs(cfg) if (g == pre or g.startswith(pre + "/")) and g not in parts]
        for g in stale:
            update(cfg.update, f"DROP SILENT GRAPH <{g}>")
            key = os.path.join(cfg.out, "loaded", "data_" + re.sub(r"[^A-Za-z0-9]+", "_", g.split("/graph/", 1)[-1]).strip("_") + ".nt")
            if os.path.exists(key):
                os.remove(key)
            log(cfg, rid, g, "data", 0, None, "warn", {"dropped": True})
            out(f"  DROP {g} (이번 물질화에 없음)")
        # 어휘 그래프
        for g, files in vocab_graphs(cfg).items():
            path = os.path.join(cfg.out, "vocab_" + re.sub(r"[^A-Za-z0-9]+", "_", g.split("/graph/", 1)[-1]) + ".ttl")
            with open(path, "w", encoding="utf-8") as f:
                for x in files:
                    f.write(open(x, encoding="utf-8").read() + "\n")
            put_graph(cfg.gsp, g, path, "text/turtle")      # 어휘 그래프는 작다 — 늘 교체
            n = count(cfg, g)
            log(cfg, rid, g, "vocab", n, None, "ok", {"files": [os.path.relpath(x, cfg.repo) for x in files]})
            out(f"  {g}  {n:,} — 교체 ({', '.join(os.path.basename(x) for x in files)})")
        detail = {"triples": total, "graphs": len(parts), "dropped": stale}
    except Exception as e:  # noqa: BLE001 — 실패도 감사 기록에 남긴다
        ok, detail = False, {"error": str(e)[:2000]}
        out("실패: " + str(e))
    end_run(cfg, rid, ok, detail)
    out("ksxkg materialize: " + ("완료" if ok else "실패"))
    return ok
