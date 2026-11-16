"""Local test of db/migrations/018_my_stats.sql on a throw-away PostgreSQL.

Usage: python test_migration_018.py
"""
import json
import sys
import tempfile
import uuid
from pathlib import Path

import pgserver
import psycopg

HERE = Path(__file__).parent
ROOT = HERE.parent.parent.parent
DB_DIR = ROOT / "db" / "test"
failures = []


def check(name, ok):
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        failures.append(name)


def attempt(conn, role, user_id, sql, params=None):
    conn.execute(f"set role {role}")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id or "",))
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
        migration = (ROOT / "db" / "migrations" / "018_my_stats.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        ali, vusal = (str(uuid.uuid4()) for _ in range(2))
        for u in (ali, vusal):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))

        kimya = conn.execute("insert into subjects (slug, name) values ('kimya', 'Kimya') returning id").fetchone()[0]
        bio = conn.execute("insert into subjects (slug, name) values ('biologiya', 'Biologiya') returning id").fetchone()[0]
        t1 = conn.execute("insert into topics (subject_id, name) values (%s, 'A') returning id", (kimya,)).fetchone()[0]
        t2 = conn.execute("insert into topics (subject_id, name) values (%s, 'B') returning id", (kimya,)).fetchone()[0]
        t_bio = conn.execute("insert into topics (subject_id, name) values (%s, 'C') returning id", (bio,)).fetchone()[0]

        def question(topic, active=True):
            return conn.execute(
                "insert into questions (topic_id, body, options, correct_answer, difficulty, is_active) "
                "values (%s, 'x', '{\"A\": \"1\", \"B\": \"2\"}', 'A', 1, %s) returning id",
                (topic, active),
            ).fetchone()[0]

        kq = [question(t1) for _ in range(4)] + [question(t2) for _ in range(2)]
        k_inactive = question(t2, active=False)
        bq = question(t_bio)

        def answer(who, q, given, days_ago):
            conn.execute(
                "insert into answers (user_id, question_id, given_answer, answered_at) "
                "values (%s, %s, %s, now() - %s * interval '1 day')",
                (who, q, given, days_ago),
            )

        # ali: today 3 answers (2 right), yesterday 1 wrong, 2 days ago 1 right -> 3-day run;
        # 10 and 11 days ago another 2-day run; plus noise that must not count
        answer(ali, kq[0], "A", 0)
        answer(ali, kq[1], "A", 0)
        answer(ali, kq[2], "B", 0)
        answer(ali, kq[2], "B", 1)
        answer(ali, kq[3], "A", 2)
        answer(ali, kq[0], "A", 10)
        answer(ali, kq[4], "B", 11)
        answer(ali, kq[4], "A", 40)  # latest answer to kq[4] is the wrong one (11 days ago)
        answer(ali, k_inactive, "A", 0)  # inactive: counts as an answer, not as a solved question
        answer(ali, bq, "A", 5)  # other subject: only in the streak
        answer(vusal, kq[5], "A", 0)  # someone else

        stats = "select get_my_stats(%s::smallint, %s)"
        rows, err = attempt(conn, "authenticated", ali, stats, (kimya, 14))
        check("ali can read own stats", err is None and rows and rows[0][0] is not None)
        s = rows[0][0] if rows else {}
        if isinstance(s, str):
            s = json.loads(s)
        check("answered counts every kimya answer", s.get("answered") == 9)
        check("correct counts right answers", s.get("correct") == 6)
        check("tried = distinct active questions", s.get("questions_tried") == 5)
        check("solved uses the latest answer", s.get("questions_solved") == 3)
        check("bank: 6 active questions in 2 topics", (s.get("questions_total"), s.get("topics_total")) == (6, 2))
        check("best streak over all subjects is 3 days", s.get("best_streak") == 3)
        days = s.get("days", [])
        check("14 days, oldest first", len(days) == 14 and days[0]["day"] < days[-1]["day"])
        check("today: 4 answers, 3 right", (days[-1]["answered"], days[-1]["correct"]) == (4, 3))
        check("yesterday: 1 answer, 0 right", (days[-2]["answered"], days[-2]["correct"]) == (1, 0))
        check("days without answers are zero", days[-4]["answered"] == 0)
        check("other users are not counted", sum(d["answered"] for d in days) == 8)

        rows, _ = attempt(conn, "authenticated", ali, stats, (kimya, 500))
        s = rows[0][0]
        check("days are capped at 31", len((json.loads(s) if isinstance(s, str) else s)["days"]) == 31)

        rows, _ = attempt(conn, "authenticated", vusal, stats, (bio, 7))
        s = rows[0][0]
        s = json.loads(s) if isinstance(s, str) else s
        check("empty subject gives zeros", (s["answered"], s["questions_solved"], len(s["days"])) == (0, 0, 7))

        _, err = attempt(conn, "anon", None, stats, (kimya, 14))
        check("anon cannot call", err is not None)

    if failures:
        print(f"\n{len(failures)} FAILED")
        sys.exit(1)
    print("\nALL PASSED")


if __name__ == "__main__":
    main()
