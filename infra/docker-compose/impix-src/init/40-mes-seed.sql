-- IMPIX MES 시드 데이터 (가상). 기간 2026-09-21 ~ 2026-10-20, 결정적으로 생성(실행할 때마다 같은 결과).
-- 시나리오용 사건: DCM-02 금형온도 상승(2026-10-02 06:00 ~ 10-06 18:00) → 해당 하우징 기공 → 조립 후 누설 불량·보류
-- 의도적 품질 이슈는 [이슈] 주석으로 표시.
\connect impix_mes
SET search_path = mes;

-- 결정적 난수(0~1): 같은 키는 항상 같은 값
CREATE FUNCTION prand(k text) RETURNS numeric LANGUAGE sql IMMUTABLE AS
$$ SELECT (abs(hashtextextended(k, 42)) % 1000000) / 1000000.0 $$;

INSERT INTO tm_factory VALUES ('IMP1','1공장(주조·가공)','1100','Y'),('IMP2','2공장(조립·검사)','1200','Y');

INSERT INTO tm_code VALUES
 ('EQP_STAT','1','가동',1,'Y'),('EQP_STAT','2','대기',2,'Y'),('EQP_STAT','3','고장',3,'Y'),
 ('EQP_STAT','4','보전',4,'Y'),('EQP_STAT','5','셋업',5,'Y'),('EQP_STAT','6','비가동(계획)',6,'Y'),
 ('EQP_GRP','DCM','다이캐스팅기',1,'Y'),('EQP_GRP','CNC','CNC',2,'Y'),('EQP_GRP','WSH','세척기',3,'Y'),
 ('EQP_GRP','ASM','조립기',4,'Y'),('EQP_GRP','LKT','누설시험기',5,'Y'),('EQP_GRP','VIS','비전검사기',6,'Y'),('EQP_GRP','PKG','포장기',7,'Y'),
 ('ERR_CD','E01','비상정지',1,'Y'),('ERR_CD','E02','과부하',2,'Y'),('ERR_CD','E03','온도이상',3,'Y'),
 ('ERR_CD','E04','압력이상',4,'Y'),('ERR_CD','E05','통신이상',5,'Y'),('ERR_CD','E06','자재부족',6,'Y'),('ERR_CD','E07','공구마모',7,'Y'),
 ('ALM_CD','A001','비상정지 발생',1,'Y'),('ALM_CD','A101','금형온도 상한 초과',2,'Y'),('ALM_CD','A102','사출압력 이상',3,'Y'),
 ('ALM_CD','A201','스핀들 과부하',4,'Y'),('ALM_CD','A202','진동 과다',5,'Y'),('ALM_CD','A301','시험압력 저하',6,'Y'),
 ('ALM_CD','A900','통신 끊김',9,'Y'),
 ('DEFECT_CD','D-PORO','기공',1,'Y'),('DEFECT_CD','D-SCR','스크래치',2,'Y'),('DEFECT_CD','D-BURR','버',3,'Y'),
 ('DEFECT_CD','D-DIM','치수불량',4,'Y'),('DEFECT_CD','D-LEAK','누설',5,'Y'),('DEFECT_CD','D-NOISE','이음',6,'Y'),
 ('DEFECT_CD','D-FUNC','작동불량',7,'Y'),('DEFECT_CD','D-ASSY','오조립',8,'Y'),('DEFECT_CD','D-SHORT','미성형',9,'Y'),
 ('PARAM_KIND','T','온도',1,'Y'),('PARAM_KIND','P','압력',2,'Y'),('PARAM_KIND','C','사이클',3,'Y'),
 ('PARAM_KIND','L','부하',4,'Y'),('PARAM_KIND','V','진동',5,'Y'),('PARAM_KIND','K','누설량',6,'Y'),('PARAM_KIND','Q','토크',7,'Y'),
 ('INSP_TP','P','공정검사',1,'Y'),('INSP_TP','L','누설검사',2,'Y'),('INSP_TP','F','최종검사',3,'Y'),
 ('PROC_TP','DC','주조',1,'Y'),('PROC_TP','MC','가공',2,'Y'),('PROC_TP','WS','세척',3,'Y'),
 ('PROC_TP','AS','조립',4,'Y'),('PROC_TP','IN','검사',5,'Y'),('PROC_TP','PK','포장',6,'Y');
