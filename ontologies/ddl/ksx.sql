-- KS X 9101-1 v1.0 표준 원장 DDL (ksxgen 생성물, 직접 수정 금지)
CREATE SCHEMA IF NOT EXISTS ksx;

CREATE TABLE ksx."Site" (
  "SiteSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "SiteID" VARCHAR(50) NOT NULL,
  "SiteName" VARCHAR(200),
  "BusinessRegistrationNumber" VARCHAR(50),
  "DialNumber" VARCHAR(30),
  "PostalCode" VARCHAR(10),
  "BaseAddress" VARCHAR(1000),
  "DetailAddress" VARCHAR(1000),
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_Site" UNIQUE ("EnterpriseID", "SiteID")
);
COMMENT ON TABLE ksx."Site" IS '사업장 — 회사 내 하위 관리단위로서의 사업장을 의미한다.';
COMMENT ON COLUMN ksx."Site"."SiteSequenceNo" IS '사업장 일련번호';
COMMENT ON COLUMN ksx."Site"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Site"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Site"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Site"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Site"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Site"."Note" IS '비고';
COMMENT ON COLUMN ksx."Site"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Site"."SiteName" IS '사업장명';
COMMENT ON COLUMN ksx."Site"."BusinessRegistrationNumber" IS '사업자등록번호';
COMMENT ON COLUMN ksx."Site"."DialNumber" IS '전화번호';
COMMENT ON COLUMN ksx."Site"."PostalCode" IS '우편번호';
COMMENT ON COLUMN ksx."Site"."BaseAddress" IS '기본주소';
COMMENT ON COLUMN ksx."Site"."DetailAddress" IS '상세주소';
COMMENT ON COLUMN ksx."Site"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."Plant" (
  "PlantSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PlantID" VARCHAR(50) NOT NULL,
  "PlantName" VARCHAR(200),
  "DialNumber" VARCHAR(30),
  "CountryID" VARCHAR(30),
  "PostalCode" VARCHAR(10),
  "BaseAddress" VARCHAR(1000),
  "DetailAddress" VARCHAR(1000),
  CONSTRAINT "UK_Plant" UNIQUE ("EnterpriseID", "PlantID")
);
COMMENT ON TABLE ksx."Plant" IS '공장 — 회사 내 하위 관리단위로서의 공장을 의미한다.';
COMMENT ON COLUMN ksx."Plant"."PlantSequenceNo" IS '공장 일련번호';
COMMENT ON COLUMN ksx."Plant"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Plant"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Plant"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Plant"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Plant"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Plant"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Plant"."Note" IS '비고';
COMMENT ON COLUMN ksx."Plant"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Plant"."PlantName" IS '공장명';
COMMENT ON COLUMN ksx."Plant"."DialNumber" IS '전화번호';
COMMENT ON COLUMN ksx."Plant"."CountryID" IS '국가식별자';
COMMENT ON COLUMN ksx."Plant"."PostalCode" IS '우편번호';
COMMENT ON COLUMN ksx."Plant"."BaseAddress" IS '기본주소';
COMMENT ON COLUMN ksx."Plant"."DetailAddress" IS '상세주소';

CREATE TABLE ksx."Department" (
  "DepartmentSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "DepartmentID" VARCHAR(50) NOT NULL,
  "DepartmentName" VARCHAR(200),
  "ParentDepartmentID" VARCHAR(50),
  CONSTRAINT "UK_Department" UNIQUE ("EnterpriseID", "DepartmentID")
);
COMMENT ON TABLE ksx."Department" IS '부서 — 회사 내 하위 관리 단위로서의 부서를 의미한다.';
COMMENT ON COLUMN ksx."Department"."DepartmentSequenceNo" IS '부서 일련번호';
COMMENT ON COLUMN ksx."Department"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Department"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Department"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Department"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Department"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Department"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Department"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Department"."Note" IS '비고';
COMMENT ON COLUMN ksx."Department"."DepartmentID" IS '부서식별자';
COMMENT ON COLUMN ksx."Department"."DepartmentName" IS '부서명';
COMMENT ON COLUMN ksx."Department"."ParentDepartmentID" IS '상위부서식별자';

CREATE TABLE ksx."Personnel" (
  "PersonnelSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PersonnelID" VARCHAR(50) NOT NULL,
  "PersonnelName" VARCHAR(200),
  "DepartmentID" VARCHAR(50),
  "EmploymentStatusType" VARCHAR(30),
  "PersonInChargeEmail" VARCHAR(255),
  "PersonInChargeDialNumber" VARCHAR(30),
  CONSTRAINT "UK_Personnel" UNIQUE ("EnterpriseID", "PersonnelID")
);
COMMENT ON TABLE ksx."Personnel" IS '사원 — 사원코드, 사원명, 인적정보 등을 관리하는 사원 마스터를 의미한다. 일반적으로 HRMS(Human Resource Management System)에서 사용되지만 작업 스케줄링 또는 자원 할당에서 사용될 수도 있다.';
COMMENT ON COLUMN ksx."Personnel"."PersonnelSequenceNo" IS '사원 일련번호';
COMMENT ON COLUMN ksx."Personnel"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Personnel"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Personnel"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Personnel"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Personnel"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Personnel"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Personnel"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Personnel"."Note" IS '비고';
COMMENT ON COLUMN ksx."Personnel"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."Personnel"."PersonnelName" IS '사원명';
COMMENT ON COLUMN ksx."Personnel"."DepartmentID" IS '부서식별자';
COMMENT ON COLUMN ksx."Personnel"."EmploymentStatusType" IS '재직유형';
COMMENT ON COLUMN ksx."Personnel"."PersonInChargeEmail" IS '담당자이메일명';
COMMENT ON COLUMN ksx."Personnel"."PersonInChargeDialNumber" IS '담당자전화번호';

CREATE TABLE ksx."CustomerPartyMaster" (
  "CustomerPartyMasterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "CustomerID" VARCHAR(50) NOT NULL,
  "CustomerName" VARCHAR(200),
  "BusinessRegistrationNumber" VARCHAR(50),
  "RepresentativeName" VARCHAR(200),
  "CountryID" VARCHAR(30),
  "PostalCode" VARCHAR(10),
  "BaseAddress" VARCHAR(1000),
  "DetailAddress" VARCHAR(1000),
  "DialNumber" VARCHAR(30),
  "FaxNumber" VARCHAR(30),
  "UseIndicator" BOOLEAN,
  "PersonInChargeName" VARCHAR(200),
  "PersonInChargeEmail" VARCHAR(255),
  "PersonInChargeDialNumber" VARCHAR(30),
  CONSTRAINT "UK_CustomerPartyMaster" UNIQUE ("EnterpriseID", "CustomerID")
);
COMMENT ON TABLE ksx."CustomerPartyMaster" IS '고객사 — 고객사 코드, 고객사명, 사업자등록번호 등 고객사 정보를 관리하는 고객사 마스터를 의미한다.';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CustomerPartyMasterSequenceNo" IS '고객사 일련번호';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."Note" IS '비고';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CustomerName" IS '고객사명';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."BusinessRegistrationNumber" IS '사업자등록번호';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."RepresentativeName" IS '대표자명';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."CountryID" IS '국가식별자';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."PostalCode" IS '우편번호';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."BaseAddress" IS '기본주소';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."DetailAddress" IS '상세주소';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."DialNumber" IS '전화번호';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."FaxNumber" IS '팩스번호';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."PersonInChargeName" IS '담당자명';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."PersonInChargeEmail" IS '담당자이메일명';
COMMENT ON COLUMN ksx."CustomerPartyMaster"."PersonInChargeDialNumber" IS '담당자전화번호';

CREATE TABLE ksx."VendorPartyMaster" (
  "VendorPartyMasterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50) NOT NULL,
  "VendorName" VARCHAR(200),
  "BusinessRegistrationNumber" VARCHAR(50),
  "RepresentativeName" VARCHAR(200),
  "CountryID" VARCHAR(30),
  "PostalCode" VARCHAR(10),
  "BaseAddress" VARCHAR(1000),
  "DetailAddress" VARCHAR(1000),
  "DialNumber" VARCHAR(30),
  "FaxNumber" VARCHAR(30),
  "UseIndicator" BOOLEAN,
  "PersonInChargeName" VARCHAR(200),
  "PersonInChargeEmail" VARCHAR(255),
  "PersonInChargeDialNumber" VARCHAR(30),
  CONSTRAINT "UK_VendorPartyMaster" UNIQUE ("EnterpriseID", "VendorID")
);
COMMENT ON TABLE ksx."VendorPartyMaster" IS '공급사 — 공급사 코드, 공급사명, 사업자등록번호 등 공급사 정보를 관리하는 공급사 마스터를 의미한다.';
COMMENT ON COLUMN ksx."VendorPartyMaster"."VendorPartyMasterSequenceNo" IS '공급사 일련번호';
COMMENT ON COLUMN ksx."VendorPartyMaster"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."VendorPartyMaster"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."VendorPartyMaster"."Note" IS '비고';
COMMENT ON COLUMN ksx."VendorPartyMaster"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."VendorName" IS '공급사명';
COMMENT ON COLUMN ksx."VendorPartyMaster"."BusinessRegistrationNumber" IS '사업자등록번호';
COMMENT ON COLUMN ksx."VendorPartyMaster"."RepresentativeName" IS '대표자명';
COMMENT ON COLUMN ksx."VendorPartyMaster"."CountryID" IS '국가식별자';
COMMENT ON COLUMN ksx."VendorPartyMaster"."PostalCode" IS '우편번호';
COMMENT ON COLUMN ksx."VendorPartyMaster"."BaseAddress" IS '기본주소';
COMMENT ON COLUMN ksx."VendorPartyMaster"."DetailAddress" IS '상세주소';
COMMENT ON COLUMN ksx."VendorPartyMaster"."DialNumber" IS '전화번호';
COMMENT ON COLUMN ksx."VendorPartyMaster"."FaxNumber" IS '팩스번호';
COMMENT ON COLUMN ksx."VendorPartyMaster"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."VendorPartyMaster"."PersonInChargeName" IS '담당자명';
COMMENT ON COLUMN ksx."VendorPartyMaster"."PersonInChargeEmail" IS '담당자이메일명';
COMMENT ON COLUMN ksx."VendorPartyMaster"."PersonInChargeDialNumber" IS '담당자전화번호';

CREATE TABLE ksx."CommonCodeMaster" (
  "CommonCodeMasterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "CommonCodeID" VARCHAR(50) NOT NULL,
  "CommonCodeName" VARCHAR(200),
  "CommonCodeGroup" VARCHAR(30) NOT NULL,
  "ParentCommonCodeGroup" VARCHAR(50),
  "ParentCommonCodeID" VARCHAR(50),
  "CommonCodeSequence" INTEGER,
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_CommonCodeMaster" UNIQUE ("EnterpriseID", "CommonCodeGroup", "CommonCodeID")
);
COMMENT ON TABLE ksx."CommonCodeMaster" IS '공통코드정보 — 애플리케이션 내에서 사용되는 각종 코드를 모아 놓은 통합 코드를 의미한다.';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CommonCodeMasterSequenceNo" IS '공통코드정보 일련번호';
COMMENT ON COLUMN ksx."CommonCodeMaster"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."CommonCodeMaster"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."CommonCodeMaster"."Note" IS '비고';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CommonCodeID" IS '공통코드식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CommonCodeName" IS '공통코드명';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CommonCodeGroup" IS '공통코드그룹';
COMMENT ON COLUMN ksx."CommonCodeMaster"."ParentCommonCodeGroup" IS '상위공통코드그룹';
COMMENT ON COLUMN ksx."CommonCodeMaster"."ParentCommonCodeID" IS '상위공통코드식별자';
COMMENT ON COLUMN ksx."CommonCodeMaster"."CommonCodeSequence" IS '표시순번';
COMMENT ON COLUMN ksx."CommonCodeMaster"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."WorkCalendar" (
  "WorkCalendarSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "CalendarID" VARCHAR(50) NOT NULL,
  "CalendarType" VARCHAR(30),
  "CalendarDate" DATE,
  "DayOfWeek" VARCHAR(30),
  "WeekOfYear" INTEGER,
  "DayOfYear" INTEGER,
  "ScheduleType" VARCHAR(30),
  CONSTRAINT "UK_WorkCalendar" UNIQUE ("EnterpriseID", "CalendarID")
);
COMMENT ON TABLE ksx."WorkCalendar" IS '달력 — 생산 현장의 달력을 의미한다. 단, 인사에서 사용하는 일반 달력과는 차이가 있다.';
COMMENT ON COLUMN ksx."WorkCalendar"."WorkCalendarSequenceNo" IS '달력 일련번호';
COMMENT ON COLUMN ksx."WorkCalendar"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."WorkCalendar"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."WorkCalendar"."Note" IS '비고';
COMMENT ON COLUMN ksx."WorkCalendar"."CalendarID" IS '달력식별자';
COMMENT ON COLUMN ksx."WorkCalendar"."CalendarType" IS '달력유형';
COMMENT ON COLUMN ksx."WorkCalendar"."CalendarDate" IS '달력일자';
COMMENT ON COLUMN ksx."WorkCalendar"."DayOfWeek" IS '요일';
COMMENT ON COLUMN ksx."WorkCalendar"."WeekOfYear" IS '주수';
COMMENT ON COLUMN ksx."WorkCalendar"."DayOfYear" IS '총누계일수';
COMMENT ON COLUMN ksx."WorkCalendar"."ScheduleType" IS '근무일유형';

CREATE TABLE ksx."UOMGroupHeader" (
  "UOMGroupHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "UOMGroupID" VARCHAR(50) NOT NULL,
  "UOMGroupName" VARCHAR(200),
  CONSTRAINT "UK_UOMGroupHeader" UNIQUE ("EnterpriseID", "UOMGroupID")
);
COMMENT ON TABLE ksx."UOMGroupHeader" IS '단위그룹헤더 — 단위그룹(UOMGroup) 명사의 헤더 구조체(struct) 단위그룹 1건의 공통 정보(중량, 부피, 길이 등 측정 단위의 그룹) 단위그룹마다 1회 나타남';
COMMENT ON COLUMN ksx."UOMGroupHeader"."UOMGroupHeaderSequenceNo" IS '단위그룹헤더 일련번호';
COMMENT ON COLUMN ksx."UOMGroupHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."UOMGroupHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."UOMGroupHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."UOMGroupHeader"."UOMGroupID" IS '단위그룹식별자';
COMMENT ON COLUMN ksx."UOMGroupHeader"."UOMGroupName" IS '단위그룹명';

CREATE TABLE ksx."UOMGroupLine" (
  "UOMGroupLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "UOMGroupID" VARCHAR(50) NOT NULL,
  "UOMCode" VARCHAR(20) NOT NULL,
  "UOMCodeName" VARCHAR(200),
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_UOMGroupLine" UNIQUE ("EnterpriseID", "UOMGroupID", "UOMCode")
);
COMMENT ON TABLE ksx."UOMGroupLine" IS '단위그룹라인 — 단위그룹(UOMGroup) 명사의 라인 구조체(struct[1..N]) 단위그룹에 속하는 단위코드 행 정보 단위그룹헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."UOMGroupLine"."UOMGroupLineSequenceNo" IS '단위그룹라인 일련번호';
COMMENT ON COLUMN ksx."UOMGroupLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."UOMGroupLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."UOMGroupLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."UOMGroupLine"."UOMGroupID" IS '단위그룹식별자';
COMMENT ON COLUMN ksx."UOMGroupLine"."UOMCode" IS '단위코드';
COMMENT ON COLUMN ksx."UOMGroupLine"."UOMCodeName" IS '단위코드명';
COMMENT ON COLUMN ksx."UOMGroupLine"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."ItemMaster" (
  "ItemMasterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ItemID" VARCHAR(50) NOT NULL,
  "ItemName" VARCHAR(200),
  "ItemType" VARCHAR(30),
  "PhantomIndicator" BOOLEAN,
  "ItemLargeClass" VARCHAR(30),
  "ItemMediumClass" VARCHAR(30),
  "ItemSmallClass" VARCHAR(30),
  "ModelName" VARCHAR(200),
  "ItemSpecification" VARCHAR(1000),
  "ItemDetailSpecification" VARCHAR(1000),
  "UseIndicator" BOOLEAN,
  "CountryOfOrigin" VARCHAR(255),
  "PlaceOfOrigin" VARCHAR(255),
  "ItemUOMCode" VARCHAR(20),
  "Weight" NUMERIC(18,6),
  "NetWeight" NUMERIC(18,6),
  "WeightUOMCode" VARCHAR(20),
  "Volume" NUMERIC(18,6),
  "VolumeUOMCode" VARCHAR(20),
  "Length" NUMERIC(18,6),
  "Width" NUMERIC(18,6),
  "Height" NUMERIC(18,6),
  "DimensionUOMCode" VARCHAR(20),
  "ValidEndDate" DATE,
  "DrawingNumber" VARCHAR(50),
  "LotControlIndicator" BOOLEAN,
  "PurchaseLeadTime" INTERVAL,
  "ProductionLeadTime" INTERVAL,
  "LotSize" NUMERIC(18,6),
  "MainCustomerID" VARCHAR(50),
  "MainVendorID" VARCHAR(50),
  "SafetyStock" NUMERIC(18,6),
  "MaximumStockLevel" NUMERIC(18,6),
  "ReceiptWarehouseID" VARCHAR(50),
  "IssueWarehouseID" VARCHAR(50),
  "ABCClass" VARCHAR(30),
  "ReplacementItemID" VARCHAR(50),
  "IncomingInspectionIndicator" BOOLEAN,
  "FinalInspectionIndicator" BOOLEAN,
  "OutgoingInspectionIndicator" BOOLEAN,
  CONSTRAINT "UK_ItemMaster" UNIQUE ("EnterpriseID", "ItemID")
);
COMMENT ON TABLE ksx."ItemMaster" IS '품목마스터 — 품목코드, 품목명, 규격 등과 각종 속성값을 관리하는 품목마스터를 의미한다. 단, 수량정보는 포함하지 않는다.';
COMMENT ON COLUMN ksx."ItemMaster"."ItemMasterSequenceNo" IS '품목마스터 일련번호';
COMMENT ON COLUMN ksx."ItemMaster"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ItemMaster"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ItemMaster"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ItemMaster"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ItemMaster"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ItemMaster"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ItemMaster"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ItemMaster"."Note" IS '비고';
COMMENT ON COLUMN ksx."ItemMaster"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ItemMaster"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."ItemMaster"."ItemType" IS '품목유형';
COMMENT ON COLUMN ksx."ItemMaster"."PhantomIndicator" IS '가상품목여부';
COMMENT ON COLUMN ksx."ItemMaster"."ItemLargeClass" IS '품목대분류';
COMMENT ON COLUMN ksx."ItemMaster"."ItemMediumClass" IS '품목중분류';
COMMENT ON COLUMN ksx."ItemMaster"."ItemSmallClass" IS '품목소분류';
COMMENT ON COLUMN ksx."ItemMaster"."ModelName" IS '모델명';
COMMENT ON COLUMN ksx."ItemMaster"."ItemSpecification" IS '품목사양';
COMMENT ON COLUMN ksx."ItemMaster"."ItemDetailSpecification" IS '품목상세사양';
COMMENT ON COLUMN ksx."ItemMaster"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."ItemMaster"."CountryOfOrigin" IS '원산국가';
COMMENT ON COLUMN ksx."ItemMaster"."PlaceOfOrigin" IS '원산지역';
COMMENT ON COLUMN ksx."ItemMaster"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ItemMaster"."Weight" IS '중량';
COMMENT ON COLUMN ksx."ItemMaster"."NetWeight" IS '순중량';
COMMENT ON COLUMN ksx."ItemMaster"."WeightUOMCode" IS '중량단위코드';
COMMENT ON COLUMN ksx."ItemMaster"."Volume" IS '부피';
COMMENT ON COLUMN ksx."ItemMaster"."VolumeUOMCode" IS '부피단위코드';
COMMENT ON COLUMN ksx."ItemMaster"."Length" IS '길이';
COMMENT ON COLUMN ksx."ItemMaster"."Width" IS '너비';
COMMENT ON COLUMN ksx."ItemMaster"."Height" IS '높이';
COMMENT ON COLUMN ksx."ItemMaster"."DimensionUOMCode" IS '치수단위코드';
COMMENT ON COLUMN ksx."ItemMaster"."ValidEndDate" IS '유효종료일';
COMMENT ON COLUMN ksx."ItemMaster"."DrawingNumber" IS '도면번호';
COMMENT ON COLUMN ksx."ItemMaster"."LotControlIndicator" IS '로트사용여부';
COMMENT ON COLUMN ksx."ItemMaster"."PurchaseLeadTime" IS '구매리드타임';
COMMENT ON COLUMN ksx."ItemMaster"."ProductionLeadTime" IS '생산리드타임';
COMMENT ON COLUMN ksx."ItemMaster"."LotSize" IS '로트사이즈';
COMMENT ON COLUMN ksx."ItemMaster"."MainCustomerID" IS '주요 고객사식별자';
COMMENT ON COLUMN ksx."ItemMaster"."MainVendorID" IS '주요 공급사식별자';
COMMENT ON COLUMN ksx."ItemMaster"."SafetyStock" IS '안전재고';
COMMENT ON COLUMN ksx."ItemMaster"."MaximumStockLevel" IS '최대재고수준';
COMMENT ON COLUMN ksx."ItemMaster"."ReceiptWarehouseID" IS '입고창고식별자';
COMMENT ON COLUMN ksx."ItemMaster"."IssueWarehouseID" IS '출고창고식별자';
COMMENT ON COLUMN ksx."ItemMaster"."ABCClass" IS '에이비씨분류';
COMMENT ON COLUMN ksx."ItemMaster"."ReplacementItemID" IS '대체품목식별자';
COMMENT ON COLUMN ksx."ItemMaster"."IncomingInspectionIndicator" IS '수입검사여부';
COMMENT ON COLUMN ksx."ItemMaster"."FinalInspectionIndicator" IS '생산입고(최종)검사여부';
COMMENT ON COLUMN ksx."ItemMaster"."OutgoingInspectionIndicator" IS '출하검사여부';

