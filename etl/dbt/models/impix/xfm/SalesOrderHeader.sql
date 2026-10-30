-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/erp/SalesOrderHeader.yaml
-- SalesOrderHeader ← erp.tb_sd_so_h (1:1)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast('P2' as text) as "PlantID",
    cast(s.so_no as text) as "SalesDocumentNumber",
    cast(xfm.code('SO_TP', (s.so_tp)::text) as text) as "SalesOrderType",
    cast(s.so_tp as text) as "_src__SalesOrderType",
    cast(xfm.code('SO_STAT', (s.so_stat)::text) as text) as "SalesStatus",
    cast(s.so_stat as text) as "_src__SalesStatus",
    cast(s.cust_cd as text) as "CustomerID",
    cast(xfm.to_date8(s.so_dt) as date) as "SalesDate",
    cast(s.reg_id as text) as "CreatorID"
from {{ source('stg', 'erp__tb_sd_so_h') }} s