-- [이슈] LOT 상태(W/R/H/C/S)는 코드 테이블에 없음(프로그램 하드코딩)

INSERT INTO tm_proc VALUES
 ('P100','다이캐스팅','DC','IMP1','WDC10',10,'Y'),('P200','CNC가공','MC','IMP1','WMC20',20,'Y'),('P300','세척/외관','WS','IMP1','WWS30',30,'Y'),
 ('A100','조립','AS','IMP2','WAS40',10,'Y'),('A200','누설시험','IN','IMP2','WLT50',20,'Y'),('A300','최종검사','IN','IMP2','WFI60',30,'Y'),('A400','포장','PK','IMP2','WPK70',40,'Y');

INSERT INTO tm_line VALUES ('L-M1','하우징가공','IMP1','ML01','Y'),('L-A1','A100조립','IMP2','AL01','Y'),('L-A2','B200조립','IMP2','AL02','Y');

INSERT INTO tm_eqp VALUES
 ('DCM-01','다이캐스팅기 1호','DCM','P','P100','L-M1','IMP1','도시바기계','DC350J','DC350-1801','20180305','10.10.1.11','20200061','Y'),
 ('DCM-02','다이캐스팅기 2호','DCM','P','P100','L-M1','IMP1','도시바기계','DC350J','DC350-1802','20180305','10.10.1.12','20200061','Y'),
 ('DCM-03','다이캐스팅기 3호','DCM','P','P100','L-M1','IMP1','LK','IMPRESS-400','LK400-2103','20210510','10.10.1.13','20200061','Y'),
 ('DCM-04','다이캐스팅기 4호','DCM','P','P100','L-M1','IMP1','LK','IMPRESS-400','LK400-2104','20210510','10.10.1.14','20200062','Y'),
 ('DCM-00','다이캐스팅기 구0호','DCM','P','P100','L-M1','IMP1','도시바기계','DC250',NULL,'20120101',NULL,NULL,'N'),
 ('CNC-01','수직형 MCT 1호','CNC','P','P200','L-M1','IMP1','두산','DNM 5700','DNM-1901','20190402','10.10.2.11','20200062','Y'),
 ('CNC-02','수직형 MCT 2호','CNC','P','P200','L-M1','IMP1','두산','DNM 5700','DNM-1902','20190402','10.10.2.12','20200062','Y'),
 ('CNC-03','수직형 MCT 3호','CNC','P','P200','L-M1','IMP1','두산','DNM 5700','DNM-1903','20190402','10.10.2.13','20200062','Y'),
 ('CNC-04','수직형 MCT 4호','CNC','P','P200','L-M1','IMP1','화천','VESTA-1000','VST-2205','20220815','10.10.2.14','20200062','Y'),
 ('CNC-05','수직형 MCT 5호','CNC','P','P200','L-M1','IMP1','화천','VESTA-1000','VST-2206','20220815','10.10.2.15','20200062','Y'),
 ('CNC-06','수직형 MCT 6호','CNC','P','P200','L-M1','IMP1','화천','VESTA-1000','VST-2401','20240108','10.10.2.16','20200062','1'),   -- [이슈] 사용여부 '1'
 ('WSH-01','세척기 1호','WSH','P','P300','L-M1','IMP1','대성','DS-WS200',NULL,'20180305','10.10.3.11','20200061','Y'),
 ('ASM-01','펌프 조립기 A1','ASM','P','A100','L-A1','IMP2','자체제작',NULL,NULL,'20240210','10.20.1.11','20200061','Y'),
 ('ASM-02','펌프 조립기 B1','ASM','P','A100','L-A2','IMP2','자체제작',NULL,NULL,'20250105','10.20.1.12','20200061','Y'),
 ('LKT-01','누설시험기 1호','LKT','I','A200','L-A1','IMP2','코스모','LS-R902','R902-2401','20240210','10.20.2.11','20210071','Y'),
 ('LKT-02','누설시험기 2호','LKT','I','A200','L-A2','IMP2','코스모','LS-R902','R902-2501','20250105','10.20.2.12','20210071','Y'),
 ('VIS-01','비전·성능 검사기','VIS','I','A300',NULL,'IMP2','자체제작',NULL,NULL,'20240210','10.20.3.11','20210071','Y'),
 ('PKG-01','자동 포장기','PKG','L','A400',NULL,'IMP2','삼일','SI-PK10',NULL,'20240210',NULL,NULL,'Y');