CREATE TABLE ksx."BOMHeader" (
  "BOMHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "BOMID" VARCHAR(50) NOT NULL,
  "BOMRevisionNumber" INTEGER NOT NULL,
  "BOMType" VARCHAR(30),
  "ItemID" VARCHAR(50),
  "BOMQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "RoutingID" VARCHAR(50),
  CONSTRAINT "UK_BOMHeader" UNIQUE ("EnterpriseID", "BOMID", "BOMRevisionNumber")
);
COMMENT ON TABLE ksx."BOMHeader" IS '자재명세서헤더 — 자재명세서(BOM) 명사의 헤더 구조체(struct) 자재명세서 1건의 공통 정보(모품목, 버전, 유형, 공정경로) 자재명세서마다 1회 나타남';
COMMENT ON COLUMN ksx."BOMHeader"."BOMHeaderSequenceNo" IS '자재명세서헤더 일련번호';
COMMENT ON COLUMN ksx."BOMHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."BOMHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."BOMHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."BOMHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."BOMHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."BOMHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."BOMHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."BOMHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."BOMHeader"."BOMID" IS '자재명세서식별자';
COMMENT ON COLUMN ksx."BOMHeader"."BOMRevisionNumber" IS '자재명세서버전';
COMMENT ON COLUMN ksx."BOMHeader"."BOMType" IS '자재명세서유형';
COMMENT ON COLUMN ksx."BOMHeader"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."BOMHeader"."BOMQuantity" IS '품목기준수량';
COMMENT ON COLUMN ksx."BOMHeader"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."BOMHeader"."RoutingID" IS '공정경로식별자';

CREATE TABLE ksx."BOMLine" (
  "BOMLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "BOMID" VARCHAR(50) NOT NULL,
  "BOMRevisionNumber" INTEGER NOT NULL,
  "BOMLineSequence" INTEGER NOT NULL,
  "ChildItemID" VARCHAR(50),
  "ChildItemUOMCode" VARCHAR(20),
  "ActualRequirementQuantity" NUMERIC(18,6),
  "OperationSequence" INTEGER,
  "BackFlushedIndicator" BOOLEAN,
  "ValidStartDateTime" TIMESTAMP,
  "ValidEndDateTime" TIMESTAMP,
  CONSTRAINT "UK_BOMLine" UNIQUE ("EnterpriseID", "BOMID", "BOMRevisionNumber", "BOMLineSequence")
);
COMMENT ON TABLE ksx."BOMLine" IS '자재명세서라인 — 자재명세서(BOM) 명사의 라인 구조체(struct[1..N]) 자재명세서를 구성하는 자품목 행 정보 자재명세서헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."BOMLine"."BOMLineSequenceNo" IS '자재명세서라인 일련번호';
COMMENT ON COLUMN ksx."BOMLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."BOMLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."BOMLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."BOMLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."BOMLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."BOMLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."BOMLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."BOMLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."BOMLine"."BOMID" IS '자재명세서식별자';
COMMENT ON COLUMN ksx."BOMLine"."BOMRevisionNumber" IS '자재명세서버전';
COMMENT ON COLUMN ksx."BOMLine"."BOMLineSequence" IS '자재명세서라인순번';
COMMENT ON COLUMN ksx."BOMLine"."ChildItemID" IS '자품목식별자';
COMMENT ON COLUMN ksx."BOMLine"."ChildItemUOMCode" IS '자품목기준단위코드';
COMMENT ON COLUMN ksx."BOMLine"."ActualRequirementQuantity" IS '실소요수량';
COMMENT ON COLUMN ksx."BOMLine"."OperationSequence" IS '공정순번';
COMMENT ON COLUMN ksx."BOMLine"."BackFlushedIndicator" IS '백플러시여부';
COMMENT ON COLUMN ksx."BOMLine"."ValidStartDateTime" IS '유효시작일시';
COMMENT ON COLUMN ksx."BOMLine"."ValidEndDateTime" IS '유효종료일시';

CREATE TABLE ksx."Lot" (
  "LotSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "LotID" VARCHAR(50) NOT NULL,
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "ParentLotID" VARCHAR(50),
  "ChildLotID" VARCHAR(50),
  "LotType" VARCHAR(30),
  "ItemID" VARCHAR(50),
  "CarrierID" VARCHAR(50),
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "ScheduledDueDate" DATE,
  "LotPriority" INTEGER,
  "CurrentOperationID" VARCHAR(50),
  "NextOperationID" VARCHAR(50),
  "LotState" VARCHAR(30),
  "HoldIndicator" BOOLEAN,
  "HotIndicator" BOOLEAN,
  "ReworkIndicator" BOOLEAN,
  "LotCreatedQuantity" NUMERIC(18,6),
  "ProducedQuantity" NUMERIC(18,6),
  "DefectQuantity" NUMERIC(18,6),
  "ReworkQuantity" INTEGER,
  "ReworkCount" INTEGER,
  "TotalReworkCount" INTEGER,
  "LotStartedDateTime" TIMESTAMP,
  "PersonnelID" VARCHAR(50),
  CONSTRAINT "UK_Lot" UNIQUE ("EnterpriseID", "LotID")
);
COMMENT ON TABLE ksx."Lot" IS '로트 — 묶음 생산 단위의 정보를 의미한다.';
COMMENT ON COLUMN ksx."Lot"."LotSequenceNo" IS '로트 일련번호';
COMMENT ON COLUMN ksx."Lot"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Lot"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Lot"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Lot"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Lot"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Lot"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Lot"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Lot"."Note" IS '비고';
COMMENT ON COLUMN ksx."Lot"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."Lot"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."Lot"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."Lot"."ParentLotID" IS '모로트식별자';
COMMENT ON COLUMN ksx."Lot"."ChildLotID" IS '자로트식별자';
COMMENT ON COLUMN ksx."Lot"."LotType" IS '로트유형';
COMMENT ON COLUMN ksx."Lot"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."Lot"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."Lot"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."Lot"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."Lot"."ScheduledDueDate" IS '생산마감기한';
COMMENT ON COLUMN ksx."Lot"."LotPriority" IS '로트우선순위';
COMMENT ON COLUMN ksx."Lot"."CurrentOperationID" IS '현재공정식별자';
COMMENT ON COLUMN ksx."Lot"."NextOperationID" IS '다음공정식별자';
COMMENT ON COLUMN ksx."Lot"."LotState" IS '로트상태';
COMMENT ON COLUMN ksx."Lot"."HoldIndicator" IS '보류여부';
COMMENT ON COLUMN ksx."Lot"."HotIndicator" IS '긴급여부';
COMMENT ON COLUMN ksx."Lot"."ReworkIndicator" IS '재작업여부';
COMMENT ON COLUMN ksx."Lot"."LotCreatedQuantity" IS '로트수량';
COMMENT ON COLUMN ksx."Lot"."ProducedQuantity" IS '생산수량';
COMMENT ON COLUMN ksx."Lot"."DefectQuantity" IS '불량수량';
COMMENT ON COLUMN ksx."Lot"."ReworkQuantity" IS '재작업수량';
COMMENT ON COLUMN ksx."Lot"."ReworkCount" IS '재작업횟수';
COMMENT ON COLUMN ksx."Lot"."TotalReworkCount" IS '총재작업횟수';
COMMENT ON COLUMN ksx."Lot"."LotStartedDateTime" IS '공정투입일시';
COMMENT ON COLUMN ksx."Lot"."PersonnelID" IS '사원식별자';

CREATE TABLE ksx."RoutingHeader" (
  "RoutingHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "RoutingID" VARCHAR(50) NOT NULL,
  "RoutingName" VARCHAR(200),
  "ItemID" VARCHAR(50),
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_RoutingHeader" UNIQUE ("EnterpriseID", "RoutingID")
);
COMMENT ON TABLE ksx."RoutingHeader" IS '공정경로헤더 — 공정경로(Routing) 명사의 헤더 구조체(struct) 공정경로 1건의 공통 정보(공정경로명, 대상 품목, 사용 여부) 공정경로마다 1회 나타남';
COMMENT ON COLUMN ksx."RoutingHeader"."RoutingHeaderSequenceNo" IS '공정경로헤더 일련번호';
COMMENT ON COLUMN ksx."RoutingHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."RoutingHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."RoutingHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."RoutingHeader"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."RoutingName" IS '공정경로명';
COMMENT ON COLUMN ksx."RoutingHeader"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."RoutingHeader"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."RoutingLine" (
  "RoutingLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "RoutingID" VARCHAR(50) NOT NULL,
  "OperationSequence" INTEGER NOT NULL,
  "OperationID" VARCHAR(50),
  "LastOperationIndicator" BOOLEAN,
  "SetupTime" INTERVAL,
  "RunTime" INTERVAL,
  "MoveTime" INTERVAL,
  CONSTRAINT "UK_RoutingLine" UNIQUE ("EnterpriseID", "RoutingID", "OperationSequence")
);
COMMENT ON TABLE ksx."RoutingLine" IS '공정경로라인 — 공정경로(Routing) 명사의 라인 구조체(struct[1..N]) 공정경로를 구성하는 공정 행 정보 공정경로헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."RoutingLine"."RoutingLineSequenceNo" IS '공정경로라인 일련번호';
COMMENT ON COLUMN ksx."RoutingLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."RoutingLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."RoutingLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."RoutingLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."RoutingLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."RoutingLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."RoutingLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."RoutingLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."RoutingLine"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."RoutingLine"."OperationSequence" IS '공정순번';
COMMENT ON COLUMN ksx."RoutingLine"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."RoutingLine"."LastOperationIndicator" IS '최종공정여부';
COMMENT ON COLUMN ksx."RoutingLine"."SetupTime" IS '준비시간';
COMMENT ON COLUMN ksx."RoutingLine"."RunTime" IS '작업시간';
COMMENT ON COLUMN ksx."RoutingLine"."MoveTime" IS '이동시간';

CREATE TABLE ksx."Operation" (
  "OperationSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "OperationID" VARCHAR(50) NOT NULL,
  "OperationName" VARCHAR(200),
  "OperationType" VARCHAR(30),
  "UseIndicator" BOOLEAN,
  "OperationLargeClass" VARCHAR(30),
  "OperationMediumClass" VARCHAR(30),
  "OperationSmallClass" VARCHAR(30),
  "BackFlushedIndicator" BOOLEAN,
  CONSTRAINT "UK_Operation" UNIQUE ("EnterpriseID", "OperationID")
);
COMMENT ON TABLE ksx."Operation" IS '공정 — 생산작업을 수행하는 작업장 또는 작업장 내 세부 작업단위를 의미한다.';
COMMENT ON COLUMN ksx."Operation"."OperationSequenceNo" IS '공정 일련번호';
COMMENT ON COLUMN ksx."Operation"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Operation"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Operation"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Operation"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Operation"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Operation"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Operation"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Operation"."Note" IS '비고';
COMMENT ON COLUMN ksx."Operation"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."Operation"."OperationName" IS '공정명';
COMMENT ON COLUMN ksx."Operation"."OperationType" IS '공정유형';
COMMENT ON COLUMN ksx."Operation"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."Operation"."OperationLargeClass" IS '공정대분류';
COMMENT ON COLUMN ksx."Operation"."OperationMediumClass" IS '공정중분류';
COMMENT ON COLUMN ksx."Operation"."OperationSmallClass" IS '공정소분류';
COMMENT ON COLUMN ksx."Operation"."BackFlushedIndicator" IS '백플러시여부';

CREATE TABLE ksx."Equipment" (
  "EquipmentSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "EquipmentID" VARCHAR(50) NOT NULL,
  "EquipmentName" VARCHAR(200),
  "ParentEquipmentID" VARCHAR(50),
  "EquipmentType" VARCHAR(30),
  "EquipmentLargeClass" VARCHAR(30),
  "EquipmentMediumClass" VARCHAR(30),
  "EquipmentSmallClass" VARCHAR(30),
  "DepartmentInChargeID" VARCHAR(50),
  "PersonInChargeID" VARCHAR(50),
  "OperationID" VARCHAR(50),
  "UseIndicator" BOOLEAN,
  "DAQDevice" VARCHAR(255),
  "FixedAssetID" VARCHAR(50),
  "ModelNumber" VARCHAR(50),
  "SerialNumber" VARCHAR(50),
  "CountryOfOrigin" VARCHAR(255),
  "Manufacturer" VARCHAR(255),
  "AcquisitionDate" DATE,
  "Location" VARCHAR(1000),
  CONSTRAINT "UK_Equipment" UNIQUE ("EnterpriseID", "EquipmentID")
);
COMMENT ON TABLE ksx."Equipment" IS '설비 — 설비명, 설비유형 등 설비 관리 및 회사의 자산으로서 관리를 위한 설비정보를 의미한다.';
COMMENT ON COLUMN ksx."Equipment"."EquipmentSequenceNo" IS '설비 일련번호';
COMMENT ON COLUMN ksx."Equipment"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Equipment"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Equipment"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Equipment"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Equipment"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Equipment"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Equipment"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Equipment"."Note" IS '비고';
COMMENT ON COLUMN ksx."Equipment"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."Equipment"."EquipmentName" IS '설비명';
COMMENT ON COLUMN ksx."Equipment"."ParentEquipmentID" IS '상위설비식별자';
COMMENT ON COLUMN ksx."Equipment"."EquipmentType" IS '설비유형';
COMMENT ON COLUMN ksx."Equipment"."EquipmentLargeClass" IS '설비대분류';
COMMENT ON COLUMN ksx."Equipment"."EquipmentMediumClass" IS '설비중분류';
COMMENT ON COLUMN ksx."Equipment"."EquipmentSmallClass" IS '설비소분류';
COMMENT ON COLUMN ksx."Equipment"."DepartmentInChargeID" IS '관리부서식별자';
COMMENT ON COLUMN ksx."Equipment"."PersonInChargeID" IS '관리자식별자';
COMMENT ON COLUMN ksx."Equipment"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."Equipment"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."Equipment"."DAQDevice" IS '데이터수집장치';
COMMENT ON COLUMN ksx."Equipment"."FixedAssetID" IS '고정자산식별자';
COMMENT ON COLUMN ksx."Equipment"."ModelNumber" IS '모델번호';
COMMENT ON COLUMN ksx."Equipment"."SerialNumber" IS '일련번호';
COMMENT ON COLUMN ksx."Equipment"."CountryOfOrigin" IS '제조국가';
COMMENT ON COLUMN ksx."Equipment"."Manufacturer" IS '제조업체';
COMMENT ON COLUMN ksx."Equipment"."AcquisitionDate" IS '취득일';
COMMENT ON COLUMN ksx."Equipment"."Location" IS '위치';

CREATE TABLE ksx."OperationEquipment" (
  "OperationEquipmentSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "OperationID" VARCHAR(50) NOT NULL,
  "OperationName" VARCHAR(200),
  "EquipmentID" VARCHAR(50) NOT NULL,
  "EquipmentName" VARCHAR(200),
  "EquipmentSmallClass" VARCHAR(30),
  "EquipmentQuantity" INTEGER,
  CONSTRAINT "UK_OperationEquipment" UNIQUE ("EnterpriseID", "OperationID", "EquipmentID")
);
COMMENT ON TABLE ksx."OperationEquipment" IS '공정설비 — 공정별 사용되는 설비 정보 데이터를 의미한다.';
COMMENT ON COLUMN ksx."OperationEquipment"."OperationEquipmentSequenceNo" IS '공정설비 일련번호';
COMMENT ON COLUMN ksx."OperationEquipment"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."OperationEquipment"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."OperationEquipment"."Note" IS '비고';
COMMENT ON COLUMN ksx."OperationEquipment"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."OperationName" IS '공정명';
COMMENT ON COLUMN ksx."OperationEquipment"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."OperationEquipment"."EquipmentName" IS '설비명';
COMMENT ON COLUMN ksx."OperationEquipment"."EquipmentSmallClass" IS '설비소분류';
COMMENT ON COLUMN ksx."OperationEquipment"."EquipmentQuantity" IS '기준사용대수';

CREATE TABLE ksx."Carrier" (
  "CarrierSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "CarrierID" VARCHAR(50) NOT NULL,
  "CarrierType" VARCHAR(30),
  "ItemType" VARCHAR(30),
  "LoadState" VARCHAR(30),
  "CarrierState" VARCHAR(30),
  "CurrentQuantity" NUMERIC(18,6),
  CONSTRAINT "UK_Carrier" UNIQUE ("EnterpriseID", "CarrierID")
);
COMMENT ON TABLE ksx."Carrier" IS '캐리어 — 제조 공정 내 이동에 필요한 물리적 용기를 의미한다.';
COMMENT ON COLUMN ksx."Carrier"."CarrierSequenceNo" IS '캐리어 일련번호';
COMMENT ON COLUMN ksx."Carrier"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Carrier"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Carrier"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Carrier"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Carrier"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Carrier"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Carrier"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Carrier"."Note" IS '비고';
COMMENT ON COLUMN ksx."Carrier"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."Carrier"."CarrierType" IS '캐리어유형';
COMMENT ON COLUMN ksx."Carrier"."ItemType" IS '품목유형';
COMMENT ON COLUMN ksx."Carrier"."LoadState" IS '적재상태';
COMMENT ON COLUMN ksx."Carrier"."CarrierState" IS '캐리어상태';
COMMENT ON COLUMN ksx."Carrier"."CurrentQuantity" IS '적재수량';

CREATE TABLE ksx."StockerInventory" (
  "StockerInventorySequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "StockerID" VARCHAR(50) NOT NULL,
  "ZoneID" VARCHAR(50),
  "FullCapacity" INTEGER,
  "CurrentCapacity" INTEGER,
  "LotID" VARCHAR(50),
  "CarrierID" VARCHAR(50),
  "AlternateStockerID" VARCHAR(50),
  CONSTRAINT "UK_StockerInventory" UNIQUE ("EnterpriseID", "StockerID")
);
COMMENT ON TABLE ksx."StockerInventory" IS '저장소재공정보 — 공장 내 공정 물류 저장소 정보를 의미한다. 이는 공정 내 물류 최적화를 위해 Lot Dispatcher를 사용하는데 SCS(StockerControlSystem), Dispatcher, MES 상호연동을 위해 존재한다.';
COMMENT ON COLUMN ksx."StockerInventory"."StockerInventorySequenceNo" IS '저장소재공정보 일련번호';
COMMENT ON COLUMN ksx."StockerInventory"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."StockerInventory"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."StockerInventory"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."StockerInventory"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."StockerInventory"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."StockerInventory"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."StockerInventory"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."StockerInventory"."Note" IS '비고';
COMMENT ON COLUMN ksx."StockerInventory"."StockerID" IS '저장소식별자';
COMMENT ON COLUMN ksx."StockerInventory"."ZoneID" IS '구역식별자';
COMMENT ON COLUMN ksx."StockerInventory"."FullCapacity" IS '최대용량';
COMMENT ON COLUMN ksx."StockerInventory"."CurrentCapacity" IS '현재용량';
COMMENT ON COLUMN ksx."StockerInventory"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."StockerInventory"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."StockerInventory"."AlternateStockerID" IS '대체저장소식별자';

CREATE TABLE ksx."WarehouseLocationHeader" (
  "WarehouseLocationHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "WarehouseID" VARCHAR(50) NOT NULL,
  "WarehouseName" VARCHAR(200),
  "WarehouseType" VARCHAR(30),
  "UseIndicator" BOOLEAN,
  "NegativeInventoryIndicator" BOOLEAN,
  CONSTRAINT "UK_WarehouseLocationHeader" UNIQUE ("EnterpriseID", "WarehouseID")
);
COMMENT ON TABLE ksx."WarehouseLocationHeader" IS '창고헤더 — 창고(WarehouseLocation) 명사의 헤더 구조체(struct) 창고 1건의 공통 정보(창고명, 창고유형, 재고 관리 기준) 창고마다 1회 나타남';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."WarehouseLocationHeaderSequenceNo" IS '창고헤더 일련번호';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."WarehouseName" IS '창고명';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."WarehouseType" IS '창고유형';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."WarehouseLocationHeader"."NegativeInventoryIndicator" IS '음수재고허용여부';

CREATE TABLE ksx."WarehouseLocationLine" (
  "WarehouseLocationLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "WarehouseID" VARCHAR(50) NOT NULL,
  "WarehouseSection" VARCHAR(255) NOT NULL,
  "WarehouseSectionName" VARCHAR(200),
  CONSTRAINT "UK_WarehouseLocationLine" UNIQUE ("EnterpriseID", "WarehouseID", "WarehouseSection")
);
COMMENT ON TABLE ksx."WarehouseLocationLine" IS '창고라인 — 창고(WarehouseLocation) 명사의 라인 구조체(struct[1..N]) 창고 내 저장 섹션 행 정보 창고헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."WarehouseLocationLineSequenceNo" IS '창고라인 일련번호';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."WarehouseSection" IS '창고섹션';
COMMENT ON COLUMN ksx."WarehouseLocationLine"."WarehouseSectionName" IS '창고섹션명';

