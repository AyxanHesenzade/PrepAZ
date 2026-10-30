"""Local test of out/import_kt1_s01.sql (image-only questions) on a throw-away PostgreSQL, like the other import tests.

Usage: python test_import_scans.py [path/to/import.sql]
"""
import re
import sys
import tempfile
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
DB_DIR = HERE.parent.parent / "db" / "test"
SQL = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / "out" / "import_kt1_s01.sql"
failures = []


def check(name, ok):
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        failures.append(name)


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        db = psycopg.connect(srv.get_uri(), autocommit=True)
        db.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        db.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        db.execute("insert into subjects (slug, name, sort_order, is_active) values ('kimya','Kimya',1,true)")
        db.execute((HERE.parent.parent / "db" / "migrations" / "003_solution_image.sql").read_text(encoding="utf-8"))
        sql = SQL.read_text(encoding="utf-8")
        prefix = re.search(r"(KT[0-9]+-S[0-9]{2})-Q", sql).group(1)        # e.g. KT1-S02
        first = re.search(r"'(" + prefix + r"-Q[0-9]{3})'", sql).group(1)    # any code of this file
        expected = int(re.search(r"(\d+) image-only questions", sql).group(1))   # the number the generator announces in its header

        db.execute(sql)
        db.execute(sql)  # safe to run again
        n = db.execute("select count(*) from questions where code like '" + prefix + "-Q%'").fetchone()[0]
        check(f"{n} questions loaded once (second run changed nothing)", n == expected and n > 0)
        row = db.execute("select body, image_path, options, correct_answer, type::text, difficulty, is_active, source, source_ref, "
                         "year, groups from questions where code = %s", (first,)).fetchone()
        check(f"{first} has empty text and its own image", row[0] == "" and row[1] == f"{first}.png")
        check("options are just the five letters", row[2] == {k: k for k in "ABCDE"})
        check("answer is a letter, type qapali, active", row[3] in list("ABCDE") and row[4] == "qapali" and row[6] is True)
        check("source DIM with the book and question number", row[7] == "DİM" and row[8].endswith(f"sual {int(first[-3:])}"))
        check("year 2025, no groups", row[9] == 2025 and list(row[10]) == [])
        check("all answers are A-E", db.execute("select count(*) from questions where code like '" + prefix + "-Q%' "
                                                "and correct_answer not in ('A','B','C','D','E')").fetchone()[0] == 0)
        check("every question has its image", db.execute("select count(*) from questions where code like '" + prefix + "-Q%' "
                                                         "and (image_path is null or image_path <> code || '.png')").fetchone()[0] == 0)
        check("one topic used", db.execute("select count(distinct topic_id) from questions where code like '" + prefix + "-Q%'").fetchone()[0] == 1)
        check("sections are not duplicated", db.execute("select count(*) from topics where parent_id is null").fetchone()[0] == 1)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
