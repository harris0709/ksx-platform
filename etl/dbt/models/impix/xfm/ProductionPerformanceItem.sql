-- ksxload gen 생성물 — 직접 수정 금지. 원본: mapping/impix/mes/ProductionPerformanceItem.yaml
-- ProductionPerformanceItem ← mes.tb_lot_link (1:1(LOT 소비 → 투입품목))
select
    cast('IMPIX' as text) as "EnterpriseID",
    cast('HQ' as text) as "SiteID",
    cast(xfm.xref('plant', (t.fac_id)::text) as text) as "PlantID",
    cast(concat('PP-', o.trk_out_id) as text) as "ProductionPerformanceID",
    cast(1 as integer) as "ProductionPerformanceSequence",
    cast(xfm.upper_trim(f.item_cd) as text) as "ItemID",
    cast(s.from_lot_no as text) as "LotID",
    cast(xfm.int(s.link_qty) as integer) as "IssuedQuantity",
    cast(true as boolean) as "IssuedIndicator",
    cast(o.proc_cd as text) as "OperationID",
    cast(t.mo_no as text) as "ProductionOrderID"
from {{ source('stg', 'mes__tb_lot_link') }} s
left join {{ source('stg', 'mes__tb_lot') }} f on s.from_lot_no = f.lot_no
left join {{ source('stg', 'mes__tb_lot') }} t on s.to_lot_no = t.lot_no
left join {{ source('stg', 'mes__tb_trk_out') }} o on s.to_lot_no = o.lot_no AND o.proc_cd = 'A100'
where (s.link_tp = 'CONSUME')