CREATE TABLE ksx."Batch" (
  "BatchSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "BatchID" VARCHAR(50) NOT NULL,
  "BatchName" VARCHAR(200),
  "BatchDescription" VARCHAR(1000),
  "BatchType" VARCHAR(30),
  "ParentBatchID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "BOMID" VARCHAR(50),
  "BOMRevisionNumber" INTEGER,
  "RecipeID" VARCHAR(50),
  "RecipeVersion" VARCHAR(255),
  "OperationID" VARCHAR(50),
  "EquipmentID" VARCHAR(50),
  "BatchState" VARCHAR(30),
  "HoldIndicator" BOOLEAN,
  "ReworkIndicator" BOOLEAN,
  "QualityDispositionCode" VARCHAR(30),
  "BatchPlannedQuantity" NUMERIC(18,6),
  "ProducedQuantity" NUMERIC(18,6),
  "DefectQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "ScheduleStartDateTime" TIMESTAMP,
  "ScheduleEndDateTime" TIMESTAMP,
  "BatchStartDateTime" TIMESTAMP,
  "BatchEndDateTime" TIMESTAMP,
  "ManufactureDate" DATE,
  "ValidEndDate" DATE,
  "PersonnelID" VARCHAR(50),
  CONSTRAINT "UK_Batch" UNIQUE ("EnterpriseID", "BatchID")
);
COMMENT ON TABLE ksx."Batch" IS '배치 — 배치 공정의 1회 실행으로 생산되고 있거나 생산된 물질의 단위를 의미한다. 원료를 정해진 양만큼 투입하여 일괄 처리하는 공정(배합, 반응, 발효, 열처리 등)의 생산 단위이며, 공급사에서 생산하여 납품한 구매품의 배치를 포함한다.';
COMMENT ON COLUMN ksx."Batch"."BatchSequenceNo" IS '배치 일련번호';
COMMENT ON COLUMN ksx."Batch"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Batch"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Batch"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Batch"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Batch"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Batch"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Batch"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Batch"."Note" IS '비고';
COMMENT ON COLUMN ksx."Batch"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."Batch"."BatchName" IS '배치명';
COMMENT ON COLUMN ksx."Batch"."BatchDescription" IS '배치설명';
COMMENT ON COLUMN ksx."Batch"."BatchType" IS '배치유형';
COMMENT ON COLUMN ksx."Batch"."ParentBatchID" IS '모배치식별자';
COMMENT ON COLUMN ksx."Batch"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."Batch"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."Batch"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."Batch"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."Batch"."BOMID" IS '자재명세서식별자';
COMMENT ON COLUMN ksx."Batch"."BOMRevisionNumber" IS '자재명세서버전';
COMMENT ON COLUMN ksx."Batch"."RecipeID" IS '레시피식별자';
COMMENT ON COLUMN ksx."Batch"."RecipeVersion" IS '레시피버전';
COMMENT ON COLUMN ksx."Batch"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."Batch"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."Batch"."BatchState" IS '배치상태';
COMMENT ON COLUMN ksx."Batch"."HoldIndicator" IS '보류여부';
COMMENT ON COLUMN ksx."Batch"."ReworkIndicator" IS '재작업여부';
COMMENT ON COLUMN ksx."Batch"."QualityDispositionCode" IS '품질판정코드';
COMMENT ON COLUMN ksx."Batch"."BatchPlannedQuantity" IS '배치계획수량';
COMMENT ON COLUMN ksx."Batch"."ProducedQuantity" IS '생산수량';
COMMENT ON COLUMN ksx."Batch"."DefectQuantity" IS '불량수량';
COMMENT ON COLUMN ksx."Batch"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."Batch"."ScheduleStartDateTime" IS '계획시작일시';
COMMENT ON COLUMN ksx."Batch"."ScheduleEndDateTime" IS '계획종료일시';
COMMENT ON COLUMN ksx."Batch"."BatchStartDateTime" IS '배치시작일시';
COMMENT ON COLUMN ksx."Batch"."BatchEndDateTime" IS '배치종료일시';
COMMENT ON COLUMN ksx."Batch"."ManufactureDate" IS '제조일';
COMMENT ON COLUMN ksx."Batch"."ValidEndDate" IS '유효종료일';
COMMENT ON COLUMN ksx."Batch"."PersonnelID" IS '사원식별자';

CREATE TABLE ksx."Line" (
  "LineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "LineID" VARCHAR(50) NOT NULL,
  "LineName" VARCHAR(200),
  "LineDescription" VARCHAR(1000),
  "LineType" VARCHAR(30),
  "ProductionMethodType" VARCHAR(30),
  "ParentLineID" VARCHAR(50),
  "DepartmentInChargeID" VARCHAR(50),
  "PersonInChargeID" VARCHAR(50),
  "CalendarID" VARCHAR(50),
  "IssueWarehouseID" VARCHAR(50),
  "ReceiptWarehouseID" VARCHAR(50),
  "StandardCapacity" NUMERIC(18,6),
  "CapacityUOMCode" VARCHAR(20),
  "StandardCycleTime" INTERVAL,
  "ShiftCount" INTEGER,
  "StandardHeadcount" INTEGER,
  "Location" VARCHAR(1000),
  "UseIndicator" BOOLEAN,
  "ValidStartDate" DATE,
  "ValidEndDate" DATE,
  CONSTRAINT "UK_Line" UNIQUE ("EnterpriseID", "LineID")
);
COMMENT ON TABLE ksx."Line" IS '라인 — 같은 공장 안에서 공정과 설비를 일정한 흐름으로 배치하여 특정 품목 또는 품목군을 생산하는 생산 단위를 의미한다. 라인은 공장에 속하며, 하나 이상의 공정과 설비로 구성된다.';
COMMENT ON COLUMN ksx."Line"."LineSequenceNo" IS '라인 일련번호';
COMMENT ON COLUMN ksx."Line"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Line"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Line"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Line"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Line"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Line"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Line"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Line"."Note" IS '비고';
COMMENT ON COLUMN ksx."Line"."LineID" IS '라인식별자';
COMMENT ON COLUMN ksx."Line"."LineName" IS '라인명';
COMMENT ON COLUMN ksx."Line"."LineDescription" IS '라인설명';
COMMENT ON COLUMN ksx."Line"."LineType" IS '라인유형';
COMMENT ON COLUMN ksx."Line"."ProductionMethodType" IS '생산방식유형';
COMMENT ON COLUMN ksx."Line"."ParentLineID" IS '상위라인식별자';
COMMENT ON COLUMN ksx."Line"."DepartmentInChargeID" IS '관리부서식별자';
COMMENT ON COLUMN ksx."Line"."PersonInChargeID" IS '관리자식별자';
COMMENT ON COLUMN ksx."Line"."CalendarID" IS '달력식별자';
COMMENT ON COLUMN ksx."Line"."IssueWarehouseID" IS '출고창고식별자';
COMMENT ON COLUMN ksx."Line"."ReceiptWarehouseID" IS '입고창고식별자';
COMMENT ON COLUMN ksx."Line"."StandardCapacity" IS '표준생산능력';
COMMENT ON COLUMN ksx."Line"."CapacityUOMCode" IS '생산능력단위코드';
COMMENT ON COLUMN ksx."Line"."StandardCycleTime" IS '표준사이클타임';
COMMENT ON COLUMN ksx."Line"."ShiftCount" IS '작업조수';
COMMENT ON COLUMN ksx."Line"."StandardHeadcount" IS '표준작업인원';
COMMENT ON COLUMN ksx."Line"."Location" IS '위치';
COMMENT ON COLUMN ksx."Line"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."Line"."ValidStartDate" IS '유효시작일';
COMMENT ON COLUMN ksx."Line"."ValidEndDate" IS '유효종료일';

CREATE TABLE ksx."Enterprise" (
  "EnterpriseSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "EnterpriseName" VARCHAR(200),
  "BusinessRegistrationNumber" VARCHAR(50),
  "CorporateRegistrationNumber" VARCHAR(50),
  "RepresentativeName" VARCHAR(200),
  "ParentEnterpriseID" VARCHAR(50),
  "CountryID" VARCHAR(30),
  "BaseCurrencyCode" VARCHAR(30),
  "DialNumber" VARCHAR(30),
  "FaxNumber" VARCHAR(30),
  "PostalCode" VARCHAR(10),
  "BaseAddress" VARCHAR(1000),
  "DetailAddress" VARCHAR(1000),
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_Enterprise" UNIQUE ("EnterpriseID")
);
COMMENT ON TABLE ksx."Enterprise" IS '회사 — 기업업무시스템 간 제조업무데이터를 교환하는 법인 단위의 회사를 의미한다. 회사는 하나 이상의 사업장으로 구성되며, 모든 명사 정보의 최상위 소유 범위가 된다.';
COMMENT ON COLUMN ksx."Enterprise"."EnterpriseSequenceNo" IS '회사 일련번호';
COMMENT ON COLUMN ksx."Enterprise"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Enterprise"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Enterprise"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Enterprise"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Enterprise"."Note" IS '비고';
COMMENT ON COLUMN ksx."Enterprise"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Enterprise"."EnterpriseName" IS '회사명';
COMMENT ON COLUMN ksx."Enterprise"."BusinessRegistrationNumber" IS '사업자등록번호';
COMMENT ON COLUMN ksx."Enterprise"."CorporateRegistrationNumber" IS '법인등록번호';
COMMENT ON COLUMN ksx."Enterprise"."RepresentativeName" IS '대표자명';
COMMENT ON COLUMN ksx."Enterprise"."ParentEnterpriseID" IS '상위회사식별자';
COMMENT ON COLUMN ksx."Enterprise"."CountryID" IS '국가식별자';
COMMENT ON COLUMN ksx."Enterprise"."BaseCurrencyCode" IS '기준통화코드';
COMMENT ON COLUMN ksx."Enterprise"."DialNumber" IS '전화번호';
COMMENT ON COLUMN ksx."Enterprise"."FaxNumber" IS '팩스번호';
COMMENT ON COLUMN ksx."Enterprise"."PostalCode" IS '우편번호';
COMMENT ON COLUMN ksx."Enterprise"."BaseAddress" IS '기본주소';
COMMENT ON COLUMN ksx."Enterprise"."DetailAddress" IS '상세주소';
COMMENT ON COLUMN ksx."Enterprise"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."ProjectMaster" (
  "ProjectMasterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProjectID" VARCHAR(50) NOT NULL,
  "ProjectName" VARCHAR(200),
  "ProjectStatusCode" VARCHAR(30),
  "ResponsibleDepartmentID" VARCHAR(50),
  "PersonInChargeID" VARCHAR(50),
  "ProjectContractDate" DATE,
  "ExpectedStartDate" DATE,
  "ExpectedEndDate" DATE,
  "ActualStartDate" DATE,
  "ActualEndDate" DATE,
  "SalesDocumentNumber" VARCHAR(50),
  "SalesDocumentSequence" INTEGER,
  "ItemID" VARCHAR(50),
  "UseIndicator" BOOLEAN,
  "DivisionID" VARCHAR(50),
  CONSTRAINT "UK_ProjectMaster" UNIQUE ("EnterpriseID", "ProjectID")
);
COMMENT ON TABLE ksx."ProjectMaster" IS '프로젝트마스터 — 프로젝트 코드, 프로젝트명 등을 관리하는 프로젝트마스터를 의미한다. 주요 프로젝트 필드의 ProjectAccounting 관련 애플리케이션 활성화를 위한정보로 활용되기도 한다.';
COMMENT ON COLUMN ksx."ProjectMaster"."ProjectMasterSequenceNo" IS '프로젝트마스터 일련번호';
COMMENT ON COLUMN ksx."ProjectMaster"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProjectMaster"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProjectMaster"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProjectMaster"."ProjectID" IS '프로젝트식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."ProjectName" IS '프로젝트명';
COMMENT ON COLUMN ksx."ProjectMaster"."ProjectStatusCode" IS '프로젝트상태코드';
COMMENT ON COLUMN ksx."ProjectMaster"."ResponsibleDepartmentID" IS '프로젝트담당부서식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."PersonInChargeID" IS '프로젝트담당자식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."ProjectContractDate" IS '프로젝트계약일';
COMMENT ON COLUMN ksx."ProjectMaster"."ExpectedStartDate" IS '시작예정일';
COMMENT ON COLUMN ksx."ProjectMaster"."ExpectedEndDate" IS '종료예정일';
COMMENT ON COLUMN ksx."ProjectMaster"."ActualStartDate" IS '실제시작일';
COMMENT ON COLUMN ksx."ProjectMaster"."ActualEndDate" IS '실제종료일';
COMMENT ON COLUMN ksx."ProjectMaster"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."ProjectMaster"."SalesDocumentSequence" IS '수주문서순번';
COMMENT ON COLUMN ksx."ProjectMaster"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProjectMaster"."UseIndicator" IS '사용여부';
COMMENT ON COLUMN ksx."ProjectMaster"."DivisionID" IS '사업부식별자';

CREATE TABLE ksx."EngineeringChangeOrder" (
  "EngineeringChangeOrderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "EngineeringChangeOrderID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "ValidStartDate" DATE,
  "ValidEndDate" DATE,
  "ExpectedExecutionDate" DATE,
  "ExecutionDate" DATE,
  "BOMType" VARCHAR(30),
  "BOMID" VARCHAR(50),
  "BOMRevisionNumber" INTEGER,
  "ChildItemID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "ActualRequirementQuantity" NUMERIC(18,6),
  CONSTRAINT "UK_EngineeringChangeOrder" UNIQUE ("EnterpriseID", "EngineeringChangeOrderID")
);
COMMENT ON TABLE ksx."EngineeringChangeOrder" IS '설계변경지시 — 제품의 설계를 변경하는 지시를 의미한다. 설계변경지시 수행 결과는 BOM 및 공정경로BOM에 반영된다.';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."EngineeringChangeOrderSequenceNo" IS '설계변경지시 일련번호';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."Note" IS '비고';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."EngineeringChangeOrderID" IS '설계변경지시식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ValidStartDate" IS '유효시작일';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ValidEndDate" IS '유효종료일';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ExpectedExecutionDate" IS '적용예정일';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ExecutionDate" IS '적용이행일';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."BOMType" IS '자재명세서유형';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."BOMID" IS '자재명세서식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."BOMRevisionNumber" IS '자재명세서버전';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ChildItemID" IS '자품목식별자';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."EngineeringChangeOrder"."ActualRequirementQuantity" IS '실소요수량';

CREATE TABLE ksx."SalesOrderHeader" (
  "SalesOrderHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "SalesDocumentNumber" VARCHAR(50) NOT NULL,
  "SalesOrderType" VARCHAR(30),
  "CustomerID" VARCHAR(50),
  "SalesDate" DATE,
  "SalesStatus" VARCHAR(30),
  "ShipmentTermsCode" VARCHAR(30),
  "SalesTransactionType" VARCHAR(30),
  "ReturnIndicator" BOOLEAN,
  "ExportIndicator" BOOLEAN,
  "SalesAutomaticApprovalIndicator" BOOLEAN,
  CONSTRAINT "UK_SalesOrderHeader" UNIQUE ("EnterpriseID", "SalesDocumentNumber")
);
COMMENT ON TABLE ksx."SalesOrderHeader" IS '수주오더헤더 — 수주오더(SalesOrder) 명사의 헤더 구조체(struct) 수주문서 1건의 공통 정보(고객사, 수주일, 수주유형, 거래 조건) 수주문서마다 1회 나타남';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesOrderHeaderSequenceNo" IS '수주오더헤더 일련번호';
COMMENT ON COLUMN ksx."SalesOrderHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SalesOrderHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SalesOrderHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesOrderType" IS '수주유형';
COMMENT ON COLUMN ksx."SalesOrderHeader"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesDate" IS '수주일';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesStatus" IS '수주상태';
COMMENT ON COLUMN ksx."SalesOrderHeader"."ShipmentTermsCode" IS '출하조건코드';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesTransactionType" IS '거래유형';
COMMENT ON COLUMN ksx."SalesOrderHeader"."ReturnIndicator" IS '반품여부';
COMMENT ON COLUMN ksx."SalesOrderHeader"."ExportIndicator" IS '수출여부';
COMMENT ON COLUMN ksx."SalesOrderHeader"."SalesAutomaticApprovalIndicator" IS '수주자동승인여부';

CREATE TABLE ksx."SalesOrderLine" (
  "SalesOrderLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "SalesDocumentNumber" VARCHAR(50) NOT NULL,
  "SalesDocumentSequence" INTEGER NOT NULL,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "ItemQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "SellingUOMCode" VARCHAR(20),
  "ConversionUnitQuantity" NUMERIC(18,6),
  "ItemUnitQuantity" NUMERIC(18,6),
  "RequestedDeliveryDate" DATE,
  CONSTRAINT "UK_SalesOrderLine" UNIQUE ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence")
);
COMMENT ON TABLE ksx."SalesOrderLine" IS '수주오더라인 — 수주오더(SalesOrder) 명사의 라인 구조체(struct[1..N]) 수주문서를 구성하는 품목 행 정보 수주오더헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."SalesOrderLine"."SalesOrderLineSequenceNo" IS '수주오더라인 일련번호';
COMMENT ON COLUMN ksx."SalesOrderLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SalesOrderLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SalesOrderLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."SalesOrderLine"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."SalesOrderLine"."SalesDocumentSequence" IS '수주문서순번';
COMMENT ON COLUMN ksx."SalesOrderLine"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."SalesOrderLine"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."SalesOrderLine"."ItemQuantity" IS '품목수량';
COMMENT ON COLUMN ksx."SalesOrderLine"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."SalesOrderLine"."SellingUOMCode" IS '판매단위코드';
COMMENT ON COLUMN ksx."SalesOrderLine"."ConversionUnitQuantity" IS '단위환산수량';
COMMENT ON COLUMN ksx."SalesOrderLine"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."SalesOrderLine"."RequestedDeliveryDate" IS '요청납기일';

CREATE TABLE ksx."SalesPlan" (
  "SalesPlanSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "SalesPlanID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "SalesProjection" NUMERIC(18,6),
  "ProjectionStartDate" DATE,
  "ProjectionEndDate" DATE,
  CONSTRAINT "UK_SalesPlan" UNIQUE ("EnterpriseID", "SalesPlanID")
);
COMMENT ON TABLE ksx."SalesPlan" IS '판매계획 — 고객사 Forecast정보 및 수요예측정보를 토대로 작성된 판매계획을 의미한다.';
COMMENT ON COLUMN ksx."SalesPlan"."SalesPlanSequenceNo" IS '판매계획 일련번호';
COMMENT ON COLUMN ksx."SalesPlan"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SalesPlan"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SalesPlan"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SalesPlan"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SalesPlan"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SalesPlan"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SalesPlan"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SalesPlan"."Note" IS '비고';
COMMENT ON COLUMN ksx."SalesPlan"."SalesPlanID" IS '판매계획식별자';
COMMENT ON COLUMN ksx."SalesPlan"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."SalesPlan"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."SalesPlan"."SalesProjection" IS '판매추정치';
COMMENT ON COLUMN ksx."SalesPlan"."ProjectionStartDate" IS '예측시작일';
COMMENT ON COLUMN ksx."SalesPlan"."ProjectionEndDate" IS '예측종료일';

CREATE TABLE ksx."BasePrice" (
  "BasePriceSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ItemID" VARCHAR(50) NOT NULL,
  "CurrencyCode" VARCHAR(30) NOT NULL,
  "UnitPrice" NUMERIC(18,6),
  "PaymentTermsCode" VARCHAR(30),
  "UseIndicator" BOOLEAN,
  CONSTRAINT "UK_BasePrice" UNIQUE ("EnterpriseID", "ItemID", "CurrencyCode")
);
COMMENT ON TABLE ksx."BasePrice" IS '기준가격 — 구매요청 시 참조하기 위한 구매품의 기준가격 정보를 의미한다.';
COMMENT ON COLUMN ksx."BasePrice"."BasePriceSequenceNo" IS '기준가격 일련번호';
COMMENT ON COLUMN ksx."BasePrice"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."BasePrice"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."BasePrice"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."BasePrice"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."BasePrice"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."BasePrice"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."BasePrice"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."BasePrice"."Note" IS '비고';
COMMENT ON COLUMN ksx."BasePrice"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."BasePrice"."CurrencyCode" IS '환종코드';
COMMENT ON COLUMN ksx."BasePrice"."UnitPrice" IS '단가';
COMMENT ON COLUMN ksx."BasePrice"."PaymentTermsCode" IS '결제조건코드';
COMMENT ON COLUMN ksx."BasePrice"."UseIndicator" IS '사용여부';

CREATE TABLE ksx."PurchaseRequisition" (
  "PurchaseRequisitionSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PurchaseRequisitionID" VARCHAR(50) NOT NULL,
  "PurchaseRequisitionRevisionNumber" INTEGER,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "DemandQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "PurchaseRequisitionUnitPrice" NUMERIC(18,6),
  "CurrencyCode" VARCHAR(30),
  "VendorID" VARCHAR(50),
  "VendorName" VARCHAR(200),
  "RequestedDeliveryDate" DATE,
  "RequesterDepartmentID" VARCHAR(50),
  "RequesterPersonnelID" VARCHAR(50),
  CONSTRAINT "UK_PurchaseRequisition" UNIQUE ("EnterpriseID", "PurchaseRequisitionID")
);
COMMENT ON TABLE ksx."PurchaseRequisition" IS '구매요청 — 생산 또는 판매를 위해 수급되어야 할 품목을 요청하는 것을 의미한다(원부자재, 소모품, 상품 등).';
COMMENT ON COLUMN ksx."PurchaseRequisition"."PurchaseRequisitionSequenceNo" IS '구매요청 일련번호';
COMMENT ON COLUMN ksx."PurchaseRequisition"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."PurchaseRequisition"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."PurchaseRequisition"."Note" IS '비고';
COMMENT ON COLUMN ksx."PurchaseRequisition"."PurchaseRequisitionID" IS '구매요청식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."PurchaseRequisitionRevisionNumber" IS '구매요청버전';
COMMENT ON COLUMN ksx."PurchaseRequisition"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."PurchaseRequisition"."DemandQuantity" IS '구매요청수량';
COMMENT ON COLUMN ksx."PurchaseRequisition"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."PurchaseRequisition"."PurchaseRequisitionUnitPrice" IS '구매요청단가';
COMMENT ON COLUMN ksx."PurchaseRequisition"."CurrencyCode" IS '환종코드';
COMMENT ON COLUMN ksx."PurchaseRequisition"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."PurchaseRequisition"."VendorName" IS '공급사명';
COMMENT ON COLUMN ksx."PurchaseRequisition"."RequestedDeliveryDate" IS '요청납기일';
COMMENT ON COLUMN ksx."PurchaseRequisition"."RequesterDepartmentID" IS '구매요청부서';
COMMENT ON COLUMN ksx."PurchaseRequisition"."RequesterPersonnelID" IS '구매요청자';

