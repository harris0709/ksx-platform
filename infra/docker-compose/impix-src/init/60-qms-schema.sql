-- =====================================================================
-- IMPIX 품질경영시스템 QMS(가상) — 스키마 qms
--   고객 클레임·수입검사·협력사 부적합·폐기·Q-COST. 별도 패키지라 코드 체계가 ERP·MES와 다름
-- =====================================================================
\connect impix_qms
CREATE SCHEMA qms;
SET search_path = qms;

CREATE TABLE qm_code (
  code_grp varchar(20), code varchar(20), code_nm varchar(100), sort_seq int, use_yn char(1),
  PRIMARY KEY (code_grp, code)
);
COMMENT ON TABLE qm_code IS 'QMS 코드';

CREATE TABLE qm_claim (
  claim_no    varchar(12) PRIMARY KEY,
  cust_cd     varchar(6),
  item_cd     varchar(30),
  lot_no      varchar(20),
  claim_tp    varchar(2),
  occur_dt    char(8),
  rcv_dt      char(8),
  defect_cd   varchar(10),
  claim_qty   numeric(10,2),
  resp_due_dt char(8),
  resp_dt     char(8),
  close_dt    char(8),
  status      varchar(6),
  claim_amt   numeric(14,2),
  cause_proc  varchar(6),
  descr       varchar(300)
);
COMMENT ON TABLE qm_claim IS '고객 클레임(부적합·라인중단·필드반송)';
COMMENT ON COLUMN qm_claim.claim_tp IS 'NC:고객부적합 LS:라인중단 FR:필드반송';
COMMENT ON COLUMN qm_claim.resp_due_dt IS '대책서(8D) 회신 기한';

CREATE TABLE qm_iqc (
  iqc_no    varchar(14) PRIMARY KEY,
  gr_no     varchar(14),
  vend_cd   varchar(6),
  item_cd   varchar(30),
  vend_lot  varchar(20),
  insp_dt   char(8),
  rcv_qty   numeric(12,2),
  smpl_qty  numeric(12,2),
  ng_qty    numeric(12,2),
  judge     char(1),
  defect_cd varchar(10),
  insp_emp  varchar(8)
);
COMMENT ON TABLE qm_iqc IS '수입검사';
COMMENT ON COLUMN qm_iqc.judge IS 'A:합격 R:불합격 S:특채';

CREATE TABLE qm_vend_ncr (
  ncr_no      varchar(12) PRIMARY KEY,
  vend_cd     varchar(6),
  item_cd     varchar(30),
  iqc_no      varchar(14),
  found_at    varchar(4),
  occur_dt    char(8),
  ng_qty      numeric(12,2),
  defect_cd   varchar(10),
  car_due_dt  char(8),
  car_cls_dt  char(8)
);
COMMENT ON TABLE qm_vend_ncr IS '협력사 부적합(시정조치 요구)';
COMMENT ON COLUMN qm_vend_ncr.found_at IS 'IQC:수입검사 LINE:공정 CUST:고객';

CREATE TABLE qm_scrap (
  scrap_no  varchar(16) PRIMARY KEY,
  scrap_dt  char(8),
  plant_cd  varchar(4),
  proc_cd   varchar(6),
  item_cd   varchar(30),
  lot_no    varchar(20),
  defect_cd varchar(10),
  scrap_qty numeric(12,2),
  unit_cost numeric(14,2),
  scrap_amt numeric(16,2)
);
COMMENT ON TABLE qm_scrap IS '불량 폐기(MES 불량 실적 연계)';

CREATE TABLE qm_qcost (
  cost_ym  char(6),
  cost_cls varchar(2),
  cost_itm varchar(20),
  amount   numeric(16,2),
  ref_no   varchar(16),
  PRIMARY KEY (cost_ym, cost_cls, cost_itm)
);
COMMENT ON TABLE qm_qcost IS 'Q-COST 월 집계';
COMMENT ON COLUMN qm_qcost.cost_cls IS 'P:예방 A:평가 IF:내부실패 EF:외부실패';
