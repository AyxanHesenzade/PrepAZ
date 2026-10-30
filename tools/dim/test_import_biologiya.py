"""Local end-to-end test of the biology import on a throw-away PostgreSQL (same setup as test_import_local.py).

Approves some rows in a COPY of the biology Excel, generates the SQL, runs it twice and checks topics,
questions, and the fact that chemistry data in the same database is untouched.
Never touches Supabase or out/biologiya_dim_yoxlama.xlsx.

Usage: python test_import_biologiya.py
"""
import shutil
import sys
import tempfile
from pathlib import Path

import pgserver
from openpyxl import load_workbook

import import_questions as imp
from subjects import SUBJECTS
from test_import_local import approve, check, failures, make_db, reset_decisions

CFG = SUBJECTS["biologiya"]


def main():
    ws = load_workbook(CFG["excel"])["suallar"]
    header = [c.value for c in ws[1]]
    rows = [dict(zip(header, r)) for r in ws.iter_rows(min_row=2, values_only=True)]
    closed = [r for r in rows if r["tip"] == "qapali" and not r["yoxlanmalı"]][:6]
    if len(closed) < 6:
        closed = [r for r in rows if r["tip"] == "qapali" and r["düzgün cavab"]][:6]
    codes = [r["kod"] for r in closed]
    sections = {r["bölmə"] for r in closed}

    work = Path(tempfile.mkdtemp())
    excel, sql_path = work / "bio.xlsx", work / "import.sql"
    shutil.copy(CFG["excel"], excel)
    reset_decisions(excel)
    approve(excel, {c: (3, "bəli") for c in codes})

    check("import script succeeds", imp.main(["--subject", "biologiya", "--file", str(excel), "--out", str(sql_path)]) == 0)
    sql = sql_path.read_text(encoding="utf-8")
    check("SQL targets biologiya only", "slug = 'biologiya'" in sql and "slug = 'kimya'" not in sql)

    srv = pgserver.get_server(Path(tempfile.mkdtemp()) / "pg")
    db = make_db(srv, "bio_test")
    db.execute("insert into subjects (slug, name, sort_order, is_active) values ('biologiya','Biologiya',5,true)")
    db.execute((Path(__file__).parent.parent.parent / "db" / "migrations" / "003_solution_image.sql").read_text(encoding="utf-8"))
    db.execute(sql)
    db.execute(sql)  # safe to run again
    n = db.execute("select count(*) from questions where code like 'BIO-%'").fetchone()[0]
    check("approved questions loaded once", n == len(codes), f"{n} vs {len(codes)}")
    check("all in the biology subject", db.execute(
        "select count(distinct t.subject_id) from questions q join topics t on t.id = q.topic_id"
    ).fetchone()[0] == 1)
    secs = {r[0] for r in db.execute("select name from topics where parent_id is null and subject_id = "
                                     "(select id from subjects where slug = 'biologiya')").fetchall()}
    check("sections match the Excel", secs == sections, f"{secs} vs {sections}")
    check("source is DİM", db.execute("select count(*) from questions where source <> 'DİM'").fetchone()[0] == 0)

    bad = work / "bad.xlsx"
    shutil.copy(excel, bad)
    wb = load_workbook(bad)
    wsb = wb["suallar"]
    wsb.cell(2, 1).value = "KIM-0001"
    wsb.cell(2, header.index("aktiv") + 1).value = "bəli"
    wsb.cell(2, header.index("çətinlik") + 1).value = 3
    wb.save(bad)
    check("a KIM- code in the biology file is rejected", imp.main(["--subject", "biologiya", "--file", str(bad), "--out", str(work / "x.sql")]) == 1)

    print(f"\n{len(failures)} failures")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