CREATE TABLE ksx."PurchaseOrderHeader" (
  "PurchaseOrderHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PurchaseDocumentNumber" VARCHAR(50) NOT NULL,
  "VendorID" VARCHAR(50),
  "PaymentTermsCode" VARCHAR(30),
  "PurchaseGroupCode" VARCHAR(30),
  "CurrencyCode" VARCHAR(30),
  "ExchangeRate" NUMERIC(18,6),
  "PurchaseApprovalDate" DATE,
  "PurchaseOrderDate" DATE,
  "PurchaseOrderTypeCode" VARCHAR(30),
  "PurchaseTransactionType" VARCHAR(30),
  "PurchaseOrderStartDate" DATE,
  "PurchaseOrderValidDate" DATE,
  "PersonnelID" VARCHAR(50),
  "PurchaseOrderClosingIndicator" BOOLEAN,
  "PurchaseOrderClosingDate" DATE,
  CONSTRAINT "UK_PurchaseOrderHeader" UNIQUE ("EnterpriseID", "PurchaseDocumentNumber")
);
COMMENT ON TABLE ksx."PurchaseOrderHeader" IS '구매발주헤더 — 구매발주(PurchaseOrder) 명사의 헤더 구조체(struct) 구매문서 1건의 공통 정보(공급사, 발주일, 결제·거래 조건, 담당자) 구매문서마다 1회 나타남';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderHeaderSequenceNo" IS '구매발주헤더 일련번호';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseDocumentNumber" IS '구매문서번호';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PaymentTermsCode" IS '결제조건코드';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseGroupCode" IS '구매그룹코드';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."CurrencyCode" IS '환종코드';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."ExchangeRate" IS '환율';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseApprovalDate" IS '승인일';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderDate" IS '구매발주일';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderTypeCode" IS '발주유형코드';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseTransactionType" IS '거래유형';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderStartDate" IS '시작일';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderValidDate" IS '유효일';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderClosingIndicator" IS '발주마감여부';
COMMENT ON COLUMN ksx."PurchaseOrderHeader"."PurchaseOrderClosingDate" IS '발주마감일';

CREATE TABLE ksx."PurchaseOrderLine" (
  "PurchaseOrderLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PurchaseDocumentNumber" VARCHAR(50) NOT NULL,
  "PurchaseDocumentSequence" INTEGER NOT NULL,
  "ItemPurchaseType" VARCHAR(30),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "PurchaseOrderLineStatusCode" VARCHAR(30),
  "TaxCode" VARCHAR(30),
  "ItemUOMCode" VARCHAR(20),
  "PurchaseOrderUOMCode" VARCHAR(20),
  "ConversionUnitQuantity" NUMERIC(18,6),
  "ItemUnitQuantity" NUMERIC(18,6),
  "PurchaseOrderQuantity" NUMERIC(18,6),
  "PurchaseGoodsReceiptQuantity" NUMERIC(18,6),
  "PurchaseTransactionUnitPrice" NUMERIC(18,6),
  "PurchaseTransactionPrice" NUMERIC(18,6),
  "PurchaseOrderUnitPrice" NUMERIC(18,6),
  "PurchaseOrderPrice" NUMERIC(18,6),
  "VATPrice" NUMERIC(18,6),
  "ExpectedDeliveryDate" DATE,
  "IncomingInspectionIndicator" BOOLEAN,
  "AccountCode" VARCHAR(30),
  "VATTransactionUnitPrice" NUMERIC(18,6),
  "VATTransactionPrice" NUMERIC(18,6),
  "VATCarryingAmount" NUMERIC(18,6),
  CONSTRAINT "UK_PurchaseOrderLine" UNIQUE ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence")
);
COMMENT ON TABLE ksx."PurchaseOrderLine" IS '구매발주라인 — 구매발주(PurchaseOrder) 명사의 라인 구조체(struct[1..N]) 구매문서를 구성하는 품목 행 정보 구매발주헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderLineSequenceNo" IS '구매발주라인 일련번호';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseDocumentNumber" IS '구매문서번호';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseDocumentSequence" IS '구매문서순번';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ItemPurchaseType" IS '구매라인유형';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderLineStatusCode" IS '발주라인상태코드';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."TaxCode" IS '세무코드';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderUOMCode" IS '발주단위코드';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ConversionUnitQuantity" IS '단위환산수량';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderQuantity" IS '구매발주수량';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseGoodsReceiptQuantity" IS '구매입고수량';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseTransactionUnitPrice" IS '구매거래단가';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseTransactionPrice" IS '구매거래금액';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderUnitPrice" IS '발주단가';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."PurchaseOrderPrice" IS '발주금액';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."VATPrice" IS '부가세금액';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."ExpectedDeliveryDate" IS '납기예정일';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."IncomingInspectionIndicator" IS '수입검사여부';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."AccountCode" IS '계정코드';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."VATTransactionUnitPrice" IS '부가세포함거래단가';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."VATTransactionPrice" IS '부가세포함거래금액';
COMMENT ON COLUMN ksx."PurchaseOrderLine"."VATCarryingAmount" IS '부가세포함장부금액';

CREATE TABLE ksx."MaterialArrival" (
  "MaterialArrivalSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PurchaseDocumentNumber" VARCHAR(50) NOT NULL,
  "PurchaseDocumentSequence" INTEGER NOT NULL,
  "ItemID" VARCHAR(50),
  "PurchaseGoodsReceiptQuantity" NUMERIC(18,6),
  "ReceiptWarehouseID" VARCHAR(50),
  "GoodsReceiptDate" DATE,
  "LotID" VARCHAR(50) NOT NULL,
  "ItemQuantity" NUMERIC(18,6),
  "VendorID" VARCHAR(50),
  CONSTRAINT "UK_MaterialArrival" UNIQUE ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence", "LotID")
);
COMMENT ON TABLE ksx."MaterialArrival" IS '자재도착 — 자재가 입고 전 수입검사를 위해 도착한 정보를 의미한다.';
COMMENT ON COLUMN ksx."MaterialArrival"."MaterialArrivalSequenceNo" IS '자재도착 일련번호';
COMMENT ON COLUMN ksx."MaterialArrival"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."MaterialArrival"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."MaterialArrival"."Note" IS '비고';
COMMENT ON COLUMN ksx."MaterialArrival"."PurchaseDocumentNumber" IS '구매문서번호';
COMMENT ON COLUMN ksx."MaterialArrival"."PurchaseDocumentSequence" IS '구매문서순번';
COMMENT ON COLUMN ksx."MaterialArrival"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."PurchaseGoodsReceiptQuantity" IS '구매입고수량';
COMMENT ON COLUMN ksx."MaterialArrival"."ReceiptWarehouseID" IS '입고창고식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."GoodsReceiptDate" IS '입고처리일';
COMMENT ON COLUMN ksx."MaterialArrival"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."MaterialArrival"."ItemQuantity" IS '품목수량';
COMMENT ON COLUMN ksx."MaterialArrival"."VendorID" IS '공급사식별자';

CREATE TABLE ksx."GoodsReceipt" (
  "GoodsReceiptSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "GoodsReceiptID" VARCHAR(50) NOT NULL,
  "WarehouseID" VARCHAR(50),
  "PersonnelID" VARCHAR(50),
  "GoodsReceiptSequence" INTEGER NOT NULL,
  "GoodsReceiptType" VARCHAR(30),
  "GoodsReceiptReturnType" VARCHAR(30),
  "GoodsReceiptDate" DATE,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "InventoryTransactionDocumentNumber" VARCHAR(50),
  "InventoryTransactionDocumentSequence" INTEGER,
  "InventoryTransactionTypeCode" VARCHAR(30),
  "InvoiceNumber" VARCHAR(50),
  "InvoiceSequence" INTEGER,
  "InvoiceProcessingIndicator" BOOLEAN,
  "IncomingInspectionIndicator" BOOLEAN,
  "VendorID" VARCHAR(50),
  "PurchaseOrderUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "GoodsReceiptQuantity" NUMERIC(18,6),
  "IncomingInspectionAcceptedQuantity" NUMERIC(18,6),
  "IncomingInspectionRejectedQuantity" NUMERIC(18,6),
  "PurchaseGroupCode" VARCHAR(30),
  "ItemUOMCode" VARCHAR(20),
  CONSTRAINT "UK_GoodsReceipt" UNIQUE ("EnterpriseID", "GoodsReceiptID", "GoodsReceiptSequence")
);
COMMENT ON TABLE ksx."GoodsReceipt" IS '입고 — 구매 발주된 품목을 협력업체로부터 납품 받은 정보를 의미한다.';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptSequenceNo" IS '입고 일련번호';
COMMENT ON COLUMN ksx."GoodsReceipt"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."GoodsReceipt"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."GoodsReceipt"."Note" IS '비고';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptID" IS '입고식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptSequence" IS '입고순번';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptType" IS '입고처리유형';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptReturnType" IS '입고반품유형';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptDate" IS '입고처리일';
COMMENT ON COLUMN ksx."GoodsReceipt"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."GoodsReceipt"."InventoryTransactionDocumentNumber" IS '수불문서번호';
COMMENT ON COLUMN ksx."GoodsReceipt"."InventoryTransactionDocumentSequence" IS '수불문서순번';
COMMENT ON COLUMN ksx."GoodsReceipt"."InventoryTransactionTypeCode" IS '수불유형코드';
COMMENT ON COLUMN ksx."GoodsReceipt"."InvoiceNumber" IS '송장번호';
COMMENT ON COLUMN ksx."GoodsReceipt"."InvoiceSequence" IS '송장라인순번';
COMMENT ON COLUMN ksx."GoodsReceipt"."InvoiceProcessingIndicator" IS '송장처리여부';
COMMENT ON COLUMN ksx."GoodsReceipt"."IncomingInspectionIndicator" IS '수입검사여부';
COMMENT ON COLUMN ksx."GoodsReceipt"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."GoodsReceipt"."PurchaseOrderUOMCode" IS '발주단위코드';
COMMENT ON COLUMN ksx."GoodsReceipt"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."GoodsReceipt"."GoodsReceiptQuantity" IS '입고처리수량';
COMMENT ON COLUMN ksx."GoodsReceipt"."IncomingInspectionAcceptedQuantity" IS '수입검사합격수량';
COMMENT ON COLUMN ksx."GoodsReceipt"."IncomingInspectionRejectedQuantity" IS '수입검사불합격수량';
COMMENT ON COLUMN ksx."GoodsReceipt"."PurchaseGroupCode" IS '구매그룹코드';
COMMENT ON COLUMN ksx."GoodsReceipt"."ItemUOMCode" IS '기준단위코드';

CREATE TABLE ksx."GoodsIssue" (
  "GoodsIssueSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "GoodsIssueID" VARCHAR(50) NOT NULL,
  "InventoryTransactionDocumentNumber" VARCHAR(50),
  "InventoryTransactionDocumentSequence" INTEGER,
  "ItemID" VARCHAR(50),
  "InventoryTransactionTypeCode" VARCHAR(30),
  "InventoryTransferType" VARCHAR(30),
  "InventoryVariationType" VARCHAR(30),
  "InventoryTransactionType" VARCHAR(30),
  "LotID" VARCHAR(50),
  "SerialUseIndicator" BOOLEAN,
  "VendorID" VARCHAR(50),
  "WarehouseID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "OrderUOMCode" VARCHAR(20),
  "OrderQuantity" NUMERIC(18,6),
  CONSTRAINT "UK_GoodsIssue" UNIQUE ("EnterpriseID", "GoodsIssueID")
);
COMMENT ON TABLE ksx."GoodsIssue" IS '자재불출 — 자재불출 요청된 자재를 불출하는 것을 의미한다(일반적으로 재고 관리주체가 다를 경우 창고관리부서에서 사용).';
COMMENT ON COLUMN ksx."GoodsIssue"."GoodsIssueSequenceNo" IS '자재불출 일련번호';
COMMENT ON COLUMN ksx."GoodsIssue"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."GoodsIssue"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."GoodsIssue"."Note" IS '비고';
COMMENT ON COLUMN ksx."GoodsIssue"."GoodsIssueID" IS '자재불출식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryTransactionDocumentNumber" IS '수불문서번호';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryTransactionDocumentSequence" IS '수불문서순번';
COMMENT ON COLUMN ksx."GoodsIssue"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryTransactionTypeCode" IS '수불유형코드';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryTransferType" IS '입출고유형';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryVariationType" IS '재고증감유형';
COMMENT ON COLUMN ksx."GoodsIssue"."InventoryTransactionType" IS '수불유형';
COMMENT ON COLUMN ksx."GoodsIssue"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."SerialUseIndicator" IS '시리얼사용여부';
COMMENT ON COLUMN ksx."GoodsIssue"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."GoodsIssue"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."GoodsIssue"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."GoodsIssue"."OrderUOMCode" IS '오더단위코드';
COMMENT ON COLUMN ksx."GoodsIssue"."OrderQuantity" IS '오더수량';

CREATE TABLE ksx."ProductionPlanning" (
  "ProductionPlanningSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPlanID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "ProductionPlanQuantity" INTEGER,
  "ScheduleStartDateTime" TIMESTAMP,
  "ScheduleEndDateTime" TIMESTAMP,
  CONSTRAINT "UK_ProductionPlanning" UNIQUE ("EnterpriseID", "ProductionPlanID")
);
COMMENT ON TABLE ksx."ProductionPlanning" IS '생산계획 — 특정 제품을 생산하기 위한 계획을 의미한다.';
COMMENT ON COLUMN ksx."ProductionPlanning"."ProductionPlanningSequenceNo" IS '생산계획 일련번호';
COMMENT ON COLUMN ksx."ProductionPlanning"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPlanning"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPlanning"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPlanning"."ProductionPlanID" IS '생산계획식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductionPlanning"."ProductionPlanQuantity" IS '생산계획수량';
COMMENT ON COLUMN ksx."ProductionPlanning"."ScheduleStartDateTime" IS '생산계획시작일시';
COMMENT ON COLUMN ksx."ProductionPlanning"."ScheduleEndDateTime" IS '생산계획종료일시';

CREATE TABLE ksx."ProductionOrder" (
  "ProductionOrderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionOrderID" VARCHAR(50) NOT NULL,
  "ProductionOrderSequence" INTEGER NOT NULL,
  "ItemID" VARCHAR(50),
  "LineID" VARCHAR(50),
  "RoutingID" VARCHAR(50),
  "BOMID" VARCHAR(50),
  "BOMRevisionNumber" INTEGER,
  "ItemUOMCode" VARCHAR(20),
  "ProductionOrderQuantity" INTEGER,
  "ProductionDueDateTime" TIMESTAMP,
  "ScheduleStartDateTime" TIMESTAMP,
  "ScheduleEndDateTime" TIMESTAMP,
  "SalesDocumentNumber" VARCHAR(50),
  "SalesDocumentSequence" INTEGER,
  CONSTRAINT "UK_ProductionOrder" UNIQUE ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence")
);
COMMENT ON TABLE ksx."ProductionOrder" IS '생산지시 — 특정 제품의 생산을 지시하는 정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductionOrder"."ProductionOrderSequenceNo" IS '생산지시 일련번호';
COMMENT ON COLUMN ksx."ProductionOrder"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionOrder"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionOrder"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionOrder"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionOrder"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."LineID" IS '라인식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."BOMID" IS '자재명세서식별자';
COMMENT ON COLUMN ksx."ProductionOrder"."BOMRevisionNumber" IS '자재명세서버전';
COMMENT ON COLUMN ksx."ProductionOrder"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductionOrder"."ProductionOrderQuantity" IS '생산지시수량';
COMMENT ON COLUMN ksx."ProductionOrder"."ProductionDueDateTime" IS '생산완료기한일시';
COMMENT ON COLUMN ksx."ProductionOrder"."ScheduleStartDateTime" IS '생산계획시작일시';
COMMENT ON COLUMN ksx."ProductionOrder"."ScheduleEndDateTime" IS '생산계획종료일시';
COMMENT ON COLUMN ksx."ProductionOrder"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."ProductionOrder"."SalesDocumentSequence" IS '수주문서순번';

CREATE TABLE ksx."OperationStart" (
  "OperationStartSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "OperationStartID" VARCHAR(50) NOT NULL,
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "LotCreatedQuantity" NUMERIC(18,6),
  "OperationID" VARCHAR(50),
  "EquipmentID" VARCHAR(50),
  "OperationStartTime" TIMESTAMP,
  "PersonnelID" VARCHAR(50),
  CONSTRAINT "UK_OperationStart" UNIQUE ("EnterpriseID", "OperationStartID")
);
COMMENT ON TABLE ksx."OperationStart" IS '착공 — 설비에 해당 공정의 생산을 지시한다.';
COMMENT ON COLUMN ksx."OperationStart"."OperationStartSequenceNo" IS '착공 일련번호';
COMMENT ON COLUMN ksx."OperationStart"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."OperationStart"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."OperationStart"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."OperationStart"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."OperationStart"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."OperationStart"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."OperationStart"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."OperationStart"."Note" IS '비고';
COMMENT ON COLUMN ksx."OperationStart"."OperationStartID" IS '착공식별자';
COMMENT ON COLUMN ksx."OperationStart"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."OperationStart"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."OperationStart"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."OperationStart"."LotCreatedQuantity" IS '로트수량';
COMMENT ON COLUMN ksx."OperationStart"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."OperationStart"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."OperationStart"."OperationStartTime" IS '착공시간';
COMMENT ON COLUMN ksx."OperationStart"."PersonnelID" IS '사원식별자';

CREATE TABLE ksx."OperationEnd" (
  "OperationEndSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "OperationEndID" VARCHAR(50) NOT NULL,
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "LotCreatedQuantity" NUMERIC(18,6),
  "OperationID" VARCHAR(50),
  "EquipmentID" VARCHAR(50),
  "OperationEndTime" TIMESTAMP,
  "PersonnelID" VARCHAR(50),
  "ProducedQuantity" NUMERIC(18,6),
  "DefectQuantity" NUMERIC(18,6),
  "ReworkCount" INTEGER,
  CONSTRAINT "UK_OperationEnd" UNIQUE ("EnterpriseID", "OperationEndID")
);
COMMENT ON TABLE ksx."OperationEnd" IS '완공 — 해당 공정의 생산 완료를 보고한다.';
COMMENT ON COLUMN ksx."OperationEnd"."OperationEndSequenceNo" IS '완공 일련번호';
COMMENT ON COLUMN ksx."OperationEnd"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."OperationEnd"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."OperationEnd"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."OperationEnd"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."OperationEnd"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."OperationEnd"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."OperationEnd"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."OperationEnd"."Note" IS '비고';
COMMENT ON COLUMN ksx."OperationEnd"."OperationEndID" IS '완공식별자';
COMMENT ON COLUMN ksx."OperationEnd"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."OperationEnd"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."OperationEnd"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."OperationEnd"."LotCreatedQuantity" IS '로트수량';
COMMENT ON COLUMN ksx."OperationEnd"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."OperationEnd"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."OperationEnd"."OperationEndTime" IS '완공시간';
COMMENT ON COLUMN ksx."OperationEnd"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."OperationEnd"."ProducedQuantity" IS '생산수량';
COMMENT ON COLUMN ksx."OperationEnd"."DefectQuantity" IS '불량수량';
COMMENT ON COLUMN ksx."OperationEnd"."ReworkCount" IS '재작업횟수';

CREATE TABLE ksx."TransferCommand" (
  "TransferCommandSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "TransferCommandID" VARCHAR(50) NOT NULL,
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "CarrierID" VARCHAR(50),
  "SourceID" VARCHAR(50),
  "SourceType" VARCHAR(30),
  "SourceName" VARCHAR(200),
  "DestinationID" VARCHAR(50),
  "DestinationType" VARCHAR(30),
  "DestinationName" VARCHAR(200),
  CONSTRAINT "UK_TransferCommand" UNIQUE ("EnterpriseID", "TransferCommandID")
);
COMMENT ON TABLE ksx."TransferCommand" IS '이동지시 — 현재 공정에서 다음 공정으로 작업할 Lot의 이동을 지시한다.';
COMMENT ON COLUMN ksx."TransferCommand"."TransferCommandSequenceNo" IS '이동지시 일련번호';
COMMENT ON COLUMN ksx."TransferCommand"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."TransferCommand"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."TransferCommand"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."TransferCommand"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."TransferCommand"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."TransferCommand"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."TransferCommand"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."TransferCommand"."Note" IS '비고';
COMMENT ON COLUMN ksx."TransferCommand"."TransferCommandID" IS '이동지시식별자';
COMMENT ON COLUMN ksx."TransferCommand"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."TransferCommand"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."TransferCommand"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."TransferCommand"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."TransferCommand"."SourceID" IS '출발지식별자';
COMMENT ON COLUMN ksx."TransferCommand"."SourceType" IS '출발지유형';
COMMENT ON COLUMN ksx."TransferCommand"."SourceName" IS '출발지명';
COMMENT ON COLUMN ksx."TransferCommand"."DestinationID" IS '목적지식별자';
COMMENT ON COLUMN ksx."TransferCommand"."DestinationType" IS '목적지유형';
COMMENT ON COLUMN ksx."TransferCommand"."DestinationName" IS '목적지명';

