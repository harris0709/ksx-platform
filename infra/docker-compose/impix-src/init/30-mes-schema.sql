-- =====================================================================
-- IMPIX 레거시 MES (가상) — 스키마 mes
--   FK를 거의 선언하지 않고, 일시를 문자열로 저장하며, 상태값을 하드코딩한
--   전형적인 현장 MES 구조. 주석도 일부만 달려 있다.
-- =====================================================================
\connect impix_mes
CREATE SCHEMA mes;
SET search_path = mes;

CREATE TABLE tm_factory (
  fac_id       varchar(4) PRIMARY KEY,
  fac_nm       varchar(50),
  erp_plant_cd varchar(4),
  use_flag     char(1)
);
COMMENT ON TABLE tm_factory IS '공장 기준정보';
COMMENT ON COLUMN tm_factory.erp_plant_cd IS 'ERP 플랜트코드';

CREATE TABLE tm_code (
  grp_cd   varchar(20),
  cd       varchar(20),
  cd_nm    varchar(100),
  sort_no  int,
  use_flag char(1),
  PRIMARY KEY (grp_cd, cd)
);
COMMENT ON TABLE tm_code IS 'MES 코드';

CREATE TABLE tm_proc (
  proc_cd   varchar(6) PRIMARY KEY,
  proc_nm   varchar(50),
  proc_tp   varchar(2),
  fac_id    varchar(4),
  erp_wc_cd varchar(6),
  seq_no    int,
  use_flag  char(1)
);
COMMENT ON TABLE tm_proc IS '공정';

CREATE TABLE tm_line (
  line_id     varchar(6) PRIMARY KEY,
  line_nm     varchar(50),
  fac_id      varchar(4),
  erp_line_cd varchar(6),
  use_flag    char(1)
);

CREATE TABLE tm_eqp (
  eqp_id     varchar(10) PRIMARY KEY,
  eqp_nm     varchar(100),
  eqp_grp    varchar(6),
  eqp_kind   varchar(2),
  proc_cd    varchar(6),
  line_id    varchar(6),
  fac_id     varchar(4),
  maker      varchar(50),
  model_no   varchar(50),
  serial_no  varchar(50),
  install_dt char(8),
  plc_ip     varchar(15),
  mgr_emp_no varchar(8),
  use_flag   varchar(1)
);
COMMENT ON TABLE tm_eqp IS '설비 마스터';
COMMENT ON COLUMN tm_eqp.eqp_grp IS '설비그룹(EQP_GRP)';
COMMENT ON COLUMN tm_eqp.eqp_kind IS '설비종류 P:생산 I:검사 L:물류';

CREATE TABLE tm_item (
  item_cd  varchar(30) PRIMARY KEY,
  item_nm  varchar(200),
  item_tp  varchar(2),
  unit     varchar(10),
  sync_dtm timestamp
);
COMMENT ON TABLE tm_item IS '품목(ERP 동기화 사본)';

CREATE TABLE tm_param (
  param_id   varchar(30) PRIMARY KEY,
  eqp_id     varchar(10),
  param_cd   varchar(20),
  param_nm   varchar(50),
  param_kind varchar(2),
  unit       varchar(10),
  lsl        numeric(12,3),
  usl        numeric(12,3),
  lcl        numeric(12,3),
  ucl        numeric(12,3),
  coll_cycle_sec int,
  grade      char(1),
  use_flag   char(1)
);
COMMENT ON TABLE tm_param IS '설비 파라미터 정의';
COMMENT ON COLUMN tm_param.lsl IS '규격하한';
COMMENT ON COLUMN tm_param.usl IS '규격상한';
COMMENT ON COLUMN tm_param.grade IS '관리등급 A/B/C';

CREATE TABLE tb_lot (
  lot_no       varchar(20) PRIMARY KEY,
  lot_tp       char(1),
  item_cd      varchar(30),
  mo_no        varchar(12),
  mo_seq       int,
  fac_id       varchar(4),
  lot_qty      numeric(12,2),
  cur_qty      numeric(12,2),
  ng_qty       numeric(12,2),
  cur_proc_cd  varchar(6),
  next_proc_cd varchar(6),
  lot_stat     char(1),
  hold_flag    char(1),
  hot_flag     char(1),
  rework_cnt   int,
  prior_no     int,
  due_dt       char(8),
  crt_dtm      timestamp,
  crt_user     varchar(10),
  upd_dtm      timestamp
);
COMMENT ON TABLE tb_lot IS 'LOT';
COMMENT ON COLUMN tb_lot.lot_stat IS 'W:대기 R:진행 H:보류 C:완료 S:폐기';

