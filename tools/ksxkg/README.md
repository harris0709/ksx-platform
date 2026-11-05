# ksxkg — S5 지식 그래프(A-Box) 구성

구현안내서 8장. 표준 원장(S3)을 S4 생성물로 가상 그래프(Ontop)와 물질화 그래프(Fuseki Named Graph)로 만들고, 완료 기준(표 19)을 검사한다.

```bash
# infra/docker-compose 폴더에서(이미지: tools/ksxkg/Dockerfile — Morph-KGC·psql 포함, 저장소를 /repo로 연결)
docker compose --profile tools run --rm s5-tools materialize   # 원장 → Morph-KGC → 그래프별 반영 → Fuseki, audit.kg_load
docker compose --profile tools run --rm s5-tools check         # 검사 10건 → mapping/<기업>/S5_검증결과.md
docker compose --profile tools run --rm s5-tools query --endpoint ontop "SPARQL"   # 질의 한 건(ontop|fuseki)
```

| 모듈 | 내용 |
|---|---|
| `materialize.py` | Morph-KGC 실행(물질화 필터 적용 사본, 컨테이너 안 임시 폴더에 출력) → 그래프별 N-Triples → 반영(빈 그래프 POST, 적재본과 같으면 차이만, 그 밖·`--full`은 PUT) → 어휘 그래프 교체 → 감사 기록 |
| `check.py` | 가상 = SQL(Ontop 클래스별 개체 수, 사업장별 로트 수), 물질화 = 기대치((그래프, 클래스)별 개체 수, 그래프별 트리플 수), 그래프 분리 6건 |
| `mappings.py` | R2RML 읽기, 물질화 필터(명사의 원장 행 조건을 본 매핑·확장 속성 매핑에 함께) |
| `base.py` | 설정(`mapping/<기업>/s5_plan.yaml` + `ksxgen.yaml`), psql, SPARQL·Graph Store 프로토콜 |

설정: `mapping/<기업>/s5_plan.yaml`(양식 `mapping/_template/s5_plan.yaml`). 그래프 배정(기업 공통 기준정보)은 S4 생성 단계의 `ksxgen.yaml` `common_graph_nouns`.
시험: `python tests/coverage/test_ksxkg.py`. 실행 순서와 승인 절차는 `docs/S5_지식그래프구성_실행가이드.docx`.
