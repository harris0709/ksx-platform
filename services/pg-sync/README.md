# pg-sync — 지식 그래프 → 속성 그래프·벡터 동기화 (S8, 구현안내서 11장)

지식 그래프(Fuseki: S5 물질화 그래프 + S7 추론 그래프)가 원본이고, Apache AGE 속성 그래프(`ksx_graph`)와 Qdrant 컬렉션은 탐색·검색용 파생본입니다.

| 구분 | 지금(S8) | 운영(다음 단계) |
|---|---|---|
| 실행 | `ksxkg sync` 배치 — S5 물질화·S7 추론 뒤 야간 실행 | Kafka로 물질화·추론 그래프 변경 이벤트를 받아 같은 반영 로직을 실행 |
| 반영 | 내보낸 노드·관계를 `pgsync.node`·`pgsync.edge`(IRI ↔ AGE id)와 비교해 **차이만** 추가·변경·삭제 | 같음(변경 그래프만) |
| 정합 | RDF(SPARQL 집계)와 AGE 라벨 테이블의 노드·관계 수, 라벨마다 오차 0 · 끊긴 관계 0 | 야간 검사 |
| 벡터 | 문장 해시가 바뀐 점만 다시 임베딩(TEI bge-m3) → Qdrant upsert, 없어진 점 삭제 | 같음 |

```bash
# 관리자(postgres)로 한 번(라벨이 바뀌면 다시) — 라벨·인덱스·서비스 계정 권한·접속 시 AGE 로드
docker compose exec -T postgres psql -U postgres -d ksx -v ON_ERROR_STOP=1 < ../../ontologies/graph/age_schema.sql
docker compose --profile ai up -d embed
export S5_PLAN=mapping/impix/s8_plan.yaml
docker compose --profile tools run --rm -e S5_PLAN s5-tools sync
```

- 쓰기 계정은 `ksx_owner`(라벨 테이블에 SQL로 직접 쓴다 — cypher 해석기를 쓰지 않으므로 `LOAD 'age'`가 필요 없다).
- 읽기 계정(`ksx_reader`, MCP 도구)은 관리자가 아니어서 `LOAD 'age'`를 쓸 수 없으므로(`$libdir/plugins` 밖), `age_schema.sql`이 계정에 `session_preload_libraries = 'age'`를 걸어 접속할 때 로드되게 한다. 세션은 `SET search_path = ag_catalog, "$user", public;`만 하면 cypher를 쓸 수 있다.
- 노드: 키 `iri`, 라벨 = 클래스, 속성 = 리터럴·코드값·`graph`·`ent`/`site`/`plant`(추론 노드는 `ruleId`)·S6 위반 표식 `violates`. 관계: 라벨 = 객체 관계(`ref*`·`hasLine`·`lineOf`·추론 `inf:` 관계), 속성 `graph`·`inferred`·`ruleId`.