CREATE TABLE ksx."TransferStart" (
  "TransferStartSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "TransferStartID" VARCHAR(50) NOT NULL,
  "TransferCommandID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "CarrierID" VARCHAR(50),
  "TransferStartDateTime" TIMESTAMP,
  "CurrentLocation" VARCHAR(1000),
  "DestinationID" VARCHAR(50),
  "DestinationType" VARCHAR(30),
  "DestinationName" VARCHAR(200),
  "ErrorCode" VARCHAR(30),
  "ErrorMessage" VARCHAR(1000),
  CONSTRAINT "UK_TransferStart" UNIQUE ("EnterpriseID", "TransferStartID")
);
COMMENT ON TABLE ksx."TransferStart" IS '운행시작 — 이동지시 명령을 받아 운행 시작 시 시작 정보를 보고한다.';
COMMENT ON COLUMN ksx."TransferStart"."TransferStartSequenceNo" IS '운행시작 일련번호';
COMMENT ON COLUMN ksx."TransferStart"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."TransferStart"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."TransferStart"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."TransferStart"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."TransferStart"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."TransferStart"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."TransferStart"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."TransferStart"."Note" IS '비고';
COMMENT ON COLUMN ksx."TransferStart"."TransferStartID" IS '운행시작식별자';
COMMENT ON COLUMN ksx."TransferStart"."TransferCommandID" IS '이동지시식별자';
COMMENT ON COLUMN ksx."TransferStart"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."TransferStart"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."TransferStart"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."TransferStart"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."TransferStart"."TransferStartDateTime" IS '운행시작일시';
COMMENT ON COLUMN ksx."TransferStart"."CurrentLocation" IS '현재위치';
COMMENT ON COLUMN ksx."TransferStart"."DestinationID" IS '목적지식별자';
COMMENT ON COLUMN ksx."TransferStart"."DestinationType" IS '목적지유형';
COMMENT ON COLUMN ksx."TransferStart"."DestinationName" IS '목적지명';
COMMENT ON COLUMN ksx."TransferStart"."ErrorCode" IS '오류코드';
COMMENT ON COLUMN ksx."TransferStart"."ErrorMessage" IS '오류메세지';

CREATE TABLE ksx."TransferEnd" (
  "TransferEndSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "TransferEndID" VARCHAR(50) NOT NULL,
  "TransferCommandID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "CarrierID" VARCHAR(50),
  "TransferEndDateTime" TIMESTAMP,
  "DestinationID" VARCHAR(50),
  "DestinationType" VARCHAR(30),
  "DestinationName" VARCHAR(200),
  CONSTRAINT "UK_TransferEnd" UNIQUE ("EnterpriseID", "TransferEndID")
);
COMMENT ON TABLE ksx."TransferEnd" IS '운행완료 — 이동지시 명령을 받아 운행 완료 시 완료 정보를 보고한다.';
COMMENT ON COLUMN ksx."TransferEnd"."TransferEndSequenceNo" IS '운행완료 일련번호';
COMMENT ON COLUMN ksx."TransferEnd"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."TransferEnd"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."TransferEnd"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."TransferEnd"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."TransferEnd"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."TransferEnd"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."TransferEnd"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."TransferEnd"."Note" IS '비고';
COMMENT ON COLUMN ksx."TransferEnd"."TransferEndID" IS '운행완료식별자';
COMMENT ON COLUMN ksx."TransferEnd"."TransferCommandID" IS '이동지시식별자';
COMMENT ON COLUMN ksx."TransferEnd"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."TransferEnd"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."TransferEnd"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."TransferEnd"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."TransferEnd"."TransferEndDateTime" IS '운행완료일시';
COMMENT ON COLUMN ksx."TransferEnd"."DestinationID" IS '목적지식별자';
COMMENT ON COLUMN ksx."TransferEnd"."DestinationType" IS '목적지유형';
COMMENT ON COLUMN ksx."TransferEnd"."DestinationName" IS '목적지명';

CREATE TABLE ksx."InTransitLocation" (
  "InTransitLocationSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "InTransitLocationID" VARCHAR(50) NOT NULL,
  "TransferCommandID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "LotName" VARCHAR(200),
  "LotDescription" VARCHAR(1000),
  "CarrierID" VARCHAR(50),
  "CurrentLocation" VARCHAR(1000),
  CONSTRAINT "UK_InTransitLocation" UNIQUE ("EnterpriseID", "InTransitLocationID")
);
COMMENT ON TABLE ksx."InTransitLocation" IS '운송위치 — 이동 중 현재 운송 위치 정보를 보고한다.';
COMMENT ON COLUMN ksx."InTransitLocation"."InTransitLocationSequenceNo" IS '운송위치 일련번호';
COMMENT ON COLUMN ksx."InTransitLocation"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."InTransitLocation"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."InTransitLocation"."Note" IS '비고';
COMMENT ON COLUMN ksx."InTransitLocation"."InTransitLocationID" IS '운송위치식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."TransferCommandID" IS '이동지시식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."LotName" IS '로트명';
COMMENT ON COLUMN ksx."InTransitLocation"."LotDescription" IS '로트설명';
COMMENT ON COLUMN ksx."InTransitLocation"."CarrierID" IS '캐리어식별자';
COMMENT ON COLUMN ksx."InTransitLocation"."CurrentLocation" IS '현재위치';

CREATE TABLE ksx."EquipmentState" (
  "EquipmentStateSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "EquipmentStateID" VARCHAR(50) NOT NULL,
  "EquipmentID" VARCHAR(50),
  "EquipmentState" VARCHAR(30),
  "EquipmentControlMode" VARCHAR(30),
  "EquipmentOperationMode" VARCHAR(30),
  "ProcessedLotQuantity" NUMERIC(18,6),
  "LastProcessedLotID" VARCHAR(50),
  "LastProcessedOperationID" VARCHAR(50),
  "ErrorCode" VARCHAR(30),
  "ErrorMessage" VARCHAR(1000),
  CONSTRAINT "UK_EquipmentState" UNIQUE ("EnterpriseID", "EquipmentStateID")
);
COMMENT ON TABLE ksx."EquipmentState" IS '설비상태 — 설비의 상태가 변경될 시 상태 정보를 보고한다.';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentStateSequenceNo" IS '설비상태 일련번호';
COMMENT ON COLUMN ksx."EquipmentState"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."EquipmentState"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."EquipmentState"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."EquipmentState"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."EquipmentState"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."EquipmentState"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."EquipmentState"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."EquipmentState"."Note" IS '비고';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentStateID" IS '설비상태식별자';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentState" IS '설비상태';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentControlMode" IS '설비제어모드';
COMMENT ON COLUMN ksx."EquipmentState"."EquipmentOperationMode" IS '설비운영모드';
COMMENT ON COLUMN ksx."EquipmentState"."ProcessedLotQuantity" IS '진행로트수량';
COMMENT ON COLUMN ksx."EquipmentState"."LastProcessedLotID" IS '최종진행로트식별자';
COMMENT ON COLUMN ksx."EquipmentState"."LastProcessedOperationID" IS '최종진행공정식별자';
COMMENT ON COLUMN ksx."EquipmentState"."ErrorCode" IS '오류코드';
COMMENT ON COLUMN ksx."EquipmentState"."ErrorMessage" IS '오류메세지';

CREATE TABLE ksx."Alarm" (
  "AlarmSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "AlarmID" VARCHAR(50) NOT NULL,
  "EquipmentID" VARCHAR(50),
  "AlarmState" VARCHAR(30),
  "ErrorCode" VARCHAR(30),
  "ErrorMessage" VARCHAR(1000),
  "EventDateTime" TIMESTAMP,
  "CurrentLocation" VARCHAR(1000),
  CONSTRAINT "UK_Alarm" UNIQUE ("EnterpriseID", "AlarmID")
);
COMMENT ON TABLE ksx."Alarm" IS '알람 — 설비에서 발생하는 알람 정보를 의미한다.';
COMMENT ON COLUMN ksx."Alarm"."AlarmSequenceNo" IS '알람 일련번호';
COMMENT ON COLUMN ksx."Alarm"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Alarm"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Alarm"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Alarm"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Alarm"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Alarm"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Alarm"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Alarm"."Note" IS '비고';
COMMENT ON COLUMN ksx."Alarm"."AlarmID" IS '알람식별자';
COMMENT ON COLUMN ksx."Alarm"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."Alarm"."AlarmState" IS '알람상태';
COMMENT ON COLUMN ksx."Alarm"."ErrorCode" IS '오류코드';
COMMENT ON COLUMN ksx."Alarm"."ErrorMessage" IS '오류메세지';
COMMENT ON COLUMN ksx."Alarm"."EventDateTime" IS '이벤트발생일시';
COMMENT ON COLUMN ksx."Alarm"."CurrentLocation" IS '현재위치';

CREATE TABLE ksx."SupplierInspectionPlan" (
  "SupplierInspectionPlanSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ProjectID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "ItemUOMCode" VARCHAR(20),
  "PurchaseDocumentNumber" VARCHAR(50),
  "PurchaseDocumentSequence" INTEGER,
  "PurchaseOrderQuantity" NUMERIC(18,6),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "ExpectedDeliveryDate" DATE,
  "InspectionPlanID" VARCHAR(50) NOT NULL,
  "InspectionID" VARCHAR(50) NOT NULL,
  "InspectionName" VARCHAR(200),
  "Inspector" VARCHAR(255),
  "InspectionLocation" VARCHAR(1000),
  "ExpectedInspectionDate" DATE,
  "ExpectedInspectionTimePeriod" INTEGER,
  "InspectionMethod" VARCHAR(30),
  "InspectionPlanQuantity" NUMERIC(18,6),
  "InspectionCheckSheet" VARCHAR(1000),
  CONSTRAINT "UK_SupplierInspectionPlan" UNIQUE ("EnterpriseID", "InspectionPlanID", "InspectionID")
);
COMMENT ON TABLE ksx."SupplierInspectionPlan" IS '협력업체품질검사계획 — 수주산업에서 프로젝트성으로 추진하고 있는 협력업체 발주품에 대해 발주처 및 협력업체 품질부서에서 품질검사를 하기 위한 일정 계획을 의미한다.';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."SupplierInspectionPlanSequenceNo" IS '협력업체품질검사계획 일련번호';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."Note" IS '비고';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ProjectID" IS '프로젝트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."PurchaseDocumentNumber" IS '구매문서번호';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."PurchaseDocumentSequence" IS '구매문서순번';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."PurchaseOrderQuantity" IS '구매발주수량';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ExpectedDeliveryDate" IS '납기예정일';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionPlanID" IS '검사계획식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionID" IS '검사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionName" IS '검사명';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."Inspector" IS '검사자';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionLocation" IS '검사위치';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ExpectedInspectionDate" IS '검사예정일';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."ExpectedInspectionTimePeriod" IS '검사예정기간';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionMethod" IS '검사방법';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionPlanQuantity" IS '검사계획수량';
COMMENT ON COLUMN ksx."SupplierInspectionPlan"."InspectionCheckSheet" IS '검사체크시트';

CREATE TABLE ksx."SupplierInspectionApplication" (
  "SupplierInspectionApplicationSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ProjectID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "ItemUOMCode" VARCHAR(20),
  "PurchaseDocumentNumber" VARCHAR(50),
  "PurchaseDocumentSequence" INTEGER,
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "InspectionPlanID" VARCHAR(50),
  "InspectionID" VARCHAR(50),
  "InspectionApplicationID" VARCHAR(50) NOT NULL,
  "ApplicationPersonnelID" VARCHAR(50),
  "InspectionName" VARCHAR(200),
  "InspectionLocation" VARCHAR(1000),
  "InspectionMethod" VARCHAR(30),
  "ExpectedInspectionDate" DATE,
  "InspectionDate" DATE,
  "InspectionTimePeriod" INTEGER,
  "InspectionQuantity" NUMERIC(18,6),
  "SelfCheckInspectionResultSheet" VARCHAR(1000),
  "InspectionStatusCode" VARCHAR(30),
  "ReasonForApplication" VARCHAR(255),
  "InspectionCancelReason" VARCHAR(1000),
  CONSTRAINT "UK_SupplierInspectionApplication" UNIQUE ("EnterpriseID", "InspectionApplicationID")
);
COMMENT ON TABLE ksx."SupplierInspectionApplication" IS '협력업체품질검사신청 — 품질검사계획에 따라 협력업체에 품질검사를 신청하는 것을 의미한다.';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."SupplierInspectionApplicationSequenceNo" IS '협력업체품질검사신청 일련번호';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."Note" IS '비고';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ProjectID" IS '프로젝트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."PurchaseDocumentNumber" IS '구매문서번호';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."PurchaseDocumentSequence" IS '구매문서순번';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionPlanID" IS '검사계획식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionID" IS '검사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionApplicationID" IS '검사신청식별자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ApplicationPersonnelID" IS '검사신청자';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionName" IS '검사명';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionLocation" IS '검사위치';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionMethod" IS '검사방법';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ExpectedInspectionDate" IS '검사예정일';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionDate" IS '검사일';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionTimePeriod" IS '검사기간';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionQuantity" IS '검사수량';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."SelfCheckInspectionResultSheet" IS '자체점검결과시트';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionStatusCode" IS '검사상태코드';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."ReasonForApplication" IS '검사신청사유';
COMMENT ON COLUMN ksx."SupplierInspectionApplication"."InspectionCancelReason" IS '검사취소사유';

CREATE TABLE ksx."SupplierInspectionResult" (
  "SupplierInspectionResultSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ProjectID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "InspectionPlanID" VARCHAR(50),
  "InspectionID" VARCHAR(50),
  "InspectionApplicationID" VARCHAR(50),
  "InspectionResultID" VARCHAR(50) NOT NULL,
  "Inspector" VARCHAR(255),
  "InspectionParticipant" VARCHAR(1000),
  "InspectionLocation" VARCHAR(1000),
  "InspectionDate" DATE,
  "InspectionQuantity" NUMERIC(18,6),
  "InspectionResult" VARCHAR(30),
  "InspectionResultSheet" VARCHAR(1000),
  "InspectionStatusCode" VARCHAR(30),
  CONSTRAINT "UK_SupplierInspectionResult" UNIQUE ("EnterpriseID", "InspectionResultID")
);
COMMENT ON TABLE ksx."SupplierInspectionResult" IS '협력업체품질검사결과 — 검사결과를 품질관리 부서에 전달하는 것을 의미한다.';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."SupplierInspectionResultSequenceNo" IS '협력업체품질검사결과 일련번호';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."Note" IS '비고';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."ProjectID" IS '프로젝트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionPlanID" IS '검사계획식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionID" IS '검사식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionApplicationID" IS '검사신청식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionResultID" IS '검사결과식별자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."Inspector" IS '검사자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionParticipant" IS '검사입회자';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionLocation" IS '검사위치';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionDate" IS '검사일';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionQuantity" IS '검사수량';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionResult" IS '검사결과';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionResultSheet" IS '검사결과시트';
COMMENT ON COLUMN ksx."SupplierInspectionResult"."InspectionStatusCode" IS '검사상태코드';

CREATE TABLE ksx."CorrectiveActionRequest" (
  "CorrectiveActionRequestSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "InspectionApplicationID" VARCHAR(50),
  "CorrectiveActionRequestID" VARCHAR(50) NOT NULL,
  "CorrectiveActionRequestIssuerID" VARCHAR(50),
  "CorrectiveActionRequestRecipientID" VARCHAR(50),
  "CorrectiveActionRequestLocation" VARCHAR(1000),
  "CorrectiveActionRequestDocumentReference" VARCHAR(255),
  CONSTRAINT "UK_CorrectiveActionRequest" UNIQUE ("EnterpriseID", "CorrectiveActionRequestID")
);
COMMENT ON TABLE ksx."CorrectiveActionRequest" IS '시정조치요청 — 공급사에 시정조치를 요청하는 것을 의미한다.';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestSequenceNo" IS '시정조치요청 일련번호';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."Note" IS '비고';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."InspectionApplicationID" IS '검사신청식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestID" IS '시정조치요청식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestIssuerID" IS '시정조치요청발행자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestRecipientID" IS '시정조치요청접수자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestLocation" IS '시정조치요청위치';
COMMENT ON COLUMN ksx."CorrectiveActionRequest"."CorrectiveActionRequestDocumentReference" IS '시정조치요청첨부자료';

CREATE TABLE ksx."CorrectiveActionPlan" (
  "CorrectiveActionPlanSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "CorrectiveActionRequestID" VARCHAR(50),
  "CorrectiveActionPlanID" VARCHAR(50) NOT NULL,
  "PersonInChargeID" VARCHAR(50),
  "PersonInChargeEmail" VARCHAR(255),
  "PersonInChargeDialNumber" VARCHAR(30),
  "ExpectedCorrectiveActionDate" DATE,
  "CorrectiveActionRequestDocumentReference" VARCHAR(255),
  "CorrectiveActionApprovalIndicator" BOOLEAN,
  "CorrectiveActionStatusCode" VARCHAR(30),
  "ReasonForRejection" VARCHAR(255),
  CONSTRAINT "UK_CorrectiveActionPlan" UNIQUE ("EnterpriseID", "CorrectiveActionPlanID")
);
COMMENT ON TABLE ksx."CorrectiveActionPlan" IS '시정조치계획 — 공급사에서 시정조치 사항을 기술하고, 시정조치 계획을 수립하여 고객사에게 전달하는 것을 의미한다.';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionPlanSequenceNo" IS '시정조치계획 일련번호';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."Note" IS '비고';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionRequestID" IS '시정조치요청식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionPlanID" IS '시정조치계획식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."PersonInChargeID" IS '시정조치담당자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."PersonInChargeEmail" IS '시정조치담당자이메일명';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."PersonInChargeDialNumber" IS '시정조치담당자전화번호';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ExpectedCorrectiveActionDate" IS '시정조치예정일';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionRequestDocumentReference" IS '시정조치요청첨부자료';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionApprovalIndicator" IS '시정조치접수여부';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."CorrectiveActionStatusCode" IS '시정조치상태코드';
COMMENT ON COLUMN ksx."CorrectiveActionPlan"."ReasonForRejection" IS '반려사유';

CREATE TABLE ksx."CorrectiveActionResult" (
  "CorrectiveActionResultSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "VendorID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "CorrectiveActionRequestID" VARCHAR(50),
  "CorrectiveActionPlanID" VARCHAR(50),
  "CorrectiveActionResultID" VARCHAR(50) NOT NULL,
  "PersonInChargeID" VARCHAR(50),
  "PersonInChargeEmail" VARCHAR(255),
  "PersonInChargeDialNumber" VARCHAR(30),
  "CorrectiveActionConfirmorID" VARCHAR(50),
  "CorrectiveActionConfirmorEmail" VARCHAR(255),
  "CorrectiveActionConfirmorDialNumber" VARCHAR(30),
  "CorrectiveActionDateTime" TIMESTAMP,
  "CorrectiveActionResultDescription" VARCHAR(1000),
  "CorrectiveActionStatusCode" VARCHAR(30),
  "ReasonForRejection" VARCHAR(255),
  CONSTRAINT "UK_CorrectiveActionResult" UNIQUE ("EnterpriseID", "CorrectiveActionResultID")
);
COMMENT ON TABLE ksx."CorrectiveActionResult" IS '시정조치결과 — 시정조치계획에 따라 수행 결과를 고객사에 전달하는 것을 의미한다.';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionResultSequenceNo" IS '시정조치결과 일련번호';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."Note" IS '비고';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionRequestID" IS '시정조치요청식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionPlanID" IS '시정조치계획식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionResultID" IS '시정조치결과식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."PersonInChargeID" IS '시정조치담당자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."PersonInChargeEmail" IS '시정조치담당자이메일명';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."PersonInChargeDialNumber" IS '시정조치담당자전화번호';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionConfirmorID" IS '시정조치확인자식별자';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionConfirmorEmail" IS '시정조치확인자이메일명';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionConfirmorDialNumber" IS '시정조치확인자전화번호';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionDateTime" IS '시정조치일시';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionResultDescription" IS '시정조치결과내용';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."CorrectiveActionStatusCode" IS '시정조치상태코드';
COMMENT ON COLUMN ksx."CorrectiveActionResult"."ReasonForRejection" IS '반려사유';

CREATE TABLE ksx."ProductPacking" (
  "ProductPackingSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "PackingType" VARCHAR(30),
  "WarehouseID" VARCHAR(50),
  "SerialNumber" VARCHAR(50),
  "BoxNumber" VARCHAR(50) NOT NULL,
  "PalletNumber" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "PackingSequence" INTEGER NOT NULL,
  "LotID" VARCHAR(50),
  CONSTRAINT "UK_ProductPacking" UNIQUE ("EnterpriseID", "BoxNumber", "PackingSequence")
);
COMMENT ON TABLE ksx."ProductPacking" IS '제품포장 — 제품 출하를 위해 완성된 제품을 포장하기 위한 정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductPacking"."ProductPackingSequenceNo" IS '제품포장 일련번호';
COMMENT ON COLUMN ksx."ProductPacking"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductPacking"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductPacking"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductPacking"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductPacking"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductPacking"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductPacking"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductPacking"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductPacking"."PackingType" IS '포장유형';
COMMENT ON COLUMN ksx."ProductPacking"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."ProductPacking"."SerialNumber" IS '일련번호';
COMMENT ON COLUMN ksx."ProductPacking"."BoxNumber" IS '포장박스번호';
COMMENT ON COLUMN ksx."ProductPacking"."PalletNumber" IS '포장파렛트번호';
COMMENT ON COLUMN ksx."ProductPacking"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductPacking"."PackingSequence" IS '포장순번';
COMMENT ON COLUMN ksx."ProductPacking"."LotID" IS '로트식별자';

