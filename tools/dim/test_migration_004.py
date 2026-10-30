"""Local test of db/migrations/004: before it another user's mastery rows are visible, after it they are not.

Usage: python test_migration_004.py   (needs pgserver + psycopg, same as test_import_local.py)
"""
import sys
import uuid
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
DB_DIR = HERE.parent.parent / "db" / "test"
MIGRATION = HERE.parent.parent / "db" / "migrations" / "004_topic_mastery_security_invoker.sql"


def count_as(conn, user_id):
    conn.execute("set role authenticated")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id,))
    n = conn.execute("select count(*) from topic_mastery").fetchone()[0]
    conn.execute("reset role")
    return n


def main():
    import tempfile
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        conn.execute("insert into subjects (slug, name, sort_order, is_active) values ('kimya','Kimya',1,true)")
        sid = conn.execute("select id from subjects").fetchone()[0]
        conn.execute("insert into topics (subject_id, name, sort_order) values (%s,'T',1)", (sid,))
        tid = conn.execute("select id from topics").fetchone()[0]
        a, b = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (a, b):
            conn.execute("insert into auth.users (id) values (%s)", (u,))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))
        conn.execute(
            "insert into questions (code, topic_id, type, body, options, correct_answer, difficulty, source, is_active) "
            "values ('Q1', %s, 'qapali', 'x', '{\"a\":\"A\",\"b\":\"B\"}', 'a', 1, 's', true)", (tid,))
        qid = conn.execute("select id from questions").fetchone()[0]
        for u in (a, b):
            conn.execute("insert into answers (user_id, question_id, given_answer) values (%s,%s,'a')", (u, qid))

        before = count_as(conn, a)
        conn.execute(MIGRATION.read_text(encoding="utf-8"))
        after = count_as(conn, a)
        print(f"before={before} after={after}")
        ok = before == 2 and after == 1
        print("PASS" if ok else "FAIL")
        sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
