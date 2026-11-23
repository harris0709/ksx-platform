---
doc_id: SOP-AS-004
version: 2
status: 현행
title: 펌프 조립 작업표준
effective: 2025-01-06
owner: D120
nouns: [Operation, Equipment, ProductionPerformanceItem, Lot, BOM]
links: [Operation:A100, Equipment:ASM-01, Equipment:ASM-02, ItemMaster:EWP-A100, ItemMaster:EWP-B200, ItemMaster:IMP-A100, ItemMaster:MTR-12V, ItemMaster:PCB-EWP12, ItemMaster:SEAL-M18, ItemMaster:CON-3P, Department:D120]
---
# 펌프 조립 작업표준

## 1. 적용 범위

2공장 조립팀(D120)이 펌프 조립기 ASM-01(A100 라인)·ASM-02(B200 라인)로 전동식 워터펌프 EWP-A100·EWP-B200을 조립하는 공정(A100)에 적용한다.

## 2. 투입 부품과 LOT 기록

BOM 현행 판의 자품목(하우징, 임펠러, BLDC 모터, 컨트롤러 PCB, 메커니컬 씰, O-링, 볼트, 커넥터)을 투입한다. 하우징·임펠러·모터·PCB는 투입할 때 부품 LOT을 바코드로 읽어 생산실적 투입품목에 남긴다. 투입 LOT 기록이 빠지면 고객 클레임 때 원인 LOT을 역추적할 수 없으므로 기록 없이 조립하지 않는다.

## 3. 체결 조건

하우징 볼트 체결토크는 5.5~7.0 N·m(관리 5.8~6.7 N·m)이다. 토크 이상은 설비가 자동으로 불합격 처리하며, 연속 3회 이상이면 공구를 점검한다. 메커니컬 씰은 압입 전 O-링에 윤활제를 바른다.

## 4. 공정 간 인계

조립을 마친 제품은 누설시험(A200)으로 넘긴다. 조립 LOT 번호는 품목·일자·라인 순번으로 정한다(예: E261003A1).
