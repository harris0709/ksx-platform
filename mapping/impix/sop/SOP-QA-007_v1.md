---
doc_id: SOP-QA-007
version: 1
status: 현행
title: 고객 클레임 처리 절차
effective: 2024-03-04
owner: D210
nouns: [CustomerComplaint, Lot, Operation, QualityCost]
links: [CustomerPartyMaster:C001, CustomerPartyMaster:C002, CustomerPartyMaster:C003, Department:D210]
---
# 고객 클레임 처리 절차

## 1. 접수

고객 클레임(입고검사 부적합, 라인 중단, 필드 반송)은 품질보증파트(D210)가 접수하고 클레임 번호, 고객, 품목, LOT, 불량유형(누수, 소음, 커넥터 접촉불량, 라벨 오기), 수량, 금액을 등록한다.

## 2. 원인 분석과 대책 회신

접수 후 24시간 안에 고객 재고와 사내 재고를 선별한다. 클레임 LOT을 역추적해 원인 공정을 지정하고 8D 보고서로 원인과 대책을 정리한다. 대책 회신 기한은 접수일로부터 7일이다. 공급사 부품이 원인이면 시정조치요청(CAR)을 발행한다(SOP-QA-008).

## 3. 종결

대책 효과를 확인한 뒤 클레임을 종결(CLOSE)하고, 클레임 금액과 선별·재작업 비용을 품질비용으로 집계한다. 같은 불량유형이 3개월 안에 다시 발생하면 재발로 보고 대책을 다시 세운다. 종결된 클레임의 원인–조치는 유사 사례 검색에 쓰이도록 이력으로 남긴다.
