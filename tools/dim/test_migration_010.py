"""Local test of db/migrations/010_exam_goals.sql on a throw-away PostgreSQL.

Usage: python test_migration_010.py
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
        migration = (ROOT / "db" / "migrations" / "010_exam_goals.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice
        check("two periods seeded", conn.execute("select count(*) from exam_periods").fetchone() == (2,))
        admin, user, other = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user, other):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        rows, err = attempt(conn, "authenticated", user, "select code from exam_periods order by sort_order")
        check("user reads periods", err is None and rows == [("winter",), ("summer",)])
        _, err = attempt(conn, "anon", None, "select * from exam_periods")
        check("anon cannot read periods", err is not None)
        n, err = attempt(conn, "authenticated", user, "update exam_periods set exam_date = date '2030-01-01'")
        check("user cannot change periods", err is not None or n == 0)
        _, err = attempt(conn, "authenticated", user, "insert into exam_periods (code, name, exam_date) values ('x1','Xx', date '2030-01-01')")
        check("user cannot add period", err is not None)
        n, err = attempt(conn, "authenticated", admin, "update exam_periods set exam_date = date '2027-02-20' where code = 'winter'")
        check("admin changes a date", err is None and n == 1)
        attempt(conn, "authenticated", admin, "update exam_periods set is_active = false where code = 'summer'")
        rows, _ = attempt(conn, "authenticated", user, "select code from exam_periods")
        check("inactive period hidden from user", rows == [("winter",)])
        _, err = attempt(conn, "authenticated", admin, "delete from exam_periods")
        check("nobody deletes periods", err is not None)

        n, err = attempt(conn, "authenticated", user, "insert into user_goals (user_id, exam_period_id, daily_goal) values (auth.uid(), 1, 30)")
        check("user adds own goal", err is None and n == 1)
        _, err = attempt(conn, "authenticated", user, f"insert into user_goals (user_id) values ('{other}')")
        check("user cannot add goal for another", err is not None)
        rows, _ = attempt(conn, "authenticated", other, "select * from user_goals")
        check("other user sees nothing", rows == [])
        n, err = attempt(conn, "authenticated", user, "update user_goals set daily_goal = 50, custom_exam_date = date '2027-03-01'")
        check("user updates own goal", err is None and n == 1)
        n, err = attempt(conn, "authenticated", other, "update user_goals set daily_goal = 99")
        check("other cannot update it", err is not None or n == 0)
        for bad in ("update user_goals set daily_goal = 1", "update user_goals set daily_goal = 500"):
            _, err = attempt(conn, "authenticated", user, bad)
            check("bad goal rejected: " + bad[-12:], err == "CheckViolation")
        _, err = attempt(conn, "authenticated", user, "delete from user_goals")
        check("no delete on goals", err is not None)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
