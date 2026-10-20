# KS X 9101 표준 원장 SQL 스키마 (Text-to-SQL용, ksxgen 생성물)

- 스키마: `ksx`, 테이블·컬럼명은 따옴표 식별자(대소문자 구분)
- PK(…SequenceNo)는 내부 대리키이며 조인·답변에 쓰지 않는다. 조인은 아래 FK(부모 UK 참조)만 사용

## Site (사업장) — 7.4.1.1 표 12
UK: EnterpriseID, SiteID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SiteSequenceNo | 사업장 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| SiteID | 사업장식별자 | VARCHAR(50) |  |
| SiteName | 사업장명 | VARCHAR(200) |  |
| BusinessRegistrationNumber | 사업자등록번호 | VARCHAR(50) |  |
| DialNumber | 전화번호 | VARCHAR(30) |  |
| PostalCode | 우편번호 | VARCHAR(10) |  |
| BaseAddress | 기본주소 | VARCHAR(1000) |  |
| DetailAddress | 상세주소 | VARCHAR(1000) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |

## Plant (공장) — 7.4.1.2 표 13
UK: EnterpriseID, PlantID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| PlantSequenceNo | 공장 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PlantID | 공장식별자 | VARCHAR(50) |  |
| PlantName | 공장명 | VARCHAR(200) |  |
| DialNumber | 전화번호 | VARCHAR(30) |  |
| CountryID | 국가식별자 | VARCHAR(30) | 코드:CountryID |
| PostalCode | 우편번호 | VARCHAR(10) |  |
| BaseAddress | 기본주소 | VARCHAR(1000) |  |
| DetailAddress | 상세주소 | VARCHAR(1000) |  |

## Department (부서) — 7.4.1.3 표 14
UK: EnterpriseID, DepartmentID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| DepartmentSequenceNo | 부서 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| DepartmentID | 부서식별자 | VARCHAR(50) |  |
| DepartmentName | 부서명 | VARCHAR(200) |  |
| ParentDepartmentID | 상위부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |

## Personnel (사원) — 7.4.1.4 표 15
UK: EnterpriseID, PersonnelID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| PersonnelSequenceNo | 사원 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PersonnelID | 사원식별자 | VARCHAR(50) |  |
| PersonnelName | 사원명 | VARCHAR(200) |  |
| DepartmentID | 부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |
| EmploymentStatusType | 재직유형 | VARCHAR(30) | 코드:EmploymentStatusType |
| PersonInChargeEmail | 담당자이메일명 | VARCHAR(255) |  |
| PersonInChargeDialNumber | 담당자전화번호 | VARCHAR(30) |  |

## CustomerPartyMaster (고객사) — 7.4.1.5 표 16
UK: EnterpriseID, CustomerID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CustomerPartyMasterSequenceNo | 고객사 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| CustomerID | 고객사식별자 | VARCHAR(50) |  |
| CustomerName | 고객사명 | VARCHAR(200) |  |
| BusinessRegistrationNumber | 사업자등록번호 | VARCHAR(50) |  |
| RepresentativeName | 대표자명 | VARCHAR(200) |  |
| CountryID | 국가식별자 | VARCHAR(30) | 코드:CountryID |
| PostalCode | 우편번호 | VARCHAR(10) |  |
| BaseAddress | 기본주소 | VARCHAR(1000) |  |
| DetailAddress | 상세주소 | VARCHAR(1000) |  |
| DialNumber | 전화번호 | VARCHAR(30) |  |
| FaxNumber | 팩스번호 | VARCHAR(30) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |
| PersonInChargeName | 담당자명 | VARCHAR(200) |  |
| PersonInChargeEmail | 담당자이메일명 | VARCHAR(255) |  |
| PersonInChargeDialNumber | 담당자전화번호 | VARCHAR(30) |  |

## VendorPartyMaster (공급사) — 7.4.1.6 표 17
UK: EnterpriseID, VendorID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| VendorPartyMasterSequenceNo | 공급사 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) |  |
| VendorName | 공급사명 | VARCHAR(200) |  |
| BusinessRegistrationNumber | 사업자등록번호 | VARCHAR(50) |  |
| RepresentativeName | 대표자명 | VARCHAR(200) |  |
| CountryID | 국가식별자 | VARCHAR(30) | 코드:CountryID |
| PostalCode | 우편번호 | VARCHAR(10) |  |
| BaseAddress | 기본주소 | VARCHAR(1000) |  |
| DetailAddress | 상세주소 | VARCHAR(1000) |  |
| DialNumber | 전화번호 | VARCHAR(30) |  |
| FaxNumber | 팩스번호 | VARCHAR(30) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |
| PersonInChargeName | 담당자명 | VARCHAR(200) |  |
| PersonInChargeEmail | 담당자이메일명 | VARCHAR(255) |  |
| PersonInChargeDialNumber | 담당자전화번호 | VARCHAR(30) |  |

## CommonCodeMaster (공통코드정보) — 7.4.1.7 표 18
UK: EnterpriseID, CommonCodeGroup, CommonCodeID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CommonCodeMasterSequenceNo | 공통코드정보 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| CommonCodeID | 공통코드식별자 | VARCHAR(50) |  |
| CommonCodeName | 공통코드명 | VARCHAR(200) |  |
| CommonCodeGroup | 공통코드그룹 | VARCHAR(30) |  |
| ParentCommonCodeGroup | 상위공통코드그룹 | VARCHAR(50) | FK→CommonCodeMaster.CommonCodeGroup |
| ParentCommonCodeID | 상위공통코드식별자 | VARCHAR(50) | FK→CommonCodeMaster.CommonCodeID |
| CommonCodeSequence | 표시순번 | INTEGER |  |
| UseIndicator | 사용여부 | BOOLEAN |  |

## WorkCalendar (달력) — 7.4.1.8 표 19
UK: EnterpriseID, CalendarID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| WorkCalendarSequenceNo | 달력 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| CalendarID | 달력식별자 | VARCHAR(50) |  |
| CalendarType | 달력유형 | VARCHAR(30) | 코드:CalendarType |
| CalendarDate | 달력일자 | DATE |  |
| DayOfWeek | 요일 | VARCHAR(30) | 코드:DayOfWeek |
| WeekOfYear | 주수 | INTEGER |  |
| DayOfYear | 총누계일수 | INTEGER |  |
| ScheduleType | 근무일유형 | VARCHAR(30) | 코드:ScheduleType |

## UOMGroupHeader (단위그룹헤더) — 7.4.1.9 표 20
UK: EnterpriseID, UOMGroupID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| UOMGroupHeaderSequenceNo | 단위그룹헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| UOMGroupID | 단위그룹식별자 | VARCHAR(50) |  |
| UOMGroupName | 단위그룹명 | VARCHAR(200) |  |

## UOMGroupLine (단위그룹라인) — 7.4.1.9 표 20
UK: EnterpriseID, UOMGroupID, UOMCode

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| UOMGroupLineSequenceNo | 단위그룹라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| UOMGroupID | 단위그룹식별자 | VARCHAR(50) | FK→UOMGroupHeader.UOMGroupID |
| UOMCode | 단위코드 | VARCHAR(20) |  |
| UOMCodeName | 단위코드명 | VARCHAR(200) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |

## ItemMaster (품목마스터) — 7.4.1.10 표 21
UK: EnterpriseID, ItemID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ItemMasterSequenceNo | 품목마스터 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ItemID | 품목식별자 | VARCHAR(50) |  |
| ItemName | 품목명 | VARCHAR(200) |  |
| ItemType | 품목유형 | VARCHAR(30) | 코드:ItemType |
| PhantomIndicator | 가상품목여부 | BOOLEAN |  |
| ItemLargeClass | 품목대분류 | VARCHAR(30) | 코드:ItemLargeClass |
| ItemMediumClass | 품목중분류 | VARCHAR(30) | 코드:ItemMediumClass |
| ItemSmallClass | 품목소분류 | VARCHAR(30) | 코드:ItemSmallClass |
| ModelName | 모델명 | VARCHAR(200) |  |
| ItemSpecification | 품목사양 | VARCHAR(1000) |  |
| ItemDetailSpecification | 품목상세사양 | VARCHAR(1000) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |
| CountryOfOrigin | 원산국가 | VARCHAR(255) |  |
| PlaceOfOrigin | 원산지역 | VARCHAR(255) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| Weight | 중량 | NUMERIC(18,6) |  |
| NetWeight | 순중량 | NUMERIC(18,6) |  |
| WeightUOMCode | 중량단위코드 | VARCHAR(20) |  |
| Volume | 부피 | NUMERIC(18,6) |  |
| VolumeUOMCode | 부피단위코드 | VARCHAR(20) |  |
| Length | 길이 | NUMERIC(18,6) |  |
| Width | 너비 | NUMERIC(18,6) |  |
| Height | 높이 | NUMERIC(18,6) |  |
| DimensionUOMCode | 치수단위코드 | VARCHAR(20) |  |
| ValidEndDate | 유효종료일 | DATE |  |
| DrawingNumber | 도면번호 | VARCHAR(50) |  |
| LotControlIndicator | 로트사용여부 | BOOLEAN |  |
| PurchaseLeadTime | 구매리드타임 | INTERVAL |  |
| ProductionLeadTime | 생산리드타임 | INTERVAL |  |
| LotSize | 로트사이즈 | NUMERIC(18,6) |  |
| MainCustomerID | 주요 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| MainVendorID | 주요 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| SafetyStock | 안전재고 | NUMERIC(18,6) |  |
| MaximumStockLevel | 최대재고수준 | NUMERIC(18,6) |  |
| ReceiptWarehouseID | 입고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| IssueWarehouseID | 출고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ABCClass | 에이비씨분류 | VARCHAR(30) | 코드:ABCClass |
| ReplacementItemID | 대체품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| IncomingInspectionIndicator | 수입검사여부 | BOOLEAN |  |
| FinalInspectionIndicator | 생산입고(최종)검사여부 | BOOLEAN |  |
| OutgoingInspectionIndicator | 출하검사여부 | BOOLEAN |  |