INSERT INTO tm_item VALUES
 ('EWP-A100','전동식 워터펌프 A100','10','EA','2026-09-01 02:00'),
 ('EWP-B200','전동식 워터펌프 B200','10','EA','2026-09-01 02:00'),
 ('HSG-A100','펌프하우징 A100(가공)','20','EA','2026-09-01 02:00'),
 ('HSG-B200','펌프하우징 B200(가공)','20','EA','2026-09-01 02:00'),
 ('ALDC12','알루미늄 합금 잉곳 ALDC12','30','KG','2026-09-01 02:00');

-- 파라미터 정의 31건
INSERT INTO tm_param
SELECT e.eqp_id || '_' || p.cd, e.eqp_id, p.cd, p.nm, p.kind,
       CASE WHEN e.eqp_id = 'DCM-04' AND p.cd = 'MOLD_TEMP' THEN 'degC'      -- [이슈] 단위 표기 혼재
            WHEN e.eqp_id = 'CNC-06' AND p.cd = 'VIB' THEN 'mm/sec'
            ELSE p.unit END,
       p.lsl, p.usl, p.lcl, p.ucl, 600, p.grade, 'Y'
FROM tm_eqp e
JOIN (VALUES
  ('DCM','MOLD_TEMP','금형온도','T','℃',180,240,192,228,'A'),
  ('DCM','INJ_PRESS','사출압력','P','bar',600,900,680,840,'A'),
  ('DCM','CYCLE_T','사이클타임','C','sec',40,60,43,55,'C'),
  ('CNC','SPDL_LOAD','스핀들부하','L','%',0,85,NULL,75,'B'),
  ('CNC','VIB','진동','V','mm/s',0,4.5,NULL,3.5,'B'),
  ('WSH','WASH_TEMP','세척수온도','T','℃',50,70,54,66,'C'),
  ('LKT','LEAK_RATE','누설량','K','cc/min',0,2.0,NULL,1.5,'A'),
  ('LKT','TEST_PRESS','시험압력','P','kPa',190,210,194,206,'B'),
  ('ASM','TORQUE','체결토크','Q','N·m',5.5,7.0,5.8,6.7,'B')
) AS p(grp,cd,nm,kind,unit,lsl,usl,lcl,ucl,grade) ON p.grp = e.eqp_grp
WHERE e.use_flag <> 'N';

-- ---------------------------------------------------------------
-- LOT·착공·완공·검사
-- ---------------------------------------------------------------
CREATE FUNCTION sim_trk(p_lot text, p_proc text, p_eqp text, p_st timestamp, p_min numeric,
                        p_in numeric, p_ng numeric, p_emp text) RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE v_id bigint; v_ed timestamp := p_st + make_interval(mins => p_min::int);
BEGIN
  INSERT INTO tb_trk_in(lot_no,proc_cd,eqp_id,in_qty,trk_in_dtm,oper_emp_no,fac_id)
  VALUES (p_lot,p_proc,p_eqp,p_in,to_char(p_st,'YYYYMMDDHH24MISS'),p_emp,
          CASE WHEN p_proc LIKE 'P%' THEN 'IMP1' ELSE 'IMP2' END)
  RETURNING trk_in_id INTO v_id;
  INSERT INTO tb_trk_out(trk_in_id,lot_no,proc_cd,eqp_id,good_qty,ng_qty,trk_out_dtm,oper_emp_no)
  VALUES (v_id,p_lot,p_proc,p_eqp,p_in - p_ng,p_ng,to_char(v_ed,'YYYYMMDDHH24MISS'),p_emp);
  RETURN p_in - p_ng;
END $$;

