---
doc_id: SOP-QA-008
version: 1
status: 현행
title: 수입검사 기준
effective: 2024-03-04
owner: D210
nouns: [SupplierInspectionResult, CorrectiveActionRequest, CorrectiveActionResult, VendorPartyMaster, GoodsReceipt]
links: [VendorPartyMaster:V001, VendorPartyMaster:V003, ItemMaster:IMP-A100, ItemMaster:CON-3P, ItemMaster:PCB-EWP24]
---
# 수입검사 기준

## 1. 적용 범위

공급사에서 들어오는 부품(임펠러, 모터, PCB, 씰, 커넥터 등)의 입고 검사에 적용한다.

## 2. 검사 항목

임펠러는 치수(외경·보스 내경), 커넥터는 외관(핀 휨·하우징 크랙), PCB는 납땜 상태를 검사한다. 샘플링은 KS Q ISO 2859-1 보통검사 수준 II, AQL 0.65를 따른다.

## 3. 부적합 처리

불합격 LOT은 반품 또는 선별 후 사용으로 처리하고, 공급사에 시정조치요청(CAR)을 발행한다. 공급사는 14일 안에 원인과 대책을 회신해야 하며, 회신 후 다음 3회 입고는 강화 검사를 한다. 같은 공급사·품목에서 부적합이 3개월 안에 반복되면 공급사 평가에 반영한다. 생산 라인이나 고객 단계에서 발견된 부품 불량도 같은 절차로 CAR을 발행한다.
