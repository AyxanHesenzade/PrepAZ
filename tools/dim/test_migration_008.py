"""Local test of db/migrations/008_app_config.sql on a throw-away PostgreSQL.

Usage: python test_migration_008.py
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
        conn.execute((ROOT / "db" / "migrations" / "005_admin_panel.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "008_app_config.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice
        check("one row with harmless defaults", conn.execute("select count(*), min(min_version) from app_config").fetchone() == (1, "0.0.0"))

        admin, user = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        rows, err = attempt(conn, "anon", None, "select min_version from app_config")
        check("signed-out app can read the config", err is None and rows == [("0.0.0",)])
        n, err = attempt(conn, "authenticated", user, "update app_config set min_version = '9.9.9'")
        check("normal user cannot update", err is not None or n == 0)
        n, err = attempt(conn, "anon", None, "update app_config set min_version = '9.9.9'")
        check("anon cannot update", err is not None or n == 0)
        n, err = attempt(conn, "authenticated", admin, "update app_config set min_version = '0.0.1+2', latest_version = '0.0.2', update_url = 'https://example.com/app.apk'")
        check("admin can update", err is None and n == 1)
        _, err = attempt(conn, "authenticated", admin, "insert into app_config (id) values (2)")
        check("no second row", err is not None)
        for bad in ("update app_config set min_version = 'abc'", "update app_config set latest_version = '1.2'",
                    "update app_config set update_url = 'javascript:alert(1)'"):
            _, err = attempt(conn, "authenticated", admin, bad)
            check("bad value rejected: " + bad[-30:], err == "CheckViolation")
        _, err = attempt(conn, "authenticated", admin, "delete from app_config")
        check("nobody deletes", err is not None)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
