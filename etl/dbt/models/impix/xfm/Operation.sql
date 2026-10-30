-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Operation.yaml
-- Operation ← mes.tm_proc (N→1(MES 공정 + ERP 작업장))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.fac_id)::text) as text) as "PlantID",
    cast(xfm.code('PROC_TP', (s.proc_tp)::text) as text) as "OperationType",
    cast(s.proc_tp as text) as "_src__OperationType",
    cast(s.proc_cd as text) as "OperationID",
    cast(s.proc_nm as text) as "OperationName",
    cast(xfm.yn(s.use_flag) as boolean) as "UseIndicator"
from {{ source('stg', 'mes__tm_proc') }} s
left join {{ source('stg', 'erp__tb_pp_wc') }} w on s.erp_wc_cd = w.wc_cd
