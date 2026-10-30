"""Local test of db/migrations/005_admin_panel.sql on a throw-away PostgreSQL (same setup as the other tests).

Checks: a normal user cannot see inactive questions, insert, update or upload images; an admin can; the migration is
safe to run twice; the user-facing behaviour (active questions readable) is unchanged.

Usage: python test_migration_005.py
"""
import sys
import tempfile
import uuid
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
DB_DIR = HERE.parent.parent / "db" / "test"
MIGRATION = HERE.parent.parent / "db" / "migrations" / "005_admin_panel.sql"
failures = []


def check(name, ok):
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        failures.append(name)


def as_user(conn, user_id):
    conn.execute("set role authenticated")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id,))


def attempt(conn, user_id, sql, params=()):
    """Runs one statement as [user_id]; returns (rows affected or None, error name or None)."""
    as_user(conn, user_id)
    try:
        cur = conn.execute(sql, params)
        return (cur.rowcount, None)
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
        conn.execute("insert into subjects (slug, name, sort_order, is_active) values ('kimya','Kimya',1,true), ('bio','Bio',2,false)")
        conn.execute("insert into topics (subject_id, name, sort_order) values (1,'T',1)")
        conn.execute("insert into storage.buckets (id, name) values ('question-images', 'question-images')")
        conn.execute(
            "insert into questions (code, topic_id, type, body, options, correct_answer, difficulty, source, is_active) values "
            "('A1', 1, 'qapali', 'active', '{\"A\":\"a\",\"B\":\"b\"}', 'A', 1, 's', true), "
            "('P1', 1, 'qapali', 'passive', '{\"A\":\"a\",\"B\":\"b\"}', 'A', 1, 's', false)"
        )
        admin, user = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user):
            conn.execute("insert into auth.users (id) values (%s)", (u,))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))

        conn.execute(MIGRATION.read_text(encoding="utf-8"))
        conn.execute(MIGRATION.read_text(encoding="utf-8"))
        check("migration runs twice without error", True)
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        count = lambda who: attempt(conn, who, "select code from questions")[0]
        check("normal user sees only the active question", count(user) == 1)
        check("admin sees active and inactive questions", count(admin) == 2)

        insert = ("insert into questions (code, topic_id, type, body, options, correct_answer, difficulty, source) "
                  "values (%s, 1, 'qapali', 'x', '{\"A\":\"a\",\"B\":\"b\"}', 'A', 2, 'Admin')")
        check("normal user cannot insert a question", attempt(conn, user, insert, ("U1",))[1] is not None)
        check("admin can insert a question", attempt(conn, admin, insert, ("N1",)) == (1, None))

        check("normal user's update changes nothing", attempt(conn, user, "update questions set body='hack' where code='A1'")[0] == 0)
        check("admin can update (also an inactive question)",
              attempt(conn, admin, "update questions set body='ok' where code='P1'")[0] == 1)
        check("normal user cannot delete", attempt(conn, user, "delete from questions where code='A1'")[1] is not None)
        check("admin cannot delete either", attempt(conn, admin, "delete from questions where code='A1'")[1] is not None)

        check("normal user sees only active subjects", attempt(conn, user, "select 1 from subjects")[0] == 1)
        check("admin sees inactive subjects too", attempt(conn, admin, "select 1 from subjects")[0] == 2)
        check("normal user cannot add topics",
              attempt(conn, user, "insert into topics (subject_id, name, sort_order) values (1,'X',2)")[1] is not None)
        check("admin can add topics",
              attempt(conn, admin, "insert into topics (subject_id, name, sort_order) values (1,'X',2)") == (1, None))

        upload = "insert into storage.objects (bucket_id, name) values ('question-images', %s)"
        check("normal user cannot upload an image", attempt(conn, user, upload, ("u.png",))[1] is not None)
        check("admin can upload an image", attempt(conn, admin, upload, ("a.png",)) == (1, None))
        check("admin cannot upload to another bucket",
              attempt(conn, admin, "insert into storage.objects (bucket_id, name) values ('other', 'x.png')")[1] is not None)

        check("is_admin() true for admin, false for user",
              attempt(conn, admin, "select 1 where is_admin()")[0] == 1 and attempt(conn, user, "select 1 where is_admin()")[0] == 0)
        check("normal user cannot add themselves to admins",
              attempt(conn, user, "insert into admins (user_id) values (%s)", (user,))[1] is not None)
        check("admins table shows a user only their own row",
              attempt(conn, admin, "select 1 from admins")[0] == 1 and attempt(conn, user, "select 1 from admins")[0] == 0)

        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
