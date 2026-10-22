"""IMPIX 가상 원천 확장 데이터 생성기 (ERP 영업·구매·재고·원가 + QMS).

MES 실적(LOT·착공·완공·불량)을 읽어 그와 맞는 ERP·QMS 데이터를 만들고 정적 SQL로 기록한다.
결과 SQL은 infra/docker-compose/impix-src/init/ 에 커밋되어 컨테이너 초기화 때 그대로 적재된다.

  PYTHONPATH=tools/s1profiler python tools/sim/gen_impix_ext.py --host <소켓|호스트> --port <포트> [--user postgres]

결정적: 같은 MES 데이터 → 같은 결과(난수 시드 고정).
"""
from __future__ import annotations

import argparse
import math
import os
import random
from collections import defaultdict, deque
from datetime import date, timedelta

from s1profiler.core import connect

H0, M0, END, FUT = date(2026, 8, 1), date(2026, 9, 21), date(2026, 10, 20), date(2026, 10, 25)
R = random.Random(20261022)
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "infra", "docker-compose", "impix-src", "init")


def ds(d):
    return d.strftime("%Y%m%d")


def days(a, b):
    d = a
    while d <= b:
        yield d
        d += timedelta(days=1)


def work(d):
    return d.isoweekday() != 7


def wadd(d, n):
    while n:
        d += timedelta(days=1)
        n -= work(d)
    return d


def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return repr(round(v, 3)) if isinstance(v, float) else str(v)
    return "'" + str(v).replace("'", "''") + "'"


class SQL:
    def __init__(self):
        self.parts = []

    def ins(self, table, cols, rows, chunk=500):
        rows = list(rows)
        for i in range(0, len(rows), chunk):
            vals = ",\n ".join("(" + ",".join(q(v) for v in r) + ")" for r in rows[i:i + chunk])
            self.parts.append(f"INSERT INTO {table}({','.join(cols)}) VALUES\n {vals};")

    def raw(self, s):
        self.parts.append(s)

    def text(self):
        return "\n".join(self.parts) + "\n"


# ---------------------------------------------------------------------------
# 기준 데이터
# ---------------------------------------------------------------------------
STD_COST = {  # 원/기준단위
    "EWP-A100": 52000, "EWP-B200": 78000, "HSG-A100": 9800, "HSG-B200": 13500, "ALDC12": 3200,
    "IMP-A100": 1800, "IMP-B200": 2400, "MTR-12V": 21000, "MTR-24V": 32000, "PCB-EWP12": 6500,
    "PCB-EWP24": 8800, "SEAL-M18": 2200, "ORG-45": 120, "BLT-M5X16": 60, "CON-3P": 900,
    "BOX-EWP": 1500, "TRAY-EWP": 400, "CLT-W5": 2500, "DRA-01": 3800, "EWP-A090": 49000, "HSG-A090": 9200,
}
STAGE_COST = {"P100": ("HSG", 3500), "P200": ("HSG", 8000), "P300": ("HSG", None),
              "A100": ("EWP", 40000), "A200": ("EWP", 47000), "A300": ("EWP", None)}
VEND_ITEMS = {"V001": ["IMP-A100", "IMP-B200"], "V002": ["MTR-12V", "MTR-24V"],
              "V003": ["PCB-EWP12", "PCB-EWP24", "CON-3P"], "V004": ["SEAL-M18", "ORG-45"],
              "V005": ["ALDC12", "BLT-M5X16"], "V006": ["BOX-EWP", "TRAY-EWP", "CLT-W5", "DRA-01"]}
ITEM_VEND = {i: v for v, its in VEND_ITEMS.items() for i in its}
WH = {"ALDC12": "W100", "CLT-W5": "W100", "DRA-01": "W100", "HSG-A100": "W100", "HSG-B200": "W100", "HSG-A090": "W100",
      "EWP-A100": "W300", "EWP-B200": "W300", "EWP-A090": "W300"}
IQC_ITEMS = {"ALDC12", "IMP-A100", "IMP-B200", "MTR-12V", "MTR-24V", "PCB-EWP12", "PCB-EWP24", "SEAL-M18", "CON-3P"}
# 조립 1EA당 소요(실 사용 BOM: A100 rev002, B200 rev001)
BOM = {"EWP-A100": {"IMP-A100": 1, "MTR-12V": 1, "PCB-EWP12": 1, "SEAL-M18": 1, "ORG-45": 2, "BLT-M5X16": 4,
                    "CON-3P": 1, "BOX-EWP": 0.1, "TRAY-EWP": 0.1},
       "EWP-B200": {"IMP-B200": 1, "MTR-24V": 1, "PCB-EWP24": 1, "SEAL-M18": 1, "ORG-45": 2, "BLT-M5X16": 6,
                    "BOX-EWP": 0.1, "TRAY-EWP": 0.1}}
PRICE = {"C001": 68000, "C002": 98000, "C003": 75000}   # 판매단가(원/EA)
CAST_KG = {"HSG-A100": 0.72, "HSG-B200": 1.02}


