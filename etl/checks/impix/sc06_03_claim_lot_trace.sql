-- SC06-03: CL2610-001 클레임 LOT의 생산 이력(하우징·주조 설비) — 표준 원장(ksx·ext)만으로 추적
-- 고객클레임 → 제품 LOT → (투입 LOT 계보) → 하우징 LOT → 공정 실적·설비 → 주조 당시 파라미터 이탈
with claim as (
  select "EnterpriseID", "CustomerComplaintID", "LotID", "CustomerID", "ComplaintQuantity", "DefectTypeDetailCode"
  from ext."CustomerComplaint" where "CustomerComplaintID" = 'CL2610-001'
),
genealogy as (                       -- 제품 LOT과 그 LOT에 투입된 하우징 LOT
  select c."LotID" as lot, 0 as depth from claim c
  union all
  select pi."LotID", 1
  from claim c
  join ksx."ProductionPerformance" pp on pp."EnterpriseID" = c."EnterpriseID" and pp."LotID" = c."LotID"
  join ksx."ProductionPerformanceItem" pi on pi."EnterpriseID" = pp."EnterpriseID"
       and pi."ProductionPerformanceID" = pp."ProductionPerformanceID"
)
select g.depth, l."LotID", l."ItemID", pp."OperationID", pe."EquipmentID",
       pp."ExecutionStartDateTime" as 착공, pp."ExecutionEndDateTime" as 완공,
       pp."ProducedQuantity" as 양품, pp."DefectQuantity" as 불량,
       (select string_agg(q."DefectTypeDetailCode" || ' ' || q."DefectTypeQuantity", ', ')
          from ksx."ProductionPerformanceQuality" q
         where q."EnterpriseID" = pp."EnterpriseID" and q."ProductionPerformanceID" = pp."ProductionPerformanceID") as 불량유형,
       (select count(*) from ksx."TraceParameter" t
          join ksx."EquipmentParameter" ep on ep."EnterpriseID" = t."EnterpriseID" and ep."ParameterID" = t."ParameterID"
         where t."EquipmentID" = pe."EquipmentID"
           and t."EventDateTime" between pp."ExecutionStartDateTime" and pp."ExecutionEndDateTime"
           and t."ParameterValue" > ep."USL") as 상한초과_파라미터
from genealogy g
join ksx."Lot" l on l."LotID" = g.lot
join ksx."ProductionPerformance" pp on pp."EnterpriseID" = l."EnterpriseID" and pp."LotID" = l."LotID"
left join ksx."ProductionPerformanceEquipment" pe on pe."EnterpriseID" = pp."EnterpriseID"
     and pe."ProductionPerformanceID" = pp."ProductionPerformanceID"
order by g.depth desc, pp."ExecutionStartDateTime";
