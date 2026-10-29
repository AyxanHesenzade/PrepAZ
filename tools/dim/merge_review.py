"""Copies the teacher's decisions from muellim_1_dest.xlsx back into the main Excel (matched by kod).

Copies: çətinlik, aktiv, müəllim qeydi (appended to qeyd; a rejected row with a note becomes yoxlanmalı).
Validates first: one error means nothing is changed. A timestamped backup of the main Excel is kept.

Usage: python merge_review.py [teacher.xlsx] [--dry-run] [--approve-all]
"""
import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

from openpyxl import load_workbook
from openpyxl.styles import PatternFill

OUT = Path(__file__).parent / "out"
MAIN = OUT / "kimya_dim_yoxlama.xlsx"
YELLOW = PatternFill("solid", fgColor="FFF2CC")
HEADER_ROW = 3  # rows 1-2 hold the instruction


def read_teacher(path):
    ws = load_workbook(path).worksheets[0]  # 'Müəllim 1-ci dəst' or 'Müəllim 2-ci dəst'
    header = [c.value for c in ws[HEADER_ROW]]
    col = {h: i for i, h in enumerate(header)}
    rows = []
    for n, row in enumerate(ws.iter_rows(min_row=HEADER_ROW + 1, values_only=True), start=HEADER_ROW + 1):
        if not row[col["kod"]]:
            continue
        rows.append((n, {
            "kod": str(row[col["kod"]]).strip(),
            "difficulty": "" if row[col["çətinlik (1–5)"]] is None else str(row[col["çətinlik (1–5)"]]).strip(),
            "active": "" if row[col["aktiv"]] is None else str(row[col["aktiv"]]).strip(),
            "note": "" if row[col["müəllim qeydi"]] is None else str(row[col["müəllim qeydi"]]).strip(),
        }))
    return rows


def validate(rows, known_codes):
    errors = []
    for n, r in rows:
        where = f"müəllim faylı sətir {n} ({r['kod']})"
        if r["kod"] not in known_codes:
            errors.append(f"{where}: belə kod əsas Excel-də yoxdur")
        if r["active"] not in ("", "bəli", "xeyr"):
            errors.append(f"{where}: aktiv 'bəli' və ya 'xeyr' olmalıdır: {r['active']!r}")
        if r["difficulty"] and not re.fullmatch(r"[1-5](\.0)?", r["difficulty"]):
            errors.append(f"{where}: çətinlik 1-5 olmalıdır: {r['difficulty']!r}")
        if r["active"] == "bəli" and not r["difficulty"]:
            errors.append(f"{where}: aktiv=bəli, amma çətinlik boşdur")
    return errors


def main(argv):
    dry = "--dry-run" in argv
    paths = [a for a in argv if not a.startswith("--")]
    teacher = Path(paths[0]) if paths else OUT / "muellim_1_dest.xlsx"
    target = Path(paths[1]) if len(paths) > 1 else MAIN

    rows = read_teacher(teacher)
    if "--approve-all" in argv:
        # explicit owner decision: every row that has a çətinlik is approved (aktiv = bəli)
        for _n, r in rows:
            if r["difficulty"]:
                r["active"] = "bəli"
    wb = load_workbook(target)
    ws = wb["suallar"]
    header = [c.value for c in ws[1]]
    col = {h: i + 1 for i, h in enumerate(header)}
    row_of = {ws.cell(r, col["kod"]).value: r for r in range(2, ws.max_row + 1)}

    errors = validate(rows, set(row_of))
    if errors:
        print(f"XƏTA: {len(errors)} problem, heç nə dəyişdirilmədi:")
        for e in errors:
            print("  -", e)
        return 1

    approved = rejected = untouched = 0
    for _n, r in rows:
        # 'xeyr' is the pre-filled default, so it only counts as a decision together with a note
        if not (r["difficulty"] or r["note"] or r["active"] == "bəli"):
            untouched += 1
            continue
        xl = row_of[r["kod"]]
        if r["difficulty"]:
            ws.cell(xl, col["çətinlik"]).value = int(float(r["difficulty"]))
        if r["active"]:
            ws.cell(xl, col["aktiv"]).value = r["active"]
        if r["note"]:
            old = ws.cell(xl, col["qeyd"]).value
            ws.cell(xl, col["qeyd"]).value = (f"{old}; " if old else "") + f"Müəllim: {r['note']}"
            if r["active"] != "bəli":
                ws.cell(xl, col["yoxlanmalı"]).value = "bəli"
                for c in ws[xl]:
                    c.fill = YELLOW
        if r["active"] == "bəli":
            approved += 1
        else:
            rejected += 1

    print(f"Müəllim faylında {len(rows)} sual: təsdiqlənib {approved}, rədd/qeyd {rejected}, toxunulmayıb {untouched}")
    if dry:
        print("(--dry-run: fayl dəyişdirilmədi)")
        return 0
    backup = target.with_name(f"{target.stem}.backup-{datetime.now():%Y%m%d-%H%M%S}{target.suffix}")
    shutil.copy(target, backup)
    wb.save(target)
    print(f"Əsas Excel yeniləndi. Ehtiyat nüsxə: {backup.name}")
    print("Növbəti: python check.py  →  python import_questions.py")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