## BOMHeader (자재명세서헤더) — 7.4.1.11 표 22
UK: EnterpriseID, BOMID, BOMRevisionNumber

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| BOMHeaderSequenceNo | 자재명세서헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| BOMID | 자재명세서식별자 | VARCHAR(50) |  |
| BOMRevisionNumber | 자재명세서버전 | INTEGER |  |
| BOMType | 자재명세서유형 | VARCHAR(30) | 코드:BOMType |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| BOMQuantity | 품목기준수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingHeader.RoutingID |

## BOMLine (자재명세서라인) — 7.4.1.11 표 22
UK: EnterpriseID, BOMID, BOMRevisionNumber, BOMLineSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| BOMLineSequenceNo | 자재명세서라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| BOMID | 자재명세서식별자 | VARCHAR(50) | FK→BOMHeader.BOMID |
| BOMRevisionNumber | 자재명세서버전 | INTEGER | FK→BOMHeader.BOMRevisionNumber |
| BOMLineSequence | 자재명세서라인순번 | INTEGER |  |
| ChildItemID | 자품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ChildItemUOMCode | 자품목기준단위코드 | VARCHAR(20) |  |
| ActualRequirementQuantity | 실소요수량 | NUMERIC(18,6) |  |
| OperationSequence | 공정순번 | INTEGER | FK→RoutingLine.OperationSequence |
| BackFlushedIndicator | 백플러시여부 | BOOLEAN |  |
| ValidStartDateTime | 유효시작일시 | TIMESTAMP |  |
| ValidEndDateTime | 유효종료일시 | TIMESTAMP |  |

## Lot (로트) — 7.4.1.12 표 23
UK: EnterpriseID, LotID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| LotSequenceNo | 로트 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| LotID | 로트식별자 | VARCHAR(50) |  |
| LotName | 로트명 | VARCHAR(200) |  |
| LotDescription | 로트설명 | VARCHAR(1000) |  |
| ParentLotID | 모로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ChildLotID | 자로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotType | 로트유형 | VARCHAR(30) | 코드:LotType |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| ScheduledDueDate | 생산마감기한 | DATE |  |
| LotPriority | 로트우선순위 | INTEGER |  |
| CurrentOperationID | 현재공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| NextOperationID | 다음공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| LotState | 로트상태 | VARCHAR(30) | 코드:LotState |
| HoldIndicator | 보류여부 | BOOLEAN |  |
| HotIndicator | 긴급여부 | BOOLEAN |  |
| ReworkIndicator | 재작업여부 | BOOLEAN |  |
| LotCreatedQuantity | 로트수량 | NUMERIC(18,6) |  |
| ProducedQuantity | 생산수량 | NUMERIC(18,6) |  |
| DefectQuantity | 불량수량 | NUMERIC(18,6) |  |
| ReworkQuantity | 재작업수량 | INTEGER |  |
| ReworkCount | 재작업횟수 | INTEGER |  |
| TotalReworkCount | 총재작업횟수 | INTEGER |  |
| LotStartedDateTime | 공정투입일시 | TIMESTAMP |  |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |

## RoutingHeader (공정경로헤더) — 7.4.1.13 표 24
UK: EnterpriseID, RoutingID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| RoutingHeaderSequenceNo | 공정경로헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| RoutingID | 공정경로식별자 | VARCHAR(50) |  |
| RoutingName | 공정경로명 | VARCHAR(200) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| UseIndicator | 사용여부 | BOOLEAN |  |

## RoutingLine (공정경로라인) — 7.4.1.13 표 24
UK: EnterpriseID, RoutingID, OperationSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| RoutingLineSequenceNo | 공정경로라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingHeader.RoutingID |
| OperationSequence | 공정순번 | INTEGER |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| LastOperationIndicator | 최종공정여부 | BOOLEAN |  |
| SetupTime | 준비시간 | INTERVAL |  |
| RunTime | 작업시간 | INTERVAL |  |
| MoveTime | 이동시간 | INTERVAL |  |

## Operation (공정) — 7.4.1.14 표 25
UK: EnterpriseID, OperationID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| OperationSequenceNo | 공정 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| OperationID | 공정식별자 | VARCHAR(50) |  |
| OperationName | 공정명 | VARCHAR(200) |  |
| OperationType | 공정유형 | VARCHAR(30) | 코드:OperationType |
| UseIndicator | 사용여부 | BOOLEAN |  |
| OperationLargeClass | 공정대분류 | VARCHAR(30) | 코드:OperationLargeClass |
| OperationMediumClass | 공정중분류 | VARCHAR(30) | 코드:OperationMediumClass |
| OperationSmallClass | 공정소분류 | VARCHAR(30) | 코드:OperationSmallClass |
| BackFlushedIndicator | 백플러시여부 | BOOLEAN |  |

## Equipment (설비) — 7.4.1.15 표 26
UK: EnterpriseID, EquipmentID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| EquipmentSequenceNo | 설비 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| EquipmentID | 설비식별자 | VARCHAR(50) |  |
| EquipmentName | 설비명 | VARCHAR(200) |  |
| ParentEquipmentID | 상위설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| EquipmentType | 설비유형 | VARCHAR(30) | 코드:EquipmentType |
| EquipmentLargeClass | 설비대분류 | VARCHAR(30) | 코드:EquipmentLargeClass |
| EquipmentMediumClass | 설비중분류 | VARCHAR(30) | 코드:EquipmentMediumClass |
| EquipmentSmallClass | 설비소분류 | VARCHAR(30) | 코드:EquipmentSmallClass |
| DepartmentInChargeID | 관리부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |
| PersonInChargeID | 관리자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| UseIndicator | 사용여부 | BOOLEAN |  |
| DAQDevice | 데이터수집장치 | VARCHAR(255) |  |
| FixedAssetID | 고정자산식별자 | VARCHAR(50) |  |
| ModelNumber | 모델번호 | VARCHAR(50) |  |
| SerialNumber | 일련번호 | VARCHAR(50) |  |
| CountryOfOrigin | 제조국가 | VARCHAR(255) |  |
| Manufacturer | 제조업체 | VARCHAR(255) |  |
| AcquisitionDate | 취득일 | DATE |  |
| Location | 위치 | VARCHAR(1000) |  |

## OperationEquipment (공정설비) — 7.4.1.16 표 27
UK: EnterpriseID, OperationID, EquipmentID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| OperationEquipmentSequenceNo | 공정설비 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| OperationName | 공정명 | VARCHAR(200) | FK→Operation.OperationName (사본) |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| EquipmentName | 설비명 | VARCHAR(200) | FK→Equipment.EquipmentName (사본) |
| EquipmentSmallClass | 설비소분류 | VARCHAR(30) | 코드:EquipmentSmallClass |
| EquipmentQuantity | 기준사용대수 | INTEGER |  |

## Carrier (캐리어) — 7.4.1.17 표 28
UK: EnterpriseID, CarrierID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CarrierSequenceNo | 캐리어 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| CarrierID | 캐리어식별자 | VARCHAR(50) |  |
| CarrierType | 캐리어유형 | VARCHAR(30) | 코드:CarrierType |
| ItemType | 품목유형 | VARCHAR(30) | 코드:ItemType |
| LoadState | 적재상태 | VARCHAR(30) | 코드:LoadState |
| CarrierState | 캐리어상태 | VARCHAR(30) | 코드:CarrierState |
| CurrentQuantity | 적재수량 | NUMERIC(18,6) |  |

## StockerInventory (저장소재공정보) — 7.4.1.18 표 29
UK: EnterpriseID, StockerID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| StockerInventorySequenceNo | 저장소재공정보 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| StockerID | 저장소식별자 | VARCHAR(50) |  |
| ZoneID | 구역식별자 | VARCHAR(50) |  |
| FullCapacity | 최대용량 | INTEGER |  |
| CurrentCapacity | 현재용량 | INTEGER |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| AlternateStockerID | 대체저장소식별자 | VARCHAR(50) | FK→StockerInventory.StockerID |

## WarehouseLocationHeader (창고헤더) — 7.4.1.19 표 30
UK: EnterpriseID, WarehouseID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| WarehouseLocationHeaderSequenceNo | 창고헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| WarehouseID | 창고식별자 | VARCHAR(50) |  |
| WarehouseName | 창고명 | VARCHAR(200) |  |
| WarehouseType | 창고유형 | VARCHAR(30) | 코드:WarehouseType |
| UseIndicator | 사용여부 | BOOLEAN |  |
| NegativeInventoryIndicator | 음수재고허용여부 | BOOLEAN |  |

## WarehouseLocationLine (창고라인) — 7.4.1.19 표 30
UK: EnterpriseID, WarehouseID, WarehouseSection

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| WarehouseLocationLineSequenceNo | 창고라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| WarehouseSection | 창고섹션 | VARCHAR(255) |  |
| WarehouseSectionName | 창고섹션명 | VARCHAR(200) |  |