CREATE TABLE ksx."EquipmentParameter" (
  "EquipmentParameterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ParameterID" VARCHAR(50) NOT NULL,
  "ParameterName" VARCHAR(200),
  "ParameterType" VARCHAR(30),
  "ParameterGrade" VARCHAR(30),
  "ParameterUOMCode" VARCHAR(20),
  "EquipmentID" VARCHAR(50),
  "LSL" NUMERIC(18,6),
  "USL" NUMERIC(18,6),
  "PeriodicDataCollectionIndicator" BOOLEAN,
  "DataCollectionPeriod" INTERVAL,
  CONSTRAINT "UK_EquipmentParameter" UNIQUE ("EnterpriseID", "ParameterID")
);
COMMENT ON TABLE ksx."EquipmentParameter" IS '설비파라미터 — 설비에서 수집되는 Parameter 값의 집합을 의미한다.';
COMMENT ON COLUMN ksx."EquipmentParameter"."EquipmentParameterSequenceNo" IS '설비파라미터 일련번호';
COMMENT ON COLUMN ksx."EquipmentParameter"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."EquipmentParameter"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."EquipmentParameter"."Note" IS '비고';
COMMENT ON COLUMN ksx."EquipmentParameter"."ParameterID" IS '파라미터식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."ParameterName" IS '파라미터명';
COMMENT ON COLUMN ksx."EquipmentParameter"."ParameterType" IS '파라미터유형';
COMMENT ON COLUMN ksx."EquipmentParameter"."ParameterGrade" IS '파라미터등급';
COMMENT ON COLUMN ksx."EquipmentParameter"."ParameterUOMCode" IS '파라미터단위코드';
COMMENT ON COLUMN ksx."EquipmentParameter"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."EquipmentParameter"."LSL" IS '규격하한';
COMMENT ON COLUMN ksx."EquipmentParameter"."USL" IS '규격상한';
COMMENT ON COLUMN ksx."EquipmentParameter"."PeriodicDataCollectionIndicator" IS '주기적수집여부';
COMMENT ON COLUMN ksx."EquipmentParameter"."DataCollectionPeriod" IS '수집주기';

CREATE TABLE ksx."TraceParameter" (
  "TraceParameterSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "TraceParameterID" VARCHAR(50) NOT NULL,
  "EquipmentID" VARCHAR(50),
  "ParameterID" VARCHAR(50),
  "EventDateTime" TIMESTAMP,
  "ParameterUOMCode" VARCHAR(20),
  "ParameterValue" NUMERIC(18,6),
  "ValidationResultCode" VARCHAR(30),
  CONSTRAINT "UK_TraceParameter" UNIQUE ("EnterpriseID", "TraceParameterID")
);
COMMENT ON TABLE ksx."TraceParameter" IS '설비파라미터이력 — 설비에서 수집되는 Parameter 값의 적재 및 검증 이력을 의미한다.';
COMMENT ON COLUMN ksx."TraceParameter"."TraceParameterSequenceNo" IS '설비파라미터이력 일련번호';
COMMENT ON COLUMN ksx."TraceParameter"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."TraceParameter"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."TraceParameter"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."TraceParameter"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."TraceParameter"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."TraceParameter"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."TraceParameter"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."TraceParameter"."Note" IS '비고';
COMMENT ON COLUMN ksx."TraceParameter"."TraceParameterID" IS '설비파라미터이력식별자';
COMMENT ON COLUMN ksx."TraceParameter"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."TraceParameter"."ParameterID" IS '파라미터식별자';
COMMENT ON COLUMN ksx."TraceParameter"."EventDateTime" IS '이벤트발생일시';
COMMENT ON COLUMN ksx."TraceParameter"."ParameterUOMCode" IS '파라미터단위코드';
COMMENT ON COLUMN ksx."TraceParameter"."ParameterValue" IS '파라미터값';
COMMENT ON COLUMN ksx."TraceParameter"."ValidationResultCode" IS '검증결과코드';

CREATE TABLE ksx."ProductionPerformance" (
  "ProductionPerformanceSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPerformanceID" VARCHAR(50) NOT NULL,
  "ProductionPerformanceSequence" INTEGER NOT NULL,
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "ItemID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "ProducedQuantity" NUMERIC(18,6),
  "DefectQuantity" NUMERIC(18,6),
  "ReworkQuantity" INTEGER,
  "OperationID" VARCHAR(50),
  "RoutingID" VARCHAR(50),
  "OperationSequence" INTEGER,
  "PersonnelID" VARCHAR(50),
  "ProductionPerformanceDate" DATE,
  "ExecutionStartDateTime" TIMESTAMP,
  "ExecutionEndDateTime" TIMESTAMP,
  "CancelIndicator" BOOLEAN,
  "CancelDateTime" TIMESTAMP,
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  CONSTRAINT "UK_ProductionPerformance" UNIQUE ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence")
);
COMMENT ON TABLE ksx."ProductionPerformance" IS '생산실적 — 생산지시에 의해 실행된 생산의 실적 결과 정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionPerformanceSequenceNo" IS '생산실적 일련번호';
COMMENT ON COLUMN ksx."ProductionPerformance"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPerformance"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPerformance"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionPerformanceID" IS '생산실적식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionPerformanceSequence" IS '생산실적순번';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionPerformance"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProducedQuantity" IS '생산수량';
COMMENT ON COLUMN ksx."ProductionPerformance"."DefectQuantity" IS '불량수량';
COMMENT ON COLUMN ksx."ProductionPerformance"."ReworkQuantity" IS '재작업수량';
COMMENT ON COLUMN ksx."ProductionPerformance"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."OperationSequence" IS '공정순번';
COMMENT ON COLUMN ksx."ProductionPerformance"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ProductionPerformanceDate" IS '생산실적일자';
COMMENT ON COLUMN ksx."ProductionPerformance"."ExecutionStartDateTime" IS '생산시작일시';
COMMENT ON COLUMN ksx."ProductionPerformance"."ExecutionEndDateTime" IS '생산종료일시';
COMMENT ON COLUMN ksx."ProductionPerformance"."CancelIndicator" IS '취소여부';
COMMENT ON COLUMN ksx."ProductionPerformance"."CancelDateTime" IS '취소일시';
COMMENT ON COLUMN ksx."ProductionPerformance"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."ProductionPerformance"."BatchID" IS '배치식별자';

CREATE TABLE ksx."ProductionPerformanceItem" (
  "ProductionPerformanceItemSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPerformanceID" VARCHAR(50) NOT NULL,
  "ProductionPerformanceSequence" INTEGER NOT NULL,
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "ItemID" VARCHAR(50) NOT NULL,
  "ItemUOMCode" VARCHAR(20),
  "LineID" VARCHAR(50),
  "OperationID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "ReplacementChildItemID" VARCHAR(50),
  "WarehouseID" VARCHAR(50),
  "WarehouseSection" VARCHAR(255),
  "RequiredQuantity" INTEGER,
  "IssuedQuantity" INTEGER,
  "IssuedIndicator" BOOLEAN,
  CONSTRAINT "UK_ProductionPerformanceItem" UNIQUE ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence", "ItemID")
);
COMMENT ON TABLE ksx."ProductionPerformanceItem" IS '생산실적투입품목 — 생산 과정에서 투입되는 모든 품목(원자재, 부자재, 반제품, 완제품 등) 관련 정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ProductionPerformanceItemSequenceNo" IS '생산실적투입품목 일련번호';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ProductionPerformanceID" IS '생산실적식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ProductionPerformanceSequence" IS '생산실적순번';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."LineID" IS '라인식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."ReplacementChildItemID" IS '대체자재식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."WarehouseSection" IS '창고섹션';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."RequiredQuantity" IS '소요수량';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."IssuedQuantity" IS '출고수량';
COMMENT ON COLUMN ksx."ProductionPerformanceItem"."IssuedIndicator" IS '출고완료여부';

CREATE TABLE ksx."ProductionPerformancePersonnel" (
  "ProductionPerformancePersonnelSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPerformanceID" VARCHAR(50) NOT NULL,
  "ProductionPerformanceSequence" INTEGER NOT NULL,
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "OperationID" VARCHAR(50),
  "PersonnelID" VARCHAR(50) NOT NULL,
  "ExecutionStartDateTime" TIMESTAMP,
  "ExecutionEndDateTime" TIMESTAMP,
  "TaskGroupCode" VARCHAR(30),
  "ActualLaborDateTime" TIMESTAMP,
  "ActualLaborTime" NUMERIC(18,6),
  "ActualLaborTimeUOMCode" VARCHAR(20),
  CONSTRAINT "UK_ProductionPerformancePersonnel" UNIQUE ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence", "PersonnelID")
);
COMMENT ON TABLE ksx."ProductionPerformancePersonnel" IS '생산실적투입인력 — 생산 과정에서 투입된 인력정보를 의미한다. 생산실적투입인력 명사는 표 65와같은 정보 속성을 포함하고 있다.';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ProductionPerformancePersonnelSequenceNo" IS '생산실적투입인력 일련번호';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ProductionPerformanceID" IS '생산실적식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ProductionPerformanceSequence" IS '생산실적순번';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ExecutionStartDateTime" IS '생산시작일시';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ExecutionEndDateTime" IS '생산종료일시';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."TaskGroupCode" IS '근무조코드';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ActualLaborDateTime" IS '투입일시';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ActualLaborTime" IS '투입시간';
COMMENT ON COLUMN ksx."ProductionPerformancePersonnel"."ActualLaborTimeUOMCode" IS '투입시간단위코드';

CREATE TABLE ksx."ProductionPerformanceEquipment" (
  "ProductionPerformanceEquipmentSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPerformanceID" VARCHAR(50) NOT NULL,
  "ProductionPerformanceSequence" INTEGER NOT NULL,
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "ItemUOMCode" VARCHAR(20),
  "ProducedQuantity" NUMERIC(18,6),
  "DefectQuantity" NUMERIC(18,6),
  "OperationID" VARCHAR(50),
  "RoutingID" VARCHAR(50),
  "OperationSequence" INTEGER,
  "PersonnelID" VARCHAR(50),
  "ExecutionStartDateTime" TIMESTAMP,
  "ExecutionEndDateTime" TIMESTAMP,
  "CancelIndicator" BOOLEAN,
  "CancelDateTime" TIMESTAMP,
  "EquipmentID" VARCHAR(50) NOT NULL,
  "SetupTime" INTERVAL,
  "RunTime" INTERVAL,
  "InspectionFinishedIndicator" BOOLEAN,
  CONSTRAINT "UK_ProductionPerformanceEquipment" UNIQUE ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence", "EquipmentID")
);
COMMENT ON TABLE ksx."ProductionPerformanceEquipment" IS '설비활용실적 — 생산 과정에서 사용된 설비의 활용실적 정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProductionPerformanceEquipmentSequenceNo" IS '설비활용실적 일련번호';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProductionPerformanceID" IS '생산실적식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProductionPerformanceSequence" IS '생산실적순번';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ProducedQuantity" IS '생산수량';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."DefectQuantity" IS '불량수량';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."OperationSequence" IS '공정순번';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."PersonnelID" IS '사원식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ExecutionStartDateTime" IS '생산시작일시';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."ExecutionEndDateTime" IS '생산종료일시';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."CancelIndicator" IS '취소여부';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."CancelDateTime" IS '취소일시';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."EquipmentID" IS '설비식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."SetupTime" IS '준비시간';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."RunTime" IS '가동시간';
COMMENT ON COLUMN ksx."ProductionPerformanceEquipment"."InspectionFinishedIndicator" IS '공정검사여부';

CREATE TABLE ksx."ProductionPerformanceQuality" (
  "ProductionPerformanceQualitySequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductionPerformanceID" VARCHAR(50) NOT NULL,
  "ProductionPerformanceSequence" INTEGER NOT NULL,
  "ProductionOrderID" VARCHAR(50),
  "ProductionOrderSequence" INTEGER,
  "ItemID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "OperationID" VARCHAR(50),
  "RoutingID" VARCHAR(50),
  "OperationSequence" INTEGER,
  "ExecutionStartDateTime" TIMESTAMP,
  "ExecutionEndDateTime" TIMESTAMP,
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "DefectTypeQuantity" INTEGER,
  "DefectTypeCode" VARCHAR(30) NOT NULL,
  "DefectTypeDetailCode" VARCHAR(30) NOT NULL,
  CONSTRAINT "UK_ProductionPerformanceQuality" UNIQUE ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence", "DefectTypeCode", "DefectTypeDetailCode")
);
COMMENT ON TABLE ksx."ProductionPerformanceQuality" IS '생산품질실적 — 생산 과정에서 발생한 품질정보를 의미한다.';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ProductionPerformanceQualitySequenceNo" IS '생산품질실적 일련번호';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ProductionPerformanceID" IS '생산실적식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ProductionPerformanceSequence" IS '생산실적순번';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ProductionOrderID" IS '생산지시식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ProductionOrderSequence" IS '생산지시순번';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."OperationID" IS '공정식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."RoutingID" IS '공정경로식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."OperationSequence" IS '공정순번';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ExecutionStartDateTime" IS '생산시작일시';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."ExecutionEndDateTime" IS '생산종료일시';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."DefectTypeQuantity" IS '불량유형별수량';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."DefectTypeCode" IS '불량유형코드';
COMMENT ON COLUMN ksx."ProductionPerformanceQuality"."DefectTypeDetailCode" IS '불량유형상세코드';

CREATE TABLE ksx."Inventory" (
  "InventorySequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "WarehouseID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50) NOT NULL,
  "InventoryQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  CONSTRAINT "UK_Inventory" UNIQUE ("EnterpriseID", "WarehouseID", "ItemID")
);
COMMENT ON TABLE ksx."Inventory" IS '재고 — 저장위치에 있는 품목의 실제 보유(On-hand) 수량을 의미한다.';
COMMENT ON COLUMN ksx."Inventory"."InventorySequenceNo" IS '재고 일련번호';
COMMENT ON COLUMN ksx."Inventory"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Inventory"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Inventory"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Inventory"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Inventory"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Inventory"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Inventory"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Inventory"."Note" IS '비고';
COMMENT ON COLUMN ksx."Inventory"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."Inventory"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."Inventory"."InventoryQuantity" IS '현재고수량';
COMMENT ON COLUMN ksx."Inventory"."ItemUOMCode" IS '기준단위코드';

CREATE TABLE ksx."AvailableInventory" (
  "AvailableInventorySequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "AvailableInventoryID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "AvailableInventoryQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "DemandPriority" NUMERIC(18,6),
  "PriorDemandQuantity" NUMERIC(18,6),
  "ExpectedDeliveryDate" DATE,
  CONSTRAINT "UK_AvailableInventory" UNIQUE ("EnterpriseID", "AvailableInventoryID")
);
COMMENT ON TABLE ksx."AvailableInventory" IS '가용재고 — 현 재고와 특정 시점까지의 예상 입출고를 감안하여 사용 가능한 재고를 의미한다.';
COMMENT ON COLUMN ksx."AvailableInventory"."AvailableInventorySequenceNo" IS '가용재고 일련번호';
COMMENT ON COLUMN ksx."AvailableInventory"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."AvailableInventory"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."AvailableInventory"."Note" IS '비고';
COMMENT ON COLUMN ksx."AvailableInventory"."AvailableInventoryID" IS '가용재고식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."AvailableInventory"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."AvailableInventory"."AvailableInventoryQuantity" IS '가용재고량';
COMMENT ON COLUMN ksx."AvailableInventory"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."AvailableInventory"."DemandPriority" IS '요청우선순위';
COMMENT ON COLUMN ksx."AvailableInventory"."PriorDemandQuantity" IS '요청우선수량';
COMMENT ON COLUMN ksx."AvailableInventory"."ExpectedDeliveryDate" IS '납기예정일';

CREATE TABLE ksx."StockTransfer" (
  "StockTransferSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "StockTransferID" VARCHAR(50) NOT NULL,
  "InventoryTransactionDocumentNumber" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "WarehouseID" VARCHAR(50),
  "ReceiptWarehouseID" VARCHAR(50),
  "StockTransferQuantity" NUMERIC(18,6),
  "TransferDateTime" TIMESTAMP,
  CONSTRAINT "UK_StockTransfer" UNIQUE ("EnterpriseID", "StockTransferID")
);
COMMENT ON TABLE ksx."StockTransfer" IS '재고이동 — 재고가 다른 창고로 이동하기 위해 필요한 정보를 의미한다.';
COMMENT ON COLUMN ksx."StockTransfer"."StockTransferSequenceNo" IS '재고이동 일련번호';
COMMENT ON COLUMN ksx."StockTransfer"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."StockTransfer"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."StockTransfer"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."StockTransfer"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."StockTransfer"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."StockTransfer"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."StockTransfer"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."StockTransfer"."Note" IS '비고';
COMMENT ON COLUMN ksx."StockTransfer"."StockTransferID" IS '재고이동식별자';
COMMENT ON COLUMN ksx."StockTransfer"."InventoryTransactionDocumentNumber" IS '수불문서번호';
COMMENT ON COLUMN ksx."StockTransfer"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."StockTransfer"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."StockTransfer"."ReceiptWarehouseID" IS '입고창고식별자';
COMMENT ON COLUMN ksx."StockTransfer"."StockTransferQuantity" IS '재고이동수량';
COMMENT ON COLUMN ksx."StockTransfer"."TransferDateTime" IS '이동일시';

CREATE TABLE ksx."InventoryCount" (
  "InventoryCountSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "InventoryCountDocumentNumber" VARCHAR(50) NOT NULL,
  "InventoryCountDateTime" TIMESTAMP,
  "WarehouseID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50) NOT NULL,
  "InventoryQuantity" NUMERIC(18,6),
  "InventoryCountQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  CONSTRAINT "UK_InventoryCount" UNIQUE ("EnterpriseID", "InventoryCountDocumentNumber", "WarehouseID", "ItemID")
);
COMMENT ON TABLE ksx."InventoryCount" IS '재고실사 — 보관된 재고에 대해 실수량을 파악하기 위한 정보를 의미한다.';
COMMENT ON COLUMN ksx."InventoryCount"."InventoryCountSequenceNo" IS '재고실사 일련번호';
COMMENT ON COLUMN ksx."InventoryCount"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."InventoryCount"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."InventoryCount"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."InventoryCount"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."InventoryCount"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."InventoryCount"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."InventoryCount"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."InventoryCount"."Note" IS '비고';
COMMENT ON COLUMN ksx."InventoryCount"."InventoryCountDocumentNumber" IS '재고실사문서번호';
COMMENT ON COLUMN ksx."InventoryCount"."InventoryCountDateTime" IS '재고실사일시';
COMMENT ON COLUMN ksx."InventoryCount"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."InventoryCount"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."InventoryCount"."InventoryQuantity" IS '현재고수량';
COMMENT ON COLUMN ksx."InventoryCount"."InventoryCountQuantity" IS '실사수량';
COMMENT ON COLUMN ksx."InventoryCount"."ItemUOMCode" IS '기준단위코드';

CREATE TABLE ksx."ProductIncoming" (
  "ProductIncomingSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductIncomingID" VARCHAR(50) NOT NULL,
  "ProductIncomingSequence" INTEGER NOT NULL,
  "InventoryTransactionDocumentNumber" VARCHAR(50),
  "InventoryTransactionDocumentSequence" INTEGER,
  "InventoryTransactionDate" DATE,
  "ItemID" VARCHAR(50),
  "CustomerID" VARCHAR(50),
  "WarehouseID" VARCHAR(50),
  "InventoryTransactionTypeCode" VARCHAR(30),
  "SerialUseIndicator" BOOLEAN,
  "InventoryTransferType" VARCHAR(30),
  "InventoryVariationType" VARCHAR(30),
  "InventoryTransactionType" VARCHAR(30),
  "LotControlIndicator" BOOLEAN,
  "LotID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "OrderUOMCode" VARCHAR(20),
  "OrderQuantity" NUMERIC(18,6),
  CONSTRAINT "UK_ProductIncoming" UNIQUE ("EnterpriseID", "ProductIncomingID", "ProductIncomingSequence")
);
COMMENT ON TABLE ksx."ProductIncoming" IS '제품입고 — 생산된 제품을 창고에 저장하는 것을 의미한다.';
COMMENT ON COLUMN ksx."ProductIncoming"."ProductIncomingSequenceNo" IS '제품입고 일련번호';
COMMENT ON COLUMN ksx."ProductIncoming"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductIncoming"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductIncoming"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductIncoming"."ProductIncomingID" IS '제품입고식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."ProductIncomingSequence" IS '제품입고순번';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransactionDocumentNumber" IS '수불문서번호';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransactionDocumentSequence" IS '수불문서순번';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransactionDate" IS '수불일';
COMMENT ON COLUMN ksx."ProductIncoming"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransactionTypeCode" IS '수불유형코드';
COMMENT ON COLUMN ksx."ProductIncoming"."SerialUseIndicator" IS '시리얼사용여부';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransferType" IS '입출고유형';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryVariationType" IS '재고증감유형';
COMMENT ON COLUMN ksx."ProductIncoming"."InventoryTransactionType" IS '수불유형';
COMMENT ON COLUMN ksx."ProductIncoming"."LotControlIndicator" IS '로트사용여부';
COMMENT ON COLUMN ksx."ProductIncoming"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."ProductIncoming"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductIncoming"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."ProductIncoming"."OrderUOMCode" IS '오더단위코드';
COMMENT ON COLUMN ksx."ProductIncoming"."OrderQuantity" IS '오더수량';

CREATE TABLE ksx."ProductReleaseRequestHeader" (
  "ProductReleaseRequestHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductReleaseRequestID" VARCHAR(50) NOT NULL,
  "ProductReleaseRequestDocumentNumber" VARCHAR(50),
  "ProductReleaseRequestType" VARCHAR(30),
  "ProductReleaseRequestDate" DATE,
  "CustomerID" VARCHAR(50),
  CONSTRAINT "UK_ProductReleaseRequestHeader" UNIQUE ("EnterpriseID", "ProductReleaseRequestID")
);
COMMENT ON TABLE ksx."ProductReleaseRequestHeader" IS '출하의뢰헤더 — 출하의뢰(ProductReleaseRequest) 명사의 헤더 구조체(struct) 출하의뢰 문서 1건의 공통 정보(납품문서번호, 납품구분유형, 납품지시일, 고객사) 출하의뢰마다 1회 나타남';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ProductReleaseRequestHeaderSequenceNo" IS '출하의뢰헤더 일련번호';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ProductReleaseRequestID" IS '출하요청식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ProductReleaseRequestDocumentNumber" IS '납품문서번호';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ProductReleaseRequestType" IS '납품구분유형';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."ProductReleaseRequestDate" IS '납품지시일';
COMMENT ON COLUMN ksx."ProductReleaseRequestHeader"."CustomerID" IS '고객사식별자';

