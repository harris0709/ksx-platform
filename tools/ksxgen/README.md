# ksxgen — KS X 9101 표준 컴파일러 (v0.1)

`standards/`의 테이블 정의서·공통코드 워크시트를 읽어 `ontologies/`에 생성물을 씁니다. 의존성은 openpyxl 하나입니다(망분리 환경 대응).

```bash
PYTHONPATH=tools/ksxgen python -m ksxgen build --std standards --out ontologies [--config ksxgen.yaml]
PYTHONPATH=tools/ksxgen python -m ksxgen check --std standards --out ontologies
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

## 남은 과제

- Extension 입력(`--ext extensions/{ent}`)과 금지 규칙 검사
- RML(물질화)·속성 그래프 스키마·도구 스키마 생성