CREATE FUNCTION sim_qc(p_lot text, p_proc text, p_tp text, p_in numeric, p_ng numeric,
                       p_dtm timestamp, p_emp text, p_codes text[], p_main text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE v_no text := 'Q' || to_char(p_dtm,'YYMMDD') || '-' || p_lot || '-' || p_proc;
        v_rest numeric := p_ng; v_q numeric; c text;
BEGIN
  INSERT INTO tb_qc_insp VALUES (v_no,p_lot,p_proc,p_tp,p_in,p_in-p_ng,p_ng,
     CASE WHEN p_in > 0 AND p_ng / p_in > 0.03 THEN 'NG' ELSE 'OK' END, p_dtm, p_emp);
  IF p_ng <= 0 THEN RETURN; END IF;
  IF p_main IS NOT NULL THEN       -- 주 불량(사건 원인) 우선 배분
    v_q := ceil(p_ng * 0.8);
    INSERT INTO tb_qc_defect VALUES (v_no,p_main,v_q);
    v_rest := p_ng - v_q;
  END IF;
  FOREACH c IN ARRAY p_codes LOOP
    EXIT WHEN v_rest <= 0;
    CONTINUE WHEN c = p_main;
    v_q := CASE WHEN c = p_codes[array_length(p_codes,1)] THEN v_rest
                ELSE least(v_rest, ceil(v_rest * (0.4 + 0.4 * prand(v_no || c)))) END;
    INSERT INTO tb_qc_defect VALUES (v_no,c,v_q);
    v_rest := v_rest - v_q;
  END LOOP;
  IF v_rest > 0 THEN
    UPDATE tb_qc_defect SET defect_qty = defect_qty + v_rest
     WHERE insp_no = v_no AND defect_cd = coalesce(p_main, p_codes[1]);
  END IF;
END $$;

DO $$
DECLARE
  d date; hd date; di int; n int; k int; nlots int; prod text; mo text;
  hlot text; elot text; dcm text; cnc text; asm text; lkt text;
  hitem text; eitem text; t0 timestamp; f numeric; q numeric; ng numeric;
  bad boolean; t_dc timestamp; t_mc timestamp; t_ws timestamp;
  t_as timestamp; t_lt timestamp; t_fi timestamp; t_pk timestamp; lt_rate numeric;
  op_dc text; op_as text; op_qc text; slot int;
BEGIN
  FOR d IN SELECT g::date FROM generate_series(DATE '2026-09-21', DATE '2026-10-20', interval '1 day') g
           WHERE extract(isodow FROM g) <> 7 LOOP
    hd := d - 1; IF extract(isodow FROM hd) = 7 THEN hd := d - 2; END IF;
    di := d - DATE '2026-09-21';
    FOR n IN 1..2 LOOP
      prod  := CASE n WHEN 1 THEN 'A' ELSE 'B' END;
      mo    := 'MO' || to_char(d,'YYMMDD') || lpad(n::text,3,'0');
      hitem := CASE n WHEN 1 THEN 'HSG-A100' ELSE 'HSG-B200' END;
      eitem := CASE n WHEN 1 THEN 'EWP-A100' ELSE 'EWP-B200' END;
      asm   := CASE n WHEN 1 THEN 'ASM-01' ELSE 'ASM-02' END;
      lkt   := CASE n WHEN 1 THEN 'LKT-01' ELSE 'LKT-02' END;
      f     := CASE n WHEN 1 THEN 1.0 ELSE 1.25 END;       -- B200은 작업시간 25% 더 김
      nlots := CASE n WHEN 1 THEN 2 ELSE 1 END;
      IF mo = 'MO260930002' THEN                           -- 취소 오더: 생성 후 폐기된 LOT 1건
        INSERT INTO tb_lot VALUES ('H' || to_char(d,'YYMMDD') || 'B1','N',hitem,mo,1,'IMP1',200,0,0,NULL,'P100','S','N','N',0,5,
                                   to_char(d+3,'YYYYMMDD'), hd::timestamp + time '06:10','20150012', hd::timestamp + time '09:00');
        CONTINUE;
      END IF;
      FOR k IN 1..nlots LOOP
        slot := (n-1)*2 + k;                               -- 1,2 = A100 / 3 = B200
        hlot := 'H' || to_char(d,'YYMMDD') || prod || k;
        elot := 'E' || to_char(d,'YYMMDD') || prod || k;
        dcm  := CASE slot WHEN 1 THEN 'DCM-02' ELSE 'DCM-0' || (ARRAY[1,3,4])[1 + (di + slot) % 3] END;   -- DCM-02 = A100 주력 설비
        cnc  := 'CNC-0' || ((di*3 + slot) % 6 + 1);
        op_dc := (ARRAY['20150012','20160021','20170033'])[1 + (di + slot) % 3];
        op_as := (ARRAY['20180041','20180042','20190055'])[1 + (di + slot) % 3];
        op_qc := (ARRAY['20210071','20210072'])[1 + (di + slot) % 2];

        -- 하우징 LOT (전일 주조·가공·세척)
        t_dc := hd::timestamp + time '07:00' + make_interval(mins => (slot-1)*20);
        t_mc := t_dc + make_interval(mins => (200*45*f/60)::int + 30);
        t_ws := hd::timestamp + time '15:40' + make_interval(mins => (slot-1)*80);
        bad  := dcm = 'DCM-02' AND t_dc BETWEEN TIMESTAMP '2026-10-02 06:00' AND TIMESTAMP '2026-10-06 18:00';
        INSERT INTO tb_lot VALUES (hlot,'N',hitem,mo,1,'IMP1',200,NULL,0,NULL,NULL,'R','N','N',0,5,
                                   to_char(d+1,'YYYYMMDD'), hd::timestamp + time '06:10', op_dc, NULL);
        ng := round(200 * 0.006 * prand(hlot||'DC'));
        q  := sim_trk(hlot,'P100',dcm,t_dc,200*45*f/60,200,ng,op_dc);
        ng := round(q * (0.002 + 0.006 * prand(hlot||'MC')));
        q  := sim_trk(hlot,'P200',cnc,t_mc,200*95*f/60,q,ng,op_dc);
        PERFORM sim_qc(hlot,'P200','P',q+ng,ng,t_mc + make_interval(mins => (200*95*f/60)::int),op_qc,ARRAY['D-DIM','D-BURR'],NULL);
        ng := round(q * (0.004 + 0.012 * prand(hlot||'WS')))
              + CASE WHEN bad THEN round(q * (0.02 + 0.02 * prand(hlot||'PORO'))) ELSE 0 END;
        q  := sim_trk(hlot,'P300','WSH-01',t_ws,70*f,q,ng,op_dc);
        PERFORM sim_qc(hlot,'P300','P',q+ng,ng,t_ws + make_interval(mins => (70*f)::int),op_qc,
                       ARRAY['D-SCR','D-BURR','D-PORO'], CASE WHEN bad THEN 'D-PORO' END);
        UPDATE tb_lot SET cur_qty = q, ng_qty = 200 - q, cur_proc_cd = 'P300', next_proc_cd = NULL, lot_stat = 'C',
                          upd_dtm = t_ws + make_interval(mins => (70*f)::int) WHERE lot_no = hlot;

        -- 조립 LOT (당일 조립·누설·최종검사·포장)
        t0   := d::timestamp + time '08:00';
        t_as := t0 + make_interval(mins => CASE slot WHEN 2 THEN 210 ELSE 0 END);
        t_lt := t_as + make_interval(mins => (q*60*f/60)::int + 10);
        INSERT INTO tb_lot VALUES (elot,'N',eitem,mo,1,'IMP2',q,NULL,0,NULL,NULL,'R','N','N',0,5,
                                   to_char(d+3,'YYYYMMDD'), t0 - interval '20 minutes', op_as, NULL);
        INSERT INTO tb_lot_link VALUES (hlot, elot, 'CONSUME', q, t_as);
        q  := sim_trk(elot,'A100',asm,t_as,q*60*f/60,q,round(q * 0.003 * prand(elot||'AS')),op_as);
        ng := round(q * (0.003 + 0.008 * prand(elot||'LT')))
              + CASE WHEN bad THEN round(q * (0.05 + 0.04 * prand(elot||'LEAK'))) ELSE 0 END;
        lt_rate := ng / q;
        q  := sim_trk(elot,'A200',lkt,t_lt,q*30*f/60,q,ng,op_qc);
        PERFORM sim_qc(elot,'A200','L',q+ng,ng,t_lt + make_interval(mins => ((q+ng)*30*f/60)::int),op_qc,
                       ARRAY['D-LEAK'], 'D-LEAK');
        IF lt_rate > 0.05 THEN                              -- 누설 불량률 5% 초과 → 품질 보류
          UPDATE tb_lot SET cur_qty = q, ng_qty = lot_qty - q, cur_proc_cd = 'A200', next_proc_cd = 'A300',
                            lot_stat = 'H', hold_flag = 'Y', upd_dtm = t_lt + interval '2 hours' WHERE lot_no = elot;
          CONTINUE;
        END IF;
        IF d = DATE '2026-10-20' AND slot >= 2 THEN         -- 오늘 진행 중인 LOT
          UPDATE tb_lot SET cur_qty = q, cur_proc_cd = 'A200', next_proc_cd = 'A300', lot_stat = 'W',
                            upd_dtm = t_lt + interval '1 hour' WHERE lot_no = elot;
          CONTINUE;
        END IF;
        t_fi := t_lt + make_interval(mins => (q*30*f/60)::int + 10);
        ng := round(q * (0.002 + 0.006 * prand(elot||'FI')));
        q  := sim_trk(elot,'A300','VIS-01',t_fi,q*20*f/60,q,ng,op_qc);
        PERFORM sim_qc(elot,'A300','F',q+ng,ng,t_fi + make_interval(mins => ((q+ng)*20*f/60)::int),op_qc,
                       ARRAY['D-NOISE','D-FUNC','D-ASSY'],NULL);
        t_pk := t_fi + make_interval(mins => (q*20*f/60)::int + 10);
        q  := sim_trk(elot,'A400','PKG-01',t_pk,q*8/60,q,0,op_as);
        UPDATE tb_lot SET cur_qty = q, ng_qty = lot_qty - q, cur_proc_cd = 'A400', next_proc_cd = NULL, lot_stat = 'C',
                          upd_dtm = t_pk + make_interval(mins => (q*8/60)::int) WHERE lot_no = elot;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;

-- [이슈] 원천 데이터 결함 주입
UPDATE tb_lot SET mo_no = 'MO260999001' WHERE lot_no IN ('H260925A2','E260925A2','E261008B1');   -- ERP에 없는 오더번호
UPDATE tb_lot SET lot_qty = NULL WHERE lot_no = 'E261015A1';                                       -- 수량 누락
UPDATE tb_trk_out SET good_qty = good_qty + 3 WHERE trk_out_id IN (SELECT trk_out_id FROM tb_trk_out ORDER BY trk_out_id OFFSET 101 LIMIT 2);  -- 투입≠양품+불량
UPDATE tb_trk_out o SET trk_out_dtm = to_char(to_timestamp(i.trk_in_dtm,'YYYYMMDDHH24MISS') - interval '5 minutes','YYYYMMDDHH24MISS')
  FROM tb_trk_in i WHERE i.trk_in_id = o.trk_in_id AND o.trk_out_id = 333;                         -- 완공이 착공보다 빠름
UPDATE tb_trk_in SET oper_emp_no = 'OP01' WHERE trk_in_id IN (SELECT trk_in_id FROM tb_trk_in WHERE proc_cd = 'A400' ORDER BY trk_in_id LIMIT 6);  -- ERP 사번이 아닌 공용 계정

-- ---------------------------------------------------------------
-- 파라미터 수집값(10분 주기, 30일)
-- ---------------------------------------------------------------
SELECT setseed(0.42);
INSERT INTO tb_param_val(eqp_id,param_id,coll_dtm,val)
WITH g AS (   -- z: 행마다 새로 뽑는 근사 정규난수(-3~3)
  SELECT p.*, t, (random() + random() + random() - 1.5) * 2 AS z
  FROM tm_param p
  CROSS JOIN generate_series(TIMESTAMP '2026-09-21 00:00', TIMESTAMP '2026-10-20 23:50', interval '10 minutes') t
  WHERE NOT (p.eqp_id = 'DCM-03' AND t BETWEEN TIMESTAMP '2026-10-10 02:00' AND TIMESTAMP '2026-10-10 06:00')   -- 통신 끊김 구간(데이터 공백)
)
SELECT p.eqp_id, p.param_id, t,
       round((
         CASE p.param_cd
           WHEN 'MOLD_TEMP'  THEN 210 + 6   * z
           WHEN 'INJ_PRESS'  THEN 760 + 25  * z
           WHEN 'CYCLE_T'    THEN 48  + 2   * z
           WHEN 'SPDL_LOAD'  THEN 55  + 8   * z
           WHEN 'VIB'        THEN 2.0 + 0.4 * z
           WHEN 'WASH_TEMP'  THEN 60  + 2   * z
           WHEN 'LEAK_RATE'  THEN greatest(0.05, 0.8 + 0.25 * z)
           WHEN 'TEST_PRESS' THEN 200 + 2   * z
           WHEN 'TORQUE'     THEN 6.25 + 0.18 * z
         END
         + CASE WHEN p.param_id = 'DCM-02_MOLD_TEMP' AND t BETWEEN TIMESTAMP '2026-10-02 06:00' AND TIMESTAMP '2026-10-06 18:00'
                THEN 26 + 14 * least(1, extract(epoch FROM t - TIMESTAMP '2026-10-02 06:00') / 86400.0) ELSE 0 END
         + CASE WHEN p.param_id = 'CNC-03_VIB' AND t >= TIMESTAMP '2026-10-14 00:00' THEN 0.9 ELSE 0 END   -- 공구 마모 징후
       )::numeric, 3)
FROM g p;

UPDATE tb_param_val SET val = NULL WHERE random() < 0.003;                                -- [이슈] 측정값 누락
UPDATE tb_param_val SET val = val * 1000 WHERE param_id = 'LKT-02_LEAK_RATE'
   AND coll_dtm BETWEEN TIMESTAMP '2026-10-11 09:00' AND TIMESTAMP '2026-10-11 10:00';      -- [이슈] 단위 오류(cc/min→mm³/min) 스파이크
-- 다이캐스팅기만 LOT 번호를 기록(타 설비는 미기록) — 시간 구간으로 LOT 연결 필요
UPDATE tb_param_val v SET lot_no = i.lot_no
  FROM tb_trk_in i JOIN tb_trk_out o ON o.trk_in_id = i.trk_in_id
 WHERE i.proc_cd = 'P100' AND v.eqp_id = i.eqp_id
   AND v.coll_dtm >= to_timestamp(i.trk_in_dtm,'YYYYMMDDHH24MISS')::timestamp
   AND v.coll_dtm <  to_timestamp(o.trk_out_dtm,'YYYYMMDDHH24MISS')::timestamp;

-- ---------------------------------------------------------------
-- 설비 상태 이력: 가동(착공~완공) + 고장 + 보전 + 대기/비가동 채움
-- ---------------------------------------------------------------
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,lot_no,ctrl_mode,oper_mode)
SELECT i.eqp_id,'1',to_timestamp(i.trk_in_dtm,'YYYYMMDDHH24MISS')::timestamp,
       to_timestamp(o.trk_out_dtm,'YYYYMMDDHH24MISS')::timestamp, i.lot_no,'R','A'
