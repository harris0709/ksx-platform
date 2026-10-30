# IMPIX 매핑 (S1 → S2 → S3)

| 경로 | 내용 | 단계 |
|---|---|---|
| `s1/` | 원천 인벤토리·시나리오·업무 질의·KPI 정의서, S1 승인 기록 | S1 |
| `s2_plan.yaml` | **S2 매핑 계획** — 구조·조인·기본 속성·덮어쓰기·제외·코드·단위·식별 대응(사람이 판단한 것) | S2 |
| `abbrev.yaml` | 약어 사전(정규화·컴포넌트 매칭) — S2 승인 매핑에서 보강 | S2 |
| `erp/` `mes/` `qms/` | **매핑 명세** 58건(명사 54, 로트는 출처별 4건) — `automap run`이 생성 | S2 |
| `codes.csv` | 코드 대응 165행(ERP·MES·QMS 41개 그룹 → 표준·확장 코드) | S2 |
| `units.csv` | 단위 대응 16행(확장 단위 후보 2: N·m, cc/min) | S2 |
| `xref.csv` | 식별 대응(회사·사업장·공장·창고→공장) | S2 |
| `S2_매핑정의서_IMPIX.xlsx` | 검토본: 요약·구조매핑·속성매핑·컬럼판정·후보·코드·단위·식별·테이블판정·검사·**승인** | S2 |
| `S2_매핑요약_IMPIX.md` | 지표와 명세 목록 | S2 |
| `S2_승인기록.md` | 업무 승인 기록(2026-10-23 승인) | S2 |
| `s3_plan.yaml` | **S3 적재 계획** — 원장 접속·DDL·dbt 위치·**정제 규칙**(S1 품질 이슈 → 격리·중복 정리·참조 비움·표시) | S3 |
| `S3_승인기록.md` | 적재·대사 결과와 승인 기록(승인 전 초안) | S3 |

확장(Core에 없는 명사·속성·코드)은 `extensions/impix/확장정의서.xlsx`에 정의하고, 매핑 계획에서 Core 속성과 같이 쓴다.

```bash
PYTHONPATH=tools/automap python -m automap run   --plan mapping/impix/s2_plan.yaml
PYTHONPATH=tools/automap python -m automap check --plan mapping/impix/s2_plan.yaml
```

S3 적재(`tools/ksxload`)는 명세와 `s3_plan.yaml`로 `etl/dbt/models/impix/`(dbt 모델)를 만들고, 원천을 표준 원장에 적재한다.

```bash
PYTHONPATH=tools/ksxload python -m ksxload gen      # 명세·규칙 → dbt 모델
PYTHONPATH=tools/ksxload python -m ksxload check    # 생성물 최신 여부
```
