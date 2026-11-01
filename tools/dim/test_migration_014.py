"""Local test of db/migrations/014_open_question_types.sql on a throw-away PostgreSQL.

Usage: python test_migration_014.py
"""
import sys
import tempfile
import uuid
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
ROOT = HERE.parent.parent
DB_DIR = ROOT / "db" / "test"
failures = []


def check(name, ok):
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        failures.append(name)


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "014_open_question_types.sql").read_text(encoding="utf-8")
        # SQL Editor sends the whole file as one transaction
        with conn.transaction():
            conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        user = str(uuid.uuid4())
        conn.execute("insert into auth.users (id, email) values (%s, %s)", (user, user + "@x.az"))
        conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (user,))
        conn.execute("insert into subjects (slug, name, is_active) values ('kimya', 'Kimya', true)")
        conn.execute("insert into topics (subject_id, name) values (1, 'T')")

        def question(kind, right, options=None):
            return conn.execute(
                "insert into questions (topic_id, type, body, options, correct_answer, difficulty) "
                "values (1, %s::question_type, '', %s::jsonb, %s, 3) returning id",
                (kind, options, right),
            ).fetchone()[0]

        def correct(q, given):
            return conn.execute(
                "insert into answers (user_id, question_id, given_answer) values (%s, %s, %s) returning is_correct",
                (user, q, given),
            ).fetchone()[0]

        rows = '{"1": "ABCDE", "2": "ABCDE", "3": "ABCDE"}'
        multi = question("coxlu_secim", "1,3,5")
        match = question("uygunlasdirma", "E;A;BC", rows)
        number = question("aciq_eded", "12,5")
        closed = question("qapali", "B", '{"A": "A", "B": "B"}')

        check("multi: exact digits", correct(multi, "135"))
        check("multi: any order", correct(multi, "531"))
        check("multi: repeated digit", correct(multi, "1135"))
        check("multi: missing digit is wrong", not correct(multi, "13"))
        check("multi: extra digit is wrong", not correct(multi, "1235"))
        check("multi: empty is wrong", not correct(multi, ""))
        check("multi: null is wrong", not correct(multi, None))

        check("matching: exact", correct(match, "E;A;BC"))
        check("matching: letters in any order, lower case", correct(match, "e;a;cb"))
        check("matching: rows swapped is wrong", not correct(match, "A;E;BC"))
        check("matching: missing letter is wrong", not correct(match, "E;A;B"))
        check("matching: blank row is wrong", not correct(match, "E;;BC"))
        check("matching: empty is wrong", not correct(match, ""))
        check("matching: null is wrong", not correct(match, None))

        check("numeric: comma", correct(number, "12,5"))
        check("numeric: dot", correct(number, "12.5"))
        check("numeric: 12.50", correct(number, "12.50"))
        check("numeric: other number is wrong", not correct(number, "12"))
        check("numeric: text is wrong, no error", not correct(number, "abc"))

        check("closed still works", correct(closed, "B"))
        check("closed wrong", not correct(closed, "A"))
        conn.close()
        srv.cleanup()
    if failures:
        sys.exit(f"{len(failures)} failed")
    print("OK")


if __name__ == "__main__":
    main()