CREATE TABLE ksx."ProductReleaseRequestLine" (
  "ProductReleaseRequestLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductReleaseRequestID" VARCHAR(50) NOT NULL,
  "ProductReleaseRequestSequence" INTEGER NOT NULL,
  "LineID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "ProductReleaseRequestQuantity" NUMERIC(18,6),
  "ProductReleaseQuantity" NUMERIC(18,6),
  "SalesQuantity" NUMERIC(18,6),
  "ItemUOMCode" VARCHAR(20),
  "SellingUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "ProductReleaseUnitQuantity" NUMERIC(18,6),
  "SalesUnitQuantity" NUMERIC(18,6),
  "WarehouseID" VARCHAR(50),
  "RequestedDeliveryDate" DATE,
  "SalesDocumentNumber" VARCHAR(50),
  "SalesDocumentSequence" INTEGER,
  "ProductReleaseDate" DATE,
  "DeliveryDate" DATE,
  CONSTRAINT "UK_ProductReleaseRequestLine" UNIQUE ("EnterpriseID", "ProductReleaseRequestID", "ProductReleaseRequestSequence")
);
COMMENT ON TABLE ksx."ProductReleaseRequestLine" IS '출하의뢰라인 — 출하의뢰(ProductReleaseRequest) 명사의 라인 구조체(struct[1..N]) 출하의뢰 문서를 구성하는 품목 행 정보 출하의뢰헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseRequestLineSequenceNo" IS '출하의뢰라인 일련번호';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseRequestID" IS '출하요청식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseRequestSequence" IS '납품순번';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."LineID" IS '라인식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseRequestQuantity" IS '납품수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseQuantity" IS '출고수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SalesQuantity" IS '매출수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SellingUOMCode" IS '판매단위코드';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseUnitQuantity" IS '기준출고수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SalesUnitQuantity" IS '기준매출수량';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."RequestedDeliveryDate" IS '요청납기일';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."SalesDocumentSequence" IS '수주문서순번';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."ProductReleaseDate" IS '출고일';
COMMENT ON COLUMN ksx."ProductReleaseRequestLine"."DeliveryDate" IS '납품일';

CREATE TABLE ksx."ProductRelease" (
  "ProductReleaseSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductReleaseID" VARCHAR(50) NOT NULL,
  "ProductReleaseSequence" INTEGER NOT NULL,
  "ProductReleaseRequestID" VARCHAR(50),
  "SalesDocumentNumber" VARCHAR(50),
  "SalesDocumentSequence" INTEGER,
  "InventoryTransactionDate" DATE,
  "LineID" VARCHAR(50),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "OrderUOMCode" VARCHAR(20),
  "OrderQuantity" NUMERIC(18,6),
  "SellingUOMCode" VARCHAR(20),
  "SalesQuantity" NUMERIC(18,6),
  "ReturnIndicator" BOOLEAN,
  "ItemUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "SalesUnitQuantity" NUMERIC(18,6),
  "ReturnUnitQuantity" NUMERIC(18,6),
  "CustomerID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "SerialUseIndicator" BOOLEAN,
  "WarehouseID" VARCHAR(50),
  CONSTRAINT "UK_ProductRelease" UNIQUE ("EnterpriseID", "ProductReleaseID", "ProductReleaseSequence")
);
COMMENT ON TABLE ksx."ProductRelease" IS '제품출고 — 수주된 품목을 고객에게 보내는 것을 의미한다.';
COMMENT ON COLUMN ksx."ProductRelease"."ProductReleaseSequenceNo" IS '제품출고 일련번호';
COMMENT ON COLUMN ksx."ProductRelease"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductRelease"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductRelease"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductRelease"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductRelease"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductRelease"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductRelease"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductRelease"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductRelease"."ProductReleaseID" IS '출고식별자';
COMMENT ON COLUMN ksx."ProductRelease"."ProductReleaseSequence" IS '출고순번';
COMMENT ON COLUMN ksx."ProductRelease"."ProductReleaseRequestID" IS '출하요청식별자';
COMMENT ON COLUMN ksx."ProductRelease"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."ProductRelease"."SalesDocumentSequence" IS '수주문서순번';
COMMENT ON COLUMN ksx."ProductRelease"."InventoryTransactionDate" IS '수불일';
COMMENT ON COLUMN ksx."ProductRelease"."LineID" IS '라인식별자';
COMMENT ON COLUMN ksx."ProductRelease"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductRelease"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."ProductRelease"."OrderUOMCode" IS '오더단위코드';
COMMENT ON COLUMN ksx."ProductRelease"."OrderQuantity" IS '오더수량';
COMMENT ON COLUMN ksx."ProductRelease"."SellingUOMCode" IS '판매단위코드';
COMMENT ON COLUMN ksx."ProductRelease"."SalesQuantity" IS '매출수량';
COMMENT ON COLUMN ksx."ProductRelease"."ReturnIndicator" IS '반품여부';
COMMENT ON COLUMN ksx."ProductRelease"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."ProductRelease"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."ProductRelease"."SalesUnitQuantity" IS '기준매출수량';
COMMENT ON COLUMN ksx."ProductRelease"."ReturnUnitQuantity" IS '기준반품수량';
COMMENT ON COLUMN ksx."ProductRelease"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."ProductRelease"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."ProductRelease"."SerialUseIndicator" IS '시리얼사용여부';
COMMENT ON COLUMN ksx."ProductRelease"."WarehouseID" IS '창고식별자';

CREATE TABLE ksx."DeliveryHeader" (
  "DeliveryHeaderSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "DeliveryID" VARCHAR(50) NOT NULL,
  "DeliveryDateTime" TIMESTAMP,
  "CustomerID" VARCHAR(50),
  "PackingList" VARCHAR(1000),
  "PackingType" VARCHAR(30),
  "TransportationMethodCode" VARCHAR(30),
  "DepartmentInChargeID" VARCHAR(50),
  "DepartmentInChargeName" VARCHAR(200),
  "PersonInChargeID" VARCHAR(50),
  "PersonInChargeName" VARCHAR(200),
  "PersonInChargeDialNumber" VARCHAR(30),
  "TransportationCompany" VARCHAR(255),
  "PersonInChargeNameOfTransportation" VARCHAR(255),
  "PersonInChargeDialNumberOfTransportation" VARCHAR(255),
  "Recipient" VARCHAR(255),
  "RecipientDialNumber" VARCHAR(30),
  "RecipientEmail" VARCHAR(255),
  "ShippingPoint" VARCHAR(255),
  "ShipToAddress" VARCHAR(1000),
  "PreferredReceiptDate" DATE,
  "DeliveryNote" VARCHAR(1000),
  "DeliveryConfirmationDocument" VARCHAR(255),
  CONSTRAINT "UK_DeliveryHeader" UNIQUE ("EnterpriseID", "DeliveryID")
);
COMMENT ON TABLE ksx."DeliveryHeader" IS '배송헤더 — 배송(Delivery) 명사의 헤더 구조체(struct) 특정 수량의 물품을 공급업체에서 단일 고객 목적지로 운송하는 데 사용되는 배송 1건의 공통 정보 배송마다 1회 나타남';
COMMENT ON COLUMN ksx."DeliveryHeader"."DeliveryHeaderSequenceNo" IS '배송헤더 일련번호';
COMMENT ON COLUMN ksx."DeliveryHeader"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."DeliveryHeader"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."DeliveryHeader"."Note" IS '비고';
COMMENT ON COLUMN ksx."DeliveryHeader"."DeliveryID" IS '배송식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."DeliveryDateTime" IS '배송일시';
COMMENT ON COLUMN ksx."DeliveryHeader"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."PackingList" IS '포장내용';
COMMENT ON COLUMN ksx."DeliveryHeader"."PackingType" IS '포장유형';
COMMENT ON COLUMN ksx."DeliveryHeader"."TransportationMethodCode" IS '운송방법';
COMMENT ON COLUMN ksx."DeliveryHeader"."DepartmentInChargeID" IS '배송처리담당부서식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."DepartmentInChargeName" IS '배송처리담당부서명';
COMMENT ON COLUMN ksx."DeliveryHeader"."PersonInChargeID" IS '배송처리담당자식별자';
COMMENT ON COLUMN ksx."DeliveryHeader"."PersonInChargeName" IS '배송처리담당자명';
COMMENT ON COLUMN ksx."DeliveryHeader"."PersonInChargeDialNumber" IS '배송처리담당자전화번호';
COMMENT ON COLUMN ksx."DeliveryHeader"."TransportationCompany" IS '운송사';
COMMENT ON COLUMN ksx."DeliveryHeader"."PersonInChargeNameOfTransportation" IS '운송담당자명';
COMMENT ON COLUMN ksx."DeliveryHeader"."PersonInChargeDialNumberOfTransportation" IS '운송담당자전화번호';
COMMENT ON COLUMN ksx."DeliveryHeader"."Recipient" IS '수취인';
COMMENT ON COLUMN ksx."DeliveryHeader"."RecipientDialNumber" IS '수취인전화번호';
COMMENT ON COLUMN ksx."DeliveryHeader"."RecipientEmail" IS '수취인이메일';
COMMENT ON COLUMN ksx."DeliveryHeader"."ShippingPoint" IS '선적지';
COMMENT ON COLUMN ksx."DeliveryHeader"."ShipToAddress" IS '배송지';
COMMENT ON COLUMN ksx."DeliveryHeader"."PreferredReceiptDate" IS '인수희망일';
COMMENT ON COLUMN ksx."DeliveryHeader"."DeliveryNote" IS '배송메모';
COMMENT ON COLUMN ksx."DeliveryHeader"."DeliveryConfirmationDocument" IS '납품확인서';

CREATE TABLE ksx."DeliveryLine" (
  "DeliveryLineSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "DeliveryID" VARCHAR(50) NOT NULL,
  "DeliveryLineSequence" INTEGER NOT NULL,
  "ProductReleaseID" VARCHAR(50),
  "ProductReleaseSequence" INTEGER,
  "SalesDocumentNumber" VARCHAR(50),
  "SalesDocumentSequence" INTEGER,
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "InvoiceNumber" VARCHAR(50),
  "LotID" VARCHAR(50),
  "ItemUOMCode" VARCHAR(20),
  "ItemUnitQuantity" NUMERIC(18,6),
  "OrderUOMCode" VARCHAR(20),
  "OrderQuantity" NUMERIC(18,6),
  "ProductDeliveryUOMCode" VARCHAR(20),
  "ProductDeliveryQuantity" NUMERIC(18,6),
  "RequestedDeliveryDate" DATE,
  CONSTRAINT "UK_DeliveryLine" UNIQUE ("EnterpriseID", "DeliveryID", "DeliveryLineSequence")
);
COMMENT ON TABLE ksx."DeliveryLine" IS '배송라인 — 배송(Delivery) 명사의 라인 구조체(struct[1..N]) 납품되는 품목 행 정보 배송헤더 아래에 1회 이상 반복하여 나타남(1..N)';
COMMENT ON COLUMN ksx."DeliveryLine"."DeliveryLineSequenceNo" IS '배송라인 일련번호';
COMMENT ON COLUMN ksx."DeliveryLine"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."DeliveryLine"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."DeliveryLine"."Note" IS '비고';
COMMENT ON COLUMN ksx."DeliveryLine"."DeliveryID" IS '배송식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."DeliveryLineSequence" IS '배송라인순번';
COMMENT ON COLUMN ksx."DeliveryLine"."ProductReleaseID" IS '출고식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."ProductReleaseSequence" IS '출고순번';
COMMENT ON COLUMN ksx."DeliveryLine"."SalesDocumentNumber" IS '수주문서번호';
COMMENT ON COLUMN ksx."DeliveryLine"."SalesDocumentSequence" IS '수주문서순번';
COMMENT ON COLUMN ksx."DeliveryLine"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."DeliveryLine"."InvoiceNumber" IS '거래명세서번호';
COMMENT ON COLUMN ksx."DeliveryLine"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."DeliveryLine"."ItemUOMCode" IS '기준단위코드';
COMMENT ON COLUMN ksx."DeliveryLine"."ItemUnitQuantity" IS '기준단위수량';
COMMENT ON COLUMN ksx."DeliveryLine"."OrderUOMCode" IS '오더단위코드';
COMMENT ON COLUMN ksx."DeliveryLine"."OrderQuantity" IS '오더수량';
COMMENT ON COLUMN ksx."DeliveryLine"."ProductDeliveryUOMCode" IS '납품단위코드';
COMMENT ON COLUMN ksx."DeliveryLine"."ProductDeliveryQuantity" IS '납품수량';
COMMENT ON COLUMN ksx."DeliveryLine"."RequestedDeliveryDate" IS '요청납품일';

CREATE TABLE ksx."Return" (
  "ReturnSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ReturnID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "LotID" VARCHAR(50),
  "BatchID" VARCHAR(50),
  "WarehouseID" VARCHAR(50),
  "ReturnSequence" INTEGER NOT NULL,
  "ReturnNumber" VARCHAR(50),
  "ProductReturnDocumentNumber" VARCHAR(50),
  "ReturnDateTime" TIMESTAMP,
  "CustomerID" VARCHAR(50),
  "VendorID" VARCHAR(50),
  "ReturnQuantity" NUMERIC(18,6),
  "ReturnType" VARCHAR(30),
  CONSTRAINT "UK_Return" UNIQUE ("EnterpriseID", "ReturnID", "ReturnSequence")
);
COMMENT ON TABLE ksx."Return" IS '반품 — 반품(구매반품, 제품반품)에 대한 정보를 의미한다.';
COMMENT ON COLUMN ksx."Return"."ReturnSequenceNo" IS '반품 일련번호';
COMMENT ON COLUMN ksx."Return"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."Return"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."Return"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."Return"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."Return"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."Return"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."Return"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."Return"."Note" IS '비고';
COMMENT ON COLUMN ksx."Return"."ReturnID" IS '반품식별자';
COMMENT ON COLUMN ksx."Return"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."Return"."LotID" IS '로트식별자';
COMMENT ON COLUMN ksx."Return"."BatchID" IS '배치식별자';
COMMENT ON COLUMN ksx."Return"."WarehouseID" IS '창고식별자';
COMMENT ON COLUMN ksx."Return"."ReturnSequence" IS '반품순서';
COMMENT ON COLUMN ksx."Return"."ReturnNumber" IS '반품번호';
COMMENT ON COLUMN ksx."Return"."ProductReturnDocumentNumber" IS '반품문서번호';
COMMENT ON COLUMN ksx."Return"."ReturnDateTime" IS '반품일시';
COMMENT ON COLUMN ksx."Return"."CustomerID" IS '고객사식별자';
COMMENT ON COLUMN ksx."Return"."VendorID" IS '공급사식별자';
COMMENT ON COLUMN ksx."Return"."ReturnQuantity" IS '반품수량';
COMMENT ON COLUMN ksx."Return"."ReturnType" IS '반품유형';

CREATE TABLE ksx."ProductTraceParameterOnCustomer" (
  "ProductTraceParameterOnCustomerSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ProductTraceParameterOnCustomerID" VARCHAR(50) NOT NULL,
  "ItemID" VARCHAR(50),
  "SerialNumber" VARCHAR(50),
  "Location" VARCHAR(1000),
  "ItemType" VARCHAR(30),
  "ParameterName" VARCHAR(200),
  "ParameterValue" NUMERIC(18,6),
  "CollectionDateTime" TIMESTAMP,
  CONSTRAINT "UK_ProductTraceParameterOnCustomer" UNIQUE ("EnterpriseID", "ProductTraceParameterOnCustomerID")
);
COMMENT ON TABLE ksx."ProductTraceParameterOnCustomer" IS '고객제품데이터 — 고객에게 판매 완료 후 부가적인 서비스 제공 및 가치창출을 위해 고객 제품에서 수집되는 데이터를 의미한다.';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ProductTraceParameterOnCustomerSequenceNo" IS '고객제품데이터 일련번호';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."Note" IS '비고';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ProductTraceParameterOnCustomerID" IS '고객제품데이터식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."SerialNumber" IS '제조번호';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."Location" IS '위치';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ItemType" IS '품목유형';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ParameterName" IS '파라미터명';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."ParameterValue" IS '파라미터값';
COMMENT ON COLUMN ksx."ProductTraceParameterOnCustomer"."CollectionDateTime" IS '수집일시';

CREATE TABLE ksx."AfterSalesServiceRequest" (
  "AfterSalesServiceRequestSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "RequestNumber" VARCHAR(50) NOT NULL,
  "TransferSequence" INTEGER,
  "BasicAcceptProcessCode" VARCHAR(30),
  "PromisedVisitDateTime" TIMESTAMP,
  "TransferRegistrationCode" VARCHAR(30),
  "SerialNumber" VARCHAR(50),
  CONSTRAINT "UK_AfterSalesServiceRequest" UNIQUE ("EnterpriseID", "RequestNumber")
);
COMMENT ON TABLE ksx."AfterSalesServiceRequest" IS '사후서비스신청 — 고객에게 판매된 제품의 고장으로 제조자 혹은 대리점 등에 고장 접수 시 필요한 데이터를 의미한다.';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."AfterSalesServiceRequestSequenceNo" IS '사후서비스신청 일련번호';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."Note" IS '비고';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."RequestNumber" IS '신청번호';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."TransferSequence" IS '이관순번';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."BasicAcceptProcessCode" IS '접수내용단순처리코드';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."PromisedVisitDateTime" IS '약속방문일시';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."TransferRegistrationCode" IS '이관등록코드';
COMMENT ON COLUMN ksx."AfterSalesServiceRequest"."SerialNumber" IS '제조번호';

CREATE TABLE ksx."AfterSalesServiceRequestResult" (
  "AfterSalesServiceRequestResultSequenceNo" BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "EnterpriseID" VARCHAR(50) NOT NULL,
  "SiteID" VARCHAR(50) NOT NULL,
  "PlantID" VARCHAR(50) NOT NULL,
  "CreatorID" VARCHAR(50),
  "CreationDateTime" TIMESTAMP,
  "ModifierID" VARCHAR(50),
  "ModificationDateTime" TIMESTAMP,
  "Note" VARCHAR(1000),
  "ItemID" VARCHAR(50),
  "ItemName" VARCHAR(200),
  "RequestNumber" VARCHAR(50) NOT NULL,
  "TransferSequence" INTEGER NOT NULL,
  "RegisterSequence" INTEGER NOT NULL,
  "RepairSequence" INTEGER NOT NULL,
  "SerialNumber" VARCHAR(50),
  "FaultLargeClass" VARCHAR(30),
  "FaultSmallClass" VARCHAR(30),
  "ErrorCode" VARCHAR(30),
  "InstallationDate" DATE,
  "ProcessingDate" DATE,
  "EndIndicator" BOOLEAN,
  "WorkType" VARCHAR(30),
  "ChildItemID" VARCHAR(50),
  "ChildItemName" VARCHAR(200),
  "ItemSpecification" VARCHAR(1000),
  "RepairType" VARCHAR(30),
  CONSTRAINT "UK_AfterSalesServiceRequestResult" UNIQUE ("EnterpriseID", "RequestNumber", "TransferSequence", "RegisterSequence", "RepairSequence")
);
COMMENT ON TABLE ksx."AfterSalesServiceRequestResult" IS '사후서비스결과 — 고객의 사후서비스 접수 이후 제조사 혹은 대리점의 처리결과를 교환하기 위해 필요한 데이터를 의미한다.';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."AfterSalesServiceRequestResultSequenceNo" IS '사후서비스결과 일련번호';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."EnterpriseID" IS '회사식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."SiteID" IS '사업장식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."PlantID" IS '공장식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."CreatorID" IS '등록자식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."CreationDateTime" IS '등록일시';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ModifierID" IS '수정자식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ModificationDateTime" IS '수정일시';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."Note" IS '비고';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ItemID" IS '품목식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ItemName" IS '품목명';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."RequestNumber" IS '신청번호';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."TransferSequence" IS '이관순번';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."RegisterSequence" IS '등록순번';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."RepairSequence" IS '수리순번';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."SerialNumber" IS '제조번호';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."FaultLargeClass" IS '하자현상대분류';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."FaultSmallClass" IS '하자현상소분류';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ErrorCode" IS '오류코드';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."InstallationDate" IS '설치일';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ProcessingDate" IS '처리일';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."EndIndicator" IS '종료여부';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."WorkType" IS '작업유형';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ChildItemID" IS '자품목식별자';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ChildItemName" IS '자품목명';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."ItemSpecification" IS '품목사양';
COMMENT ON COLUMN ksx."AfterSalesServiceRequestResult"."RepairType" IS '수리유형';

