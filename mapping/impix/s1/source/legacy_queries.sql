-- =====================================================================
-- IMPIX 원천 시스템에서 수집한 리포트·인터페이스 SQL (S1 절차 7: 암묵 관계 파악)
--   출처: MES 리포트 화면 6종, ERP-MES 인터페이스 배치 2종 (가상)
--   FK가 선언되지 않은 조인을 이 SQL에서 찾아 implicit_relations 시트에 기록한다.
-- =====================================================================

-- [MES-RPT-01] LOT 공정 진행 현황
SELECT l.lot_no, l.item_cd, i.item_nm, p.proc_nm, l.lot_stat, l.cur_qty
FROM mes.tb_lot l
JOIN mes.tm_item i ON i.item_cd = l.item_cd
LEFT JOIN mes.tm_proc p ON p.proc_cd = l.cur_proc_cd
WHERE l.lot_stat IN ('W','R','H');

-- [MES-RPT-02] 공정별 착공·완공 실적
SELECT t.lot_no, t.proc_cd, t.eqp_id, t.trk_in_dtm, o.trk_out_dtm, o.good_qty, o.ng_qty
FROM mes.tb_trk_in t
JOIN mes.tb_trk_out o ON o.trk_in_id = t.trk_in_id
JOIN mes.tm_eqp e ON e.eqp_id = t.eqp_id
JOIN mes.tb_lot l ON l.lot_no = t.lot_no;

-- [MES-RPT-03] 불량 유형별 집계
SELECT q.proc_cd, d.defect_cd, c.cd_nm, sum(d.defect_qty)
FROM mes.tb_qc_insp q
JOIN mes.tb_qc_defect d ON d.insp_no = q.insp_no
JOIN mes.tm_code c ON c.grp_cd = 'DEFECT_CD' AND c.cd = d.defect_cd
GROUP BY 1,2,3;

-- [MES-RPT-04] 설비 가동률(일별)
SELECT s.eqp_id, e.eqp_nm, date_trunc('day', s.st_dtm), s.stat_cd, sum(s.ed_dtm - s.st_dtm)
FROM mes.tb_eqp_stat s
JOIN mes.tm_eqp e ON e.eqp_id = s.eqp_id
JOIN mes.tm_code c ON c.grp_cd = 'EQP_STAT' AND c.cd = s.stat_cd
GROUP BY 1,2,3,4;

-- [MES-RPT-05] 파라미터 SPC 차트
SELECT v.eqp_id, p.param_nm, v.coll_dtm, v.val, p.lsl, p.usl
FROM mes.tb_param_val v
JOIN mes.tm_param p ON p.param_id = v.param_id
WHERE v.coll_dtm >= now() - interval '7 days';

-- [MES-RPT-06] LOT 계보(하우징 → 완제품)
SELECT k.from_lot_no, f.item_cd, k.to_lot_no, t.item_cd, k.link_qty
FROM mes.tb_lot_link k
JOIN mes.tb_lot f ON f.lot_no = k.from_lot_no
JOIN mes.tb_lot t ON t.lot_no = k.to_lot_no;

-- [MES-RPT-07] 알람 이력
SELECT a.eqp_id, a.alm_cd, c.cd_nm, a.occur_dtm, a.clear_dtm
FROM mes.tb_alarm a
JOIN mes.tm_code c ON c.grp_cd = 'ALM_CD' AND c.cd = a.alm_cd;

-- [IF-ERP-01] MES 생산실적 → ERP 오더 실적 반영(야간 배치, 시스템 간 조인)
SELECT m.mo_no, m.mo_seq, m.item_cd, sum(r.good_qty) AS good_qty
FROM mes.tb_prod_rslt r
JOIN erp.tb_pp_mo m ON m.mo_no = r.mo_no
JOIN erp.tb_pp_wc w ON w.wc_cd = (SELECT erp_wc_cd FROM mes.tm_proc x WHERE x.proc_cd = r.proc_cd)
WHERE r.proc_cd = 'A400'
GROUP BY 1,2,3;

-- [IF-ERP-02] ERP 제조오더 → MES LOT 생성(시스템 간 조인)
SELECT m.mo_no, m.mo_seq, m.item_cd, m.mo_qty, f.fac_id, ln.line_id
FROM erp.tb_pp_mo m
JOIN mes.tm_factory f ON f.erp_plant_cd = m.plant_cd
JOIN mes.tm_line ln ON ln.erp_line_cd = m.line_cd
WHERE m.mo_stat = '20';

-- [ERP-RPT-11] 납기 준수 현황(영업 주간 보고)
SELECT h.cust_cd, c.cust_nm, d.so_no, d.so_seq, d.item_cd, d.so_qty, d.req_dlv_dt, v.dlv_dt, v.dlv_qty
FROM erp.tb_sd_so_d d
JOIN erp.tb_sd_so_h h ON h.so_no = d.so_no
JOIN erp.tb_sd_cust c ON c.cust_cd = h.cust_cd
LEFT JOIN erp.tb_sd_dlv v ON v.so_no = d.so_no AND v.so_seq = d.so_seq
WHERE h.so_stat <> '90';

-- [ERP-RPT-12] 일 재고 금액(경영 보고)
SELECT s.stk_dt, s.wh_cd, w.wh_nm, s.item_cd, s.stk_qty, c.std_cost, s.stk_qty * c.std_cost AS amt
FROM erp.tb_mm_stock_day s
JOIN erp.tb_mm_wh w ON w.wh_cd = s.wh_cd
JOIN erp.tb_co_std_cost c ON s.item_cd = c.item_cd AND c.cost_ym = substr(s.stk_dt, 1, 6);

-- [ERP-RPT-13] 구매 입고·수입검사 대기
SELECT g.gr_no, g.po_no, g.po_seq, p.vend_cd, v.vend_nm, g.item_cd, g.gr_qty, g.iqc_stat
FROM erp.tb_mm_gr g
JOIN erp.tb_mm_po_d d ON d.po_no = g.po_no AND d.po_seq = g.po_seq
JOIN erp.tb_mm_po_h p ON p.po_no = d.po_no
JOIN erp.tb_mm_vend v ON v.vend_cd = p.vend_cd
WHERE g.iqc_yn = 'Y';

-- [QMS-RPT-01] 클레임 대책 회신 현황
SELECT c.claim_no, c.cust_cd, c.claim_tp, t.code_nm, c.defect_cd, d.code_nm, c.resp_due_dt, c.resp_dt
FROM qms.qm_claim c
JOIN qms.qm_code t ON t.code_grp = 'CLAIM_TP' AND t.code = c.claim_tp
LEFT JOIN qms.qm_code d ON d.code_grp = 'CLM_DEF' AND d.code = c.defect_cd;

-- [QMS-RPT-02] 협력업체 부적합(수입검사 연결)
SELECT n.ncr_no, n.vend_cd, n.item_cd, i.iqc_no, i.judge, i.ng_qty, n.car_due_dt, n.car_cls_dt
FROM qms.qm_vend_ncr n
LEFT JOIN qms.qm_iqc i ON i.iqc_no = n.iqc_no;
