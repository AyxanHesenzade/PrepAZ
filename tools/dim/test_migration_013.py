"""Local test of db/migrations/013_topic_progress.sql on a throw-away PostgreSQL.

Usage: python test_migration_013.py
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


def attempt(conn, role, user_id, sql):
    conn.execute(f"set role {role}")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id or "",))
    try:
        cur = conn.execute(sql)
        return (cur.fetchall() if cur.description else cur.rowcount, None)
    except psycopg.errors.Error as e:
        return (None, type(e).__name__)
    finally:
        conn.execute("reset role")


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "013_topic_progress.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        user, other = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (user, other):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))
        subject = conn.execute("insert into subjects (slug, name) values ('kimya', 'Kimya') returning id").fetchone()[0]
        topic = conn.execute("insert into topics (subject_id, name) values (%s, 'Duzlar') returning id", (subject,)).fetchone()[0]
        questions = [
            conn.execute(
                "insert into questions (topic_id, body, options, correct_answer, difficulty, is_active) "
                "values (%s, 'x', '{\"A\": \"1\", \"B\": \"2\"}', 'A', 1, %s) returning id",
                (topic, i < 10),
            ).fetchone()[0]
            for i in range(11)
        ]

        def answer(who, index, given, minutes_ago):
            conn.execute(
                "insert into answers (user_id, question_id, given_answer, answered_at) "
                "values (%s, %s, %s, now() - %s * interval '1 minute')",
                (who, questions[index], given, minutes_ago),
            )

        answer(user, 0, "B", 10)  # wrong, then right: counts as right
        answer(user, 0, "A", 5)
        answer(user, 1, "A", 10)  # right, then wrong: counts as wrong
        answer(user, 1, "B", 5)
        answer(user, 2, "A", 5)
        answer(user, 3, "B", 5)
        answer(user, 10, "A", 5)  # inactive question: ignored
        answer(other, 0, "A", 5)

        select = "select total_questions, answered, correct from topic_progress"
        rows, err = attempt(conn, "authenticated", user, select)
        check("measured against all active questions, latest answer wins", err is None and rows == [(10, 4, 2)])
        rows, _ = attempt(conn, "authenticated", other, select)
        check("each user sees only their own row", rows == [(10, 1, 1)])
        _, err = attempt(conn, "anon", None, select)
        check("anon cannot read", err is not None)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