-- 물리 FK: 부모 UK 참조. 순환 참조(회사↔사원 등) 적재 시 SET CONSTRAINTS ALL DEFERRED 사용
ALTER TABLE ksx."Site" ADD CONSTRAINT "FK_Site_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Site" ADD CONSTRAINT "FK_Site_02" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Site" ADD CONSTRAINT "FK_Site_03" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Plant" ADD CONSTRAINT "FK_Plant_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Plant" ADD CONSTRAINT "FK_Plant_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Plant" ADD CONSTRAINT "FK_Plant_03" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Plant" ADD CONSTRAINT "FK_Plant_04" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Department" ADD CONSTRAINT "FK_Department_06" FOREIGN KEY ("EnterpriseID", "ParentDepartmentID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Personnel" ADD CONSTRAINT "FK_Personnel_06" FOREIGN KEY ("EnterpriseID", "DepartmentID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CustomerPartyMaster" ADD CONSTRAINT "FK_CustomerPartyMaster_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CustomerPartyMaster" ADD CONSTRAINT "FK_CustomerPartyMaster_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CustomerPartyMaster" ADD CONSTRAINT "FK_CustomerPartyMaster_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CustomerPartyMaster" ADD CONSTRAINT "FK_CustomerPartyMaster_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CustomerPartyMaster" ADD CONSTRAINT "FK_CustomerPartyMaster_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."VendorPartyMaster" ADD CONSTRAINT "FK_VendorPartyMaster_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."VendorPartyMaster" ADD CONSTRAINT "FK_VendorPartyMaster_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."VendorPartyMaster" ADD CONSTRAINT "FK_VendorPartyMaster_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."VendorPartyMaster" ADD CONSTRAINT "FK_VendorPartyMaster_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."VendorPartyMaster" ADD CONSTRAINT "FK_VendorPartyMaster_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CommonCodeMaster" ADD CONSTRAINT "FK_CommonCodeMaster_06" FOREIGN KEY ("EnterpriseID", "ParentCommonCodeGroup", "ParentCommonCodeID") REFERENCES ksx."CommonCodeMaster" ("EnterpriseID", "CommonCodeGroup", "CommonCodeID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WorkCalendar" ADD CONSTRAINT "FK_WorkCalendar_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WorkCalendar" ADD CONSTRAINT "FK_WorkCalendar_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WorkCalendar" ADD CONSTRAINT "FK_WorkCalendar_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WorkCalendar" ADD CONSTRAINT "FK_WorkCalendar_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WorkCalendar" ADD CONSTRAINT "FK_WorkCalendar_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupHeader" ADD CONSTRAINT "FK_UOMGroupHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupHeader" ADD CONSTRAINT "FK_UOMGroupHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupHeader" ADD CONSTRAINT "FK_UOMGroupHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupHeader" ADD CONSTRAINT "FK_UOMGroupHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupHeader" ADD CONSTRAINT "FK_UOMGroupHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."UOMGroupLine" ADD CONSTRAINT "FK_UOMGroupLine_06" FOREIGN KEY ("EnterpriseID", "UOMGroupID") REFERENCES ksx."UOMGroupHeader" ("EnterpriseID", "UOMGroupID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_06" FOREIGN KEY ("EnterpriseID", "MainCustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_07" FOREIGN KEY ("EnterpriseID", "MainVendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_08" FOREIGN KEY ("EnterpriseID", "ReceiptWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_09" FOREIGN KEY ("EnterpriseID", "IssueWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ItemMaster" ADD CONSTRAINT "FK_ItemMaster_10" FOREIGN KEY ("EnterpriseID", "ReplacementItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMHeader" ADD CONSTRAINT "FK_BOMHeader_07" FOREIGN KEY ("EnterpriseID", "RoutingID") REFERENCES ksx."RoutingHeader" ("EnterpriseID", "RoutingID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_06" FOREIGN KEY ("EnterpriseID", "BOMID", "BOMRevisionNumber") REFERENCES ksx."BOMHeader" ("EnterpriseID", "BOMID", "BOMRevisionNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BOMLine" ADD CONSTRAINT "FK_BOMLine_07" FOREIGN KEY ("EnterpriseID", "ChildItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_06" FOREIGN KEY ("EnterpriseID", "ParentLotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_07" FOREIGN KEY ("EnterpriseID", "ChildLotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_09" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_10" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_11" FOREIGN KEY ("EnterpriseID", "CurrentOperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_12" FOREIGN KEY ("EnterpriseID", "NextOperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Lot" ADD CONSTRAINT "FK_Lot_13" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingHeader" ADD CONSTRAINT "FK_RoutingHeader_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_06" FOREIGN KEY ("EnterpriseID", "RoutingID") REFERENCES ksx."RoutingHeader" ("EnterpriseID", "RoutingID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."RoutingLine" ADD CONSTRAINT "FK_RoutingLine_07" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Operation" ADD CONSTRAINT "FK_Operation_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Operation" ADD CONSTRAINT "FK_Operation_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Operation" ADD CONSTRAINT "FK_Operation_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Operation" ADD CONSTRAINT "FK_Operation_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Operation" ADD CONSTRAINT "FK_Operation_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_06" FOREIGN KEY ("EnterpriseID", "ParentEquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_07" FOREIGN KEY ("EnterpriseID", "DepartmentInChargeID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_08" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Equipment" ADD CONSTRAINT "FK_Equipment_09" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_06" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEquipment" ADD CONSTRAINT "FK_OperationEquipment_07" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Carrier" ADD CONSTRAINT "FK_Carrier_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Carrier" ADD CONSTRAINT "FK_Carrier_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Carrier" ADD CONSTRAINT "FK_Carrier_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Carrier" ADD CONSTRAINT "FK_Carrier_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Carrier" ADD CONSTRAINT "FK_Carrier_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_06" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_07" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockerInventory" ADD CONSTRAINT "FK_StockerInventory_08" FOREIGN KEY ("EnterpriseID", "AlternateStockerID") REFERENCES ksx."StockerInventory" ("EnterpriseID", "StockerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationHeader" ADD CONSTRAINT "FK_WarehouseLocationHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationHeader" ADD CONSTRAINT "FK_WarehouseLocationHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationHeader" ADD CONSTRAINT "FK_WarehouseLocationHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationHeader" ADD CONSTRAINT "FK_WarehouseLocationHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationHeader" ADD CONSTRAINT "FK_WarehouseLocationHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."WarehouseLocationLine" ADD CONSTRAINT "FK_WarehouseLocationLine_06" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_06" FOREIGN KEY ("EnterpriseID", "ParentBatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_08" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_09" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_10" FOREIGN KEY ("EnterpriseID", "BOMID", "BOMRevisionNumber") REFERENCES ksx."BOMHeader" ("EnterpriseID", "BOMID", "BOMRevisionNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_11" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_12" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Batch" ADD CONSTRAINT "FK_Batch_13" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_06" FOREIGN KEY ("EnterpriseID", "ParentLineID") REFERENCES ksx."Line" ("EnterpriseID", "LineID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_07" FOREIGN KEY ("EnterpriseID", "DepartmentInChargeID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_08" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_09" FOREIGN KEY ("EnterpriseID", "CalendarID") REFERENCES ksx."WorkCalendar" ("EnterpriseID", "CalendarID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_10" FOREIGN KEY ("EnterpriseID", "IssueWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Line" ADD CONSTRAINT "FK_Line_11" FOREIGN KEY ("EnterpriseID", "ReceiptWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Enterprise" ADD CONSTRAINT "FK_Enterprise_01" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Enterprise" ADD CONSTRAINT "FK_Enterprise_02" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Enterprise" ADD CONSTRAINT "FK_Enterprise_03" FOREIGN KEY ("ParentEnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_06" FOREIGN KEY ("EnterpriseID", "ResponsibleDepartmentID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_07" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_08" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") REFERENCES ksx."SalesOrderLine" ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_09" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProjectMaster" ADD CONSTRAINT "FK_ProjectMaster_10" FOREIGN KEY ("EnterpriseID", "DivisionID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_07" FOREIGN KEY ("EnterpriseID", "BOMID", "BOMRevisionNumber") REFERENCES ksx."BOMHeader" ("EnterpriseID", "BOMID", "BOMRevisionNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EngineeringChangeOrder" ADD CONSTRAINT "FK_EngineeringChangeOrder_08" FOREIGN KEY ("EnterpriseID", "ChildItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderHeader" ADD CONSTRAINT "FK_SalesOrderHeader_06" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_06" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber") REFERENCES ksx."SalesOrderHeader" ("EnterpriseID", "SalesDocumentNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesOrderLine" ADD CONSTRAINT "FK_SalesOrderLine_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SalesPlan" ADD CONSTRAINT "FK_SalesPlan_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."BasePrice" ADD CONSTRAINT "FK_BasePrice_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_07" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_08" FOREIGN KEY ("EnterpriseID", "RequesterDepartmentID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseRequisition" ADD CONSTRAINT "FK_PurchaseRequisition_09" FOREIGN KEY ("EnterpriseID", "RequesterPersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderHeader" ADD CONSTRAINT "FK_PurchaseOrderHeader_07" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_06" FOREIGN KEY ("EnterpriseID", "PurchaseDocumentNumber") REFERENCES ksx."PurchaseOrderHeader" ("EnterpriseID", "PurchaseDocumentNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."PurchaseOrderLine" ADD CONSTRAINT "FK_PurchaseOrderLine_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_06" FOREIGN KEY ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") REFERENCES ksx."PurchaseOrderLine" ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_08" FOREIGN KEY ("EnterpriseID", "ReceiptWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_09" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."MaterialArrival" ADD CONSTRAINT "FK_MaterialArrival_10" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_06" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_07" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsReceipt" ADD CONSTRAINT "FK_GoodsReceipt_09" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_07" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_08" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."GoodsIssue" ADD CONSTRAINT "FK_GoodsIssue_09" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPlanning" ADD CONSTRAINT "FK_ProductionPlanning_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_07" FOREIGN KEY ("EnterpriseID", "LineID") REFERENCES ksx."Line" ("EnterpriseID", "LineID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_08" FOREIGN KEY ("EnterpriseID", "RoutingID") REFERENCES ksx."RoutingHeader" ("EnterpriseID", "RoutingID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_09" FOREIGN KEY ("EnterpriseID", "BOMID", "BOMRevisionNumber") REFERENCES ksx."BOMHeader" ("EnterpriseID", "BOMID", "BOMRevisionNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionOrder" ADD CONSTRAINT "FK_ProductionOrder_10" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") REFERENCES ksx."SalesOrderLine" ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_06" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_07" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_08" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationStart" ADD CONSTRAINT "FK_OperationStart_09" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_06" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_07" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_08" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."OperationEnd" ADD CONSTRAINT "FK_OperationEnd_09" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_06" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferCommand" ADD CONSTRAINT "FK_TransferCommand_07" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_06" FOREIGN KEY ("EnterpriseID", "TransferCommandID") REFERENCES ksx."TransferCommand" ("EnterpriseID", "TransferCommandID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_07" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferStart" ADD CONSTRAINT "FK_TransferStart_08" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_06" FOREIGN KEY ("EnterpriseID", "TransferCommandID") REFERENCES ksx."TransferCommand" ("EnterpriseID", "TransferCommandID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_07" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TransferEnd" ADD CONSTRAINT "FK_TransferEnd_08" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_06" FOREIGN KEY ("EnterpriseID", "TransferCommandID") REFERENCES ksx."TransferCommand" ("EnterpriseID", "TransferCommandID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_07" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InTransitLocation" ADD CONSTRAINT "FK_InTransitLocation_08" FOREIGN KEY ("EnterpriseID", "CarrierID") REFERENCES ksx."Carrier" ("EnterpriseID", "CarrierID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_06" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_07" FOREIGN KEY ("EnterpriseID", "LastProcessedLotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentState" ADD CONSTRAINT "FK_EquipmentState_08" FOREIGN KEY ("EnterpriseID", "LastProcessedOperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Alarm" ADD CONSTRAINT "FK_Alarm_06" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_07" FOREIGN KEY ("EnterpriseID", "ProjectID") REFERENCES ksx."ProjectMaster" ("EnterpriseID", "ProjectID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_09" FOREIGN KEY ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") REFERENCES ksx."PurchaseOrderLine" ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_10" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionPlan" ADD CONSTRAINT "FK_SupplierInspectionPlan_11" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_07" FOREIGN KEY ("EnterpriseID", "ProjectID") REFERENCES ksx."ProjectMaster" ("EnterpriseID", "ProjectID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_09" FOREIGN KEY ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") REFERENCES ksx."PurchaseOrderLine" ("EnterpriseID", "PurchaseDocumentNumber", "PurchaseDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_10" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_11" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_12" FOREIGN KEY ("EnterpriseID", "InspectionPlanID", "InspectionID") REFERENCES ksx."SupplierInspectionPlan" ("EnterpriseID", "InspectionPlanID", "InspectionID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionApplication" ADD CONSTRAINT "FK_SupplierInspectionApplication_13" FOREIGN KEY ("EnterpriseID", "ApplicationPersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_07" FOREIGN KEY ("EnterpriseID", "ProjectID") REFERENCES ksx."ProjectMaster" ("EnterpriseID", "ProjectID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_09" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_10" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_11" FOREIGN KEY ("EnterpriseID", "InspectionPlanID", "InspectionID") REFERENCES ksx."SupplierInspectionPlan" ("EnterpriseID", "InspectionPlanID", "InspectionID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."SupplierInspectionResult" ADD CONSTRAINT "FK_SupplierInspectionResult_12" FOREIGN KEY ("EnterpriseID", "InspectionApplicationID") REFERENCES ksx."SupplierInspectionApplication" ("EnterpriseID", "InspectionApplicationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_08" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_09" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_10" FOREIGN KEY ("EnterpriseID", "InspectionApplicationID") REFERENCES ksx."SupplierInspectionApplication" ("EnterpriseID", "InspectionApplicationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionRequest" ADD CONSTRAINT "FK_CorrectiveActionRequest_11" FOREIGN KEY ("EnterpriseID", "CorrectiveActionRequestIssuerID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_08" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_09" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_10" FOREIGN KEY ("EnterpriseID", "CorrectiveActionRequestID") REFERENCES ksx."CorrectiveActionRequest" ("EnterpriseID", "CorrectiveActionRequestID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionPlan" ADD CONSTRAINT "FK_CorrectiveActionPlan_11" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_06" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_08" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_09" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_10" FOREIGN KEY ("EnterpriseID", "CorrectiveActionRequestID") REFERENCES ksx."CorrectiveActionRequest" ("EnterpriseID", "CorrectiveActionRequestID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_11" FOREIGN KEY ("EnterpriseID", "CorrectiveActionPlanID") REFERENCES ksx."CorrectiveActionPlan" ("EnterpriseID", "CorrectiveActionPlanID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_12" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."CorrectiveActionResult" ADD CONSTRAINT "FK_CorrectiveActionResult_13" FOREIGN KEY ("EnterpriseID", "CorrectiveActionConfirmorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_06" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductPacking" ADD CONSTRAINT "FK_ProductPacking_08" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."EquipmentParameter" ADD CONSTRAINT "FK_EquipmentParameter_06" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_06" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."TraceParameter" ADD CONSTRAINT "FK_TraceParameter_07" FOREIGN KEY ("EnterpriseID", "ParameterID") REFERENCES ksx."EquipmentParameter" ("EnterpriseID", "ParameterID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_06" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_08" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_09" FOREIGN KEY ("EnterpriseID", "RoutingID", "OperationSequence") REFERENCES ksx."RoutingLine" ("EnterpriseID", "RoutingID", "OperationSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_10" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_11" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformance" ADD CONSTRAINT "FK_ProductionPerformance_12" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_06" FOREIGN KEY ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") REFERENCES ksx."ProductionPerformance" ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_07" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_09" FOREIGN KEY ("EnterpriseID", "LineID") REFERENCES ksx."Line" ("EnterpriseID", "LineID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_10" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_11" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_12" FOREIGN KEY ("EnterpriseID", "ReplacementChildItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceItem" ADD CONSTRAINT "FK_ProductionPerformanceItem_13" FOREIGN KEY ("EnterpriseID", "WarehouseID", "WarehouseSection") REFERENCES ksx."WarehouseLocationLine" ("EnterpriseID", "WarehouseID", "WarehouseSection") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_06" FOREIGN KEY ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") REFERENCES ksx."ProductionPerformance" ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_07" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_08" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformancePersonnel" ADD CONSTRAINT "FK_ProductionPerformancePersonnel_09" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_06" FOREIGN KEY ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") REFERENCES ksx."ProductionPerformance" ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_07" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_08" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_09" FOREIGN KEY ("EnterpriseID", "RoutingID", "OperationSequence") REFERENCES ksx."RoutingLine" ("EnterpriseID", "RoutingID", "OperationSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_10" FOREIGN KEY ("EnterpriseID", "PersonnelID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceEquipment" ADD CONSTRAINT "FK_ProductionPerformanceEquipment_11" FOREIGN KEY ("EnterpriseID", "EquipmentID") REFERENCES ksx."Equipment" ("EnterpriseID", "EquipmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_06" FOREIGN KEY ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") REFERENCES ksx."ProductionPerformance" ("EnterpriseID", "ProductionPerformanceID", "ProductionPerformanceSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_07" FOREIGN KEY ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") REFERENCES ksx."ProductionOrder" ("EnterpriseID", "ProductionOrderID", "ProductionOrderSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_09" FOREIGN KEY ("EnterpriseID", "OperationID") REFERENCES ksx."Operation" ("EnterpriseID", "OperationID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_10" FOREIGN KEY ("EnterpriseID", "RoutingID", "OperationSequence") REFERENCES ksx."RoutingLine" ("EnterpriseID", "RoutingID", "OperationSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_11" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductionPerformanceQuality" ADD CONSTRAINT "FK_ProductionPerformanceQuality_12" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_06" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Inventory" ADD CONSTRAINT "FK_Inventory_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AvailableInventory" ADD CONSTRAINT "FK_AvailableInventory_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_07" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."StockTransfer" ADD CONSTRAINT "FK_StockTransfer_08" FOREIGN KEY ("EnterpriseID", "ReceiptWarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_06" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."InventoryCount" ADD CONSTRAINT "FK_InventoryCount_07" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_07" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_08" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductIncoming" ADD CONSTRAINT "FK_ProductIncoming_09" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestHeader" ADD CONSTRAINT "FK_ProductReleaseRequestHeader_06" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_06" FOREIGN KEY ("EnterpriseID", "ProductReleaseRequestID") REFERENCES ksx."ProductReleaseRequestHeader" ("EnterpriseID", "ProductReleaseRequestID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_07" FOREIGN KEY ("EnterpriseID", "LineID") REFERENCES ksx."Line" ("EnterpriseID", "LineID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_08" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_09" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductReleaseRequestLine" ADD CONSTRAINT "FK_ProductReleaseRequestLine_10" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") REFERENCES ksx."SalesOrderLine" ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_06" FOREIGN KEY ("EnterpriseID", "ProductReleaseRequestID") REFERENCES ksx."ProductReleaseRequestHeader" ("EnterpriseID", "ProductReleaseRequestID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_07" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") REFERENCES ksx."SalesOrderLine" ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_08" FOREIGN KEY ("EnterpriseID", "LineID") REFERENCES ksx."Line" ("EnterpriseID", "LineID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_09" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_10" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_11" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductRelease" ADD CONSTRAINT "FK_ProductRelease_12" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_06" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_07" FOREIGN KEY ("EnterpriseID", "DepartmentInChargeID") REFERENCES ksx."Department" ("EnterpriseID", "DepartmentID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryHeader" ADD CONSTRAINT "FK_DeliveryHeader_08" FOREIGN KEY ("EnterpriseID", "PersonInChargeID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_06" FOREIGN KEY ("EnterpriseID", "DeliveryID") REFERENCES ksx."DeliveryHeader" ("EnterpriseID", "DeliveryID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_07" FOREIGN KEY ("EnterpriseID", "ProductReleaseID", "ProductReleaseSequence") REFERENCES ksx."ProductRelease" ("EnterpriseID", "ProductReleaseID", "ProductReleaseSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_08" FOREIGN KEY ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") REFERENCES ksx."SalesOrderLine" ("EnterpriseID", "SalesDocumentNumber", "SalesDocumentSequence") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_09" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."DeliveryLine" ADD CONSTRAINT "FK_DeliveryLine_10" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_07" FOREIGN KEY ("EnterpriseID", "LotID") REFERENCES ksx."Lot" ("EnterpriseID", "LotID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_08" FOREIGN KEY ("EnterpriseID", "BatchID") REFERENCES ksx."Batch" ("EnterpriseID", "BatchID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_09" FOREIGN KEY ("EnterpriseID", "WarehouseID") REFERENCES ksx."WarehouseLocationHeader" ("EnterpriseID", "WarehouseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_10" FOREIGN KEY ("EnterpriseID", "CustomerID") REFERENCES ksx."CustomerPartyMaster" ("EnterpriseID", "CustomerID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."Return" ADD CONSTRAINT "FK_Return_11" FOREIGN KEY ("EnterpriseID", "VendorID") REFERENCES ksx."VendorPartyMaster" ("EnterpriseID", "VendorID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."ProductTraceParameterOnCustomer" ADD CONSTRAINT "FK_ProductTraceParameterOnCustomer_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequest" ADD CONSTRAINT "FK_AfterSalesServiceRequest_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_01" FOREIGN KEY ("EnterpriseID") REFERENCES ksx."Enterprise" ("EnterpriseID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_02" FOREIGN KEY ("EnterpriseID", "SiteID") REFERENCES ksx."Site" ("EnterpriseID", "SiteID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_03" FOREIGN KEY ("EnterpriseID", "PlantID") REFERENCES ksx."Plant" ("EnterpriseID", "PlantID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_04" FOREIGN KEY ("EnterpriseID", "CreatorID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_05" FOREIGN KEY ("EnterpriseID", "ModifierID") REFERENCES ksx."Personnel" ("EnterpriseID", "PersonnelID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_06" FOREIGN KEY ("EnterpriseID", "ItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_07" FOREIGN KEY ("EnterpriseID", "RequestNumber") REFERENCES ksx."AfterSalesServiceRequest" ("EnterpriseID", "RequestNumber") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE ksx."AfterSalesServiceRequestResult" ADD CONSTRAINT "FK_AfterSalesServiceRequestResult_08" FOREIGN KEY ("EnterpriseID", "ChildItemID") REFERENCES ksx."ItemMaster" ("EnterpriseID", "ItemID") DEFERRABLE INITIALLY IMMEDIATE;
