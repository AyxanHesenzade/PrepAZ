"""Adds columns that exist in build_xlsx.COLUMNS but not yet in the main Excel, WITHOUT touching anything else.

The main Excel carries the teacher's/owner's decisions (çətinlik, aktiv), so it is never rebuilt. A fresh copy is
built in a temp folder, proven identical on every existing cell (same codes, same content), and only the missing
columns are copied over by code. A timestamped backup of the main Excel is kept.

Usage: python sync_new_columns.py            (run extract_kimya.py first)
"""
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

from openpyxl import load_workbook

from build_xlsx import COLUMNS

HERE = Path(__file__).parent
MAIN = HERE / "out" / "kimya_dim_yoxlama.xlsx"
# columns that come from the PDF, so they must match the fresh build exactly
CONTENT = ("sual mətni", "A", "B", "C", "D", "E", "düzgün cavab", "həll", "tip", "mənbədə yeri", "mövzu", "bölmə")


def read(path):
    ws = load_workbook(path)["suallar"]
    header = [c.value for c in ws[1]]
    return ws, header, {r[0].value: i for i, r in enumerate(ws.iter_rows(min_row=2), start=2)}


def main():
    ws, header, rows = read(MAIN)
    missing = [c for c in COLUMNS if c not in header]
    if not missing:
        print("Əsas Excel-də bütün sütunlar var, əlavə ediləcək bir şey yoxdur.")
        return 0

    fresh_path = Path(tempfile.mkdtemp()) / "fresh.xlsx"
    run = subprocess.run(
        [sys.executable, "-W", "ignore", str(HERE / "build_xlsx.py"), "--force", "--out", str(fresh_path)],
        capture_output=True, text=True, encoding="utf-8",
    )
    if run.returncode != 0:
        print("XƏTA: təzə nüsxə qurulmadı:\n", run.stdout, run.stderr)
        return 1
    fws, fheader, frows = read(fresh_path)
    if set(rows) != set(frows):
        print("XƏTA: kodlar uyğun gəlmir, heç nə dəyişdirilmədi.")
        return 1
    diffs = [
        (code, col)
        for code, r in rows.items() for col in CONTENT
        if col in header and ws.cell(r, header.index(col) + 1).value != fws.cell(frows[code], fheader.index(col) + 1).value
    ]
    if diffs:
        print(f"XƏTA: {len(diffs)} xana təzə nüsxədən fərqlənir (məs. {diffs[:3]}), heç nə dəyişdirilmədi.")
        return 1

    backup = MAIN.with_name(f"{MAIN.stem}.backup-{datetime.now():%Y%m%d-%H%M%S}{MAIN.suffix}")
    shutil.copy(MAIN, backup)
    wb = load_workbook(MAIN)
    sheet = wb["suallar"]
    for name in missing:
        col = sheet.max_column + 1
        sheet.cell(1, col).value = name
        sheet.cell(1, col).font = sheet.cell(1, 1).font.copy()
        for code, r in rows.items():
            sheet.cell(r, col).value = fws.cell(frows[code], fheader.index(name) + 1).value
    # keep the template's column order: later columns of COLUMNS must follow the existing order
    wb.save(MAIN)
    filled = {n: sum(1 for c in rows if wb["suallar"].cell(rows[c], wb["suallar"].max_column).value) for n in missing[-1:]}
    print(f"Əlavə olunan sütunlar: {missing}. Dolu xanalar: {filled}. Ehtiyat nüsxə: {backup.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