CREATE TABLE tb_lot_link (
  from_lot_no varchar(20),
  to_lot_no   varchar(20),
  link_tp     varchar(8),
  link_qty    numeric(12,2),
  link_dtm    timestamp
);

CREATE TABLE tb_trk_in (
  trk_in_id   bigserial PRIMARY KEY,
  lot_no      varchar(20),
  proc_cd     varchar(6),
  eqp_id      varchar(10),
  in_qty      numeric(12,2),
  trk_in_dtm  varchar(14),
  oper_emp_no varchar(10),
  fac_id      varchar(4)
);
COMMENT ON TABLE tb_trk_in IS '착공(Track-In)';
COMMENT ON COLUMN tb_trk_in.trk_in_dtm IS 'YYYYMMDDHH24MISS';

CREATE TABLE tb_trk_out (
  trk_out_id  bigserial PRIMARY KEY,
  trk_in_id   bigint,
  lot_no      varchar(20),
  proc_cd     varchar(6),
  eqp_id      varchar(10),
  good_qty    numeric(12,2),
  ng_qty      numeric(12,2),
  trk_out_dtm varchar(14),
  oper_emp_no varchar(10)
);
COMMENT ON TABLE tb_trk_out IS '완공(Track-Out)';

CREATE TABLE tb_eqp_stat (
  stat_seq  bigserial PRIMARY KEY,
  eqp_id    varchar(10),
  stat_cd   varchar(2),
  st_dtm    timestamp,
  ed_dtm    timestamp,
  err_cd    varchar(6),
  lot_no    varchar(20),
  ctrl_mode varchar(1),
  oper_mode varchar(1),
  rmk       varchar(200)
);
COMMENT ON TABLE tb_eqp_stat IS '설비 상태 이력';

CREATE TABLE tb_alarm (
  alm_seq   bigserial PRIMARY KEY,
  eqp_id    varchar(10),
  alm_cd    varchar(6),
  alm_lvl   char(1),
  alm_msg   varchar(200),
  occur_dtm timestamp,
  clear_dtm timestamp
);

CREATE TABLE tb_param_val (
  eqp_id   varchar(10),
  param_id varchar(30),
  coll_dtm timestamp,
  val      numeric(14,4),
  lot_no   varchar(20)
);
CREATE INDEX ix_param_val_eqp_dtm ON tb_param_val (eqp_id, coll_dtm);
COMMENT ON TABLE tb_param_val IS '설비 파라미터 수집값(10분 주기)';

CREATE TABLE tb_qc_insp (
  insp_no     varchar(24) PRIMARY KEY,
  lot_no      varchar(20),
  proc_cd     varchar(6),
  insp_tp     char(1),
  insp_qty    numeric(12,2),
  good_qty    numeric(12,2),
  ng_qty      numeric(12,2),
  judge       varchar(4),
  insp_dtm    timestamp,
  insp_emp_no varchar(10)
);
COMMENT ON TABLE tb_qc_insp IS '품질검사 실적';

CREATE TABLE tb_qc_defect (
  insp_no    varchar(24),
  defect_cd  varchar(10),
  defect_qty numeric(12,2),
  PRIMARY KEY (insp_no, defect_cd)
);

CREATE TABLE tb_prod_rslt (
  rslt_dt  char(8),
  fac_id   varchar(4),
  line_id  varchar(6),
  proc_cd  varchar(6),
  item_cd  varchar(30),
  mo_no    varchar(12),
  good_qty numeric(12,2),
  ng_qty   numeric(12,2),
  work_min numeric(10,1),
  PRIMARY KEY (rslt_dt, proc_cd, item_cd, mo_no)
);
COMMENT ON TABLE tb_prod_rslt IS '일별 생산실적 집계';
