"""Local test of db/migrations/011_legal_acceptances.sql on a throw-away PostgreSQL.

Usage: python test_migration_011.py
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
        migration = (ROOT / "db" / "migrations" / "011_legal_acceptances.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice
        admin, user, other = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user, other):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        add = f"insert into legal_acceptances (user_id, version) values ('{user}', 1) on conflict do nothing"
        n, err = attempt(conn, "authenticated", user, add)
        check("user records own acceptance", err is None and n == 1)
        n, err = attempt(conn, "authenticated", user, add)
        check("repeat is ignored", err is None and n == 0)
        _, err = attempt(conn, "authenticated", user, f"insert into legal_acceptances (user_id, version) values ('{other}', 1)")
        check("user cannot record for another", err is not None)
        _, err = attempt(conn, "anon", None, add)
        check("anon cannot record", err is not None)
        _, err = attempt(conn, "authenticated", user, "insert into legal_acceptances (user_id, version) values (default, 0)")
        check("bad version rejected", err == "CheckViolation")
        _, err = attempt(conn, "authenticated", user, "insert into legal_acceptances (version, accepted_at) values (2, '2000-01-01')")
        check("user cannot forge the time", err is not None)
        rows, _ = attempt(conn, "authenticated", user, "select version from legal_acceptances")
        check("user reads own row", rows == [(1,)])
        rows, _ = attempt(conn, "authenticated", other, "select * from legal_acceptances")
        check("other user sees nothing", rows == [])
        rows, _ = attempt(conn, "authenticated", admin, "select version from legal_acceptances")
        check("admin reads all", rows == [(1,)])
        _, err = attempt(conn, "authenticated", user, "update legal_acceptances set version = 2")
        check("no update", err is not None)
        _, err = attempt(conn, "authenticated", user, "delete from legal_acceptances")
        check("no delete", err is not None)
        conn.execute("delete from auth.users where id = %s", (user,))
        check("removed with the account", conn.execute("select count(*) from legal_acceptances").fetchone() == (0,))
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
