-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/BasePrice.yaml
-- BasePrice ← erp.tb_mm_price (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(xfm.code('CURR', (s.curr_cd)::text) as text) as "CurrencyCode",
    cast(s.curr_cd as text) as "_src__CurrencyCode",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.unit_prc as numeric) as "UnitPrice"
from {{ source('stg', 'erp__tb_mm_price') }} s
where (to_char(current_date, 'YYYYMMDD') BETWEEN s.valid_fr AND s.valid_to)
