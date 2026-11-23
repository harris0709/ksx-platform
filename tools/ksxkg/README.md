# ksxkg — S5 지식 그래프(A-Box) 구성 · S6 검증(SHACL) · S7 규칙 추론 · S8 속성 그래프·벡터 인덱스

구현안내서 8장·9장. 표준 원장(S3)을 S4 생성물로 가상 그래프(Ontop)와 물질화 그래프(Fuseki Named Graph)로 만들고 완료 기준(표 19)을 검사한다(S5). 물질화 그래프를 적합성·품질 셰이프로 검증하고 위반을 추론에서 제외한다(S6).

```bash
# infra/docker-compose 폴더에서(이미지: tools/ksxkg/Dockerfile — Morph-KGC·psql 포함, 저장소를 /repo로 연결)
docker compose --profile tools run --rm s5-tools materialize   # 원장 → Morph-KGC → 그래프별 반영 → Fuseki, audit.kg_load
docker compose --profile tools run --rm s5-tools check         # 검사 10건 → mapping/<기업>/S5_검증결과.md
docker compose --profile tools run --rm s5-tools query --endpoint ontop "SPARQL"   # 질의 한 건(ontop|fuseki)

# S6 — 계획 파일을 지정해 실행
export S5_PLAN=mapping/impix/s6_plan.yaml
docker compose --profile tools run --rm -e S5_PLAN s5-tools validate --seed   # 의도적 위반 시험 → S6_의도적위반시험.md
docker compose --profile tools run --rm -e S5_PLAN s5-tools validate          # 실데이터 검증 → S6_검증결과.md, audit.shacl_result, graph/quality
unset S5_PLAN

# S7
export S5_PLAN=mapping/impix/s7_plan.yaml
docker compose --profile tools run --rm -e S5_PLAN s5-tools infer          # 규칙 실행 + 정확도 평가 → S7_추론결과.md, audit.rule_run·rule_eval
docker compose --profile tools run --rm -e S5_PLAN s5-tools infer --eval   # 평가만
unset S5_PLAN

# S8 — 관리자로 속성 그래프 스키마 적용(한 번, 라벨이 바뀌면 다시) + 임베딩 서버 기동
docker compose exec -T postgres psql -U postgres -d ksx -v ON_ERROR_STOP=1 < ../../ontologies/graph/age_schema.sql
docker compose --profile ai up -d embed
export S5_PLAN=mapping/impix/s8_plan.yaml
docker compose --profile tools run --rm -e S5_PLAN s5-tools sync          # AGE 차이 반영·정합·탐색 확인·Qdrant 4종·검색 평가 → S8_동기화결과.md
docker compose --profile tools run --rm -e S5_PLAN s5-tools sync --eval   # 검색 평가만
docker compose --profile tools run --rm -e S5_PLAN s5-tools search --collection documents "금형온도 상한 초과 조치"
unset S5_PLAN
```

| 모듈 | 내용 |
|---|---|
| `materialize.py` | Morph-KGC 실행(물질화 필터 적용 사본, 컨테이너 안 임시 폴더에 출력) → 그래프별 N-Triples → 반영(빈 그래프 POST, 적재본과 같으면 차이만, 그 밖·`--full`은 PUT) → 어휘 그래프 교체 → 감사 기록 |
| `check.py` | 가상 = SQL(Ontop 클래스별 개체 수, 사업장별 로트 수), 물질화 = 기대치((그래프, 클래스)별 개체 수, 그래프별 트리플 수), 그래프 분리 6건 |
| `validate.py` | (S6) 적합성(`ontologies/shapes`) + 품질 셰이프(`ontologies/quality`, 계획 매개변수 `{{이름}}` 채움)를 Fuseki SHACL 서비스로 합집합 검증 → 대상 그래프·차원(구조·값·관계·의미) 분류 → `audit.shacl_result` → 위반(Violation)만 `ksxq:violates` 표식(`graph/quality`) → 업무 규칙으로 추론 제외 확인. `--seed`: 실제 개체 복제 위반·정상 대조군을 시험 그래프에 넣고 검출·추론 제외 확인 후 삭제 |
| `infer.py` | (S7) 이 기업의 추론 그래프 삭제 → 규칙(A-* → R-*, 파일명 순)을 합집합에 CONSTRUCT → `graph/inferred/{기업}/{사업장}/{규칙}` PUT → `audit.rule_run`. 계획의 정답 사례(업무 질의 + 원천 전수)와 비교해 규칙별 정밀도·재현율 → `audit.rule_eval`, 배치 시간 목표 |
| `sync.py` | (S8) Fuseki 데이터·추론 그래프 → 노드(키 IRI)·관계 → AGE `ksx_graph`에 차이만(pgsync.node·edge, IRI ↔ AGE id) → 정합 검사(SPARQL 집계 vs 라벨 테이블) → 탐색 확인(cypher) → Qdrant 4종(바뀐 문장만 TEI 임베딩, 명사 카드 업무 용어) → 검색 평가(컬렉션별 판정 지표) → `audit.graph_sync`·`search_eval` |
| `mappings.py` | R2RML 읽기, 물질화 필터(명사의 원장 행 조건을 본 매핑·확장 속성 매핑에 함께) |
| `base.py` | 설정(`mapping/<기업>/s5_plan.yaml` + `ksxgen.yaml`), psql, SPARQL·Graph Store 프로토콜 |

설정: `mapping/<기업>/s5_plan.yaml`(양식 `mapping/_template/s5_plan.yaml`), S6은 `mapping/<기업>/s6_plan.yaml`(`base:`로 S5 설정을 물려받음 — 품질 셰이프 목록, 추론 제외 확인 규칙, 매개변수, 의도적 위반 seeds). 그래프 배정(기업 공통 기준정보)은 S4 생성 단계의 `ksxgen.yaml` `common_graph_nouns`.
시험: `python tests/coverage/test_ksxkg.py`. 실행 순서와 승인 절차는 `docs/S5_지식그래프구성_실행가이드.docx`, S6은 `docs/S6_검증_실행가이드.docx`(구현안내서 v1.7 9장), S7은 `docs/S7_규칙추론_실행가이드.docx`(10장), S8은 `docs/S8_속성그래프벡터인덱스_실행가이드.docx`(11장)·`services/pg-sync/README.md`. S7 양식: `mapping/_template/s7_plan.yaml`, `rule_양식.rq`, `s7_answers_양식.sql`, `S7_승인기록_양식.md`, `S7_판단사항_결정카드_양식.md`. S6 양식: `mapping/_template/s6_plan.yaml`, `quality_shapes_양식.ttl`, `S6_승인기록_양식.md`, `S6_판단사항_결정카드_양식.md`.
