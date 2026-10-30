-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/Lot.yaml
-- Lot ← mes.tb_lot (1:1)
-- 규칙 적용 전(명세대로 변환한 행)
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (s.fac_id)::text) as text) as "PlantID",
    cast(s.lot_no as text) as "LotID",
    cast(xfm.code('LOT_TP', (s.lot_tp)::text) as text) as "LotType",
    cast(s.lot_tp as text) as "_src__LotType",
    cast(xfm.code('LOT_STAT', (s.lot_stat)::text) as text) as "LotState",
    cast(s.lot_stat as text) as "_src__LotState",
    cast(s.mo_no as text) as "ProductionOrderID",
    cast(s.mo_seq as integer) as "ProductionOrderSequence",
    cast(s.cur_qty as numeric) as "ProducedQuantity",
    cast(s.cur_proc_cd as text) as "CurrentOperationID",
    cast(s.prior_no as integer) as "LotPriority",
    cast(s.crt_user as text) as "CreatorID",
    cast(xfm.upper_trim(s.item_cd) as text) as "ItemID",
    cast(s.lot_qty as numeric) as "LotCreatedQuantity",
    cast(s.ng_qty as numeric) as "DefectQuantity",
    cast(s.next_proc_cd as text) as "NextOperationID",
    cast(xfm.yn(s.hold_flag) as boolean) as "HoldIndicator",
    cast(xfm.yn(s.hot_flag) as boolean) as "HotIndicator",
    cast(s.rework_cnt as integer) as "ReworkCount",
    cast(xfm.to_date8(s.due_dt) as date) as "ScheduledDueDate",
    cast(xfm.to_ts(s.crt_dtm) as timestamp) as "CreationDateTime",
    cast(xfm.to_ts(s.upd_dtm) as timestamp) as "ModificationDateTime",
    cast('PRODUCTION' as text) as "LotOriginType"
from {{ source('stg', 'mes__tb_lot') }} s