def wh(item):
    return WH.get(item, "W200")


# ---------------------------------------------------------------------------
def load_mes(conn):
    rcpt = defaultdict(float)        # (date, item) → 포장 완공 양품
    rcpt_mo = defaultdict(float)     # (date, lot, mo, item)
    asm_in = defaultdict(float)      # (date, item) → 조립 착공 투입
    cast_in = defaultdict(float)     # (date, hsg item) → 주조 투입
    hsg_out = defaultdict(float)     # (date, hsg item) → 세척 완공 양품
    lots = {}
    for lot, item, mo, stat, cur in conn.execute(
            "SELECT lot_no, item_cd, mo_no, lot_stat, cur_qty FROM mes.tb_lot").fetchall():
        lots[lot] = (item, mo, stat, float(cur or 0))
    rows = conn.execute("""SELECT o.lot_no, o.proc_cd, substr(o.trk_out_dtm,1,8), o.good_qty, o.ng_qty, i.in_qty,
                                  substr(i.trk_in_dtm,1,8)
                           FROM mes.tb_trk_out o JOIN mes.tb_trk_in i ON i.trk_in_id = o.trk_in_id""").fetchall()
    for lot, proc, od, good, ng, inq, idt in rows:
        item, mo, _, _ = lots[lot]
        od = date(int(od[:4]), int(od[4:6]), int(od[6:]))
        idt = date(int(idt[:4]), int(idt[4:6]), int(idt[6:]))
        if proc == "A400":
            rcpt[(od, item)] += float(good)
            rcpt_mo[(od, lot, mo, item)] += float(good)
        elif proc == "A100":
            asm_in[(idt, item)] += float(inq)
        elif proc == "P100":
            cast_in[(idt, item)] += float(inq)
        elif proc == "P300":
            hsg_out[(od, item)] += float(good)
    defects = conn.execute("""SELECT q.insp_dtm::date, q.proc_cd, q.lot_no, d.defect_cd, d.defect_qty
                              FROM mes.tb_qc_defect d JOIN mes.tb_qc_insp q ON q.insp_no = d.insp_no""").fetchall()
    other_ng = conn.execute("""SELECT substr(trk_out_dtm,1,8), proc_cd, lot_no, ng_qty FROM mes.tb_trk_out
                               WHERE proc_cd IN ('P100','A100') AND ng_qty > 0""").fetchall()
    return lots, rcpt, rcpt_mo, asm_in, cast_in, hsg_out, defects, other_ng


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="localhost")
    ap.add_argument("--port", default="5433")
    ap.add_argument("--user", default="postgres")
    ap.add_argument("--password", default=os.environ.get("PGPASSWORD", ""))
    a = ap.parse_args()
    mes = connect({"host": a.host, "port": a.port, "dbname": "impix_mes", "user": a.user, "password": a.password})
    lots, rcpt, rcpt_mo, asm_in, cast_in, hsg_out, defects, other_ng = load_mes(mes)

    erp, qms = SQL(), SQL()
    erp.raw("-- 생성: tools/sim/gen_impix_ext.py (수정하지 말고 생성기를 고쳐 다시 생성)\n\\connect impix_erp\nSET search_path = erp;")
    qms.raw("-- 생성: tools/sim/gen_impix_ext.py\n\\connect impix_qms\nSET search_path = qms;")

    # ---------------- 마스터·코드 ----------------
    erp.ins("tb_sd_cust", ["cust_cd", "cust_nm", "biz_reg_no", "cust_grp", "chrg_nm", "chrg_email"], [
        ("C001", "가온모터스(가상)", "2208100001", "OE", "구매1팀", "buyer1@gaon.example"),
        ("C002", "누리EV(가상)", "2208100002", "OE", "부품구매", "parts@nuri.example"),
        ("C003", "한빛오토파츠(가상)", "2208100003", "AM", None, None)])
    erp.ins("tb_mm_vend", ["vend_cd", "vend_nm", "biz_reg_no", "chrg_nm", "chrg_email"], [
        ("V001", "대한정밀(가상)", "3108100001", "영업팀", "sales@daehan.example"),
        ("V002", "세진모터(가상)", "3108100002", "영업팀", "sales@sejin.example"),
        ("V003", "하늘전자(가상)", "3108100003", "품질팀", None),
        ("V004", "우성실링(가상)", "3108100004", None, None),
        ("V005", "동아금속(가상)", "3108100005", "영업팀", "order@donga.example"),
        ("V006", "한결포장(가상)", "3108100006", None, None)])
    erp.ins("tb_mm_wh", ["wh_cd", "wh_nm", "wh_tp", "plant_cd"], [
        ("W100", "1공장 자재·반제품창고", "RM", "1100"), ("W200", "2공장 부품창고", "RM", "1200"),
        ("W300", "제품창고", "FG", "1200"), ("W900", "불량·보류창고", "QH", "1200")])
    erp.ins("tb_cm_code", ["code_grp", "code", "code_nm", "sort_seq", "use_yn"], [
        ("CUST_GRP", "OE", "완성차", 1, "Y"), ("CUST_GRP", "AM", "보수용", 2, "Y"),
        ("WH_TP", "RM", "자재", 1, "Y"), ("WH_TP", "FG", "제품", 2, "Y"), ("WH_TP", "QH", "불량·보류", 3, "Y"),
        ("SO_STAT", "10", "접수", 1, "Y"), ("SO_STAT", "20", "확정", 2, "Y"), ("SO_STAT", "40", "완료", 4, "Y"),
        ("SO_STAT", "90", "취소", 9, "Y"), ("SO_TP", "N", "일반", 1, "Y"), ("SO_TP", "S", "보수용", 2, "Y"),
        ("PO_STAT", "20", "발주", 2, "Y"), ("PO_STAT", "40", "입고완료", 4, "Y")])
    erp.ins("tb_co_std_cost", ["item_cd", "cost_ym", "std_cost", "mat_cost", "lab_cost", "ovh_cost"],
            [(i, ym, c, round(c * .7), round(c * .18), c - round(c * .7) - round(c * .18))
             for i, c in STD_COST.items() for ym in ("202608", "202609", "202610")])
    erp.ins("tb_mm_price", ["item_cd", "vend_cd", "unit_prc", "valid_fr", "valid_to"],
            [(i, v, round(STD_COST[i] * 0.97), "20260101", "20261231") for i, v in ITEM_VEND.items()])

    # ---------------- 수주(고객 요구) ----------------
    so_h, so_d, demand = [], [], []      # demand: (req_date, so_no, seq, cust, item, qty, prio)
    for d in days(date(2026, 7, 22), date(2026, 10, 18)):
        if not work(d):
            continue
        for n, cust, item, qty in ((1, "C001", "EWP-A100", 360), (2, "C002", "EWP-B200", 185)):
            so = f"SO{d:%y%m%d}{n:03d}"
            req = wadd(d, 8)
            if req < H0:
                continue
            stat = "90" if so == "SO260923002" else ("40" if req <= END else "20")
            so_h.append((so, cust, ds(d), "N", stat, "20220081"))
            so_d.append([so, 1, item, qty, "EA", PRICE[cust], ds(req)])
            if stat != "90":
                demand.append([req, so, 1, cust, item, qty, 1])
        if d.isoweekday() == 3:          # 수요일: 보수용 고객 주문
            so = f"SO{d:%y%m%d}003"
            qty = 50 + 10 * R.randint(0, 4)
            req = wadd(d, 4)
            if d < H0:
                continue
            so_h.append((so, "C003", ds(d), "S", "40" if req <= END else "20", "20220081"))
            so_d.append([so, 1, "EWP-A100", qty, "EA", PRICE["C003"], ds(req)])
            demand.append([req, so, 1, "C003", "EWP-A100", qty, 2])

    # ---------------- 생산(제품·하우징) ----------------
    fg_rcpt = defaultdict(float)
    fg_lot = defaultdict(list)          # (date, item) → [(lot, qty)]
    rcpt_rows = []
    pp_plan = []
    for d in days(H0, FUT):
        if not work(d):
            continue
        for line, item, pq in (("AL01", "EWP-A100", 400), ("AL02", "EWP-B200", 200)):
            if not (d == date(2026, 9, 30) and item == "EWP-B200"):
                pp_plan.append((ds(d), line, item, pq))
        pp_plan.append((ds(d), "ML01", "HSG-A100", 400))
        if not (d == date(2026, 9, 29) or d == date(2026, 9, 30)):
            pp_plan.append((ds(d), "ML01", "HSG-B200", 200))
        if d < M0:                     # MES 도입 전 이력: 일 실적만 존재
            for item, base in (("EWP-A100", 382), ("EWP-B200", 192)):
                v = round(base * R.uniform(0.955, 0.99))
                fg_rcpt[(d, item)] += v
                fg_lot[(d, item)].append((f"E{d:%y%m%d}{item[4]}1", v))
                rcpt_rows.append((f"PR{d:%y%m%d}{len(rcpt_rows) % 1000:03d}", ds(d), None, item, v, "W300", "HIST"))
    for (d, lot, mo, item), v in sorted(rcpt_mo.items()):
        fg_rcpt[(d, item)] += v
        fg_lot[(d, item)].append((lot, v))
        rcpt_rows.append((f"PR{d:%y%m%d}{len(rcpt_rows) % 1000:03d}", ds(d), mo, item, v, "W300", "MES"))
    # [EV7] 보류 LOT E261003A1 특채 입고(ERP 수기) — MES는 여전히 보류(H)
    sp_qty = lots["E261003A1"][3]
    fg_rcpt[(date(2026, 10, 8), "EWP-A100")] += sp_qty
    fg_lot[(date(2026, 10, 8), "EWP-A100")].insert(0, ("E261003A1", sp_qty))
    rcpt_rows.append(("PR261008SP1", "20261008", "MO261003001", "EWP-A100", sp_qty, "W300", "MAN"))

    # ---------------- 재고 시뮬레이션 + 출하 ----------------
    stock = defaultdict(float)
    stock.update({("W300", "EWP-A100"): 120, ("W300", "EWP-B200"): 400, ("W300", "EWP-A090"): 150,
                  ("W100", "HSG-A100"): 400, ("W100", "HSG-B200"): 200, ("W100", "HSG-A090"): 300,
                  ("W100", "ALDC12"): 6000, ("W100", "CLT-W5"): 300, ("W100", "DRA-01"): 150})
    weekly = {i: 0 for i in ITEM_VEND}
    for item, need in BOM["EWP-A100"].items():
        weekly[item] += need * 400 * 6
    for item, need in BOM["EWP-B200"].items():
        weekly[item] += need * 200 * 6
    weekly["ALDC12"] = 0.72 * 400 * 6 + 1.02 * 200 * 6
    weekly["CLT-W5"], weekly["DRA-01"] = 48, 24
    safety = {i: math.ceil(w / 6 * 1.5) for i, w in weekly.items()}
    safety["MTR-24V"] = 80
    safety["PCB-EWP24"] = 150
    for i, w in weekly.items():
        stock[(wh(i), i)] = stock.get((wh(i), i), 0) + w / 6 * 3 + safety[i]
    stock[("W200", "PCB-EWP12")] += 300            # 격리 LOT(장기 체화)

    po_h, po_d, gr, gi, stk_day, dlv, iqc = [], [], [], [], [], [], []
    fgq = defaultdict(deque)
    fgq["EWP-A100"].append(["E260731A1", date(2026, 7, 31), 120])
    fgq["EWP-B200"].append(["E260731B1", date(2026, 7, 31), 400])
    backlog = []                                       # [req_date, so, seq, cust, item, remaining, prio]
    pending = sorted(demand)
    gi_seq = 0
    mat_check = []                                     # (date, mo, ok, short_items)
    mat_rows = []

    def add_gi(d, tp, item, qty, mo=None, rmk=None):
        nonlocal gi_seq
        gi_seq += 1
        gi.append((f"GI{d:%y%m%d}{gi_seq % 10000:04d}", ds(d), tp, item, round(qty, 3), wh(item), mo, rmk))

    po_n = 0
    for d in days(H0, END):
        # 1) 월요일 정기 발주·입고(전주 금요일 발주, 월요일 납품)
        if d.isoweekday() == 1:
            for vend, items in VEND_ITEMS.items():
                po_n += 1
                po = f"PO{d:%y%m%d}{po_n % 1000:03d}"
                po_h.append((po, vend, ds(d - timedelta(3)), "40", "20220081"))
                for seq, item in enumerate(items, 1):
                    qty = math.ceil(max(0, weekly[item] + safety[item] - stock[(wh(item), item)]) / 10) * 10
                    if item == "PCB-EWP12":
                        qty = math.ceil(max(0, weekly[item] + safety[item] - (stock[(wh(item), item)] - 300)) / 10) * 10
                    if qty <= 0:
                        continue
                    po_d.append([po, seq, item, qty, round(STD_COST[item] * .97), ds(d), qty])
                    arrivals = [(d, qty, "AM")]
                    if item == "MTR-24V" and d == date(2026, 10, 12):          # 공급사 납기 지연(분할 납품, 오후 잔량)
                        arrivals = [(d, 60, "AM"), (d, qty - 60, "PM")]
                    for k, (ad, aq, ap) in enumerate(arrivals):
                        gno = f"GR{ad:%y%m%d}{len(gr) % 10000:04d}"
                        rej = (item == "PCB-EWP24" and ad == date(2026, 10, 5)) or (item == "IMP-A100" and ad == date(2026, 9, 7))
                        gr.append([gno, po, seq, vend, item, aq, ds(ad), wh(item), f"{vend}-{ad:%y%m%d}{k}",
                                   "Y" if item in IQC_ITEMS else "N", ("20" if rej else "10") if item in IQC_ITEMS else None,
                                   ad, ap])
        # 입고 반영(당일 도착분) — 불합격은 재고 미반영, 2일 뒤 대체 납품
        for g in [g for g in gr if g[11] == d]:
            if g[10] == "20":                           # 불합격 → 익일 오후 대체 납품
                rep = f"GR{d + timedelta(1):%y%m%d}{len(gr) % 10000:04d}"
                gr.append([rep, g[1], g[2], g[3], g[4], g[5], ds(d + timedelta(1)), g[7], g[8] + "R", "Y", "10",
                           d + timedelta(1), "PM"])
                continue
            stock[(g[7], g[4])] += g[5]
        # 2) 자재 충족 점검(제조오더 착수 시점의 전일 마감 재고 기준)
        if d >= M0 and work(d):
            for n, item in ((1, "EWP-A100"), (2, "EWP-B200")):
                mo = f"MO{d:%y%m%d}{n:03d}"
                if mo == "MO260930002":
                    continue
                qty = 400 if n == 1 else 200
                am = defaultdict(float)
                for g in gr:
                    if g[11] == d and g[12] == "AM" and g[10] != "20":
                        am[(g[7], g[4])] += g[5]
                short = []
                for c, need in BOM[item].items():
                    av = prev_close.get((wh(c), c), 0) + am[(wh(c), c)] - (300 if c == "PCB-EWP12" else 0)
                    mat_rows.append((ds(d), mo, c, round(need * qty, 3), round(av, 3), round(max(0, need * qty - av), 3)))
                    if av < need * qty:
                        short.append(c)
                mat_check.append((ds(d), mo, item, "N" if short else "Y", ",".join(short)))
        # 3) 소모(생산 투입)
        if work(d):
            for item in ("EWP-A100", "EWP-B200"):
                base = asm_in.get((d, item)) if d >= M0 else fg_rcpt.get((d, item), 0) * 1.01
                for c, need in BOM[item].items():
                    use = need * (base or 0)
                    if use:
                        stock[(wh(c), c)] -= use
                        add_gi(d, "PRD", c, use)
                hsg = "HSG-A100" if item == "EWP-A100" else "HSG-B200"
                if base:
                    stock[("W100", hsg)] -= base
                    add_gi(d, "PRD", hsg, base)
            for hsg in ("HSG-A100", "HSG-B200"):
                cin = cast_in.get((d, hsg)) if d >= M0 else (400 if hsg == "HSG-A100" else 200)
                if cin:
                    stock[("W100", "ALDC12")] -= CAST_KG[hsg] * cin
                    add_gi(d, "PRD", "ALDC12", CAST_KG[hsg] * cin)
                hout = hsg_out.get((d, hsg)) if d >= M0 else cin * 0.985
                stock[("W100", hsg)] += hout or 0
            for c, per in (("CLT-W5", 8), ("DRA-01", 4)):
                stock[("W100", c)] -= per
                add_gi(d, "PRD", c, per)
            for item in ("EWP-A100", "EWP-B200"):
                stock[("W300", item)] += fg_rcpt.get((d, item), 0)
                fgq[item].extend([lt, d, q_] for lt, q_ in fg_lot.get((d, item), []))
        # 4) 출하: 납기 도래 수주 + 이월 잔량, 우선순위(OE 먼저) → 요청일 순
        while pending and pending[0][0] <= d:
            backlog.append(pending.pop(0))
        backlog.sort(key=lambda b: (b[6], b[0]))
        if work(d):
            for b in backlog:
                avail = stock[("W300", b[4])]
                ship = min(avail, b[5])
                if ship <= 0:
                    continue
                left = ship
                while left > 0.001:                       # 선입선출 LOT 할당
                    if fgq[b[4]]:
                        e = fgq[b[4]][0]
                        take = min(e[2], left)
                        lot = e[0]
                        e[2] -= take
                        if e[2] <= 0.001:
                            fgq[b[4]].popleft()
                    else:
                        take, lot = left, None
                    dlv.append((f"DL{d:%y%m%d}{len(dlv) % 10000:04d}", b[1], b[2], b[3], b[4], take, ds(d), "W300", lot))
                    left -= take
                stock[("W300", b[4])] -= ship
                add_gi(d, "SAL", b[4], ship)
                b[5] -= ship
            backlog = [b for b in backlog if b[5] > 0]
        # 5) 재고 실사 조정(10-01, 9-30 실사 결과)
        if d == date(2026, 10, 1):
            for item, diff in (("ORG-45", -120), ("BLT-M5X16", -300), ("EWP-B200", -4)):
                stock[(wh(item), item)] += diff
                add_gi(d, "ADJ", item, -diff, rmk="9월 실사 차이 조정")
        prev_close = dict(stock)
        if os.environ.get("SIMDBG") and date(2026, 10, 1) <= d <= date(2026, 10, 16):
            print(d, {k[1]: round(v) for k, v in stock.items() if k[1] in ("EWP-A100", "EWP-B200", "MTR-24V", "PCB-EWP24")},
                  [(b[1], b[5]) for b in backlog])
        for (w, i), v in sorted(stock.items()):
            stk_day.append((ds(d), w, i, round(v, 3)))
        if d == date(2026, 9, 30):
            cnt_book = {(w, i): v for (w, i), v in stock.items()}

    # 수주 상세 출하 수량·마감
    shipped = defaultdict(float)
    for r in dlv:
        shipped[(r[1], r[2])] += r[5]
    for r in so_d:
        r.append(shipped[(r[0], r[1])])
        r.append("Y" if shipped[(r[0], r[1])] >= r[3] else "N")
    erp.ins("tb_sd_so_h", ["so_no", "cust_cd", "so_dt", "so_tp", "so_stat", "reg_id"], so_h)
    erp.ins("tb_sd_so_d", ["so_no", "so_seq", "item_cd", "so_qty", "unit", "unit_prc", "req_dlv_dt", "dlv_qty", "cls_yn"], so_d)
    erp.ins("tb_pp_mat_chk", ["chk_dt", "mo_no", "comp_cd", "req_qty", "avail_qty", "short_qty"], mat_rows)
    erp.ins("tb_sd_dlv", ["dlv_no", "so_no", "so_seq", "cust_cd", "item_cd", "dlv_qty", "dlv_dt", "wh_cd", "lot_no"], dlv)
    erp.ins("tb_pp_plan", ["plan_dt", "line_cd", "item_cd", "plan_qty"], pp_plan)
    erp.ins("tb_pp_rcpt", ["rcpt_no", "rcpt_dt", "mo_no", "item_cd", "rcpt_qty", "wh_cd", "src"], rcpt_rows)
    erp.ins("tb_mm_po_h", ["po_no", "vend_cd", "po_dt", "po_stat", "emp_no"], po_h)
    erp.ins("tb_mm_po_d", ["po_no", "po_seq", "item_cd", "po_qty", "unit_prc", "due_dt", "gr_qty"], po_d)
    erp.ins("tb_mm_gr", ["gr_no", "po_no", "po_seq", "vend_cd", "item_cd", "gr_qty", "gr_dt", "wh_cd", "vend_lot",
                         "iqc_yn", "iqc_stat"], [g[:11] for g in gr])
    erp.ins("tb_mm_gi", ["gi_no", "gi_dt", "gi_tp", "item_cd", "gi_qty", "wh_cd", "mo_no", "rmk"], gi)
    erp.ins("tb_mm_stock_day", ["stk_dt", "wh_cd", "item_cd", "stk_qty"], stk_day)
    cnt = []
    for (w, i), v in sorted(cnt_book.items()):
        diff = {"ORG-45": -120, "BLT-M5X16": -300, "EWP-B200": -4}.get(i, 0)
        cnt.append(("CNT2609", "20260930", w, i, round(v, 3), round(v + diff, 3)))
    erp.ins("tb_mm_cnt", ["cnt_no", "cnt_dt", "wh_cd", "item_cd", "book_qty", "cnt_qty"], cnt)
    # 현재고 LOT별(입고일): 최근 입고부터 채우는 FIFO 가정 + 장기 체화 LOT
    lot_rows = []
    for (w, i), v in sorted(stock.items()):
        rem = v
        if i == "PCB-EWP12":
            lot_rows.append((w, i, "V003-250920Q", "20250920", 300))
            rem -= 300
        if i in ("EWP-A090", "HSG-A090"):
            lot_rows.append((w, i, f"OLD-{i}", "20240215", round(rem, 3)))
            continue
        if i in ("EWP-A100", "EWP-B200"):
            for lt, dd, qv in fgq[i]:
                take = min(qv, rem)
                if take > 0.001:
                    lot_rows.append((w, i, lt, ds(dd), round(take, 3)))
                rem -= take
        else:
            for g in sorted((g for g in gr if g[4] == i and g[10] != "20"), key=lambda g: g[6], reverse=True):
                if rem <= 0:
                    break
                take = min(g[5], rem)
                lot_rows.append((w, i, g[8], g[6], round(take, 3)))
                rem -= take
        if rem > 0.001:
            lot_rows.append((w, i, f"INIT-{i}", "20260731", round(rem, 3)))
    erp.ins("tb_mm_stock_lot", ["wh_cd", "item_cd", "lot_no", "rcv_dt", "stk_qty"], lot_rows)

    # 수요예측(FCST)·판매계획(PLAN)
    actual = defaultdict(float)
    for r, h in zip(so_d, so_h):
        if h[4] != "90":
            actual[(h[2][:6], h[1], r[2])] += r[3]
    plan = []
    fc_err = {"C001": (-0.04, 0.035, 0.07, 0.0), "C002": (0.08, 0.08, -0.05, 0.0), "C003": (-0.2, 0.25, 0.3, 0.0)}
    for k, ym in enumerate(("202608", "202609", "202610", "202611")):
        for cust, item in (("C001", "EWP-A100"), ("C002", "EWP-B200"), ("C003", "EWP-A100")):
            base = actual.get((ym, cust, item)) or {"C001": 9700, "C002": 4800, "C003": 300}[cust]
            if ym == "202610":
                base = {"C001": 9990, "C002": 4995, "C003": 320}[cust]   # 10월 전체(예상) 기준
            fc = round(base * (1 + fc_err[cust][k]) / 10) * 10
            pl = round(base * (1 + fc_err[cust][k] / 3) / 10) * 10
            prev = date(int(ym[:4]), int(ym[4:]), 1) - timedelta(days=11)
            plan.append((ym, "FCST", 1, cust, item, fc, f"{prev:%Y-%m-%d} 09:00"))
            plan.append((ym, "PLAN", 1, cust, item, pl, f"{prev + timedelta(days=5):%Y-%m-%d} 09:00"))
    erp.ins("tb_sd_plan", ["plan_ym", "plan_tp", "plan_ver", "cust_cd", "item_cd", "plan_qty", "reg_dt"], plan)
    erp.raw("COMMENT ON TABLE tb_sd_plan IS '수요예측(FCST)·판매계획(PLAN) 월별';")

    # ---------------- QMS ----------------
    qms.ins("qm_code", ["code_grp", "code", "code_nm", "sort_seq", "use_yn"], [
        ("CLAIM_TP", "NC", "고객 부적합", 1, "Y"), ("CLAIM_TP", "LS", "고객 라인 중단", 2, "Y"), ("CLAIM_TP", "FR", "필드 반송", 3, "Y"),
        ("CLM_DEF", "C-LEAK", "누수", 1, "Y"), ("CLM_DEF", "C-NOISE", "소음", 2, "Y"), ("CLM_DEF", "C-CONN", "커넥터 접촉불량", 3, "Y"),
        ("CLM_DEF", "C-LABEL", "라벨 오기", 4, "Y"),
        ("IQC_DEF", "I-DIM", "치수", 1, "Y"), ("IQC_DEF", "I-SOLDER", "납땜 불량", 2, "Y"), ("IQC_DEF", "I-APP", "외관", 3, "Y"),
        ("QCOST", "P", "예방비용", 1, "Y"), ("QCOST", "A", "평가비용", 2, "Y"), ("QCOST", "IF", "내부실패비용", 3, "Y"),
        ("QCOST", "EF", "외부실패비용", 4, "Y")])
    claims = [
        ("CL2609-001", "C001", "EWP-A100", "E260915A1", "NC", "20260923", "20260924", "C-NOISE", 3, "20261001", "20260930", "20261006", "CLOSE", 450000, "A300", "입고검사 소음 3EA(MES 도입 전 LOT)"),
        ("CL2609-002", "C003", "EWP-A100", None, "FR", "20260926", "20260928", "C-NOISE", 2, "20261005", "20261007", "20261012", "CLOSE", 380000, "A300", "보수 장착 후 소음 반송"),
        ("CL2609-003", "C002", "EWP-B200", "E260922B1", "NC", "20260929", "20260929", "C-CONN", 4, "20261006", "20261005", "20261010", "CLOSE", 520000, "A100", "커넥터 접촉불량 — 하늘전자 CON-3P 원인"),
        ("CL2610-001", "C001", "EWP-A100", "E261003A1", "LS", "20261012", "20261012", "C-LEAK", 6, "20261019", "20261016", None, "RESP", 15000000, "A200", "고객 조립라인 40분 중단 — 특채 출하 LOT 누수"),
        ("CL2610-002", "C001", "EWP-A100", "E261003A1", "NC", "20261013", "20261013", "C-LEAK", 9, "20261019", None, None, "OPEN", 1200000, "A200", "선별 결과 누수 9EA"),
        ("CL2610-003", "C003", "EWP-A100", "E261005A2", "FR", "20261014", "20261015", "C-NOISE", 1, "20261022", None, None, "OPEN", 190000, None, "필드 반송 소음"),
        ("CL2610-004", "C002", "EWP-B200", "E261012B1", "NC", "20261016", "20261016", "C-LABEL", 20, "20261023", "20261019", None, "RESP", 0, "A400", "포장 라벨 품번 오기")]
    qms.ins("qm_claim", ["claim_no", "cust_cd", "item_cd", "lot_no", "claim_tp", "occur_dt", "rcv_dt", "defect_cd", "claim_qty",
                         "resp_due_dt", "resp_dt", "close_dt", "status", "claim_amt", "cause_proc", "descr"], claims)
    iqc_rows, ncr = [], []
    for g in gr:
        if g[9] != "Y":
            continue
        smpl = 32 if g[5] < 500 else (50 if g[5] < 3000 else 80)
        ng, judge, dc = 0, "A", None
        if g[10] == "20":
            ng, judge, dc = (5, "R", "I-SOLDER") if g[4] == "PCB-EWP24" else (3, "R", "I-DIM")
        elif g[4] == "CON-3P" and g[6] == "20260921":
            ng, judge, dc = 2, "S", "I-APP"
        elif R.random() < 0.06:
            ng, judge, dc = 1, "A", "I-APP"
        iqc_rows.append((f"IQ{g[0][2:]}", g[0], g[3], g[4], g[8], g[6], g[5], min(smpl, g[5]), ng, judge, dc,
                         "20210072" if g[6] >= "20260921" else "20210071"))
        if judge in ("R", "S"):
            due = (g[11] + timedelta(14))
            ncr.append((f"NCR{g[6][2:6]}{len(ncr) + 1:03d}", g[3], g[4], f"IQ{g[0][2:]}", "IQC", g[6], ng, dc, ds(due),
                        ds(due - timedelta(2)) if g[4] != "PCB-EWP24" else None))
    ncr.append(("NCR2609901", "V003", "CON-3P", None, "LINE", "20260927", 6, "I-APP", "20261011", "20261014"))
    ncr.append(("NCR2609902", "V003", "CON-3P", None, "CUST", "20260929", 4, "I-APP", "20261013", None))
    qms.ins("qm_iqc", ["iqc_no", "gr_no", "vend_cd", "item_cd", "vend_lot", "insp_dt", "rcv_qty", "smpl_qty", "ng_qty", "judge",
                       "defect_cd", "insp_emp"], iqc_rows)
    qms.ins("qm_vend_ncr", ["ncr_no", "vend_cd", "item_cd", "iqc_no", "found_at", "occur_dt", "ng_qty", "defect_cd", "car_due_dt",
                            "car_cls_dt"], ncr)
    # 폐기(MES 불량 연계) — 단계별 단위원가
    scrap = []
    for (dt, proc, lot, dc, qty) in defects:
        dt = date.fromisoformat(str(dt)[:10])
        item = lots[lot][0]
        kind, uc = STAGE_COST.get(proc, ("EWP", None))
        uc = uc or STD_COST[item]
        scrap.append((f"SC{dt:%y%m%d}{len(scrap) % 100000:05d}", ds(dt), "1100" if proc.startswith("P") else "1200",
                      proc, item, lot, dc, float(qty), uc, round(float(qty) * uc)))
    for (dt, proc, lot, qty) in other_ng:
        item = lots[lot][0]
        uc = STAGE_COST[proc][1]
        scrap.append((f"SC{dt[2:]}{len(scrap) % 100000:05d}", dt, "1100" if proc.startswith("P") else "1200", proc, item,
                      lot, "D-SHORT" if proc == "P100" else "D-ASSY", float(qty), uc, round(float(qty) * uc)))
    qms.ins("qm_scrap", ["scrap_no", "scrap_dt", "plant_cd", "proc_cd", "item_cd", "lot_no", "defect_cd", "scrap_qty", "unit_cost",
                         "scrap_amt"], scrap)
    sc_m = defaultdict(float)
    for s in scrap:
        sc_m[s[1][:6]] += s[9]
    cl_m = defaultdict(float)
    for c in claims:
        cl_m[c[5][:6]] += c[13]
    qc = []
    for ym, hist_scrap in (("202608", 9_400_000), ("202609", 6_100_000), ("202610", 0)):
        qc += [(ym, "P", "품질교육", 1_200_000, None), (ym, "P", "FMEA·예방활동", 800_000, None),
               (ym, "A", "수입검사", 4_200_000, None), (ym, "A", "공정·출하검사", 7_800_000, None),
               (ym, "A", "계측기교정", 600_000, None), (ym, "A", "신뢰성시험", 1_500_000, None),
               (ym, "IF", "폐기", round(sc_m.get(ym, 0) + hist_scrap), "qm_scrap"),
               (ym, "IF", "재작업", {"202608": 900_000, "202609": 750_000, "202610": 1_350_000}[ym], None),
               (ym, "EF", "클레임", round(cl_m.get(ym, 0)), "qm_claim"),
               (ym, "EF", "반품운송", {"202608": 150_000, "202609": 220_000, "202610": 310_000}[ym], None)]
    qms.ins("qm_qcost", ["cost_ym", "cost_cls", "cost_itm", "amount", "ref_no"], qc)

    with open(os.path.join(OUT, "45-erp-scm-seed.sql"), "w", encoding="utf-8") as f:
        f.write(erp.text())
    with open(os.path.join(OUT, "70-qms-seed.sql"), "w", encoding="utf-8") as f:
        f.write(qms.text())
    # 자재 충족 점검 결과는 KPI 검증용으로만 출력
    short = [m for m in mat_check if m[3] == "N"]
    print(f"수주 {len(so_d)}, 출하 {len(dlv)}, 발주 {len(po_d)}, 입고 {len(gr)}, 출고 {len(gi)}, 일재고 {len(stk_day)}, "
          f"IQC {len(iqc_rows)}, NCR {len(ncr)}, 폐기 {len(scrap)}, 클레임 {len(claims)}")
    print("자재 미충족 오더:", short)
    neg = sorted({(r[1], r[2]) for r in stk_day if r[3] < -0.001})
    print("음수 재고:", neg[:10])
    first = {}
    for r in dlv:
        first.setdefault((r[1], r[2]), []).append(r[6])
    late = [(r[0], r[6], max(first.get((r[0], r[1]), ['-']))) for r, h in zip(so_d, so_h)
            if h[4] != "90" and r[6] <= ds(END) and (r[-1] == "N" or max(first[(r[0], r[1])]) > r[6])]
    print("납기 지연 수주:", len(late), late)
    print("E261003A1 출하:", [r for r in dlv if r[8] == "E261003A1"])
    print("LOT 미할당 출하:", sum(1 for r in dlv if r[8] is None))


if __name__ == "__main__":
    main()
