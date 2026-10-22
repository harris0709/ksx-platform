-- =====================================================================
-- IMPIX 레거시 ERP (가상) — 스키마 erp
--   표준(KS X 9101)과 다른 이름·약어·자체 코드를 쓰는 전형적인 국내 ERP 구조.
--   S1 스키마 추출·프로파일링, S2 매핑 실습의 원천이다.
-- =====================================================================
\connect impix_erp
CREATE SCHEMA erp;
SET search_path = erp;

CREATE TABLE tb_cm_comp (
  comp_cd   varchar(10) PRIMARY KEY,
  comp_nm   varchar(100) NOT NULL,
  biz_reg_no varchar(12),
  corp_reg_no varchar(14),
  ceo_nm    varchar(50),
  tel_no    varchar(20),
  zip_cd    varchar(6),
  addr1     varchar(200),
  addr2     varchar(200),
  curr_cd   varchar(3) DEFAULT 'KRW',
  use_yn    char(1) DEFAULT 'Y',
  reg_dt    timestamp DEFAULT now(),
  reg_id    varchar(8)
);
COMMENT ON TABLE tb_cm_comp IS '회사 마스터';
COMMENT ON COLUMN tb_cm_comp.comp_cd IS '회사코드';
COMMENT ON COLUMN tb_cm_comp.comp_nm IS '회사명';
COMMENT ON COLUMN tb_cm_comp.biz_reg_no IS '사업자등록번호';
COMMENT ON COLUMN tb_cm_comp.corp_reg_no IS '법인등록번호';
COMMENT ON COLUMN tb_cm_comp.ceo_nm IS '대표자명';
COMMENT ON COLUMN tb_cm_comp.curr_cd IS '기준통화';

