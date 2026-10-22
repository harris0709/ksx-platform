# IMPIX — S1 원천 분석 (구현안내서 4장)

IMPIX는 실습용 **가상 기업**입니다. 원천 시스템은 레거시 스타일 ERP·MES·QMS(PostgreSQL)이며
`infra/docker-compose/impix-src/`가 만들어 냅니다(MES·QMS 2026-09-21 ~ 10-20, ERP 영업·구매·재고 2026-08-01 ~, 결정적 생성).
KPI 기준 일시는 2026-10-20 17:00입니다.

## 실행

```bash
cd infra/docker-compose
../scripts/gen-secrets.sh --add-missing                          # 새 키(IMPIX_SRC_*)만 .env에 추가
docker compose --profile sim up -d impix-src                     # 가상 원천 DB(5433)
docker compose --profile tools build s1-tools
docker compose --profile tools run --rm s1-tools all       --config mapping/impix/s1/s1_config.yaml
docker compose --profile tools run --rm s1-tools kpi       --config mapping/impix/s1/s1_config.yaml
docker compose --profile tools run --rm s1-tools scenarios --config mapping/impix/s1/s1_config.yaml
```

## 파일

| 파일 | 내용 | 4.1 절차 |
|---|---|---|
| `s1_config.yaml` | 원천 접속, 코드 마스터, 수작업 관계, 품질 점검, 테이블별 명사 1차 추정, 시나리오 | 3~7 |
| `scenarios.yaml` | 시나리오 7종 목적·흐름·KPI, **업무 질의서 155건**(KPI 연결 55건), 실습 데이터 사건 EV1~EV11(정답지) | 1~3 |
| `kpi_catalog.yaml` | **전사 KPI 34종** 정의(산식·단위·주기·표준 명사·원천·공백)와 산출 SQL | KPI |
| `S1_KPI정의서_IMPIX.xlsx` | KPI 정의서·산출값(8~10월)·월별 비교·일별 추이·명사-KPI 매트릭스·공백·Extension·산출 SQL | KPI |
| `s1_kpi_IMPIX.json` | KPI 산출값 원자료(S7 규칙·S9 평가 기준값) | → S7·S9 |
| `source/legacy_queries.sql` | 고객사에서 받은 리포트·인터페이스 SQL(암묵 관계 근거) | 7 |
| `S1_원천인벤토리_IMPIX.xlsx` | 요약·원천인벤토리(표 8)·컬럼·프로파일·코드·관계·품질이슈·시나리오-명사 | 4~7 |
| `S1_원천분석_요약_IMPIX.md` | 주요 수치, 상(上) 이슈, 암묵 관계 | — |
| `s1_extract_IMPIX.json` | 스키마·프로파일·코드·관계·이슈 원자료(S2 automap 입력) | → S2 |
| `S1_업무질의서_IMPIX.xlsx` | 질의서 155건(유형·판단 기준·필요 명사·관련 KPI·기대 답), KPI별 질의 | 2 |
| `S1_시나리오정의서_IMPIX.docx` | 시나리오 7종 정의, 대상 명사·원천 대응, 공백·Extension 후보, 승인란 | 1, 3 |

## KPI 34종

| 영역 | KPI |
|---|---|
| 생산관리 — 생산현황 | PR01 공정별 일/월 생산실적, PR02 재공재고(WIP), PR03 양품율(직행률), PR04 공정별 불량금액, PR05 품질 실패비용 |
| 생산관리 — 설비관리현황 | EQ01 표준 UPM 대비 분당 생산성, EQ02 양품율, EQ03 작업시간, EQ04 MTBF, EQ05 MTTR, EQ06 시간가동율, EQ07 성능가동율, EQ08 OEE |
| 품질관리 — 품질현황 | QM01 고객 부적합 건수, QM02 일정 준수율, QM03 Line 중단 Claim·필드 반송, QM04 Q-COST, QM05 공정 PPM, QM06 불량 유형별 폐기, QM07 불량 손실액, QM08 협력업체 불량건수, QM09 수입검사 PPM |
| SCM — PSI | SC01 수요예측 정확도, SC02 판매계획준수율, SC03 생산계획준수율, SC04 자재충족율, SC05 제조 리드타임, SC06 재고 보유일수, SC07 재고회전율, SC08 재고정확도, SC09 장기 체화 재고 비율 |
| 고객서비스 | CS01 납기이행율, CS02 품절율, CS03 결품율 |

KPI를 고치거나 더할 때는 `kpi_catalog.yaml`만 바꾸고 `kpi` 명령을 다시 실행합니다.

## 완료 기준(표 7)

**2026-10-22 승인 완료** — [`S1_승인기록.md`](S1_승인기록.md)

- 대상 테이블 100% 프로파일 → 인벤토리 `요약` 시트
- 시나리오별 대상 명사 목록 승인 → 정의서 `승인` 절(도메인 컨설턴트·현업 검수자 서명)