FROM tb_trk_in i JOIN tb_trk_out o ON o.trk_in_id = i.trk_in_id
WHERE o.trk_out_id <> 333;

-- 고장: 설비·일자별 결정적 발생(약 8%), DCM-02 사건 기간 고장 2건
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,err_cd,ctrl_mode,oper_mode,rmk)
SELECT e.eqp_id,'3', g::date + time '05:00' + make_interval(mins => (prand(e.eqp_id||g::date)*60)::int),
       g::date + time '05:00' + make_interval(mins => (prand(e.eqp_id||g::date)*60)::int + 20 + (prand(g::date||e.eqp_id)*70)::int),
       (ARRAY['E01','E02','E04','E05','E06','E07'])[1 + (prand('err'||e.eqp_id||g::date)*6)::int % 6],'L','M','현장 조치'
FROM tm_eqp e CROSS JOIN generate_series(DATE '2026-09-21', DATE '2026-10-20', interval '1 day') g
WHERE e.use_flag <> 'N' AND prand('down'||e.eqp_id||g::date) < 0.08 AND extract(isodow FROM g) <> 7;
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,err_cd,ctrl_mode,oper_mode,rmk) VALUES
 ('DCM-02','3','2026-10-04 04:30','2026-10-04 06:00','E03','L','M','금형온도 상승, 냉각수 점검'),
 ('DCM-02','3','2026-10-05 05:00','2026-10-05 06:10','E03','L','M','냉각채널 막힘 의심'),
 ('CNC-03','3','2026-10-16 10:15','2026-10-16 10:55','E07','L','M','공구 교체');                    -- [이슈] 가동 구간과 겹침
