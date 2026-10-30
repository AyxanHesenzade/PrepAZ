"""Local test of db/migrations/009_reports.sql on a throw-away PostgreSQL.

Usage: python test_migration_009.py
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
        return (None, type(e).__name__ + ": " + str(e).splitlines()[0])
    finally:
        conn.execute("reset role")


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        conn.execute((ROOT / "db" / "migrations" / "005_admin_panel.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "009_reports.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        conn.execute("insert into subjects (slug, name, sort_order, is_active) values ('kimya','Kimya',1,true)")
        conn.execute("insert into topics (subject_id, name, sort_order) values (1,'T',1)")
        qid = conn.execute(
            "insert into questions (code, topic_id, type, body, options, correct_answer, difficulty, source, is_active) "
            "values ('KIM-1', 1, 'qapali', 'b', '{\"A\":\"a\",\"B\":\"b\"}', 'A', 1, 's', true) returning id"
        ).fetchone()[0]
        admin, user, other = (str(uuid.uuid4()) for _ in range(3))
        for u in (admin, user, other):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        ins_q = "insert into reports (kind, question_id, question_code, message, app_version) values ('question', %s, 'KIM-1', 'Cavab səhvdir, düzü B-dir', '0.0.1+2')"
        n, err = attempt(conn, user, ins_q, (qid,))
        check("user adds a question report (user_id filled by the database)", err is None and n == 1)
        check("report belongs to the user", conn.execute("select user_id::text from reports").fetchone()[0] == user)
        n, err = attempt(conn, user, "insert into reports (kind, message) values ('app', 'Tətbiq açılışda donur')")
        check("user adds an app report", err is None and n == 1)

        _, err = attempt(conn, user, "insert into reports (kind, message) values ('app', 'qısa')")
        check("short description rejected", err is not None and "CheckViolation" in err)
        _, err = attempt(conn, user, "insert into reports (kind, message) values ('app', '          ')")
        check("blank description rejected", err is not None)
        _, err = attempt(conn, user, "insert into reports (kind, message) values ('app', %s)", ("x" * 1001,))
        check("too long description rejected", err is not None)
        _, err = attempt(conn, user, "insert into reports (kind, message) values ('question', 'Sualda xəta var amma kod yoxdur')")
        check("question report needs a code", err is not None)
        _, err = attempt(conn, user, "insert into reports (kind, question_code, message) values ('app', 'KIM-1', 'Tətbiq xətası amma kod var')")
        check("app report must not carry a code", err is not None)
        _, err = attempt(conn, user, "insert into reports (user_id, kind, message) values (%s, 'app', 'Başqası adından yazıram')", (other,))
        check("cannot report as somebody else", err is not None)
        _, err = attempt(conn, user, "insert into reports (kind, message, status) values ('app', 'Özümü həll edilmiş yazıram', 'done')")
        check("user cannot set the status", err is not None)

        rows, _ = attempt(conn, user, "select * from reports")
        check("user cannot read reports (not even his own)", rows == [])
        n, err = attempt(conn, user, "update reports set status = 'done'")
        check("user cannot update", err is not None or n == 0)
        n, err = attempt(conn, user, "delete from reports")
        check("user cannot delete", err is not None or n == 0)

        rows, _ = attempt(conn, admin, "select count(*) from reports")
        check("admin reads all", rows == [(2,)])
        n, err = attempt(conn, admin, "update reports set status = 'seen', admin_note = 'baxdım'")
        check("admin updates status and note", err is None and n == 2)
        n, err = attempt(conn, admin, "delete from reports where kind = 'app'")
        check("admin deletes", err is None and n == 1)

        for i in range(9):
            attempt(conn, other, "insert into reports (kind, message) values ('app', %s)", (f"Test bildirişi nömrə {i}",))
        _, err = attempt(conn, other, "insert into reports (kind, message) values ('app', 'Onuncudan sonrakı bildiriş')")
        check("10th report in an hour is fine", err is None)
        _, err = attempt(conn, other, "insert into reports (kind, message) values ('app', 'On birinci bildiriş limit aşır')")
        check("11th report in an hour is blocked", err is not None and "too_many_reports" in err)

        conn.execute("delete from questions where id = %s", (qid,))
        check("deleting the question keeps the report and its code",
              conn.execute("select question_code, question_id from reports where kind = 'question'").fetchone() == ("KIM-1", None))
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
