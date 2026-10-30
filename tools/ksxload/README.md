# ksxload — S3 데이터 전환·적재 (0.1)

승인된 매핑 명세(S2)대로 원천 데이터를 표준 원장(ksx·ext 스키마)에 적재하고 대사한다(구현안내서 6장).

```
원천(impix-src)  ──stage──▶  stg.<시스템>__<테이블>     원천 그대로 복제(초기 적재)
                               │ dbt seed·run·test  (모델은 gen이 명세에서 생성)
                               ▼
                             xfm.<모델>                 변환 뷰: 코드·단위·일시·식별자·정제 규칙
                               │ publish  (한 트랜잭션, FK 지연 검사)
                               ▼
                             ksx.<명사> · ext.<명사>     표준 원장 76 + 확장 22 테이블
                             audit.run · load_log · quarantine   실행·대사·정제 기록
```

## 명령

PC에서는 Docker `s3-tools` 서비스로 실행한다. 이 서비스에는 dbt, psql, ksxload가 들어 있다.
명령은 `infra/docker-compose` 폴더에서 실행한다.

```bash
docker compose --profile tools build s3-tools
docker compose --profile tools run --rm s3-tools ddl        # 표준·확장 테이블, xfm·audit 준비(한 번)
docker compose --profile tools run --rm s3-tools stage      # 원천 56개 테이블 → stg + 행 수 대사
docker compose --profile tools run --rm s3-tools gen        # 명세·규칙 → dbt 모델(저장소에 커밋된 것과 같아야 함)
docker compose --profile tools run --rm s3-tools dbt build  # seed → run(뷰 79) → test(382)
docker compose --profile tools run --rm s3-tools publish    # xfm → 표준 원장 + 대사(--dry-run: 되돌림)
docker compose --profile tools run --rm s3-tools review     # 정제 규칙 검토서(xlsx) — 현업 공동 검토 자료
```

| 명령 | 하는 일 | 결과 확인 |
|---|---|---|
| `ddl` | `ontologies/ddl/*.sql` 적용. 이미 있으면 건너뛴다(`--recreate`는 다시 만든다). `xfm` 스키마와 `audit.load_log`·`audit.quarantine`을 만든다 | 테이블 98, FK 672 |
| `stage` | 원천을 psql `\copy`로 그대로 복제하고 원천 행 수와 비교한다 | 56 테이블, 143,858행 일치 |
| `gen` | 명세(`mapping/<기업>/{erp,mes,qms}/*.yaml`)와 정제 규칙(`s3_plan.yaml`)으로 `etl/dbt/models/<기업>/`·`seeds/<기업>/`와 적재 목록 `etl/dbt/publish/<기업>.yml`을 만든다 | 모델 79(규칙 적용 10) |
| `dbt build` | 변환 함수 생성(on-run-start) → seed(대응표) → 뷰 → 테스트(UK 유일·필수 값·코드 대응) | 테스트 382 통과 |
| `xfm` | dbt 없이 같은 SQL로 seed·뷰·테스트를 실행한다(dbt를 쓸 수 없는 환경용) | `dbt build`와 같음 |
| `publish` | 대상 70개 테이블을 비우고 FK 순서대로 적재한다. FK 고아가 있으면 커밋이 실패해 원장은 그대로 남는다 | 아래 대사 |
| `check` | gen 생성물이 명세·규칙과 같은지 본다(CI) | 통과 |
| `review` | 계획의 `review`·`s2_regressions`·`approval` 절과 마지막 publish 기록으로 `mapping/<기업>/S3_정제규칙_검토서_<기업>.xlsx`를 만든다(작성기준·검토목록·처리행·대사·원천정정요청·S2회귀·승인) | 미결정 0 |

## 대사 (구현안내서 6.6 표 15)