-- 계획보전: 매주 토요일 19:00~21:00
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,ctrl_mode,oper_mode,rmk)
SELECT e.eqp_id,'4', g + time '19:00', g + time '21:00','L','M','주간 PM'
FROM tm_eqp e CROSS JOIN generate_series(DATE '2026-09-26', DATE '2026-10-17', interval '7 days') g
WHERE e.use_flag <> 'N';
-- 빈 구간: 4시간 이하 → 대기(2), 초과 → 비가동 계획(6)
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,ctrl_mode,oper_mode)
SELECT eqp_id, CASE WHEN nx - ed <= interval '4 hours' THEN '2' ELSE '6' END, ed, nx, 'R','A'
FROM (SELECT eqp_id, ed_dtm AS ed, lead(st_dtm) OVER (PARTITION BY eqp_id ORDER BY st_dtm) AS nx FROM tb_eqp_stat) s
WHERE nx > ed + interval '1 minute';
-- 현재 상태(종료일시 없음)
INSERT INTO tb_eqp_stat(eqp_id,stat_cd,st_dtm,ed_dtm,ctrl_mode,oper_mode)
SELECT eqp_id,'2',max(ed_dtm),NULL,'R','A' FROM tb_eqp_stat GROUP BY eqp_id;

-- ---------------------------------------------------------------
-- 알람: 고장 연동 + 금형온도 상한 초과(시간당 1건) + 통신 끊김
-- ---------------------------------------------------------------
INSERT INTO tb_alarm(eqp_id,alm_cd,alm_lvl,alm_msg,occur_dtm,clear_dtm)
SELECT eqp_id, CASE err_cd WHEN 'E01' THEN 'A001' WHEN 'E02' THEN 'A201' WHEN 'E03' THEN 'A101'
                           WHEN 'E04' THEN 'A102' WHEN 'E05' THEN 'A900' WHEN 'E07' THEN 'A202' ELSE 'A001' END,
       'H', coalesce(rmk,'설비 고장'), st_dtm, ed_dtm
