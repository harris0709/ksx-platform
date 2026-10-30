# ksx-platform

KS X 9101 기반 제조 온톨로지 End-to-End 구현 저장소입니다. 구조와 단계(S0~S11)는 「KS X 9101 기반 제조 온톨로지 End-to-End 구현 안내서」를 따릅니다.

## 폴더 구조

| 폴더 | 내용 | 관리 주체 | 단계 |
|---|---|---|---|
| `standards/` | KS X 9101 표준 문서, 테이블 정의서, 공통코드 워크시트 (읽기 전용) | 표준 관리자 | S4 입력 |
| `extensions/{ent}/` | 기업 확장 정의서(테이블 정의서와 같은 양식) | 온톨로지 엔지니어 | S2, S4 |
| `mapping/{ent}/{src}/` | 원천→표준 매핑 명세(*.yaml), 코드·단위 대응표(*.csv) | 데이터 엔지니어 + 현업 승인 | S2 |
| `tools/ksxgen/` | 생성기 (표준·확장 정의서 → 생성물 12종) | 온톨로지 엔지니어 | S4 |
| `tools/automap/` | 매핑 추천기·명세 생성기 (결정론 매처 + 유사도 후보 + 검토자 계획) | 데이터 엔지니어 | S2 |
| `etl/dbt/` | stg → ksx/ext 변환 모델·테스트·매크로 | 데이터 엔지니어 | S3 |
| `ontologies/` | **생성물** (tbox, shapes, rules, mappings, vocab, catalog, ddl, graph, report) | 생성기만 수정 | S4~S9 |
| `services/` | MCP 도구 서버, rule-runner, pg-sync, decision-engine, bod-gateway | AI·백엔드 | S7~S10 |
| `dags/` | Airflow DAG (적재→물질화→검증→추론→동기화) | 데이터 엔지니어 | S3~S8 |
| `infra/` | docker-compose, helm, keycloak realm, opa 정책, postgres 초기화 | 인프라·보안 | S0 |
| `tests/` | 커버리지·회귀·E2E 인수 시나리오 | 전원 | S11 |
| `web/` | 웹 콘솔(명사 브라우저·적합성·추론 결과). `tools/build_web.py`가 데이터 생성, Vercel로 배포 | 전원 | S9·E12 |

## 규칙

1. `standards/`는 표준 개정 시에만 교체합니다(PR + 표준 관리자 승인).
2. `ontologies/`는 손으로 고치지 않습니다. `ksxgen build` 결과를 커밋하며, CI가 재생성 결과와 비교합니다.
3. 매핑 명세는 `status: approved`인 항목만 변환·생성에 쓰입니다.
4. 비밀번호·토큰은 저장소에 넣지 않습니다. `.env.example`을 복사해 `.env`로 쓰고, 운영은 비밀 저장소를 씁니다.
5. 표준 문서(docx·xlsx)는 일반 Git 파일로 관리합니다. 대용량 바이너리가 생기면 Git LFS로 전환합니다(.gitattributes 참고).

## 현재 구현 상태

| 단계 | 구현 | 위치 |
|---|---|---|
| S0 환경 | 개발 스택(PostgreSQL 16.4, Fuseki 5.2.0, Ontop 5.1.2, Qdrant, Keycloak, OPA) | `infra/docker/` |
| S4 T-Box 생성 | **ksxgen 0.2** — 테이블 정의서·공통코드 → T-Box·SHACL·OBDA·DDL·SKOS·카탈로그·적재 순서·커버리지. **기업 확장(`--ext`)**: 확장 정의서 → Extension T-Box·SHACL·OBDA·DDL·코드, 금지 규칙 검사 | `tools/ksxgen/` → `ontologies/` |
| S5 A-Box | Ontop 가상화 매핑(테이블 76개) 생성, 시험용 OBDA 실행기 | `ontologies/mappings/`, `tests/e2e/obda_exec.py` |
| S6 검증 | 표준 적합성 SHACL(76개 셰이프) | `ontologies/shapes/` |
| S7 추론 | 규칙 5종(계보·BOM 전개·영향 수주·납기 리스크) + rule-runner | `ontologies/rules/`, `services/rule-runner/` |
| 시험 | 생성기 회귀, E2E 최소 시험(DDL → 시드 → OBDA → SHACL → 규칙), GitHub Actions CI | `tests/`, `.github/workflows/` |
| S1 원천 분석 | **s1profiler 0.2** — 스키마·프로파일·코드·암묵 관계·품질 → 인벤토리, 시나리오 7종·업무 질의 155건, **전사 KPI 34종 정의·산출(Excel)**. IMPIX 가상 원천(ERP·MES·QMS) | `tools/s1profiler/`, `tools/sim/`, `mapping/impix/s1/`, `infra/docker-compose/impix-src/` |
| S2 표준 매핑 | **기업 확장 정의서 양식** + IMPIX 확장(확장 명사 5·확장 속성 테이블 17·확장 코드 52·판정 46), **automap 0.1** — 결정론 매칭(①~④)·검토자 판단 계획 → 매핑 명세 58건·코드 대응 165·단위·식별 대응·검토본(Excel). 필수 속성 100%·컬럼 판정 100%·결정론 71.9%. **2026-10-23 승인** | `extensions/`, `tools/automap/`, `mapping/impix/` |
| S3 데이터 전환·적재 | **ksxload 0.1** — 원천 → stg(56 테이블) → dbt 변환(xfm 뷰 79, 테스트 382) → 표준 원장(70 테이블, 28만 행) + 대사(행 수·합계·UK·필수 값·FK 고아·코드)·정제 규칙(S1 품질 이슈)·감사 기록. 초기 적재(증분 CDC는 다음) | `tools/ksxload/`, `etl/dbt/`, `mapping/impix/s3_plan.yaml` |
| S8~S11 | 양식·설정 예시만 있음(다음 구현 대상) | `services/` |

