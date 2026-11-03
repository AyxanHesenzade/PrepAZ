"""Runs test/fixtures/check_answer_cases.json through the REAL check_answer trigger of the database
(db/migrations/014_open_question_types.sql on a throw-away PostgreSQL).

The same file is used by test/features/quiz/answer_checker_test.dart. If this test and the Dart test both pass,
the offline result on the phone (AnswerChecker) equals the server's decision.

Usage: python test_check_answer_parity.py
"""
import json
import sys
import tempfile
import uuid
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
ROOT = HERE.parent.parent
DB_DIR = ROOT / "db" / "test"
CASES = ROOT / "test" / "fixtures" / "check_answer_cases.json"
failures = []

OPTIONS = {
    "qapali": '{"A": "1", "B": "2", "C": "3", "D": "4", "E": "5"}',
    "uygunlasdirma": '{"1": "ABCDE", "2": "ABCDE", "3": "ABCDE"}',
}


def main():
    cases = json.loads(CASES.read_text(encoding="utf-8"))["cases"]
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        with conn.transaction():
            conn.execute((ROOT / "db" / "migrations" / "014_open_question_types.sql").read_text(encoding="utf-8"))

        user = str(uuid.uuid4())
        conn.execute("insert into auth.users (id, email) values (%s, %s)", (user, user + "@x.az"))
        conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (user,))
        conn.execute("insert into subjects (slug, name, is_active) values ('kimya', 'Kimya', true)")
        conn.execute("insert into topics (subject_id, name) values (1, 'T')")

        for case in cases:
            kind, right, given = case["type"], case["right"], case["given"]
            question = conn.execute(
                "insert into questions (topic_id, type, body, options, correct_answer, difficulty) "
                "values (1, %s::question_type, '', %s::jsonb, %s, 3) returning id",
                (kind, OPTIONS.get(kind), right),
            ).fetchone()[0]
            got = conn.execute(
                "insert into answers (user_id, question_id, given_answer) values (%s, %s, %s) returning is_correct",
                (user, question, given),
            ).fetchone()[0]
            ok = got == case["correct"]
            print(("PASS " if ok else "FAIL ") + f"{kind:14} right={right!r:10} given={given!r:14} -> server says {got}")
            if not ok:
                failures.append(case)

    print(f"\n{len(cases)} cases, {len(failures)} failures")
    if failures:
        print("The fixture is wrong (the server is the truth): fix the 'correct' value of the failing cases.")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
