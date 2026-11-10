# ksxkg — S5 지식 그래프(A-Box) 구성 · S6 검증(SHACL)

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
```

| 모듈 | 내용 |
|---|---|
| `materialize.py` | Morph-KGC 실행(물질화 필터 적용 사본, 컨테이너 안 임시 폴더에 출력) → 그래프별 N-Triples → 반영(빈 그래프 POST, 적재본과 같으면 차이만, 그 밖·`--full`은 PUT) → 어휘 그래프 교체 → 감사 기록 |
| `check.py` | 가상 = SQL(Ontop 클래스별 개체 수, 사업장별 로트 수), 물질화 = 기대치((그래프, 클래스)별 개체 수, 그래프별 트리플 수), 그래프 분리 6건 |
| `validate.py` | (S6) 적합성(`ontologies/shapes`) + 품질 셰이프(`ontologies/quality`, 계획 매개변수 `{{이름}}` 채움)를 Fuseki SHACL 서비스로 합집합 검증 → 대상 그래프·차원(구조·값·관계·의미) 분류 → `audit.shacl_result` → 위반(Violation)만 `ksxq:violates` 표식(`graph/quality`) → 업무 규칙으로 추론 제외 확인. `--seed`: 실제 개체 복제 위반·정상 대조군을 시험 그래프에 넣고 검출·추론 제외 확인 후 삭제 |
| `mappings.py` | R2RML 읽기, 물질화 필터(명사의 원장 행 조건을 본 매핑·확장 속성 매핑에 함께) |
| `base.py` | 설정(`mapping/<기업>/s5_plan.yaml` + `ksxgen.yaml`), psql, SPARQL·Graph Store 프로토콜 |

설정: `mapping/<기업>/s5_plan.yaml`(양식 `mapping/_template/s5_plan.yaml`), S6은 `mapping/<기업>/s6_plan.yaml`(`base:`로 S5 설정을 물려받음 — 품질 셰이프 목록, 추론 제외 확인 규칙, 매개변수, 의도적 위반 seeds). 그래프 배정(기업 공통 기준정보)은 S4 생성 단계의 `ksxgen.yaml` `common_graph_nouns`.
시험: `python tests/coverage/test_ksxkg.py`. 실행 순서와 승인 절차는 `docs/S5_지식그래프구성_실행가이드.docx`, S6은 `docs/S6_검증_실행가이드.docx`(구현안내서 v1.6 9장). S6 양식: `mapping/_template/s6_plan.yaml`, `quality_shapes_양식.ttl`, `S6_승인기록_양식.md`, `S6_판단사항_결정카드_양식.md`.
