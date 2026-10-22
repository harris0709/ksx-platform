# IMPIX — S1 원천 분석 (구현안내서 4장)

IMPIX는 실습용 **가상 기업**입니다. 원천 시스템은 레거시 스타일 ERP·MES(PostgreSQL)이며
`infra/docker-compose/impix-src/`가 만들어 냅니다(2026-09-21 ~ 10-20, 결정적 생성).

## 실행

```bash
cd infra/docker-compose
../scripts/gen-secrets.sh --add-missing                          # 새 키(IMPIX_SRC_*)만 .env에 추가
docker compose --profile sim up -d impix-src                     # 가상 원천 DB(5433)
docker compose --profile tools build s1-tools
docker compose --profile tools run --rm s1-tools all       --config mapping/impix/s1/s1_config.yaml
docker compose --profile tools run --rm s1-tools scenarios --config mapping/impix/s1/s1_config.yaml
```

## 파일

| 파일 | 내용 | 4.1 절차 |
|---|---|---|
| `s1_config.yaml` | 원천 접속, 코드 마스터, 수작업 관계, 품질 점검, 테이블별 명사 1차 추정, 시나리오 | 3~7 |
| `scenarios.yaml` | 시나리오 목적·흐름·KPI, **업무 질의서 100건**, 실습 데이터 사건(정답지) | 1~3 |
| `source/legacy_queries.sql` | 고객사에서 받은 리포트·인터페이스 SQL(암묵 관계 근거) | 7 |
| `S1_원천인벤토리_IMPIX.xlsx` | 요약·원천인벤토리(표 8)·컬럼·프로파일·코드·관계·품질이슈·시나리오-명사 | 4~7 |
| `S1_원천분석_요약_IMPIX.md` | 주요 수치, 상(上) 이슈, 암묵 관계 | — |
| `s1_extract_IMPIX.json` | 스키마·프로파일·코드·관계·이슈 원자료(S2 automap 입력) | → S2 |
| `S1_업무질의서_IMPIX.xlsx` | 질의서 100건(유형·판단 기준·필요 명사·기대 답) | 2 |
| `S1_시나리오정의서_IMPIX.docx` | 시나리오 5종 정의, 대상 명사·원천 대응, 공백·Extension 후보, 승인란 | 1, 3 |

## 완료 기준(표 7)

- 대상 테이블 100% 프로파일 → 인벤토리 `요약` 시트
- 시나리오별 대상 명사 목록 승인 → 정의서 `승인` 절(도메인 컨설턴트·현업 검수자 서명)