## Batch (배치) — 7.4.1.20 표 31
UK: EnterpriseID, BatchID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| BatchSequenceNo | 배치 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| BatchID | 배치식별자 | VARCHAR(50) |  |
| BatchName | 배치명 | VARCHAR(200) |  |
| BatchDescription | 배치설명 | VARCHAR(1000) |  |
| BatchType | 배치유형 | VARCHAR(30) | 코드:BatchType |
| ParentBatchID | 모배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| BOMID | 자재명세서식별자 | VARCHAR(50) | FK→BOMHeader.BOMID |
| BOMRevisionNumber | 자재명세서버전 | INTEGER | FK→BOMHeader.BOMRevisionNumber |
| RecipeID | 레시피식별자 | VARCHAR(50) |  |
| RecipeVersion | 레시피버전 | VARCHAR(255) |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| BatchState | 배치상태 | VARCHAR(30) | 코드:BatchState |
| HoldIndicator | 보류여부 | BOOLEAN |  |
| ReworkIndicator | 재작업여부 | BOOLEAN |  |
| QualityDispositionCode | 품질판정코드 | VARCHAR(30) | 코드:QualityDispositionCode |
| BatchPlannedQuantity | 배치계획수량 | NUMERIC(18,6) |  |
| ProducedQuantity | 생산수량 | NUMERIC(18,6) |  |
| DefectQuantity | 불량수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ScheduleStartDateTime | 계획시작일시 | TIMESTAMP |  |
| ScheduleEndDateTime | 계획종료일시 | TIMESTAMP |  |
| BatchStartDateTime | 배치시작일시 | TIMESTAMP |  |
| BatchEndDateTime | 배치종료일시 | TIMESTAMP |  |
| ManufactureDate | 제조일 | DATE |  |
| ValidEndDate | 유효종료일 | DATE |  |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |

## Line (라인) — 7.4.1.21 표 32
UK: EnterpriseID, LineID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| LineSequenceNo | 라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| LineID | 라인식별자 | VARCHAR(50) |  |
| LineName | 라인명 | VARCHAR(200) |  |
| LineDescription | 라인설명 | VARCHAR(1000) |  |
| LineType | 라인유형 | VARCHAR(30) | 코드:LineType |
| ProductionMethodType | 생산방식유형 | VARCHAR(30) | 코드:ProductionMethodType |
| ParentLineID | 상위라인식별자 | VARCHAR(50) | FK→Line.LineID |
| DepartmentInChargeID | 관리부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |
| PersonInChargeID | 관리자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CalendarID | 달력식별자 | VARCHAR(50) | FK→WorkCalendar.CalendarID |
| IssueWarehouseID | 출고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ReceiptWarehouseID | 입고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| StandardCapacity | 표준생산능력 | NUMERIC(18,6) |  |
| CapacityUOMCode | 생산능력단위코드 | VARCHAR(20) |  |
| StandardCycleTime | 표준사이클타임 | INTERVAL |  |
| ShiftCount | 작업조수 | INTEGER |  |
| StandardHeadcount | 표준작업인원 | INTEGER |  |
| Location | 위치 | VARCHAR(1000) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |
| ValidStartDate | 유효시작일 | DATE |  |
| ValidEndDate | 유효종료일 | DATE |  |

## Enterprise (회사) — 7.4.1.22 표 33
UK: EnterpriseID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| EnterpriseSequenceNo | 회사 일련번호 | BIGINT | PK |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| EnterpriseID | 회사식별자 | VARCHAR(50) |  |
| EnterpriseName | 회사명 | VARCHAR(200) |  |
| BusinessRegistrationNumber | 사업자등록번호 | VARCHAR(50) |  |
| CorporateRegistrationNumber | 법인등록번호 | VARCHAR(50) |  |
| RepresentativeName | 대표자명 | VARCHAR(200) |  |
| ParentEnterpriseID | 상위회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| CountryID | 국가식별자 | VARCHAR(30) | 코드:CountryID |
| BaseCurrencyCode | 기준통화코드 | VARCHAR(30) | 코드:CurrencyCode |
| DialNumber | 전화번호 | VARCHAR(30) |  |
| FaxNumber | 팩스번호 | VARCHAR(30) |  |
| PostalCode | 우편번호 | VARCHAR(10) |  |
| BaseAddress | 기본주소 | VARCHAR(1000) |  |
| DetailAddress | 상세주소 | VARCHAR(1000) |  |
| UseIndicator | 사용여부 | BOOLEAN |  |

## ProjectMaster (프로젝트마스터) — 7.4.2.1 표 34
UK: EnterpriseID, ProjectID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProjectMasterSequenceNo | 프로젝트마스터 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProjectID | 프로젝트식별자 | VARCHAR(50) |  |
| ProjectName | 프로젝트명 | VARCHAR(200) |  |
| ProjectStatusCode | 프로젝트상태코드 | VARCHAR(30) | 코드:ProjectStatusCode |
| ResponsibleDepartmentID | 프로젝트담당부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |
| PersonInChargeID | 프로젝트담당자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ProjectContractDate | 프로젝트계약일 | DATE |  |
| ExpectedStartDate | 시작예정일 | DATE |  |
| ExpectedEndDate | 종료예정일 | DATE |  |
| ActualStartDate | 실제시작일 | DATE |  |
| ActualEndDate | 실제종료일 | DATE |  |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderLine.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER | FK→SalesOrderLine.SalesDocumentSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| UseIndicator | 사용여부 | BOOLEAN |  |
| DivisionID | 사업부식별자 | VARCHAR(50) | FK→Department.DepartmentID |

## EngineeringChangeOrder (설계변경지시) — 7.4.2.2 표 35
UK: EnterpriseID, EngineeringChangeOrderID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| EngineeringChangeOrderSequenceNo | 설계변경지시 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| EngineeringChangeOrderID | 설계변경지시식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ValidStartDate | 유효시작일 | DATE |  |
| ValidEndDate | 유효종료일 | DATE |  |
| ExpectedExecutionDate | 적용예정일 | DATE |  |
| ExecutionDate | 적용이행일 | DATE |  |
| BOMType | 자재명세서유형 | VARCHAR(30) | 코드:BOMType |
| BOMID | 자재명세서식별자 | VARCHAR(50) | FK→BOMHeader.BOMID |
| BOMRevisionNumber | 자재명세서버전 | INTEGER | FK→BOMHeader.BOMRevisionNumber |
| ChildItemID | 자품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ActualRequirementQuantity | 실소요수량 | NUMERIC(18,6) |  |

## SalesOrderHeader (수주오더헤더) — 7.4.3.1 표 36
UK: EnterpriseID, SalesDocumentNumber

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SalesOrderHeaderSequenceNo | 수주오더헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) |  |
| SalesOrderType | 수주유형 | VARCHAR(30) | 코드:SalesOrderType |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| SalesDate | 수주일 | DATE |  |
| SalesStatus | 수주상태 | VARCHAR(30) | 코드:SalesStatus |
| ShipmentTermsCode | 출하조건코드 | VARCHAR(30) | 코드:ShipmentTermsCode |
| SalesTransactionType | 거래유형 | VARCHAR(30) | 코드:SalesTransactionType |
| ReturnIndicator | 반품여부 | BOOLEAN |  |
| ExportIndicator | 수출여부 | BOOLEAN |  |
| SalesAutomaticApprovalIndicator | 수주자동승인여부 | BOOLEAN |  |

## SalesOrderLine (수주오더라인) — 7.4.3.1 표 36
UK: EnterpriseID, SalesDocumentNumber, SalesDocumentSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SalesOrderLineSequenceNo | 수주오더라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderHeader.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| ItemQuantity | 품목수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| SellingUOMCode | 판매단위코드 | VARCHAR(20) |  |
| ConversionUnitQuantity | 단위환산수량 | NUMERIC(18,6) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| RequestedDeliveryDate | 요청납기일 | DATE |  |

## SalesPlan (판매계획) — 7.4.3.2 표 37
UK: EnterpriseID, SalesPlanID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SalesPlanSequenceNo | 판매계획 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| SalesPlanID | 판매계획식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| SalesProjection | 판매추정치 | NUMERIC(18,6) |  |
| ProjectionStartDate | 예측시작일 | DATE |  |
| ProjectionEndDate | 예측종료일 | DATE |  |

## BasePrice (기준가격) — 7.4.4.1 표 38
UK: EnterpriseID, ItemID, CurrencyCode

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| BasePriceSequenceNo | 기준가격 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| CurrencyCode | 환종코드 | VARCHAR(30) | 코드:CurrencyCode |
| UnitPrice | 단가 | NUMERIC(18,6) |  |
| PaymentTermsCode | 결제조건코드 | VARCHAR(30) | 코드:PaymentTermsCode |
| UseIndicator | 사용여부 | BOOLEAN |  |

## PurchaseRequisition (구매요청) — 7.4.4.2 표 39
UK: EnterpriseID, PurchaseRequisitionID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| PurchaseRequisitionSequenceNo | 구매요청 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PurchaseRequisitionID | 구매요청식별자 | VARCHAR(50) |  |
| PurchaseRequisitionRevisionNumber | 구매요청버전 | INTEGER |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| DemandQuantity | 구매요청수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| PurchaseRequisitionUnitPrice | 구매요청단가 | NUMERIC(18,6) |  |
| CurrencyCode | 환종코드 | VARCHAR(30) | 코드:CurrencyCode |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| VendorName | 공급사명 | VARCHAR(200) | FK→VendorPartyMaster.VendorName (사본) |
| RequestedDeliveryDate | 요청납기일 | DATE |  |
| RequesterDepartmentID | 구매요청부서 | VARCHAR(50) | FK→Department.DepartmentID |
| RequesterPersonnelID | 구매요청자 | VARCHAR(50) | FK→Personnel.PersonnelID |