FROM tb_eqp_stat WHERE stat_cd = '3';
INSERT INTO tb_alarm(eqp_id,alm_cd,alm_lvl,alm_msg,occur_dtm,clear_dtm)
SELECT 'DCM-02','A101','M','금형온도 ' || max(val) || '℃ (USL 240)', date_trunc('hour',coll_dtm),
       date_trunc('hour',coll_dtm) + interval '40 minutes'
FROM tb_param_val WHERE param_id = 'DCM-02_MOLD_TEMP' AND val > 240
GROUP BY date_trunc('hour',coll_dtm);
INSERT INTO tb_alarm(eqp_id,alm_cd,alm_lvl,alm_msg,occur_dtm,clear_dtm) VALUES
 ('DCM-03','A900','M','PLC 통신 끊김','2026-10-10 02:00','2026-10-10 06:00'),
 ('CNC-03','A202','L','진동 경고 3.6mm/s','2026-10-15 14:20',NULL);                                  -- 미해제 알람

-- ---------------------------------------------------------------
-- 일별 생산실적 집계(완공 기준)
-- ---------------------------------------------------------------
INSERT INTO tb_prod_rslt
SELECT substr(o.trk_out_dtm,1,8), pr.fac_id, e.line_id, o.proc_cd, l.item_cd, l.mo_no,
       sum(o.good_qty), sum(o.ng_qty),
       round(sum(extract(epoch FROM to_timestamp(o.trk_out_dtm,'YYYYMMDDHH24MISS') - to_timestamp(i.trk_in_dtm,'YYYYMMDDHH24MISS')) / 60)::numeric, 1)
FROM tb_trk_out o JOIN tb_trk_in i ON i.trk_in_id = o.trk_in_id
JOIN tb_lot l ON l.lot_no = o.lot_no JOIN tm_proc pr ON pr.proc_cd = o.proc_cd
LEFT JOIN tm_eqp e ON e.eqp_id = o.eqp_id
GROUP BY 1,2,3,4,5,6;

DROP FUNCTION sim_trk(text,text,text,timestamp,numeric,numeric,numeric,text);
DROP FUNCTION sim_qc(text,text,text,numeric,numeric,timestamp,text,text[],text);
DROP FUNCTION prand(text);
ANALYZE;