CREATE TABLE tb_cm_bizarea (
  bizarea_cd varchar(4) PRIMARY KEY,
  comp_cd    varchar(10) NOT NULL REFERENCES tb_cm_comp(comp_cd),
  bizarea_nm varchar(100) NOT NULL,
  biz_reg_no varchar(12),
  tel_no     varchar(20),
  addr1      varchar(200),
  use_yn     char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_cm_bizarea IS '사업장(사업영역) 마스터';
COMMENT ON COLUMN tb_cm_bizarea.bizarea_cd IS '사업장코드';
COMMENT ON COLUMN tb_cm_bizarea.bizarea_nm IS '사업장명';

CREATE TABLE tb_cm_plant (
  plant_cd   varchar(4) PRIMARY KEY,
  comp_cd    varchar(10) NOT NULL REFERENCES tb_cm_comp(comp_cd),
  bizarea_cd varchar(4) REFERENCES tb_cm_bizarea(bizarea_cd),
  plant_nm   varchar(100) NOT NULL,
  tel_no     varchar(20),
  addr1      varchar(200),
  use_yn     char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_cm_plant IS '공장(플랜트) 마스터';
COMMENT ON COLUMN tb_cm_plant.plant_cd IS '플랜트코드';
COMMENT ON COLUMN tb_cm_plant.plant_nm IS '플랜트명';

CREATE TABLE tb_cm_dept (
  dept_cd    varchar(6) PRIMARY KEY,
  dept_nm    varchar(100) NOT NULL,
  upper_dept_cd varchar(6),
  plant_cd   varchar(4),
  use_yn     char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_cm_dept IS '부서';
COMMENT ON COLUMN tb_cm_dept.dept_cd IS '부서코드';
COMMENT ON COLUMN tb_cm_dept.upper_dept_cd IS '상위부서코드';

CREATE TABLE tb_hr_emp (
  emp_no    varchar(8) PRIMARY KEY,
  emp_nm    varchar(50) NOT NULL,
  dept_cd   varchar(6) REFERENCES tb_cm_dept(dept_cd),
  plant_cd  varchar(4),
  email     varchar(100),
  hp_no     varchar(20),
  retire_yn char(1) DEFAULT 'N',
  join_dt   char(8)
);
COMMENT ON TABLE tb_hr_emp IS '사원';
COMMENT ON COLUMN tb_hr_emp.emp_no IS '사번';
COMMENT ON COLUMN tb_hr_emp.retire_yn IS '퇴직여부';

CREATE TABLE tb_cm_code (
  code_grp  varchar(20) NOT NULL,
  code      varchar(20) NOT NULL,
  code_nm   varchar(100) NOT NULL,
  sort_seq  int,
  use_yn    char(1) DEFAULT 'Y',
  rmk       varchar(200),
  PRIMARY KEY (code_grp, code)
);
COMMENT ON TABLE tb_cm_code IS 'ERP 공통코드';
COMMENT ON COLUMN tb_cm_code.code_grp IS '코드그룹';

CREATE TABLE tb_mm_item (
  item_cd    varchar(30) PRIMARY KEY,
  item_nm    varchar(200) NOT NULL,
  item_spec  varchar(200),
  item_tp    varchar(2),
  item_grp   varchar(10),
  model_nm   varchar(50),
  unit       varchar(10),
  wgt        numeric(12,3),
  wgt_unit   varchar(5),
  lot_yn     char(1) DEFAULT 'Y',
  safety_qty numeric(12,2),
  pur_lt     int,
  prd_lt     int,
  lot_size   numeric(12,2),
  drw_no     varchar(30),
  iqc_yn     char(1),
  fqc_yn     char(1),
  oqc_yn     char(1),
  plant_cd   varchar(4),
  use_yn     char(1) DEFAULT 'Y',
  reg_dt     timestamp,
  upd_dt     timestamp
);
COMMENT ON TABLE tb_mm_item IS '품목 마스터';
COMMENT ON COLUMN tb_mm_item.item_cd IS '품목코드';
COMMENT ON COLUMN tb_mm_item.item_nm IS '품목명';
COMMENT ON COLUMN tb_mm_item.item_spec IS '규격';
COMMENT ON COLUMN tb_mm_item.item_tp IS '품목계정(ITEM_TP)';
COMMENT ON COLUMN tb_mm_item.item_grp IS '품목군(ITEM_GRP)';
COMMENT ON COLUMN tb_mm_item.unit IS '재고단위';
COMMENT ON COLUMN tb_mm_item.lot_yn IS 'LOT관리여부';
COMMENT ON COLUMN tb_mm_item.pur_lt IS '구매L/T(일)';
COMMENT ON COLUMN tb_mm_item.prd_lt IS '생산L/T(일)';

CREATE TABLE tb_pp_wc (
  wc_cd    varchar(6) PRIMARY KEY,
  wc_nm    varchar(100) NOT NULL,
  wc_tp    varchar(2),
  plant_cd varchar(4) REFERENCES tb_cm_plant(plant_cd),
  use_yn   char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_pp_wc IS '작업장(Work Center)';
COMMENT ON COLUMN tb_pp_wc.wc_cd IS '작업장코드';
COMMENT ON COLUMN tb_pp_wc.wc_tp IS '작업장유형(WC_TP)';

CREATE TABLE tb_pp_line (
  line_cd  varchar(6) PRIMARY KEY,
  line_nm  varchar(100) NOT NULL,
  line_tp  varchar(2),
  plant_cd varchar(4) REFERENCES tb_cm_plant(plant_cd),
  capa_qty numeric(12,2),
  capa_unit varchar(10),
  shift_cnt int,
  use_yn   char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_pp_line IS '생산라인';
COMMENT ON COLUMN tb_pp_line.capa_qty IS '일 표준능력';

CREATE TABLE tb_pp_rout_h (
  rout_cd varchar(20) PRIMARY KEY,
  rout_nm varchar(100),
  item_cd varchar(30) REFERENCES tb_mm_item(item_cd),
  plant_cd varchar(4),
  use_yn  char(1) DEFAULT 'Y'
);
COMMENT ON TABLE tb_pp_rout_h IS '라우팅 헤더';

CREATE TABLE tb_pp_rout_d (
  rout_cd   varchar(20) NOT NULL REFERENCES tb_pp_rout_h(rout_cd),
  oper_seq  int NOT NULL,
  wc_cd     varchar(6) REFERENCES tb_pp_wc(wc_cd),
  setup_min numeric(8,2),
  run_sec   numeric(8,2),
  move_min  numeric(8,2),
  last_yn   char(1) DEFAULT 'N',
  PRIMARY KEY (rout_cd, oper_seq)
);
COMMENT ON TABLE tb_pp_rout_d IS '라우팅 상세(공정순서)';
COMMENT ON COLUMN tb_pp_rout_d.oper_seq IS '공정순번';
COMMENT ON COLUMN tb_pp_rout_d.run_sec IS '개당 작업시간(초)';

CREATE TABLE tb_pp_bom_h (
  prnt_item_cd varchar(30) NOT NULL REFERENCES tb_mm_item(item_cd),
  bom_rev   varchar(3) NOT NULL,
  bom_tp    varchar(2),
  base_qty  numeric(12,3) DEFAULT 1,
  unit      varchar(10),
  rout_cd   varchar(20),
  plant_cd  varchar(4),
  PRIMARY KEY (prnt_item_cd, bom_rev)
);
COMMENT ON TABLE tb_pp_bom_h IS 'BOM 헤더';
COMMENT ON COLUMN tb_pp_bom_h.bom_tp IS 'BOM유형(BOM_TP)';

CREATE TABLE tb_pp_bom_d (
  prnt_item_cd varchar(30) NOT NULL,
  bom_rev   varchar(3) NOT NULL,
  seq       int NOT NULL,
  chld_item_cd varchar(30),
  req_qty   numeric(12,4),
  unit      varchar(10),
  oper_seq  int,
  bf_yn     char(1) DEFAULT 'N',
  valid_fr  char(8),
  valid_to  char(8),
  PRIMARY KEY (prnt_item_cd, bom_rev, seq),
  FOREIGN KEY (prnt_item_cd, bom_rev) REFERENCES tb_pp_bom_h(prnt_item_cd, bom_rev)
);
COMMENT ON TABLE tb_pp_bom_d IS 'BOM 상세(자품목)';
COMMENT ON COLUMN tb_pp_bom_d.req_qty IS '소요량';
COMMENT ON COLUMN tb_pp_bom_d.bf_yn IS '백플러시여부';

CREATE TABLE tb_pp_mo (
  mo_no     varchar(12) NOT NULL,
  mo_seq    int NOT NULL,
  item_cd   varchar(30) REFERENCES tb_mm_item(item_cd),
  plant_cd  varchar(4),
  line_cd   varchar(6),
  rout_cd   varchar(20),
  bom_rev   varchar(3),
  mo_qty    numeric(12,2),
  unit      varchar(10),
  plan_st_dt char(8),
  plan_ed_dt char(8),
  due_dt    char(8),
  so_no     varchar(12),
  so_seq    int,
  mo_stat   varchar(2),
  reg_dt    timestamp,
  reg_id    varchar(8),
  PRIMARY KEY (mo_no, mo_seq)
);
COMMENT ON TABLE tb_pp_mo IS '제조오더(작업지시)';
COMMENT ON COLUMN tb_pp_mo.mo_no IS '제조오더번호';
COMMENT ON COLUMN tb_pp_mo.mo_stat IS '오더상태(MO_STAT)';
COMMENT ON COLUMN tb_pp_mo.due_dt IS '납기일(YYYYMMDD)';