## PurchaseOrderHeader (구매발주헤더) — 7.4.4.3 표 40
UK: EnterpriseID, PurchaseDocumentNumber

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| PurchaseOrderHeaderSequenceNo | 구매발주헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PurchaseDocumentNumber | 구매문서번호 | VARCHAR(50) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| PaymentTermsCode | 결제조건코드 | VARCHAR(30) | 코드:PaymentTermsCode |
| PurchaseGroupCode | 구매그룹코드 | VARCHAR(30) | 코드:PurchaseGroupCode |
| CurrencyCode | 환종코드 | VARCHAR(30) | 코드:CurrencyCode |
| ExchangeRate | 환율 | NUMERIC(18,6) |  |
| PurchaseApprovalDate | 승인일 | DATE |  |
| PurchaseOrderDate | 구매발주일 | DATE |  |
| PurchaseOrderTypeCode | 발주유형코드 | VARCHAR(30) | 코드:PurchaseOrderTypeCode |
| PurchaseTransactionType | 거래유형 | VARCHAR(30) | 코드:PurchaseTransactionType |
| PurchaseOrderStartDate | 시작일 | DATE |  |
| PurchaseOrderValidDate | 유효일 | DATE |  |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| PurchaseOrderClosingIndicator | 발주마감여부 | BOOLEAN |  |
| PurchaseOrderClosingDate | 발주마감일 | DATE |  |

## PurchaseOrderLine (구매발주라인) — 7.4.4.3 표 40
UK: EnterpriseID, PurchaseDocumentNumber, PurchaseDocumentSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| PurchaseOrderLineSequenceNo | 구매발주라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PurchaseDocumentNumber | 구매문서번호 | VARCHAR(50) | FK→PurchaseOrderHeader.PurchaseDocumentNumber |
| PurchaseDocumentSequence | 구매문서순번 | INTEGER |  |
| ItemPurchaseType | 구매라인유형 | VARCHAR(30) | 코드:ItemPurchaseType |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| PurchaseOrderLineStatusCode | 발주라인상태코드 | VARCHAR(30) | 코드:PurchaseOrderLineStatusCode |
| TaxCode | 세무코드 | VARCHAR(30) | 코드:TaxCode |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| PurchaseOrderUOMCode | 발주단위코드 | VARCHAR(20) |  |
| ConversionUnitQuantity | 단위환산수량 | NUMERIC(18,6) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| PurchaseOrderQuantity | 구매발주수량 | NUMERIC(18,6) |  |
| PurchaseGoodsReceiptQuantity | 구매입고수량 | NUMERIC(18,6) |  |
| PurchaseTransactionUnitPrice | 구매거래단가 | NUMERIC(18,6) |  |
| PurchaseTransactionPrice | 구매거래금액 | NUMERIC(18,6) |  |
| PurchaseOrderUnitPrice | 발주단가 | NUMERIC(18,6) |  |
| PurchaseOrderPrice | 발주금액 | NUMERIC(18,6) |  |
| VATPrice | 부가세금액 | NUMERIC(18,6) |  |
| ExpectedDeliveryDate | 납기예정일 | DATE |  |
| IncomingInspectionIndicator | 수입검사여부 | BOOLEAN | FK→ItemMaster.IncomingInspectionIndicator (사본) |
| AccountCode | 계정코드 | VARCHAR(30) | 코드:AccountCode |
| VATTransactionUnitPrice | 부가세포함거래단가 | NUMERIC(18,6) |  |
| VATTransactionPrice | 부가세포함거래금액 | NUMERIC(18,6) |  |
| VATCarryingAmount | 부가세포함장부금액 | NUMERIC(18,6) |  |

## MaterialArrival (자재도착) — 7.4.5.1 표 41
UK: EnterpriseID, PurchaseDocumentNumber, PurchaseDocumentSequence, LotID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| MaterialArrivalSequenceNo | 자재도착 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PurchaseDocumentNumber | 구매문서번호 | VARCHAR(50) | FK→PurchaseOrderLine.PurchaseDocumentNumber |
| PurchaseDocumentSequence | 구매문서순번 | INTEGER | FK→PurchaseOrderLine.PurchaseDocumentSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| PurchaseGoodsReceiptQuantity | 구매입고수량 | NUMERIC(18,6) |  |
| ReceiptWarehouseID | 입고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| GoodsReceiptDate | 입고처리일 | DATE |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ItemQuantity | 품목수량 | NUMERIC(18,6) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |

## GoodsReceipt (입고) — 7.4.5.2 표 42
UK: EnterpriseID, GoodsReceiptID, GoodsReceiptSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| GoodsReceiptSequenceNo | 입고 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| GoodsReceiptID | 입고식별자 | VARCHAR(50) |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| GoodsReceiptSequence | 입고순번 | INTEGER |  |
| GoodsReceiptType | 입고처리유형 | VARCHAR(30) | 코드:GoodsReceiptType |
| GoodsReceiptReturnType | 입고반품유형 | VARCHAR(30) | 코드:GoodsReceiptReturnType |
| GoodsReceiptDate | 입고처리일 | DATE |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| InventoryTransactionDocumentNumber | 수불문서번호 | VARCHAR(50) |  |
| InventoryTransactionDocumentSequence | 수불문서순번 | INTEGER |  |
| InventoryTransactionTypeCode | 수불유형코드 | VARCHAR(30) | 코드:InventoryTransactionTypeCode |
| InvoiceNumber | 송장번호 | VARCHAR(50) |  |
| InvoiceSequence | 송장라인순번 | INTEGER |  |
| InvoiceProcessingIndicator | 송장처리여부 | BOOLEAN |  |
| IncomingInspectionIndicator | 수입검사여부 | BOOLEAN | FK→ItemMaster.IncomingInspectionIndicator (사본) |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| PurchaseOrderUOMCode | 발주단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| GoodsReceiptQuantity | 입고처리수량 | NUMERIC(18,6) |  |
| IncomingInspectionAcceptedQuantity | 수입검사합격수량 | NUMERIC(18,6) |  |
| IncomingInspectionRejectedQuantity | 수입검사불합격수량 | NUMERIC(18,6) |  |
| PurchaseGroupCode | 구매그룹코드 | VARCHAR(30) | 코드:PurchaseGroupCode |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |

## GoodsIssue (자재불출) — 7.4.5.3 표 43
UK: EnterpriseID, GoodsIssueID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| GoodsIssueSequenceNo | 자재불출 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| GoodsIssueID | 자재불출식별자 | VARCHAR(50) |  |
| InventoryTransactionDocumentNumber | 수불문서번호 | VARCHAR(50) |  |
| InventoryTransactionDocumentSequence | 수불문서순번 | INTEGER |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| InventoryTransactionTypeCode | 수불유형코드 | VARCHAR(30) | 코드:InventoryTransactionTypeCode |
| InventoryTransferType | 입출고유형 | VARCHAR(30) | 코드:InventoryTransferType |
| InventoryVariationType | 재고증감유형 | VARCHAR(30) | 코드:InventoryVariationType |
| InventoryTransactionType | 수불유형 | VARCHAR(30) | 코드:InventoryTransactionType |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| SerialUseIndicator | 시리얼사용여부 | BOOLEAN |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| OrderUOMCode | 오더단위코드 | VARCHAR(20) |  |
| OrderQuantity | 오더수량 | NUMERIC(18,6) |  |

## ProductionPlanning (생산계획) — 7.4.6.1 표 44
UK: EnterpriseID, ProductionPlanID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPlanningSequenceNo | 생산계획 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPlanID | 생산계획식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ProductionPlanQuantity | 생산계획수량 | INTEGER |  |
| ScheduleStartDateTime | 생산계획시작일시 | TIMESTAMP |  |
| ScheduleEndDateTime | 생산계획종료일시 | TIMESTAMP |  |

## ProductionOrder (생산지시) — 7.4.6.2 표 45
UK: EnterpriseID, ProductionOrderID, ProductionOrderSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionOrderSequenceNo | 생산지시 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) |  |
| ProductionOrderSequence | 생산지시순번 | INTEGER |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| LineID | 라인식별자 | VARCHAR(50) | FK→Line.LineID |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingHeader.RoutingID |
| BOMID | 자재명세서식별자 | VARCHAR(50) | FK→BOMHeader.BOMID |
| BOMRevisionNumber | 자재명세서버전 | INTEGER | FK→BOMHeader.BOMRevisionNumber |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ProductionOrderQuantity | 생산지시수량 | INTEGER |  |
| ProductionDueDateTime | 생산완료기한일시 | TIMESTAMP |  |
| ScheduleStartDateTime | 생산계획시작일시 | TIMESTAMP |  |
| ScheduleEndDateTime | 생산계획종료일시 | TIMESTAMP |  |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderLine.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER | FK→SalesOrderLine.SalesDocumentSequence |

## OperationStart (착공) — 7.4.6.3 표 46
UK: EnterpriseID, OperationStartID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| OperationStartSequenceNo | 착공 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| OperationStartID | 착공식별자 | VARCHAR(50) |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| LotCreatedQuantity | 로트수량 | NUMERIC(18,6) | FK→Lot.LotCreatedQuantity (사본) |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| OperationStartTime | 착공시간 | TIMESTAMP |  |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |

## OperationEnd (완공) — 7.4.6.4 표 47
UK: EnterpriseID, OperationEndID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| OperationEndSequenceNo | 완공 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| OperationEndID | 완공식별자 | VARCHAR(50) |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| LotCreatedQuantity | 로트수량 | NUMERIC(18,6) | FK→Lot.LotCreatedQuantity (사본) |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| OperationEndTime | 완공시간 | TIMESTAMP |  |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ProducedQuantity | 생산수량 | NUMERIC(18,6) |  |
| DefectQuantity | 불량수량 | NUMERIC(18,6) |  |
| ReworkCount | 재작업횟수 | INTEGER |  |

## TransferCommand (이동지시) — 7.4.6.5 표 48
UK: EnterpriseID, TransferCommandID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| TransferCommandSequenceNo | 이동지시 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| TransferCommandID | 이동지시식별자 | VARCHAR(50) |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| SourceID | 출발지식별자 | VARCHAR(50) | FK→Operation / Equipment / StockerInventory / Carrier (다형) |
| SourceType | 출발지유형 | VARCHAR(30) | 코드:LocationType |
| SourceName | 출발지명 | VARCHAR(200) |  |
| DestinationID | 목적지식별자 | VARCHAR(50) | FK→Operation / Equipment / StockerInventory / Carrier (다형) |
| DestinationType | 목적지유형 | VARCHAR(30) | 코드:LocationType |
| DestinationName | 목적지명 | VARCHAR(200) |  |

## TransferStart (운행시작) — 7.4.6.6 표 49
UK: EnterpriseID, TransferStartID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| TransferStartSequenceNo | 운행시작 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| TransferStartID | 운행시작식별자 | VARCHAR(50) |  |
| TransferCommandID | 이동지시식별자 | VARCHAR(50) | FK→TransferCommand.TransferCommandID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| TransferStartDateTime | 운행시작일시 | TIMESTAMP |  |
| CurrentLocation | 현재위치 | VARCHAR(1000) |  |
| DestinationID | 목적지식별자 | VARCHAR(50) | FK→Operation / Equipment / StockerInventory / Carrier (다형) |
| DestinationType | 목적지유형 | VARCHAR(30) | 코드:LocationType |
| DestinationName | 목적지명 | VARCHAR(200) | FK→TransferCommand.DestinationName (사본) |
| ErrorCode | 오류코드 | VARCHAR(30) | 코드:TransferErrorCode |
| ErrorMessage | 오류메세지 | VARCHAR(1000) |  |

## TransferEnd (운행완료) — 7.4.6.7 표 50
UK: EnterpriseID, TransferEndID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| TransferEndSequenceNo | 운행완료 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| TransferEndID | 운행완료식별자 | VARCHAR(50) |  |
| TransferCommandID | 이동지시식별자 | VARCHAR(50) | FK→TransferCommand.TransferCommandID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| TransferEndDateTime | 운행완료일시 | TIMESTAMP |  |
| DestinationID | 목적지식별자 | VARCHAR(50) | FK→Operation / Equipment / StockerInventory / Carrier (다형) |
| DestinationType | 목적지유형 | VARCHAR(30) | 코드:LocationType |
| DestinationName | 목적지명 | VARCHAR(200) | FK→TransferCommand.DestinationName (사본) |

## InTransitLocation (운송위치) — 7.4.6.8 표 51
UK: EnterpriseID, InTransitLocationID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| InTransitLocationSequenceNo | 운송위치 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| InTransitLocationID | 운송위치식별자 | VARCHAR(50) |  |
| TransferCommandID | 이동지시식별자 | VARCHAR(50) | FK→TransferCommand.TransferCommandID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LotName | 로트명 | VARCHAR(200) | FK→Lot.LotName (사본) |
| LotDescription | 로트설명 | VARCHAR(1000) | FK→Lot.LotDescription (사본) |
| CarrierID | 캐리어식별자 | VARCHAR(50) | FK→Carrier.CarrierID |
| CurrentLocation | 현재위치 | VARCHAR(1000) |  |

## EquipmentState (설비상태) — 7.4.6.9 표 52
UK: EnterpriseID, EquipmentStateID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| EquipmentStateSequenceNo | 설비상태 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| EquipmentStateID | 설비상태식별자 | VARCHAR(50) |  |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| EquipmentState | 설비상태 | VARCHAR(30) | 코드:EquipmentState |
| EquipmentControlMode | 설비제어모드 | VARCHAR(30) | 코드:EquipmentControlMode |
| EquipmentOperationMode | 설비운영모드 | VARCHAR(30) | 코드:EquipmentOperationMode |
| ProcessedLotQuantity | 진행로트수량 | NUMERIC(18,6) |  |
| LastProcessedLotID | 최종진행로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| LastProcessedOperationID | 최종진행공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| ErrorCode | 오류코드 | VARCHAR(30) | 코드:EquipmentErrorCode |
| ErrorMessage | 오류메세지 | VARCHAR(1000) |  |

## Alarm (알람) — 7.4.6.10 표 53
UK: EnterpriseID, AlarmID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| AlarmSequenceNo | 알람 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| AlarmID | 알람식별자 | VARCHAR(50) |  |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| AlarmState | 알람상태 | VARCHAR(30) | 코드:AlarmState |
| ErrorCode | 오류코드 | VARCHAR(30) | 코드:EquipmentErrorCode |
| ErrorMessage | 오류메세지 | VARCHAR(1000) |  |
| EventDateTime | 이벤트발생일시 | TIMESTAMP |  |
| CurrentLocation | 현재위치 | VARCHAR(1000) |  |

