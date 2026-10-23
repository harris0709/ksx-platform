# automap — S2 표준 매핑 추천·명세 생성기 (0.1)

원천 테이블 컬럼을 KS X 9101 표준 명사(Core)와 기업 확장(Extension) 속성에 대응시킨다(구현안내서 5장).
결과로 매핑 명세(YAML), 코드·단위·식별 대응표(CSV), 검토본(Excel), 요약(Markdown)을 만든다.

```
S1 추출(s1_extract_*.json) ─┐
표준 테이블 정의서(standards/) ─┼─▶ automap ─▶ mapping/{ent}/{erp|mes|qms}/{Noun}.yaml
기업 확장 정의서(extensions/)  ─┤               mapping/{ent}/codes.csv · units.csv · xref.csv
매핑 계획(s2_plan.yaml) ───────┘               mapping/{ent}/S2_매핑정의서_{ent}.xlsx · S2_매핑요약_{ent}.md
```

## 실행

```bash
PYTHONPATH=tools/automap python -m automap run   --plan mapping/impix/s2_plan.yaml   # 생성
PYTHONPATH=tools/automap python -m automap check --plan mapping/impix/s2_plan.yaml   # 완료 기준 + 생성물 최신 여부
python tests/coverage/test_automap.py                                                # 회귀 시험
```

`check`는 아래 중 하나라도 어긋나면 실패(종료 코드 1)한다. CI(`ontology-ci`)와 `scripts/verify.sh`에서 돈다.

- 필수 속성(UK·NOT NULL·기본 속성 EnterpriseID/SiteID/PlantID) 매핑 100%
- 대상 테이블(`scope_tables: all` = S1 원천 전체) 컬럼 판정 100%(매핑·확장·제외·조인 키·코드 원천·식별 대응 등)
- 검사 오류 0: 없는 표준 속성, 없는 코드 그룹·코드, 원천 값의 코드 대응 누락, 단위 대응 누락, 식별 대응 누락,
  `filter`에 쓴 컬럼이 원천(주 테이블·조인 별칭)에 없음
- 저장소의 명세·대응표·요약이 계획으로 다시 만든 결과와 같음

Windows 참고: 실행 전 검토본 Excel(`S2_매핑정의서_*.xlsx`)을 닫는다(열려 있으면 PermissionError). 한글 출력은 `export PYTHONUTF8=1`.
Python 3.15처럼 PyYAML 휠이 없는 버전은 `PYYAML_FORCE_LIBYAML=0 python -m pip install pyyaml`(순수 Python 설치).

## 매칭 단계(구현안내서 5.2 표 11)

| 단계 | 방법 | 예 |
|---|---|---|
| ① 정확 | 밑줄 제거 후 영문 속성명과 같음 | `lot_size` → LotSize |
| ② 정규화 | 약어 사전(`abbrev.yaml`)으로 펼침 | `cust_cd` → CustomerID, `so_seq` → SalesDocumentSequence |
| ③ 컴포넌트 | 끝 토큰 = 컴포넌트(ID·Date·Quantity·Class…), 앞 토큰 = 접두(앞 수식어를 떼어 가며) | `oper_emp_no` → PersonnelID |
| ④ 국문명 | 컬럼 주석과 표준 국문명 | `comp_nm`(회사명) → EnterpriseName |
| ⑤ 후보 | 미해소 컬럼의 상위 5개 유사도 후보(임베딩 대신 문자열 유사도) | 검토본 `후보(미해소)` 시트 |
| ⑥ 재순위·근거 | 검토자 판단을 계획 `map`에 기록 — 결정론과 다르면 "검토자 수정"으로 집계 | `stat_cd` → EquipmentState(후보 EquipmentStateID) |
| ⑦ 승인 | 검토본 `승인` 시트 서명 → 명세 status: approved | |

지표: **결정론 해소율**(①~④ / 컬럼 1개 매핑, 목표 70% 이상)과 **검토자 수정 비율**(결정론 후보를 바꾼 비율, 목표 20% 미만).
여러 컬럼을 조합하는 식별자 생성·계산은 "파생"으로 따로 센다.

## 매핑 계획(s2_plan.yaml) — 사람이 판단한 것만 적는다

```yaml
specs:
  - noun: ProductionPerformance            # 표준·확장 명사
    source: mes.tb_trk_out                 # 주 원천
    structure: "N→1(완공+착공+LOT+검사)"     # 구조 유형(1:1, 1→헤더·라인, N→1, 이력→이벤트, 파생)
    join: [ { table: mes.tb_lot, as: l, on: "lot_no = l.lot_no" } ]
    filter: "…"                            # 적재 필터
    base: { PlantID: "xref(plant, i.fac_id)" }       # 기본 속성(EnterpriseID·SiteID 기본값은 defaults.base)
    map:                                   # 덮어쓰기·보충(문자열 = 원천 컬럼)
      ProductionPerformanceID: { from: trk_out_id, transform: "concat('PP-',trk_out_id)" }
      InspectionResult: { from: q.judge, code: QC_JUDGE }       # 코드 대응 그룹
      ItemUOMCode: { from: unit, uom: unit }                    # 단위 대응 점검
    exclude: { eqp_id: "사유" }             # 제외 판정(사유 필수)
    rest: "사유"                           # 파생 명세: 남은 컬럼은 주 명세에서 판정
tables:                                    # 명세 밖 테이블 판정(코드 원천·식별 대응·제외·조인 원천)
codes: [ { system, group, ksx_group, map, rule, note } ]     # rule: equal·merge·approx·ext
units: [ { src_unit, ksx_uom, ext, note } ]
xref:  { plant: [ { system, src, ksx } ] }
```

- 변환을 적지 않으면 원천 형식과 표준 자료형으로 추론한다: `char(8)`→`to_date8`, `varchar(14)`→`to_ts14`,
  timestamp→`to_ts`, Y/N→`yn`, numeric→`int`(정수 속성). 컬럼별 고정 변환은 `defaults.transform_by_column`.
- YAML 1.1 주의: 키 `NO`·`YES`·`ON`은 불리언으로 읽힌다. 약어 사전 키는 따옴표로 감싼다(엔진이 문자열이 아닌 키를 거부).
- 확장 속성(`extensions/{ent}/확장정의서.xlsx`)은 Core 명사의 속성으로 합쳐져 같은 `map`에 적는다. 명세에는 `extension:` 절로 나뉘어 기록된다.

## 명세 형식(산출)

```yaml
noun: Alarm
layer: core
structure: 이력(발생·해제)→이벤트 2행
source: {system: MES, table: mes.tb_alarm}
base: {EnterpriseID: const(IMPIX), SiteID: const(HQ), PlantID: 'xref(plant, e.fac_id)'}
identity: [AlarmID]
attributes:
  ErrorCode: {from: alm_cd, match: manual, code: ALM_CD -> EquipmentErrorCode, status: reviewed}
extension:
  AlarmSeverityCode: {from: alm_lvl, match: manual, code: ALM_LVL -> AlarmSeverityCode, status: reviewed}
excluded: []
```

상태 흐름: `draft`(자동, `accept_auto: false`) → `reviewed`(데이터 엔지니어) → `approved`(도메인·현업 승인 후 계획의 status로 올림).
S3(dbt 스테이징)는 이 명세의 `from`·`transform`·`code`·`uom`을 그대로 SQL로 옮긴다.
