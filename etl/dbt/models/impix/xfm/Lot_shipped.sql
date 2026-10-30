-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/Lot_shipped.yaml
-- Lot ← erp.tb_sd_dlv (N→1(MES 도입 전 출하 LOT — LOT별 1행))
select distinct on ("EnterpriseID", "LotID")
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('wh_plant', (s.wh_cd)::text) as text) as "PlantID",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast('LEGACY' as text) as "LotOriginType"
from {{ source('stg', 'erp__tb_sd_dlv') }} s
where (s.lot_no < 'E260921')
order by "EnterpriseID", "LotID"