## SupplierInspectionPlan (협력업체품질검사계획) — 7.4.6.11 표 54
UK: EnterpriseID, InspectionPlanID, InspectionID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SupplierInspectionPlanSequenceNo | 협력업체품질검사계획 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ProjectID | 프로젝트식별자 | VARCHAR(50) | FK→ProjectMaster.ProjectID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| PurchaseDocumentNumber | 구매문서번호 | VARCHAR(50) | FK→PurchaseOrderLine.PurchaseDocumentNumber |
| PurchaseDocumentSequence | 구매문서순번 | INTEGER | FK→PurchaseOrderLine.PurchaseDocumentSequence |
| PurchaseOrderQuantity | 구매발주수량 | NUMERIC(18,6) | FK→PurchaseOrderLine.PurchaseOrderQuantity (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| ExpectedDeliveryDate | 납기예정일 | DATE | FK→PurchaseOrderLine.ExpectedDeliveryDate (사본) |
| InspectionPlanID | 검사계획식별자 | VARCHAR(50) |  |
| InspectionID | 검사식별자 | VARCHAR(50) |  |
| InspectionName | 검사명 | VARCHAR(200) |  |
| Inspector | 검사자 | VARCHAR(255) |  |
| InspectionLocation | 검사위치 | VARCHAR(1000) |  |
| ExpectedInspectionDate | 검사예정일 | DATE |  |
| ExpectedInspectionTimePeriod | 검사예정기간 | INTEGER |  |
| InspectionMethod | 검사방법 | VARCHAR(30) | 코드:InspectionMethod |
| InspectionPlanQuantity | 검사계획수량 | NUMERIC(18,6) |  |
| InspectionCheckSheet | 검사체크시트 | VARCHAR(1000) |  |

## SupplierInspectionApplication (협력업체품질검사신청) — 7.4.6.12 표 55
UK: EnterpriseID, InspectionApplicationID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SupplierInspectionApplicationSequenceNo | 협력업체품질검사신청 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ProjectID | 프로젝트식별자 | VARCHAR(50) | FK→ProjectMaster.ProjectID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| PurchaseDocumentNumber | 구매문서번호 | VARCHAR(50) | FK→PurchaseOrderLine.PurchaseDocumentNumber |
| PurchaseDocumentSequence | 구매문서순번 | INTEGER | FK→PurchaseOrderLine.PurchaseDocumentSequence |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| InspectionPlanID | 검사계획식별자 | VARCHAR(50) | FK→SupplierInspectionPlan.InspectionPlanID |
| InspectionID | 검사식별자 | VARCHAR(50) | FK→SupplierInspectionPlan.InspectionID |
| InspectionApplicationID | 검사신청식별자 | VARCHAR(50) |  |
| ApplicationPersonnelID | 검사신청자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| InspectionName | 검사명 | VARCHAR(200) | FK→SupplierInspectionPlan.InspectionName (사본) |
| InspectionLocation | 검사위치 | VARCHAR(1000) | FK→SupplierInspectionPlan.InspectionLocation (사본) |
| InspectionMethod | 검사방법 | VARCHAR(30) | 코드:InspectionMethod |
| ExpectedInspectionDate | 검사예정일 | DATE | FK→SupplierInspectionPlan.ExpectedInspectionDate (사본) |
| InspectionDate | 검사일 | DATE |  |
| InspectionTimePeriod | 검사기간 | INTEGER |  |
| InspectionQuantity | 검사수량 | NUMERIC(18,6) |  |
| SelfCheckInspectionResultSheet | 자체점검결과시트 | VARCHAR(1000) |  |
| InspectionStatusCode | 검사상태코드 | VARCHAR(30) | 코드:InspectionStatusCode |
| ReasonForApplication | 검사신청사유 | VARCHAR(255) |  |
| InspectionCancelReason | 검사취소사유 | VARCHAR(1000) |  |

## SupplierInspectionResult (협력업체품질검사결과) — 7.4.6.13 표 56
UK: EnterpriseID, InspectionResultID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| SupplierInspectionResultSequenceNo | 협력업체품질검사결과 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ProjectID | 프로젝트식별자 | VARCHAR(50) | FK→ProjectMaster.ProjectID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| InspectionPlanID | 검사계획식별자 | VARCHAR(50) | FK→SupplierInspectionPlan.InspectionPlanID |
| InspectionID | 검사식별자 | VARCHAR(50) | FK→SupplierInspectionPlan.InspectionID |
| InspectionApplicationID | 검사신청식별자 | VARCHAR(50) | FK→SupplierInspectionApplication.InspectionApplicationID |
| InspectionResultID | 검사결과식별자 | VARCHAR(50) |  |
| Inspector | 검사자 | VARCHAR(255) |  |
| InspectionParticipant | 검사입회자 | VARCHAR(1000) |  |
| InspectionLocation | 검사위치 | VARCHAR(1000) | FK→SupplierInspectionApplication.InspectionLocation (사본) |
| InspectionDate | 검사일 | DATE |  |
| InspectionQuantity | 검사수량 | NUMERIC(18,6) | FK→SupplierInspectionApplication.InspectionQuantity (사본) |
| InspectionResult | 검사결과 | VARCHAR(30) | 코드:InspectionResult |
| InspectionResultSheet | 검사결과시트 | VARCHAR(1000) |  |
| InspectionStatusCode | 검사상태코드 | VARCHAR(30) | 코드:InspectionStatusCode |

## CorrectiveActionRequest (시정조치요청) — 7.4.6.14 표 57
UK: EnterpriseID, CorrectiveActionRequestID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CorrectiveActionRequestSequenceNo | 시정조치요청 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| InspectionApplicationID | 검사신청식별자 | VARCHAR(50) | FK→SupplierInspectionApplication.InspectionApplicationID |
| CorrectiveActionRequestID | 시정조치요청식별자 | VARCHAR(50) |  |
| CorrectiveActionRequestIssuerID | 시정조치요청발행자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CorrectiveActionRequestRecipientID | 시정조치요청접수자식별자 | VARCHAR(50) |  |
| CorrectiveActionRequestLocation | 시정조치요청위치 | VARCHAR(1000) |  |
| CorrectiveActionRequestDocumentReference | 시정조치요청첨부자료 | VARCHAR(255) |  |

## CorrectiveActionPlan (시정조치계획) — 7.4.6.15 표 58
UK: EnterpriseID, CorrectiveActionPlanID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CorrectiveActionPlanSequenceNo | 시정조치계획 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| CorrectiveActionRequestID | 시정조치요청식별자 | VARCHAR(50) | FK→CorrectiveActionRequest.CorrectiveActionRequestID |
| CorrectiveActionPlanID | 시정조치계획식별자 | VARCHAR(50) |  |
| PersonInChargeID | 시정조치담당자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| PersonInChargeEmail | 시정조치담당자이메일명 | VARCHAR(255) |  |
| PersonInChargeDialNumber | 시정조치담당자전화번호 | VARCHAR(30) |  |
| ExpectedCorrectiveActionDate | 시정조치예정일 | DATE |  |
| CorrectiveActionRequestDocumentReference | 시정조치요청첨부자료 | VARCHAR(255) |  |
| CorrectiveActionApprovalIndicator | 시정조치접수여부 | BOOLEAN |  |
| CorrectiveActionStatusCode | 시정조치상태코드 | VARCHAR(30) | 코드:CorrectiveActionStatusCode |
| ReasonForRejection | 반려사유 | VARCHAR(255) |  |

## CorrectiveActionResult (시정조치결과) — 7.4.6.16 표 59
UK: EnterpriseID, CorrectiveActionResultID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| CorrectiveActionResultSequenceNo | 시정조치결과 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| CorrectiveActionRequestID | 시정조치요청식별자 | VARCHAR(50) | FK→CorrectiveActionRequest.CorrectiveActionRequestID |
| CorrectiveActionPlanID | 시정조치계획식별자 | VARCHAR(50) | FK→CorrectiveActionPlan.CorrectiveActionPlanID |
| CorrectiveActionResultID | 시정조치결과식별자 | VARCHAR(50) |  |
| PersonInChargeID | 시정조치담당자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| PersonInChargeEmail | 시정조치담당자이메일명 | VARCHAR(255) |  |
| PersonInChargeDialNumber | 시정조치담당자전화번호 | VARCHAR(30) |  |
| CorrectiveActionConfirmorID | 시정조치확인자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CorrectiveActionConfirmorEmail | 시정조치확인자이메일명 | VARCHAR(255) |  |
| CorrectiveActionConfirmorDialNumber | 시정조치확인자전화번호 | VARCHAR(30) |  |
| CorrectiveActionDateTime | 시정조치일시 | TIMESTAMP |  |
| CorrectiveActionResultDescription | 시정조치결과내용 | VARCHAR(1000) |  |
| CorrectiveActionStatusCode | 시정조치상태코드 | VARCHAR(30) | 코드:CorrectiveActionStatusCode |
| ReasonForRejection | 반려사유 | VARCHAR(255) |  |

## ProductPacking (제품포장) — 7.4.6.17 표 60
UK: EnterpriseID, BoxNumber, PackingSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductPackingSequenceNo | 제품포장 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| PackingType | 포장유형 | VARCHAR(30) | 코드:PackingType |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| SerialNumber | 일련번호 | VARCHAR(50) |  |
| BoxNumber | 포장박스번호 | VARCHAR(50) |  |
| PalletNumber | 포장파렛트번호 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| PackingSequence | 포장순번 | INTEGER |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |

## EquipmentParameter (설비파라미터) — 7.4.6.18 표 61
UK: EnterpriseID, ParameterID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| EquipmentParameterSequenceNo | 설비파라미터 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ParameterID | 파라미터식별자 | VARCHAR(50) |  |
| ParameterName | 파라미터명 | VARCHAR(200) |  |
| ParameterType | 파라미터유형 | VARCHAR(30) | 코드:ParameterType |
| ParameterGrade | 파라미터등급 | VARCHAR(30) | 코드:ParameterGrade |
| ParameterUOMCode | 파라미터단위코드 | VARCHAR(20) |  |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| LSL | 규격하한 | NUMERIC(18,6) |  |
| USL | 규격상한 | NUMERIC(18,6) |  |
| PeriodicDataCollectionIndicator | 주기적수집여부 | BOOLEAN |  |
| DataCollectionPeriod | 수집주기 | INTERVAL |  |

## TraceParameter (설비파라미터이력) — 7.4.6.19 표 62
UK: EnterpriseID, TraceParameterID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| TraceParameterSequenceNo | 설비파라미터이력 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| TraceParameterID | 설비파라미터이력식별자 | VARCHAR(50) |  |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| ParameterID | 파라미터식별자 | VARCHAR(50) | FK→EquipmentParameter.ParameterID |
| EventDateTime | 이벤트발생일시 | TIMESTAMP |  |
| ParameterUOMCode | 파라미터단위코드 | VARCHAR(20) |  |
| ParameterValue | 파라미터값 | NUMERIC(18,6) |  |
| ValidationResultCode | 검증결과코드 | VARCHAR(30) | 코드:ValidationResultCode |

## ProductionPerformance (생산실적) — 7.4.6.20 표 63
UK: EnterpriseID, ProductionPerformanceID, ProductionPerformanceSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPerformanceSequenceNo | 생산실적 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPerformanceID | 생산실적식별자 | VARCHAR(50) |  |
| ProductionPerformanceSequence | 생산실적순번 | INTEGER |  |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ProducedQuantity | 생산수량 | NUMERIC(18,6) |  |
| DefectQuantity | 불량수량 | NUMERIC(18,6) |  |
| ReworkQuantity | 재작업수량 | INTEGER |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingLine.RoutingID |
| OperationSequence | 공정순번 | INTEGER | FK→RoutingLine.OperationSequence |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ProductionPerformanceDate | 생산실적일자 | DATE |  |
| ExecutionStartDateTime | 생산시작일시 | TIMESTAMP |  |
| ExecutionEndDateTime | 생산종료일시 | TIMESTAMP |  |
| CancelIndicator | 취소여부 | BOOLEAN |  |
| CancelDateTime | 취소일시 | TIMESTAMP |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |

## ProductionPerformanceItem (생산실적투입품목) — 7.4.6.21 표 64
UK: EnterpriseID, ProductionPerformanceID, ProductionPerformanceSequence, ItemID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPerformanceItemSequenceNo | 생산실적투입품목 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPerformanceID | 생산실적식별자 | VARCHAR(50) | FK→ProductionPerformance.ProductionPerformanceID |
| ProductionPerformanceSequence | 생산실적순번 | INTEGER | FK→ProductionPerformance.ProductionPerformanceSequence |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| LineID | 라인식별자 | VARCHAR(50) | FK→Line.LineID |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ReplacementChildItemID | 대체자재식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationLine.WarehouseID |
| WarehouseSection | 창고섹션 | VARCHAR(255) | FK→WarehouseLocationLine.WarehouseSection |
| RequiredQuantity | 소요수량 | INTEGER |  |
| IssuedQuantity | 출고수량 | INTEGER |  |
| IssuedIndicator | 출고완료여부 | BOOLEAN |  |

## ProductionPerformancePersonnel (생산실적투입인력) — 7.4.6.22 표 65
UK: EnterpriseID, ProductionPerformanceID, ProductionPerformanceSequence, PersonnelID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPerformancePersonnelSequenceNo | 생산실적투입인력 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPerformanceID | 생산실적식별자 | VARCHAR(50) | FK→ProductionPerformance.ProductionPerformanceID |
| ProductionPerformanceSequence | 생산실적순번 | INTEGER | FK→ProductionPerformance.ProductionPerformanceSequence |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ExecutionStartDateTime | 생산시작일시 | TIMESTAMP |  |
| ExecutionEndDateTime | 생산종료일시 | TIMESTAMP |  |
| TaskGroupCode | 근무조코드 | VARCHAR(30) | 코드:TaskGroupCode |
| ActualLaborDateTime | 투입일시 | TIMESTAMP |  |
| ActualLaborTime | 투입시간 | NUMERIC(18,6) |  |
| ActualLaborTimeUOMCode | 투입시간단위코드 | VARCHAR(20) |  |

## ProductionPerformanceEquipment (설비활용실적) — 7.4.6.23 표 66
UK: EnterpriseID, ProductionPerformanceID, ProductionPerformanceSequence, EquipmentID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPerformanceEquipmentSequenceNo | 설비활용실적 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPerformanceID | 생산실적식별자 | VARCHAR(50) | FK→ProductionPerformance.ProductionPerformanceID |
| ProductionPerformanceSequence | 생산실적순번 | INTEGER | FK→ProductionPerformance.ProductionPerformanceSequence |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ProducedQuantity | 생산수량 | NUMERIC(18,6) |  |
| DefectQuantity | 불량수량 | NUMERIC(18,6) |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingLine.RoutingID |
| OperationSequence | 공정순번 | INTEGER | FK→RoutingLine.OperationSequence |
| PersonnelID | 사원식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ExecutionStartDateTime | 생산시작일시 | TIMESTAMP |  |
| ExecutionEndDateTime | 생산종료일시 | TIMESTAMP |  |
| CancelIndicator | 취소여부 | BOOLEAN |  |
| CancelDateTime | 취소일시 | TIMESTAMP |  |
| EquipmentID | 설비식별자 | VARCHAR(50) | FK→Equipment.EquipmentID |
| SetupTime | 준비시간 | INTERVAL |  |
| RunTime | 가동시간 | INTERVAL |  |
| InspectionFinishedIndicator | 공정검사여부 | BOOLEAN |  |

## ProductionPerformanceQuality (생산품질실적) — 7.4.6.24 표 67
UK: EnterpriseID, ProductionPerformanceID, ProductionPerformanceSequence, DefectTypeCode, DefectTypeDetailCode

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductionPerformanceQualitySequenceNo | 생산품질실적 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductionPerformanceID | 생산실적식별자 | VARCHAR(50) | FK→ProductionPerformance.ProductionPerformanceID |
| ProductionPerformanceSequence | 생산실적순번 | INTEGER | FK→ProductionPerformance.ProductionPerformanceSequence |
| ProductionOrderID | 생산지시식별자 | VARCHAR(50) | FK→ProductionOrder.ProductionOrderID |
| ProductionOrderSequence | 생산지시순번 | INTEGER | FK→ProductionOrder.ProductionOrderSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| OperationID | 공정식별자 | VARCHAR(50) | FK→Operation.OperationID |
| RoutingID | 공정경로식별자 | VARCHAR(50) | FK→RoutingLine.RoutingID |
| OperationSequence | 공정순번 | INTEGER | FK→RoutingLine.OperationSequence |
| ExecutionStartDateTime | 생산시작일시 | TIMESTAMP |  |
| ExecutionEndDateTime | 생산종료일시 | TIMESTAMP |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| DefectTypeQuantity | 불량유형별수량 | INTEGER |  |
| DefectTypeCode | 불량유형코드 | VARCHAR(30) | 코드:DefectTypeCode |
| DefectTypeDetailCode | 불량유형상세코드 | VARCHAR(30) | 코드:DefectTypeDetailCode |

## Inventory (재고) — 7.4.7.1 표 68
UK: EnterpriseID, WarehouseID, ItemID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| InventorySequenceNo | 재고 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| InventoryQuantity | 현재고수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |

## AvailableInventory (가용재고) — 7.4.7.2 표 69
UK: EnterpriseID, AvailableInventoryID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| AvailableInventorySequenceNo | 가용재고 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| AvailableInventoryID | 가용재고식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| AvailableInventoryQuantity | 가용재고량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| DemandPriority | 요청우선순위 | NUMERIC(18,6) |  |
| PriorDemandQuantity | 요청우선수량 | NUMERIC(18,6) |  |
| ExpectedDeliveryDate | 납기예정일 | DATE |  |

## StockTransfer (재고이동) — 7.4.7.3 표 70
UK: EnterpriseID, StockTransferID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| StockTransferSequenceNo | 재고이동 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| StockTransferID | 재고이동식별자 | VARCHAR(50) |  |
| InventoryTransactionDocumentNumber | 수불문서번호 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ReceiptWarehouseID | 입고창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| StockTransferQuantity | 재고이동수량 | NUMERIC(18,6) |  |
| TransferDateTime | 이동일시 | TIMESTAMP |  |

## InventoryCount (재고실사) — 7.4.7.4 표 71
UK: EnterpriseID, InventoryCountDocumentNumber, WarehouseID, ItemID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| InventoryCountSequenceNo | 재고실사 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| InventoryCountDocumentNumber | 재고실사문서번호 | VARCHAR(50) |  |
| InventoryCountDateTime | 재고실사일시 | TIMESTAMP |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| InventoryQuantity | 현재고수량 | NUMERIC(18,6) |  |
| InventoryCountQuantity | 실사수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |

## ProductIncoming (제품입고) — 7.4.8.1 표 72
UK: EnterpriseID, ProductIncomingID, ProductIncomingSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductIncomingSequenceNo | 제품입고 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductIncomingID | 제품입고식별자 | VARCHAR(50) |  |
| ProductIncomingSequence | 제품입고순번 | INTEGER |  |
| InventoryTransactionDocumentNumber | 수불문서번호 | VARCHAR(50) |  |
| InventoryTransactionDocumentSequence | 수불문서순번 | INTEGER |  |
| InventoryTransactionDate | 수불일 | DATE |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| InventoryTransactionTypeCode | 수불유형코드 | VARCHAR(30) | 코드:InventoryTransactionTypeCode |
| SerialUseIndicator | 시리얼사용여부 | BOOLEAN |  |
| InventoryTransferType | 입출고유형 | VARCHAR(30) | 코드:InventoryTransferType |
| InventoryVariationType | 재고증감유형 | VARCHAR(30) | 코드:InventoryVariationType |
| InventoryTransactionType | 수불유형 | VARCHAR(30) | 코드:InventoryTransactionType |
| LotControlIndicator | 로트사용여부 | BOOLEAN | FK→ItemMaster.LotControlIndicator (사본) |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| OrderUOMCode | 오더단위코드 | VARCHAR(20) |  |
| OrderQuantity | 오더수량 | NUMERIC(18,6) |  |

## ProductReleaseRequestHeader (출하의뢰헤더) — 7.4.8.2 표 73
UK: EnterpriseID, ProductReleaseRequestID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductReleaseRequestHeaderSequenceNo | 출하의뢰헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductReleaseRequestID | 출하요청식별자 | VARCHAR(50) |  |
| ProductReleaseRequestDocumentNumber | 납품문서번호 | VARCHAR(50) |  |
| ProductReleaseRequestType | 납품구분유형 | VARCHAR(30) | 코드:ProductReleaseRequestType |
| ProductReleaseRequestDate | 납품지시일 | DATE |  |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |

## ProductReleaseRequestLine (출하의뢰라인) — 7.4.8.2 표 73
UK: EnterpriseID, ProductReleaseRequestID, ProductReleaseRequestSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductReleaseRequestLineSequenceNo | 출하의뢰라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductReleaseRequestID | 출하요청식별자 | VARCHAR(50) | FK→ProductReleaseRequestHeader.ProductReleaseRequestID |
| ProductReleaseRequestSequence | 납품순번 | INTEGER |  |
| LineID | 라인식별자 | VARCHAR(50) | FK→Line.LineID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| ProductReleaseRequestQuantity | 납품수량 | NUMERIC(18,6) |  |
| ProductReleaseQuantity | 출고수량 | NUMERIC(18,6) |  |
| SalesQuantity | 매출수량 | NUMERIC(18,6) |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| SellingUOMCode | 판매단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| ProductReleaseUnitQuantity | 기준출고수량 | NUMERIC(18,6) |  |
| SalesUnitQuantity | 기준매출수량 | NUMERIC(18,6) |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| RequestedDeliveryDate | 요청납기일 | DATE |  |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderLine.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER | FK→SalesOrderLine.SalesDocumentSequence |
| ProductReleaseDate | 출고일 | DATE |  |
| DeliveryDate | 납품일 | DATE |  |

## ProductRelease (제품출고) — 7.4.8.3 표 74
UK: EnterpriseID, ProductReleaseID, ProductReleaseSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductReleaseSequenceNo | 제품출고 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductReleaseID | 출고식별자 | VARCHAR(50) |  |
| ProductReleaseSequence | 출고순번 | INTEGER |  |
| ProductReleaseRequestID | 출하요청식별자 | VARCHAR(50) | FK→ProductReleaseRequestHeader.ProductReleaseRequestID |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderLine.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER | FK→SalesOrderLine.SalesDocumentSequence |
| InventoryTransactionDate | 수불일 | DATE |  |
| LineID | 라인식별자 | VARCHAR(50) | FK→Line.LineID |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| OrderUOMCode | 오더단위코드 | VARCHAR(20) |  |
| OrderQuantity | 오더수량 | NUMERIC(18,6) |  |
| SellingUOMCode | 판매단위코드 | VARCHAR(20) |  |
| SalesQuantity | 매출수량 | NUMERIC(18,6) |  |
| ReturnIndicator | 반품여부 | BOOLEAN |  |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| SalesUnitQuantity | 기준매출수량 | NUMERIC(18,6) |  |
| ReturnUnitQuantity | 기준반품수량 | NUMERIC(18,6) |  |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| SerialUseIndicator | 시리얼사용여부 | BOOLEAN |  |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |

## DeliveryHeader (배송헤더) — 7.4.8.4 표 75
UK: EnterpriseID, DeliveryID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| DeliveryHeaderSequenceNo | 배송헤더 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| DeliveryID | 배송식별자 | VARCHAR(50) |  |
| DeliveryDateTime | 배송일시 | TIMESTAMP |  |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| PackingList | 포장내용 | VARCHAR(1000) |  |
| PackingType | 포장유형 | VARCHAR(30) | 코드:PackingType |
| TransportationMethodCode | 운송방법 | VARCHAR(30) | 코드:TransportationMethodCode |
| DepartmentInChargeID | 배송처리담당부서식별자 | VARCHAR(50) | FK→Department.DepartmentID |
| DepartmentInChargeName | 배송처리담당부서명 | VARCHAR(200) | FK→Department.DepartmentName (사본) |
| PersonInChargeID | 배송처리담당자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| PersonInChargeName | 배송처리담당자명 | VARCHAR(200) | FK→Personnel.PersonnelName (사본) |
| PersonInChargeDialNumber | 배송처리담당자전화번호 | VARCHAR(30) | FK→Personnel.PersonInChargeDialNumber (사본) |
| TransportationCompany | 운송사 | VARCHAR(255) |  |
| PersonInChargeNameOfTransportation | 운송담당자명 | VARCHAR(255) |  |
| PersonInChargeDialNumberOfTransportation | 운송담당자전화번호 | VARCHAR(255) |  |
| Recipient | 수취인 | VARCHAR(255) |  |
| RecipientDialNumber | 수취인전화번호 | VARCHAR(30) |  |
| RecipientEmail | 수취인이메일 | VARCHAR(255) |  |
| ShippingPoint | 선적지 | VARCHAR(255) |  |
| ShipToAddress | 배송지 | VARCHAR(1000) |  |
| PreferredReceiptDate | 인수희망일 | DATE |  |
| DeliveryNote | 배송메모 | VARCHAR(1000) |  |
| DeliveryConfirmationDocument | 납품확인서 | VARCHAR(255) |  |

## DeliveryLine (배송라인) — 7.4.8.4 표 75
UK: EnterpriseID, DeliveryID, DeliveryLineSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| DeliveryLineSequenceNo | 배송라인 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| DeliveryID | 배송식별자 | VARCHAR(50) | FK→DeliveryHeader.DeliveryID |
| DeliveryLineSequence | 배송라인순번 | INTEGER |  |
| ProductReleaseID | 출고식별자 | VARCHAR(50) | FK→ProductRelease.ProductReleaseID |
| ProductReleaseSequence | 출고순번 | INTEGER | FK→ProductRelease.ProductReleaseSequence |
| SalesDocumentNumber | 수주문서번호 | VARCHAR(50) | FK→SalesOrderLine.SalesDocumentNumber |
| SalesDocumentSequence | 수주문서순번 | INTEGER | FK→SalesOrderLine.SalesDocumentSequence |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| InvoiceNumber | 거래명세서번호 | VARCHAR(50) |  |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| ItemUOMCode | 기준단위코드 | VARCHAR(20) |  |
| ItemUnitQuantity | 기준단위수량 | NUMERIC(18,6) |  |
| OrderUOMCode | 오더단위코드 | VARCHAR(20) |  |
| OrderQuantity | 오더수량 | NUMERIC(18,6) |  |
| ProductDeliveryUOMCode | 납품단위코드 | VARCHAR(20) |  |
| ProductDeliveryQuantity | 납품수량 | NUMERIC(18,6) |  |
| RequestedDeliveryDate | 요청납품일 | DATE | FK→SalesOrderLine.RequestedDeliveryDate (사본) |

## Return (반품) — 7.4.9.1 표 76
UK: EnterpriseID, ReturnID, ReturnSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ReturnSequenceNo | 반품 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ReturnID | 반품식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| LotID | 로트식별자 | VARCHAR(50) | FK→Lot.LotID |
| BatchID | 배치식별자 | VARCHAR(50) | FK→Batch.BatchID |
| WarehouseID | 창고식별자 | VARCHAR(50) | FK→WarehouseLocationHeader.WarehouseID |
| ReturnSequence | 반품순서 | INTEGER |  |
| ReturnNumber | 반품번호 | VARCHAR(50) |  |
| ProductReturnDocumentNumber | 반품문서번호 | VARCHAR(50) |  |
| ReturnDateTime | 반품일시 | TIMESTAMP |  |
| CustomerID | 고객사식별자 | VARCHAR(50) | FK→CustomerPartyMaster.CustomerID |
| VendorID | 공급사식별자 | VARCHAR(50) | FK→VendorPartyMaster.VendorID |
| ReturnQuantity | 반품수량 | NUMERIC(18,6) |  |
| ReturnType | 반품유형 | VARCHAR(30) | 코드:ReturnType |

## ProductTraceParameterOnCustomer (고객제품데이터) — 7.4.9.2 표 77
UK: EnterpriseID, ProductTraceParameterOnCustomerID

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| ProductTraceParameterOnCustomerSequenceNo | 고객제품데이터 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ProductTraceParameterOnCustomerID | 고객제품데이터식별자 | VARCHAR(50) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| SerialNumber | 제조번호 | VARCHAR(50) | FK→고객 설치 제품(제조번호 단위) |
| Location | 위치 | VARCHAR(1000) |  |
| ItemType | 품목유형 | VARCHAR(30) | 코드:ItemType |
| ParameterName | 파라미터명 | VARCHAR(200) |  |
| ParameterValue | 파라미터값 | NUMERIC(18,6) |  |
| CollectionDateTime | 수집일시 | TIMESTAMP |  |

## AfterSalesServiceRequest (사후서비스신청) — 7.4.9.3 표 78
UK: EnterpriseID, RequestNumber

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| AfterSalesServiceRequestSequenceNo | 사후서비스신청 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| RequestNumber | 신청번호 | VARCHAR(50) |  |
| TransferSequence | 이관순번 | INTEGER |  |
| BasicAcceptProcessCode | 접수내용단순처리코드 | VARCHAR(30) | 코드:BasicAcceptProcessCode |
| PromisedVisitDateTime | 약속방문일시 | TIMESTAMP |  |
| TransferRegistrationCode | 이관등록코드 | VARCHAR(30) | 코드:TransferRegistrationCode |
| SerialNumber | 제조번호 | VARCHAR(50) | FK→고객 설치 제품(제조번호 단위) |

## AfterSalesServiceRequestResult (사후서비스결과) — 7.4.9.4 표 79
UK: EnterpriseID, RequestNumber, TransferSequence, RegisterSequence, RepairSequence

| 컬럼 | 국문 | 타입 | 비고 |
|---|---|---|---|
| AfterSalesServiceRequestResultSequenceNo | 사후서비스결과 일련번호 | BIGINT | PK |
| EnterpriseID | 회사식별자 | VARCHAR(50) | FK→Enterprise.EnterpriseID |
| SiteID | 사업장식별자 | VARCHAR(50) | FK→Site.SiteID |
| PlantID | 공장식별자 | VARCHAR(50) | FK→Plant.PlantID |
| CreatorID | 등록자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| CreationDateTime | 등록일시 | TIMESTAMP |  |
| ModifierID | 수정자식별자 | VARCHAR(50) | FK→Personnel.PersonnelID |
| ModificationDateTime | 수정일시 | TIMESTAMP |  |
| Note | 비고 | VARCHAR(1000) |  |
| ItemID | 품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ItemName | 품목명 | VARCHAR(200) | FK→ItemMaster.ItemName (사본) |
| RequestNumber | 신청번호 | VARCHAR(50) | FK→AfterSalesServiceRequest.RequestNumber |
| TransferSequence | 이관순번 | INTEGER |  |
| RegisterSequence | 등록순번 | INTEGER |  |
| RepairSequence | 수리순번 | INTEGER |  |
| SerialNumber | 제조번호 | VARCHAR(50) | FK→고객 설치 제품(제조번호 단위) |
| FaultLargeClass | 하자현상대분류 | VARCHAR(30) | 코드:FaultLargeClass |
| FaultSmallClass | 하자현상소분류 | VARCHAR(30) | 코드:FaultSmallClass |
| ErrorCode | 오류코드 | VARCHAR(30) | 코드:ServiceErrorCode |
| InstallationDate | 설치일 | DATE |  |
| ProcessingDate | 처리일 | DATE |  |
| EndIndicator | 종료여부 | BOOLEAN |  |
| WorkType | 작업유형 | VARCHAR(30) | 코드:WorkType |
| ChildItemID | 자품목식별자 | VARCHAR(50) | FK→ItemMaster.ItemID |
| ChildItemName | 자품목명 | VARCHAR(200) |  |
| ItemSpecification | 품목사양 | VARCHAR(1000) | FK→ItemMaster.ItemSpecification (사본) |
| RepairType | 수리유형 | VARCHAR(30) | 코드:RepairType |
