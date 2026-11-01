"""Local test of db/migrations/012_delete_account.sql on a throw-away PostgreSQL.

Usage: python test_migration_012.py
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
        migrations = ROOT / "db" / "migrations"
        for name in ("005_admin_panel", "009_reports", "010_exam_goals", "011_legal_acceptances"):
            conn.execute((migrations / f"{name}.sql").read_text(encoding="utf-8"))
        migration = (migrations / "012_delete_account.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        admin, user, other = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user, other):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))
        for u in (user, other):
            conn.execute("insert into sessions (user_id, kind) select %s::uuid, (enum_range(null::session_kind))[1]", (u,))
            conn.execute("insert into user_goals (user_id) values (%s)", (u,))
            conn.execute("insert into legal_acceptances (user_id, version) values (%s, 1)", (u,))
            conn.execute("insert into reports (user_id, kind, message) values (%s, 'app', 'long enough text')", (u,))

        call = "select public.delete_my_account()"
        _, err = attempt(conn, "anon", None, call)
        check("anon cannot call", err is not None)
        _, err = attempt(conn, "authenticated", admin, call)
        check("admin is refused", err is not None)
        check("admin kept", conn.execute("select count(*) from auth.users where id = %s", (admin,)).fetchone() == (1,))
        _, err = attempt(conn, "authenticated", user, f"delete from auth.users where id = '{user}'")
        check("direct delete still forbidden", err is not None)
        _, err = attempt(conn, "authenticated", user, call)
        check("user deletes own account", err is None)
        for table, column in (("auth.users", "id"), ("profiles", "id"), ("sessions", "user_id"), ("user_goals", "user_id"),
                              ("legal_acceptances", "user_id"), ("reports", "user_id")):
            gone = conn.execute(f"select count(*) from {table} where {column} = %s", (user,)).fetchone() == (0,)
            kept = conn.execute(f"select count(*) from {table} where {column} = %s", (other,)).fetchone() == (1,)
            check(f"{table}: own rows gone, other user untouched", gone and kept)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
