# s1profiler — S1 원천 분석 도구

구현안내서 4.1 절차 4~7을 한 번에 수행합니다(PostgreSQL 원천).

| 단계 | 내용 | 결과 시트 |
|---|---|---|
| 4) 스키마 추출 | 테이블·컬럼·타입·PK·UK·FK·주석 | 컬럼목록 |
| 5) 프로파일링 | 행 수, NULL·고유값·최소/최대·평균 길이, 상위 값, 값 패턴, 문자열 일시 판정, 키 후보, 일 증가량 | 컬럼프로파일, 원천인벤토리 |
| 6) 코드 수집 | 코드 마스터 테이블 + 저카디널리티 컬럼(코드 연결·주석 정의·하드코딩 의심·여부 플래그) | 코드마스터, 코드후보컬럼 |
| 7) 암묵 관계 | 선언 FK + 리포트 SQL 조인 + 이름·값 일치 + 수작업 등록, 포함률·고아 검증 | 관계(FK·암묵) |
| 품질 점검 | 중복 키, 공백, 단위 혼재, 일시 형식, 필수 NULL, 고아, 사용자 정의 SQL | 품질이슈 |

```bash
python -m s1profiler check-conn --config mapping/impix/s1/s1_config.yaml   # 접속 확인
python -m s1profiler all        --config mapping/impix/s1/s1_config.yaml   # 분석 전체
python -m s1profiler scenarios  --config mapping/impix/s1/s1_config.yaml   # 정의서·질의서
python -m s1profiler kpi        --config mapping/impix/s1/s1_config.yaml   # KPI 정의서(xlsx) + 원천 산출 검증
```

### kpi 명령

`<output_dir>/kpi_catalog.yaml`(또는 `--catalog`)을 읽어 다음 순서로 계산합니다.

1. `datasets` — 원천 시스템별 추출 SQL(PostgreSQL, `{as_of}` 치환)을 실행해 메모리 sqlite 테이블로 적재
2. `views` — 정규화·시스템 간 조인 뷰(`:as_of_date` 등은 문자열로 치환), 달력 `cal`·월 `months` 테이블 자동 생성
3. `kpis[].result` — KPI별 sqlite SQL(열: period, dim, value, num, den, note). 결과는 `k_<ID>` 테이블로 남아 뒤 KPI가 참조(OEE)
4. 산출물: `S1_KPI정의서_<기업>.xlsx`(개요·KPI정의서·KPI산출값·월별비교·일별추이·명사-KPI·공백·Extension·산출SQL), `s1_kpi_<기업>.json`

업무 질의(`scenarios.yaml`)의 `kpi:` 필드로 질의와 KPI가 서로 연결됩니다(정의서 '관련 질의' 열, 질의서 'KPI별 질의' 시트).

- 기본 드라이버는 psycopg 3입니다. 설치할 수 없는 환경은 `S1_DB_DRIVER=psql`로 psql 명령 기반 대체 드라이버를 씁니다(느림).
- 원천 계정은 읽기 전용으로 접속하며(`default_transaction_read_only`), 질의는 집계·DISTINCT만 실행합니다.
- 신규 고객사: `mapping/_template` 대신 `mapping/impix/s1/s1_config.yaml`을 복사해 접속·코드 마스터·명사 추정을 바꿉니다.