| 검사 | 방법 | IMPIX 결과 |
|---|---|---|
| 행 수 | 원천(필터 적용) = 모델 + 규칙 처리(격리·중복 정리) — 이벤트 펼침은 일시 수, LOT별 1행은 고유 키 수 | 59/59 |
| 합계 | 수량·금액(NUMERIC) 컬럼 원천 합 = 모델 합 | 47/47 (보정 컬럼 제외) |
| UK 유일 | dbt `ksx_unique_key` + 원장 UNIQUE 제약 | 중복 0 |
| 필수 값 | dbt `not_null`(UK·NOT NULL·기본 속성) | NULL 0 |
| 참조 무결성 | 원장의 모든 FK(672)에 대해 고아 행 집계 → 0이어야 커밋 | 고아 0 |
| 코드 대응 | dbt `ksx_code_mapped`(원천 코드값이 대응표에 있는가) — 발생하면 S2로 회귀 | 미대응 0 |

결과는 `audit.load_log`(단계·대상·원천 행·적재 행·상태)에 남는다.

## 정제 규칙 (`mapping/<기업>/s3_plan.yaml` rules)

| action | 처리 | 기록 |
|---|---|---|
| `dedupe` | 같은 UK 중 `keep` 순서로 1행만 | 남지 않은 행 |
| `quarantine` | `when`(모델 컬럼, 별칭 m) 또는 `orphan`(부모에 없는 참조)인 행을 적재 안 함 | 격리 행 |
| `nullify_orphan` | 부모에 없는 참조 컬럼만 NULL(행은 적재) | 원래 값이 든 행 |
| `replace_orphan` | 부모에 없는 참조 컬럼을 `with` 식(다른 모델에서 찾은 값)으로 바꿈 | 원래 값이 든 행 |
| `correct` | `when`이 참인 행의 `set` 컬럼을 식으로 고침(여러 근거가 일치할 때만). 보정 컬럼은 합계 대사에서 뺀다 | 원래 값이 든 행 |
| `flag` | 적재는 그대로, 현업 확인 대상으로 표시 | 해당 행 |

모든 규칙은 S1 품질 이슈 ID(Q…)나 S3에서 새로 발견한 ID(S3-…)를 단다.
처리 방식은 데이터 엔지니어가 혼자 정하지 않는다. 규칙마다 원천을 현업과 함께 보고(검토 카드 양식 `mapping/_template/S3_정제규칙_검토카드_양식.md`)
결정을 계획의 `review` 절에 적는다(구현안내서 v1.2 6.7). 결과는 `audit.quarantine`에 행 전체(JSON)로 남는다.
원천 정정을 요청할 때 이 기록을 근거로 쓴다.

## 변환 어휘

S2 계획 머리말의 변환 어휘(`upper_trim`·`to_date8`·`to_ts14`·`yn`·`mat_lot`·`case`·`xref`·`code` 등)는
`etl/dbt/macros/xfm_functions.sql`의 SQL 함수(`xfm.*`)로 구현했다. 번역 규칙은 `ksxload/dsl.py`에 있다.
명세의 맨 컬럼 이름에는 주 원천 별칭(`s.`)이 붙고, 조인 별칭(`o.col`)은 그대로 남는다.

## 접속

| 환경변수 | 기본값 | 쓰임 |
|---|---|---|
| `KSX_DB_HOST`·`KSX_DB_PORT`·`KSX_DB_NAME` | localhost · 5432 · ksx | 원장 DB |
| `KSX_OWNER_PASSWORD` | — | ddl·stage·dbt(스키마·뷰 소유자) |
| `KSX_LOADER_PASSWORD` | — | publish(원장 적재) |
| `POSTGRES_SUPERUSER_PASSWORD` | — | ddl 최초 1회: 기존 S0 원장에 스키마 생성 권한 보강 |
| `IMPIX_SRC_HOST`·`IMPIX_SRC_PORT`·`IMPIX_SRC_READER_PASSWORD` | localhost · 5433 | 원천(S1 설정 재사용) |

DB 접속은 psql 클라이언트만 쓴다(psycopg 불필요).
