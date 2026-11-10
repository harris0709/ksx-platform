-- S7 정답(수작업 판정) 산출 쿼리 — IMPIX 원천(impix_mes·impix_erp)에서 직접. 규칙(지식 그래프)과 다른 경로로 만든다.
-- 결과는 mapping/impix/s7_plan.yaml evaluate.cases 의 expected 로 옮긴다(정답 검토·승인 대상).

-- [impix_mes] A01 투입 LOT 전체(R-001 inf:consumedLot): 산출 LOT <- 투입 LOT
select to_lot_no || '<-' || from_lot_no from mes.tb_lot_link where link_tp = 'CONSUME' order by 1;

-- [impix_mes] A02 LOT이 거친 설비 전체(R-005 inf:processedOn): LOT@설비 — 완공된 실적만
select distinct i.lot_no || '@' || i.eqp_id from mes.tb_trk_in i join mes.tb_trk_out o using (trk_in_id) order by 1;

-- [impix_mes] A03 규격 이탈 중 가공된 LOT(R-020): 파라미터 값이 규격(LSL~USL) 밖이고, 같은 설비 실적의 착공~완공 사이
with so as (select v.eqp_id, v.coll_dtm from mes.tb_param_val v join mes.tm_param p using (param_id) where v.val > p.usl or v.val < p.lsl),
     pp as (select i.lot_no, i.eqp_id, to_timestamp(i.trk_in_dtm, 'YYYYMMDDHH24MISS')::timestamp s,
                   to_timestamp(o.trk_out_dtm, 'YYYYMMDDHH24MISS')::timestamp e
            from mes.tb_trk_in i join mes.tb_trk_out o using (trk_in_id))
select distinct pp.lot_no from so join pp on so.eqp_id = pp.eqp_id and so.coll_dtm between pp.s and pp.e order by 1;

-- [impix_mes] A04 보류 LOT이 걸린 제조오더(R-030)
select distinct mo_no from mes.tb_lot where hold_flag = 'Y' order by 1;

-- [impix_mes → impix_erp] A05 납기 리스크(R-100): 불량률(불량/양품) > 0.02 실적의 제조오더 → 수주(요청 납기 ≤ 기준일 + 7일)
select distinct l.mo_no from mes.tb_trk_out o join mes.tb_lot l using (lot_no) where o.good_qty > 0 and o.ng_qty / o.good_qty > 0.02 order by 1;
-- [impix_erp] 위 제조오더의 수주
-- select mo_no, so_no, so_seq from erp.tb_pp_mo where mo_no in (…);

-- [impix_mes → impix_erp] A07 생산실적 → 영향 수주라인(R-010): 실적(PP-trk_out_id)의 LOT 제조오더 → 수주라인(수주-순번)
select o.trk_out_id, l.mo_no from mes.tb_trk_out o join mes.tb_lot l using (lot_no);                 -- [impix_mes]
select m.mo_no, m.so_no, m.so_seq from erp.tb_pp_mo m
  join erp.tb_sd_so_d d on d.so_no = m.so_no and d.so_seq = m.so_seq;                                   -- [impix_erp] 두 결과를 제조오더로 잇는다

-- [impix_erp] A06 BOM 직접 구성품(R-002): 기준일 2026-10-20에 유효한 라인, 품목마스터에 있는 자품목만
select d.prnt_item_cd || '>' || d.chld_item_cd from erp.tb_pp_bom_d d join erp.tb_mm_item i on i.item_cd = d.chld_item_cd
where d.valid_fr <= '20261020' and coalesce(d.valid_to, '99991231') >= '20261020' order by 1;
