# S1 원천 분석 요약 — IMPIX

생성: 2026-10-22 14:44 · 도구: tools/s1profiler

| 항목 | 값 |
| --- | --- |
| 대상 기업 | IMPIX |
| 생성 일시 | 2026-10-22 14:44 |
| 원천 시스템 | ERP, MES, QMS |
| 테이블 수 | 56 |
| 1차 범위 테이블 | 53 |
| 컬럼 수 | 452 |
| 컬럼 주석 비율(%) | 12.8 |
| 총 행 수 | 143858 |
| 선언 FK | 13 |
| 암묵 관계(FK 미선언) | 116 |
| 시스템 간 관계 | 28 |
| 코드 마스터 코드 수 | 112 |
| 코드 후보 컬럼 | 73 |
| 품질 이슈(상/중/하) | 11 / 42 / 68 |
| 프로파일 완료율 | 100% (전 테이블 전수 집계) |

## 품질 이슈 (상)

| ID | 테이블.컬럼 | 이슈 | 건수 | 예시 |
| --- | --- | --- | --- | --- |
| Q001 | erp.tb_mm_item.item_cd | 대소문자·공백만 다른 중복 키 | 2 | 'EWP-A100' = 'EWP-A100 '; 'EWP-B200' = 'ewp-b200' |
| Q002 | erp.tb_pp_bom_d.chld_item_cd | 참조 고아 → erp.tb_mm_item.item_cd | 1 | IMP-B300 |
| Q003 | erp.tb_pp_rcpt.mo_no | 참조 고아 → erp.tb_pp_mo.mo_no | 1 | MO260999001 |
| Q004 | erp.tb_sd_dlv.lot_no | 참조 고아 → mes.tb_lot.lot_no | 88 | E260731A1, E260731B1, E260801A1, E260801B1, E260803A1 |
| Q005 | mes.tb_lot.mo_no | 참조 고아 → erp.tb_pp_mo.mo_no | 1 | MO260999001 |
| Q006 | mes.tb_param_val.val | 규격(USL) 10배 초과 값 — 단위 오류 의심 | 7 | LKT-02_LEAK_RATE 2026-10-11T09:00:00 1083.0 2.0; LKT-02_LEAK |
| Q007 | mes.tb_prod_rslt.mo_no | 참조 고아 → erp.tb_pp_mo.mo_no | 1 | MO260999001 |
| Q008 | mes.tb_trk_in.oper_emp_no | 참조 고아 → erp.tb_hr_emp.emp_no | 1 | OP01 |
| Q009 | mes.tb_trk_out.good_qty | 완공 수량 불일치(양품+불량 ≠ 착공 투입) | 2 | E260925B1 A100 196.0 198.0 1.0; E260925B1 A200 195.0 196.0 2 |
| Q010 | mes.tb_trk_out.trk_out_dtm | 완공 일시가 착공 일시보다 빠름 | 1 | E261009A2 A200 20261009145700 20261009145200 |
| Q011 | qms.qm_claim.lot_no | 참조 고아 → mes.tb_lot.lot_no | 1 | E260915A1 |

## 암묵 관계 (FK 미선언)

