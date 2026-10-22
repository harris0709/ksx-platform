# infra — S0 환경 구축 (구현안내서 3.1 절차 2~6)

```
infra/
├─ docker-compose/
│   ├─ docker-compose.yml          # 개발 스택 9개 서비스
│   ├─ .env.example                # 환경변수 템플릿(버전·비밀) → .env 는 커밋 금지
│   ├─ postgres/init/              # DB 3개, 계정 5종, 스키마 4개, audit, RLS 도우미, AGE
│   ├─ fuseki/                     # Dockerfile(Jena 공식 jar) + config.ttl(/ksx, TDB2)
│   ├─ ontop/                      # Dockerfile(JDBC 포함) + bootstrap 매핑(S4 전 기동 확인용)
│   ├─ keycloak/realm-ksx.json     # realm·역할·클라이언트·클레임 매퍼·개발 사용자
│   └─ opa/policies/ksx/           # 사업장 경계 정책 + 테스트 + 설정(data.json)
├─ scripts/
│   ├─ gen-secrets.sh              # 절차 6: .env 생성(무작위 비밀번호)
│   ├─ healthcheck.sh              # 부록 A S0 체크리스트 일괄 확인
│   ├─ check-claims.sh             # 절차 4 확인: 토큰 클레임
│   └─ check-opa.sh                # 절차 5 확인: 토큰 → OPA 허용 그래프
└─ helm/                           # 운영 배포(별도 작업)
```

## 서비스와 포트 (모두 127.0.0.1 바인딩)

| 서비스 | 주소 | 용도 | 단계 |
|---|---|---|---|
| PostgreSQL 16 + AGE | localhost:5432 (DB `ksx`) | 표준 원장 stg·ksx·ext·audit | S3, S8 |
| Kafka (KRaft) | localhost:29092 | CDC·pg-sync·BOD 이벤트 | S3, S8, S10 |
| Airflow | http://localhost:8080 | 배치(적재·물질화·추론·검증) | S3~S7 |
| Fuseki | http://localhost:3030/ksx | 트리플 저장소(Named Graph) | S5~S7 |
| Ontop | http://localhost:8081/sparql | 원장 가상 그래프 | S5 |
| Qdrant | http://localhost:6333 | 벡터 인덱스 | S8 |
| Keycloak | http://localhost:8180 (관리 콘솔) | OIDC realm `ksx` | 전 단계 |
| OPA | http://localhost:8181 | 사업장 경계 정책 | S9, 15장 |

## PostgreSQL 계정

| 계정 | 권한 | RLS |
|---|---|---|
| ksx_owner | 스키마·테이블 소유, DDL 적용 | — |
| ksx_loader | stg·ksx·ext 읽기/쓰기 (dbt·Airflow) | 우회(BYPASSRLS) |
| ksx_reader | ksx·ext 읽기 전용, 60초 제한 (Ontop·MCP) | 적용 |
| ksx_bod | ksx·ext 쓰기 (BOD Gateway 전용) | 적용 |
| ksx_audit | audit 기록 | — |

RLS는 S3에서 표준 테이블을 만든 뒤 `SELECT ksx.enable_site_rls('ksx."Lot"');` 로 테이블마다 켭니다.
세션 변수 `app.enterprise_id`, `app.site_id` 가 없으면 0행이 반환됩니다(기본 거부).

## Keycloak realm `ksx`

- 역할: pm, pi-consultant, data-engineer, ontology-engineer, ai-engineer, backend-engineer,
  infra-security, customer-reviewer, auditor, svc-mcp-tools, svc-bod-gateway
- 사용자 속성(관리자만 수정): enterpriseId, siteId, plantId(복수)
- 토큰 클레임: `enterpriseId`, `siteId`, `plantId`(대표 1개), `plants`(배열), `roles`(배열)
- 클라이언트: ksx-portal(사용자 로그인, PKCE), ksx-mcp·ksx-bod-gateway(서비스 계정),
  ksx-cli(**개발 전용**, 비밀번호 grant — 운영 realm에서는 삭제)
