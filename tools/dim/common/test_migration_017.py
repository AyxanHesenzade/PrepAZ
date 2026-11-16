"""Local test of db/migrations/017_leaderboard.sql on a throw-away PostgreSQL.

Usage: python test_migration_017.py
"""
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
        conn.execute((ROOT / "db" / "migrations" / "005_admin_panel.sql").read_text(encoding="utf-8"))
        migration = (ROOT / "db" / "migrations" / "017_leaderboard.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        admin, ali, vusal, nigar, ghost = (str(uuid.uuid4()) for _ in range(5))
        for u in (admin, ali, vusal, nigar, ghost):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        kimya = conn.execute("insert into subjects (slug, name) values ('kimya', 'Kimya') returning id").fetchone()[0]
        bio = conn.execute("insert into subjects (slug, name) values ('biologiya', 'Biologiya') returning id").fetchone()[0]
        t_kim = conn.execute("insert into topics (subject_id, name) values (%s, 'A') returning id", (kimya,)).fetchone()[0]
        t_bio = conn.execute("insert into topics (subject_id, name) values (%s, 'B') returning id", (bio,)).fetchone()[0]

        def question(topic, active=True):
            return conn.execute(
                "insert into questions (topic_id, body, options, correct_answer, difficulty, is_active) "
                "values (%s, 'x', '{\"A\": \"1\", \"B\": \"2\"}', 'A', 1, %s) returning id",
                (topic, active),
            ).fetchone()[0]

        kq = [question(t_kim) for _ in range(6)]
        k_inactive = question(t_kim, active=False)
        bq = question(t_bio)

        def answer(who, q, given, days_ago):
            conn.execute(
                "insert into answers (user_id, question_id, given_answer, answered_at) "
                "values (%s, %s, %s, now() - %s * interval '1 day')",
                (who, q, given, days_ago),
            )

        # --- joining -------------------------------------------------------
        join = "insert into leaderboard_players (nickname, first_name, last_name) values (%s, %s, %s)"
        n, err = attempt(conn, "authenticated", ali, join, ("Ali_07", "Əli", "Məmmədov"))
        check("player joins with default user_id", err is None and n == 1)
        _, err = attempt(conn, "authenticated", vusal, join, ("ali_07", "Vüsal", "Quliyev"))
        check("nickname is unique ignoring case", err == "UniqueViolation")
        for bad in ("ab", "a" * 21, "has space", "bad!"):
            _, err = attempt(conn, "authenticated", vusal, join, (bad, "Vüsal", "Quliyev"))
            check("bad nickname rejected: " + bad, err == "CheckViolation")
        _, err = attempt(conn, "authenticated", vusal, join, ("Vüsal", "V", "Quliyev"))
        check("too short first name rejected", err == "CheckViolation")
        n, err = attempt(conn, "authenticated", vusal, join, ("Vüsal", "Vüsal", "Quliyev"))
        check("azerbaijani letters allowed", err is None and n == 1)
        attempt(conn, "authenticated", nigar, join, ("nigar", "Nigar", "Əliyeva"))
        _, err = attempt(
            conn, "authenticated", ali,
            "insert into leaderboard_players (user_id, nickname, first_name, last_name) values (%s, 'fake', 'Fa', 'Ke')",
            (ghost,),
        )
        check("cannot join for someone else", err is not None)

        rows, _ = attempt(conn, "authenticated", ali, "select nickname from leaderboard_players")
        check("player sees only own row", rows == [("Ali_07",)])
        rows, _ = attempt(conn, "authenticated", admin, "select count(*) from leaderboard_players")
        check("admin sees all players", rows == [(3,)])
        _, err = attempt(conn, "anon", None, "select * from leaderboard_players")
        check("anon cannot read players", err is not None)
        n, err = attempt(conn, "authenticated", ali, "update leaderboard_players set nickname = 'Ali_08'")
        check("player renames self", err is None and n == 1)
        n, err = attempt(conn, "authenticated", ali, f"update leaderboard_players set nickname = 'x_x' where user_id = '{vusal}'")
        check("player cannot rename another", err is not None or n == 0)
        n, err = attempt(conn, "authenticated", admin, f"update leaderboard_players set nickname = 'renamed' where user_id = '{nigar}'")
        check("admin can rename an offensive nickname", err is None and n == 1)
        _, err = attempt(conn, "authenticated", ali, "delete from leaderboard_players")
        check("no delete", err is not None)

        # --- scoring -------------------------------------------------------
        # ali: 3 distinct correct this week; repeats and wrong answers add nothing
        answer(ali, kq[0], "A", 0)
        answer(ali, kq[0], "A", 0)
        answer(ali, kq[0], "B", 0)
        answer(ali, kq[1], "B", 0)
        answer(ali, kq[1], "A", 0)
        answer(ali, kq[2], "A", 0)
        answer(ali, k_inactive, "A", 0)  # inactive: ignored
        answer(ali, bq, "A", 0)  # other subject
        # vusal: 4 correct, but 3 of them first solved long ago
        for q in kq[:3]:
            answer(vusal, q, "A", 30)
            answer(vusal, q, "A", 0)  # re-solving this week does not count for the week
        answer(vusal, kq[3], "A", 0)
        # ghost never joined: not on the board
        for q in kq:
            answer(ghost, q, "A", 0)

        board = "select rank, nickname, score, is_me from get_leaderboard(%s::smallint, %s, %s)"
        rows, err = attempt(conn, "authenticated", ali, board, (kimya, "all", 50))
        check("all time: vusal 4, ali 3; ghost hidden", err is None and rows == [
            (1, "Vüsal", 4, False), (2, "Ali_08", 3, True),
        ])
        rows, _ = attempt(conn, "authenticated", ali, board, (kimya, "week", 50))
        check("week: only first correct answers this week", rows == [
            (1, "Ali_08", 3, True), (2, "Vüsal", 1, False),
        ])
        rows, _ = attempt(conn, "authenticated", ali, board, (bio, "all", 50))
        check("subject is separate", rows == [(1, "Ali_08", 1, True)])
        rows, _ = attempt(conn, "authenticated", ali, board, (kimya, "all", 1))
        check("own row added when outside the top", rows == [
            (1, "Vüsal", 4, False), (2, "Ali_08", 3, True),
        ])
        rows, _ = attempt(conn, "authenticated", vusal, board, (kimya, "all", 1))
        check("no duplicate when already in top", rows == [(1, "Vüsal", 4, True)])
        rows, _ = attempt(conn, "authenticated", nigar, board, (kimya, "all", 50))
        check("player without points sees others", [r[1] for r in rows] == ["Vüsal", "Ali_08"])
        _, err = attempt(conn, "anon", None, board, (kimya, "all", 50))
        check("anon cannot call leaderboard", err is not None)
        rows, _ = attempt(conn, "authenticated", ali, "select * from get_leaderboard(%s::smallint)", (kimya,))
        check("first/last name never returned", rows is not None and all(len(r) == 4 for r in rows))

        conn.execute("delete from auth.users where id = %s", (vusal,))
        rows, _ = attempt(conn, "authenticated", ali, board, (kimya, "all", 50))
        check("deleted account leaves the board", rows == [(1, "Ali_08", 3, True)])
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