## 시작하기

### 1) 생성기 실행 (Python 3.10+, openpyxl)

```bash
pip install openpyxl
PYTHONPATH=tools/ksxgen python -m ksxgen build --std standards --out ontologies   # 생성
PYTHONPATH=tools/ksxgen python -m ksxgen check --std standards --out ontologies   # 커버리지·최신 여부
```

### 2) 검증 (rdflib, pyshacl 추가 설치)

```bash
pip install rdflib pyshacl
python tests/coverage/test_ksxgen.py
KSX_TEST_PSQL="-h localhost -p 5432 -U ksx_admin -d ksx_test" python tests/regression/test_e2e_minimal.py   # 빈 DB 필요
# 또는 한 번에: ./scripts/verify.sh
```

### 3) 개발 스택 기동 (Docker Compose v2)

```bash
cp .env.example .env                      # 비밀번호 입력
# Ontop용 PostgreSQL JDBC jar를 infra/docker/ontop/jdbc/에 둔다(infra/docker/ontop/README.md)
docker compose -f infra/docker/docker-compose.yml --env-file .env up -d --build
docker compose -f infra/docker/docker-compose.yml exec postgres \
  psql -U ksx_admin -d ksx -c "ALTER ROLE ontop_ro PASSWORD '<.env의 ONTOP_DB_PASSWORD>'"
```

PostgreSQL은 첫 기동 때 `infra/postgres/init.sql`과 `ontologies/ddl/ksx.sql`(테이블 76개)을 자동 적용합니다.
접속 확인: Fuseki http://localhost:3030 · Ontop SPARQL http://localhost:8081/sparql · Qdrant http://localhost:6333 · Keycloak http://localhost:8080

### 4) 추론 규칙 실행 (Fuseki에 데이터가 적재된 뒤)

```bash
python services/rule-runner/runner.py --fuseki http://localhost:3030/ksx --ent ACME --site HQ
```

### 5) 웹 콘솔 배포(Vercel)

- `web/`이 그대로 정적 사이트입니다. Vercel 프로젝트 설정: Root Directory = `web`, Framework Preset = Other, Build Command 비움(설정은 `web/vercel.json`).
- 생성물이 바뀌면 `python tools/build_web.py`로 `web/data/nouns.js`를 다시 만든 뒤 커밋합니다(CI가 최신 여부 검사).
- Vercel 대시보드에서 이 저장소를 Import하면 `main`에 올릴 때마다 자동 배포, 병합 요청마다 미리보기 배포됩니다.
- 공개 사이트에는 표준 생성물과 가상 시드 결과만 둡니다. 고객사 매핑·실데이터는 넣지 않습니다.

## IRI 규칙

- 개체: `https://data.impix.co.kr/{EnterpriseID}/{Class}/{UK 값...}` — UK(회사+표준 식별 속성)만 쓰며 사업장·공장은 Named Graph로 구분합니다.
- 라인 구조체: `…/{Noun}/{헤더 키}/line/{라인 키}` (예: `ACME/BOM/BOM-A100_2/line/10`)
- 코드: `https://data.impix.co.kr/codelist/{그룹}/{코드}`, 단위: `…/uom/{단위코드}`
- 네임스페이스 호스트는 `ksxgen.yaml`에서 바꿉니다(의사결정 D8).
