# ksxgen — KS X 9101 표준 컴파일러 (v0.1)

`standards/`의 테이블 정의서·공통코드 워크시트를 읽어 `ontologies/`에 생성물을 씁니다. 의존성은 openpyxl 하나입니다(망분리 환경 대응).

```bash
PYTHONPATH=tools/ksxgen python -m ksxgen build --std standards --out ontologies [--config ksxgen.yaml]
PYTHONPATH=tools/ksxgen python -m ksxgen check --std standards --out ontologies
# 기업 확장(Extension)
PYTHONPATH=tools/ksxgen python -m ksxgen ext-template --out extensions/{기업}/확장정의서.xlsx
PYTHONPATH=tools/ksxgen python -m ksxgen ext-sync extensions/{기업}/확장정의서.xlsx --std standards
PYTHONPATH=tools/ksxgen python -m ksxgen build --std standards --ext extensions/{기업} --out ontologies
```

| 생성물 | 내용 |
|---|---|
| tbox/ksx9101_core.ttl | 클래스 76(명사 68 + 라인 구조체 8), 데이터 속성 377, 객체 관계 224(참조·코드·역관계) |
| shapes/ksx9101_conformance.ttl | 클래스별 SHACL(필수·타입·참조 대상·수량 ≥ 0·헤더 hasLine ≥ 1) |
| mappings/ksx9101.obda | Ontop 매핑(테이블 76개 + 헤더–라인 연결 8개) |
| ddl/ksx.sql | PostgreSQL DDL(PK 대리키, UK, 물리 FK 609 — DEFERRABLE) |
| vocab/codelist.ttl | SKOS 코드 그룹 79 · 코드 568 · 단위 47 |
| catalog/nouns/*.json, catalog/sql_schema.md | 명사 카드 68, Text-to-SQL 스키마 설명 |
| load_order.txt | FK 위상 정렬 적재 순서 |
| report/coverage.md | 커버리지·논리 관계 목록 |

## 변환 규칙 요약

- 명사 → `owl:Class`(rdfs:subClassOf ksx:Noun). 헤더 구조체는 명사 클래스, 라인 구조체는 `ksx:{Noun}Line`(ksx:StructLine 하위) + `ksx:hasLine`/`ksx:lineOf`
- 컬럼 → 데이터 속성(lowerCamel, 명사 간 공유, domain 미선언). enum → `skos:Concept`을 가리키는 객체 관계
- 물리 FK → `ksx:ref{속성명−ID}` 객체 관계(range = 부모 클래스, 역관계 자동). 논리 관계(사본·다형·표준 외)는 관계로 만들지 않고 `ksx:copyOf` 주석·리포트로 남김

## 기업 확장(`--ext`)

`extensions/{기업}/확장정의서.xlsx`(표준 테이블 정의서와 같은 양식)와 `ext.yaml`(네임스페이스)을 읽습니다. Core 생성물은 바꾸지 않습니다.

| 생성물 | 내용 |
|---|---|
| tbox/{기업}_ext.ttl | 확장 명사 클래스(ksx:Noun 하위), 신규 속성(기업 접두), `owl:imports` Core |
| shapes/{기업}_ext_shapes.ttl | 확장 명사 셰이프 + 확장 속성 셰이프(대상 Core 클래스) |
| mappings/{기업}_ext.obda | Ontop 매핑(확장 속성은 Core 명사와 같은 IRI) |
| ddl/ext_{기업}.sql | ext 스키마 DDL(Core UK 참조 FK) |
| vocab/{기업}_codelist.ttl | 확장 코드(SKOS, 표준 그룹 하위 확장은 skos:broader) |
| report/{기업}_ext.md | 속성 대응(표준 재사용·신규)과 검사 결과 |

- 표준 속성과 같은 영문명·같은 타입은 `ksx:` 공유 속성을 재사용하고, 새 이름만 기업 네임스페이스에 만듭니다.
- 다음 경우 빌드를 멈춥니다.
  - Core 테이블명·코드 그룹명 재사용
  - 표준 속성 이름에 다른 타입
  - 확장 속성이 이미 대상 Core 명사에 있음
  - 고정형 표준 그룹에 코드 추가
  - 없는 FK·코드 그룹 참조

## 남은 과제

- 하위 클래스·현장 용어 별칭·사내 제약(확장 유형 추가)
- RML(물질화)·속성 그래프 스키마·도구 스키마 생성