| 자식 | 부모 | 발견 경로 | 포함률 | 고아 |
| --- | --- | --- | --- | --- |
| erp.tb_cm_dept.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_co_std_cost.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_hr_emp.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_cnt.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_cnt.wh_cd | erp.tb_mm_wh.wh_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gi.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gi.wh_cd | erp.tb_mm_wh.wh_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gr.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gr.po_no | erp.tb_mm_po_d.po_no | SQL 조인 | 1.0 | 0 |
| erp.tb_mm_gr.po_no | erp.tb_mm_po_h.po_no | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gr.po_seq | erp.tb_mm_po_d.po_seq | SQL 조인 | 1.0 | 0 |
| erp.tb_mm_gr.vend_cd | erp.tb_mm_vend.vend_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_gr.wh_cd | erp.tb_mm_wh.wh_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_item.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_po_d.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_po_d.po_no | erp.tb_mm_po_h.po_no | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_po_h.vend_cd | erp.tb_mm_vend.vend_cd | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_price.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_price.vend_cd | erp.tb_mm_vend.vend_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_stock_day.item_cd | erp.tb_co_std_cost.item_cd | SQL 조인 | 1.0 | 0 |
| erp.tb_mm_stock_day.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_stock_day.wh_cd | erp.tb_mm_wh.wh_cd | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_stock_lot.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_stock_lot.wh_cd | erp.tb_mm_wh.wh_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_mm_wh.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_bom_d.chld_item_cd | erp.tb_mm_item.item_cd | 수작업 등록 | 0.9375 | 1 |
| erp.tb_pp_bom_h.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_bom_h.rout_cd | erp.tb_pp_rout_h.rout_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_mat_chk.comp_cd | erp.tb_mm_item.item_cd | 수작업 등록 | 1.0 | 0 |
| erp.tb_pp_mat_chk.mo_no | erp.tb_pp_mo.mo_no | 수작업 등록 | 1.0 | 0 |
| erp.tb_pp_mo.line_cd | mes.tm_line.erp_line_cd | SQL 조인 | 1.0 | 0 |
| erp.tb_pp_mo.line_cd | erp.tb_pp_line.line_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_mo.plant_cd | mes.tm_factory.erp_plant_cd | SQL 조인 | 1.0 | 0 |
| erp.tb_pp_mo.rout_cd | erp.tb_pp_rout_h.rout_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_mo.so_no | erp.tb_sd_so_h.so_no | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_plan.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_plan.line_cd | erp.tb_pp_line.line_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_rcpt.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_pp_rcpt.mo_no | erp.tb_pp_mo.mo_no | 수작업 등록 | 0.98 | 1 |
| erp.tb_pp_rout_h.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_dlv.cust_cd | erp.tb_sd_cust.cust_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_dlv.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_dlv.lot_no | mes.tb_lot.lot_no | 수작업 등록 | 0.443 | 88 |
| erp.tb_sd_dlv.so_no | erp.tb_sd_so_d.so_no | SQL 조인 | 1.0 | 0 |
| erp.tb_sd_dlv.so_no | erp.tb_sd_so_h.so_no | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_dlv.so_seq | erp.tb_sd_so_d.so_seq | SQL 조인 | 1.0 | 0 |
| erp.tb_sd_plan.cust_cd | erp.tb_sd_cust.cust_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_plan.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_so_d.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_so_d.so_no | erp.tb_sd_so_h.so_no | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| erp.tb_sd_so_h.cust_cd | erp.tb_sd_cust.cust_cd | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_alarm.alm_cd | mes.tm_code.cd | SQL 조인 | 1.0 | 0 |
| mes.tb_alarm.eqp_id | mes.tm_eqp.eqp_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_eqp_stat. | mes.tb_trk_in / mes.tb_trk_out. | 수작업 등록 | None | None |
| mes.tb_eqp_stat.eqp_id | mes.tm_eqp.eqp_id | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_eqp_stat.lot_no | mes.tb_lot.lot_no | 이름·값 일치 | 1.0 | 0 |
| mes.tb_eqp_stat.stat_cd | mes.tm_code.cd | SQL 조인 | 1.0 | 0 |
| mes.tb_lot.cur_proc_cd | mes.tm_proc.proc_cd | SQL 조인 | 1.0 | 0 |
| mes.tb_lot.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_lot.item_cd | mes.tm_item.item_cd | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_lot.item_cd | erp.tb_mm_item.item_cd | 수작업 등록 | 1.0 | 0 |
| mes.tb_lot.mo_no | erp.tb_pp_mo.mo_no | 수작업 등록 | 0.9811 | 1 |
| mes.tb_lot_link.from_lot_no | mes.tb_lot.lot_no | SQL 조인 | 1.0 | 0 |
| mes.tb_lot_link.to_lot_no | mes.tb_lot.lot_no | SQL 조인 | 1.0 | 0 |
| mes.tb_param_val. | mes.tb_trk_in / mes.tb_trk_out. | 수작업 등록 | None | None |
| mes.tb_param_val.eqp_id | mes.tm_eqp.eqp_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_param_val.lot_no | mes.tb_lot.lot_no | 이름·값 일치 | 1.0 | 0 |
| mes.tb_param_val.param_id | mes.tm_param.param_id | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_prod_rslt.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_prod_rslt.item_cd | mes.tm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tb_prod_rslt.line_id | mes.tm_line.line_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_prod_rslt.mo_no | erp.tb_pp_mo.mo_no | SQL 조인 | 0.9808 | 1 |
| mes.tb_prod_rslt.proc_cd | mes.tm_proc.proc_cd | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_qc_defect.defect_cd | mes.tm_code.cd | SQL 조인, 수작업 등록 | 1.0 | 0 |
| mes.tb_qc_defect.insp_no | mes.tb_qc_insp.insp_no | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_qc_insp.insp_emp_no | erp.tb_hr_emp.emp_no | 수작업 등록 | 1.0 | 0 |
| mes.tb_qc_insp.lot_no | mes.tb_lot.lot_no | 이름·값 일치 | 1.0 | 0 |
| mes.tb_qc_insp.proc_cd | mes.tm_proc.proc_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_in.eqp_id | mes.tm_eqp.eqp_id | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_in.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_in.lot_no | mes.tb_lot.lot_no | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_in.oper_emp_no | erp.tb_hr_emp.emp_no | 수작업 등록 | 0.8889 | 1 |
| mes.tb_trk_in.proc_cd | mes.tm_proc.proc_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_out.eqp_id | mes.tm_eqp.eqp_id | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_out.lot_no | mes.tb_lot.lot_no | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_out.oper_emp_no | erp.tb_hr_emp.emp_no | 수작업 등록 | 1.0 | 0 |
| mes.tb_trk_out.proc_cd | mes.tm_proc.proc_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tb_trk_out.trk_in_id | mes.tb_trk_in.trk_in_id | SQL 조인, 이름·값 일치 | 1.0 | 0 |
| mes.tm_eqp.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| mes.tm_eqp.line_id | mes.tm_line.line_id | 이름·값 일치 | 1.0 | 0 |
| mes.tm_eqp.mgr_emp_no | erp.tb_hr_emp.emp_no | 수작업 등록 | 1.0 | 0 |
| mes.tm_eqp.proc_cd | mes.tm_proc.proc_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tm_factory.erp_plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tm_line.erp_line_cd | erp.tb_pp_line.line_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tm_line.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| mes.tm_param.eqp_id | mes.tm_eqp.eqp_id | 이름·값 일치 | 1.0 | 0 |
| mes.tm_proc.erp_wc_cd | erp.tb_pp_wc.wc_cd | 이름·값 일치 | 1.0 | 0 |
| mes.tm_proc.fac_id | mes.tm_factory.fac_id | 이름·값 일치 | 1.0 | 0 |
| qms.qm_claim.claim_tp | qms.qm_code.code | SQL 조인 | 1.0 | 0 |
| qms.qm_claim.cust_cd | erp.tb_sd_cust.cust_cd | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_claim.defect_cd | qms.qm_code.code | SQL 조인, 수작업 등록 | 1.0 | 0 |
| qms.qm_claim.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_claim.item_cd | mes.tm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_claim.lot_no | mes.tb_lot.lot_no | 수작업 등록 | 0.8 | 1 |
| qms.qm_iqc.gr_no | erp.tb_mm_gr.gr_no | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_iqc.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_iqc.vend_cd | erp.tb_mm_vend.vend_cd | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_scrap.defect_cd | mes.tm_code.cd | 수작업 등록 | 1.0 | 0 |
| qms.qm_scrap.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_scrap.item_cd | mes.tm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_scrap.lot_no | mes.tb_lot.lot_no | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_scrap.plant_cd | erp.tb_cm_plant.plant_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_scrap.proc_cd | mes.tm_proc.proc_cd | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_vend_ncr.iqc_no | qms.qm_iqc.iqc_no | SQL 조인, 이름·값 일치, 수작업 등록 | 1.0 | 0 |
| qms.qm_vend_ncr.item_cd | erp.tb_mm_item.item_cd | 이름·값 일치 | 1.0 | 0 |
| qms.qm_vend_ncr.vend_cd | erp.tb_mm_vend.vend_cd | 이름·값 일치, 수작업 등록 | 1.0 | 0 |
