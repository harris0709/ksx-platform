# 기업 확장(Extension) 정의 양식

`확장정의서_양식.xlsx`를 `extensions/{기업}/확장정의서.xlsx`로 복사해 작성합니다. 표준 테이블 정의서(`standards/`)와 **같은 시트·같은 열**을 쓰고, 확장 전용 열(파란 머리글)만 오른쪽에 덧붙였습니다. 이 파일이 ksxgen(S4)의 Extension 입력입니다.

| 단계 | 하는 일 |
|---|---|
| S1 원천 분석 | 원천 공백·Extension **후보**를 찾음(인벤토리·시나리오 정의서·KPI 정의서) |
| **S2 표준 매핑** | 후보마다 구현안내서 5.6 규칙으로 **판정**해 이 양식에 적고 현업 승인(**작성 시점**) |
| S4 T-Box 생성 | `ksxgen build --ext extensions/{기업}` → Extension T-Box·SHACL·OBDA·DDL·코드 목록 |

## 시트

| 시트 | 작성 | 내용 |
|---|---|---|
| 작성기준 | — | 판정 규칙, 작성 방법, 금지 사항, 명령 |
| 테이블목록 | 작성 | 확장 명사·확장 속성 테이블(확장유형, 대상 Core 명사, 판정 규칙, 원천, 관련 KPI·질의, 상태) |
| 테이블정의서 | 작성 | 업무 속성(구분 '확장')만 적으면 PK·기본 속성 8종·Core 키 행은 자동 |
| 관계목록 | 자동 | FK 참조 열에서 도출 |
| 코드그룹목록·공통코드 | 작성 | 신규 그룹 / 표준 그룹 하위 확장(회사정의 계층 그룹만). '회사 코드값' = 원천 코드 |
| 판정목록 | 작성 | 후보 → 판정(표준 매핑·코드 대응·확장 속성·확장 명사·확장 코드·제외·S3 처리)과 근거 |
| 검토·승인 | 자동+서명 | 검사 결과(오류·경고)와 승인 서명 |
| DDL | 자동 | ext 스키마 CREATE TABLE 참고 |

## 명령

```bash
export PYTHONPATH=tools/ksxgen
python -m ksxgen ext-template --out extensions/{기업}/확장정의서.xlsx     # 빈 양식(예시 행 포함)
python -m ksxgen ext-sync extensions/{기업}/확장정의서.xlsx --std standards # 자동 행·시트 채움 + 검사
python -m ksxgen build --std standards --ext extensions/{기업} --out ontologies
```

`extensions/{기업}/ext.yaml`에 기업 네임스페이스를 둡니다(`ent`, `prefix`, `ns`, `schema`).

## 허용과 금지

- 허용: 확장 명사(ID 식별·기본 속성 3종·참조 대상 명시), 확장 속성(ext 스키마 1:1 `{명사}Ext`, Core UK 참조), 확장 코드. 표준 속성과 의미·타입이 같은 영문명은 표준 공유 속성(`ksx:…`)을 그대로 씁니다.
- 금지(빌드 실패): Core 명사·속성·코드의 삭제·재정의, 표준 속성 이름에 다른 타입, 표준 테이블명·코드 그룹명 재사용, 고정형 표준 그룹에 코드 추가, `ksx:` 이름 추가, Core 클래스에 대한 동치·배타 선언.
- 하위 클래스·현장 용어 별칭·사내 제약은 다음 버전에서 지원합니다.
