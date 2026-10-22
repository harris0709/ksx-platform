-- =====================================================================
-- IMPIX 레거시 ERP 확장(가상) — 영업·구매·재고·원가 (KPI 산출용)
--   SCM 이력은 ERP에 2026-08-01부터 보존(MES는 최근 30일만 보존)
-- =====================================================================
\connect impix_erp
SET search_path = erp;

CREATE TABLE tb_sd_cust (
  cust_cd    varchar(6) PRIMARY KEY,
  cust_nm    varchar(100) NOT NULL,
  biz_reg_no varchar(12),
  nation_cd  varchar(2) DEFAULT 'KR',
  cust_grp   varchar(2),
  chrg_nm    varchar(50),
  chrg_email varchar(100),
  use_yn     char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_sd_cust IS '고객';
COMMENT ON COLUMN tb_sd_cust.cust_grp IS '고객군(CUST_GRP) OE:완성차 AM:보수용';

CREATE TABLE tb_mm_vend (
  vend_cd    varchar(6) PRIMARY KEY,
  vend_nm    varchar(100) NOT NULL,
  biz_reg_no varchar(12),
  chrg_nm    varchar(50),
  chrg_email varchar(100),
  use_yn     char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_mm_vend IS '거래처(공급사)';

CREATE TABLE tb_mm_wh (
  wh_cd    varchar(4) PRIMARY KEY,
  wh_nm    varchar(50),
  wh_tp    varchar(2),
  plant_cd varchar(4),
  use_yn   char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_mm_wh IS '창고';
COMMENT ON COLUMN tb_mm_wh.wh_tp IS '창고유형(WH_TP)';

CREATE TABLE tb_co_std_cost (
  item_cd   varchar(30),
  cost_ym   char(6),
  std_cost  numeric(14,2),
  mat_cost  numeric(14,2),
  lab_cost  numeric(14,2),
  ovh_cost  numeric(14,2),
  curr_cd   varchar(3) DEFAULT 'KRW',
  PRIMARY KEY (item_cd, cost_ym)
);
COMMENT ON TABLE tb_co_std_cost IS '품목 표준원가(월)';

CREATE TABLE tb_mm_price (
  item_cd  varchar(30),
  vend_cd  varchar(6),
  unit_prc numeric(14,2),
  curr_cd  varchar(3) DEFAULT 'KRW',
  valid_fr char(8),
  valid_to char(8),
  PRIMARY KEY (item_cd, vend_cd, valid_fr)
);
COMMENT ON TABLE tb_mm_price IS '구매 단가';

CREATE TABLE tb_sd_plan (
  plan_ym  char(6),
  plan_tp  varchar(4),
  plan_ver int,
  cust_cd  varchar(6),
  item_cd  varchar(30),
  plan_qty numeric(12,2),
  reg_dt   timestamp,
  PRIMARY KEY (plan_ym, plan_tp, plan_ver, cust_cd, item_cd)
);
COMMENT ON TABLE tb_sd_plan IS '수요예측(FCST)·판매계획(PLAN) 월별';
COMMENT ON COLUMN tb_sd_plan.plan_tp IS 'FCST:전월 수요예측 PLAN:확정 판매계획';

CREATE TABLE tb_sd_so_h (
  so_no   varchar(12) PRIMARY KEY,
  cust_cd varchar(6),
  so_dt   char(8),
  so_tp   varchar(2),
  so_stat varchar(2),
  reg_id  varchar(8)
);
COMMENT ON TABLE tb_sd_so_h IS '수주 헤더';
COMMENT ON COLUMN tb_sd_so_h.so_stat IS '수주상태(SO_STAT)';

CREATE TABLE tb_sd_so_d (
  so_no      varchar(12),
  so_seq     int,
  item_cd    varchar(30),
  so_qty     numeric(12,2),
  unit       varchar(10),
  unit_prc   numeric(14,2),
  req_dlv_dt char(8),
  dlv_qty    numeric(12,2) DEFAULT 0,
  cls_yn     char(1) DEFAULT 'N',
  PRIMARY KEY (so_no, so_seq)
);
COMMENT ON TABLE tb_sd_so_d IS '수주 상세';
COMMENT ON COLUMN tb_sd_so_d.req_dlv_dt IS '고객 요청 납기';

CREATE TABLE tb_sd_dlv (
  dlv_no   varchar(14) PRIMARY KEY,
  so_no    varchar(12),
  so_seq   int,
  cust_cd  varchar(6),
  item_cd  varchar(30),
  dlv_qty  numeric(12,2),
  dlv_dt   char(8),
  wh_cd    varchar(4),
  lot_no   varchar(20),
  rtn_yn   char(1) DEFAULT 'N'
);
COMMENT ON TABLE tb_sd_dlv IS '출하(납품)';

CREATE TABLE tb_pp_plan (
  plan_dt  char(8),
  line_cd  varchar(6),
  item_cd  varchar(30),
  plan_qty numeric(12,2),
  plan_ver int DEFAULT 1,
  PRIMARY KEY (plan_dt, line_cd, item_cd)
);
COMMENT ON TABLE tb_pp_plan IS '일 생산계획';

CREATE TABLE tb_pp_rcpt (
  rcpt_no  varchar(14) PRIMARY KEY,
  rcpt_dt  char(8),
  mo_no    varchar(12),
  item_cd  varchar(30),
  rcpt_qty numeric(12,2),
  wh_cd    varchar(4),
  src      varchar(4)
);
COMMENT ON TABLE tb_pp_rcpt IS '생산입고(MES 실적 인터페이스)';

CREATE TABLE tb_pp_mat_chk (
  chk_dt    char(8),
  mo_no     varchar(12),
  comp_cd   varchar(30),
  req_qty   numeric(12,3),
  avail_qty numeric(14,3),
  short_qty numeric(12,3),
  PRIMARY KEY (chk_dt, mo_no, comp_cd)
);
COMMENT ON TABLE tb_pp_mat_chk IS '제조오더 착수 전 자재 가용성 점검(배치, 06:00)';
COMMENT ON COLUMN tb_pp_mat_chk.avail_qty IS '전일 마감 재고 + 당일 오전 입고 - 격리분';
COMMENT ON COLUMN tb_pp_rcpt.src IS 'MES:MES 연계 HIST:MES 도입 전 이력';

CREATE TABLE tb_mm_po_h (
  po_no   varchar(12) PRIMARY KEY,
  vend_cd varchar(6),
  po_dt   char(8),
  po_stat varchar(2),
  emp_no  varchar(8)
);
COMMENT ON TABLE tb_mm_po_h IS '구매발주 헤더';

CREATE TABLE tb_mm_po_d (
  po_no    varchar(12),
  po_seq   int,
  item_cd  varchar(30),
  po_qty   numeric(12,2),
  unit_prc numeric(14,2),
  due_dt   char(8),
  gr_qty   numeric(12,2) DEFAULT 0,
  PRIMARY KEY (po_no, po_seq)
);
COMMENT ON TABLE tb_mm_po_d IS '구매발주 상세';

CREATE TABLE tb_mm_gr (
  gr_no    varchar(14) PRIMARY KEY,
  po_no    varchar(12),
  po_seq   int,
  vend_cd  varchar(6),
  item_cd  varchar(30),
  gr_qty   numeric(12,2),
  gr_dt    char(8),
  wh_cd    varchar(4),
  vend_lot varchar(20),
  iqc_yn   char(1),
  iqc_stat varchar(2)
);
COMMENT ON TABLE tb_mm_gr IS '구매입고';
COMMENT ON COLUMN tb_mm_gr.iqc_stat IS '수입검사 상태(00:대기 10:합격 20:불합격 30:특채)';

CREATE TABLE tb_mm_gi (
  gi_no   varchar(14) PRIMARY KEY,
  gi_dt   char(8),
  gi_tp   varchar(3),
  item_cd varchar(30),
  gi_qty  numeric(12,3),
  wh_cd   varchar(4),
  mo_no   varchar(12),
  rmk     varchar(100)
);
COMMENT ON TABLE tb_mm_gi IS '출고(생산투입·판매·폐기)';
COMMENT ON COLUMN tb_mm_gi.gi_tp IS 'PRD:생산투입 SAL:판매출고 SCR:폐기 ADJ:재고조정';

CREATE TABLE tb_mm_stock_day (
  stk_dt  char(8),
  wh_cd   varchar(4),
  item_cd varchar(30),
  stk_qty numeric(14,3),
  PRIMARY KEY (stk_dt, wh_cd, item_cd)
);
COMMENT ON TABLE tb_mm_stock_day IS '일 마감 재고';

CREATE TABLE tb_mm_stock_lot (
  wh_cd   varchar(4),
  item_cd varchar(30),
  lot_no  varchar(20),
  rcv_dt  char(8),
  stk_qty numeric(14,3),
  PRIMARY KEY (wh_cd, item_cd, lot_no)
);
COMMENT ON TABLE tb_mm_stock_lot IS '현재고 LOT별(입고일 포함)';

CREATE TABLE tb_mm_cnt (
  cnt_no   varchar(12),
  cnt_dt   char(8),
  wh_cd    varchar(4),
  item_cd  varchar(30),
  book_qty numeric(14,3),
  cnt_qty  numeric(14,3),
  PRIMARY KEY (cnt_no, wh_cd, item_cd)
);
COMMENT ON TABLE tb_mm_cnt IS '재고실사';

COMMENT ON COLUMN tb_sd_so_d.unit_prc IS '판매단가(원)';
