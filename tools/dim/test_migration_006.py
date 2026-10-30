"""Local test of db/migrations/006_teachers.sql (+ db/seed/teachers_demo.sql) on a throw-away PostgreSQL.

Usage: python test_migration_006.py
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


def attempt(conn, user_id, sql, params=()):
    conn.execute("set role authenticated")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id,))
    try:
        cur = conn.execute(sql, params)
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
        conn.execute((ROOT / "db" / "migrations" / "005_admin_panel.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "006_teachers.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice
        delete_migration = (ROOT / "db" / "migrations" / "007_teachers_delete.sql").read_text(encoding="utf-8")
        conn.execute(delete_migration)
        conn.execute(delete_migration)
        seed = (ROOT / "db" / "seed" / "teachers_demo.sql").read_text(encoding="utf-8")
        conn.execute(seed)
        conn.execute(seed)
        check("demo seed: 3 rows, second run adds none", conn.execute("select count(*) from teachers").fetchone()[0] == 3)

        admin, user = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))
        conn.execute("update teachers set consent = false where full_name = 'Nümunə Əyani'")
        conn.execute("update teachers set is_active = false where full_name = 'Nümunə Biologiya'")

        rows, _ = attempt(conn, user, "select full_name from teachers order by sort_order")
        check("user sees only active teachers with consent", rows == [("Nümunə Müəllim",)])
        rows, _ = attempt(conn, admin, "select count(*) from teachers")
        check("admin sees all 3", rows == [(3,)])

        ins = "insert into teachers (full_name, subject_label, lesson_mode, phone) values ('X','Fizika müəllimi','online','+994501234567')"
        _, err = attempt(conn, user, ins)
        check("user cannot insert", err is not None)
        n, err = attempt(conn, admin, ins)
        check("admin can insert", err is None and n == 1)
        n, err = attempt(conn, user, "update teachers set about = 'hack'")
        check("user cannot update (0 rows)", err is not None or n == 0)
        n, err = attempt(conn, admin, "update teachers set is_active = false where full_name = 'X'")
        check("admin can update", err is None and n == 1)
        n, err = attempt(conn, user, "delete from teachers where full_name = 'X'")
        check("user cannot delete", err is not None or n == 0)
        n, err = attempt(conn, admin, "delete from teachers where full_name = 'X'")
        check("admin can delete", err is None and n == 1)

        for bad in ("insert into teachers (full_name, subject_label, lesson_mode, phone) values ('', 'a', 'online', '+994501234567')",
                    "insert into teachers (full_name, subject_label, lesson_mode, phone) values ('a', 'a', 'weird', '+994501234567')",
                    "insert into teachers (full_name, subject_label, lesson_mode, phone) values ('a', 'a', 'online', 'abc')"):
            _, err = attempt(conn, admin, bad)
            check("bad row rejected: " + bad[-40:], err == "CheckViolation")

        conn.execute("update teachers set updated_at = '2000-01-01' where full_name = 'Nümunə Müəllim'")
        conn.execute("update teachers set about = 'y' where full_name = 'Nümunə Müəllim'")
        check("updated_at is touched on update", conn.execute("select updated_at > '2001-01-01' from teachers where full_name = 'Nümunə Müəllim'").fetchone()[0])

        conn.execute("insert into storage.buckets (id, name) values ('teacher-photos', 'teacher-photos') on conflict do nothing")
        _, err = attempt(conn, user, "insert into storage.objects (bucket_id, name) values ('teacher-photos', 'a.png')")
        check("user cannot upload a photo", err is not None)
        _, err = attempt(conn, admin, "insert into storage.objects (bucket_id, name) values ('teacher-photos', 'a.png')")
        check("admin can upload a photo", err is None)
        _, err = attempt(conn, user, "delete from storage.objects where bucket_id = 'teacher-photos'")
        check("user cannot delete a photo", conn.execute("select count(*) from storage.objects where bucket_id = 'teacher-photos'").fetchone()[0] == 1)
        n, err = attempt(conn, admin, "delete from storage.objects where bucket_id = 'teacher-photos'")
        check("admin can delete a photo", err is None and n == 1)
        check("bucket is public", conn.execute("select public from storage.buckets where id = 'teacher-photos'").fetchone()[0] is True)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