- 개발 사용자: dev-pm, dev-data, dev-onto(P1·P2), dev-reviewer, dev-auditor
  (비밀번호 = .env 의 KSX_DEV_USER_PASSWORD)

## OPA 정책 `data.ksx.authz`

| 규칙 | 결과 |
|---|---|
| graphs | 공통(tbox/ksx9101, shapes, codelist) + tbox/ext/{Ent} + {Ent}/{Site}/{Plant} |
| graph_prefixes | inferred/{Ent}/{Site}/ , 감사 역할이면 bod/ |
| allow_graph | input.graph 허용 여부 |
| ledger_session | PostgreSQL RLS 세션 변수 |

그래프 IRI 기준 주소는 `opa/policies/ksx/config/data.json` 의 `graph_base`
(기본 `https://data.acme.example/graph/`). D8(네임스페이스 호스트) 결정 후 이 값만 바꿉니다.

## 운영(Helm) 전환 시

- `.env` 의 키 이름을 그대로 Vault/Kubernetes Secret 에 등록하고 Pod 환경변수로 주입
- Keycloak: `KC_HTTP_ENABLED` 제거, TLS·hostname 고정, realm 에서 ksx-cli 와 dev-* 사용자 제거
- Openllet 등 AGPL 컴포넌트는 런타임 이미지에 넣지 않음(안내서 2.1)

## [S1~S3 실습] IMPIX 가상 원천 시스템 (profile: sim / tools)

| 서비스 | 주소 | 내용 |
|---|---|---|
| impix-src | localhost:5433 | 레거시 ERP(`impix_erp.erp`)·MES(`impix_mes.mes`)·QMS(`impix_qms.qms`), 분석 계정 `s1_reader`(읽기 전용) |
| s1-tools | (일회성 실행) | S1 원천 분석 도구 `tools/s1profiler` |

```bash
../scripts/gen-secrets.sh --add-missing        # 기존 .env 유지, IMPIX_SRC_* 키만 추가
docker compose --profile sim up -d impix-src
docker compose --profile tools run --rm s1-tools all --config mapping/impix/s1/s1_config.yaml
```

기본 `docker compose up -d`에는 포함되지 않습니다(프로필 지정 시에만 기동).

초기화 스크립트(`impix-src/init/`)는 **볼륨이 비어 있을 때 한 번만** 실행됩니다. 스크립트가 바뀌면 볼륨을 지우고 다시 띄웁니다.

```bash
docker compose --profile sim stop impix-src && docker compose --profile sim rm -f impix-src
docker volume rm ksx_impix-src-data            # 이름은 docker volume ls | grep impix 로 확인
docker compose --profile sim up -d impix-src
```

| 스크립트 | 내용 |
|---|---|
| `00-databases.sh` | 분석 계정, DB 3개(impix_erp·impix_mes·impix_qms) |
| `10·15·20-erp-*` | ERP 기준정보·제조오더 / 영업·구매·재고·원가 테이블 / 기준정보 시드 |
| `30·40-mes-*` | MES 스키마 / 30일 실적 시드(결정적 생성) |
| `45-erp-scm-seed.sql` | ERP 영업·구매·재고 데이터(2026-08-01~) — **생성 파일** |
| `60-qms-schema.sql`, `70-qms-seed.sql` | QMS 스키마 / 클레임·수입검사·부적합·폐기·Q-COST — **시드는 생성 파일** |
| `90-grants.sql` | `s1_reader` 읽기 권한 |

생성 파일(45·70)은 `tools/sim/gen_impix_ext.py`가 MES 실적을 읽어 만듭니다. 손으로 고치지 말고 생성기를 고친 뒤
00~40·60만 적재한 DB에서 다시 생성합니다(`python tools/sim/gen_impix_ext.py --host … --port …`).
