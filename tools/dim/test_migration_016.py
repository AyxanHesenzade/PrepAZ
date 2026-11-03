"""Local test of db/migrations/016_download_catalog.sql on a throw-away PostgreSQL.

Usage: python test_migration_016.py
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
        conn.execute("alter table questions add column if not exists solution_image_path text")
        conn.execute("alter table storage.objects add column if not exists metadata jsonb")
        migration = (ROOT / "db" / "migrations" / "016_download_catalog.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        user = str(uuid.uuid4())
        conn.execute("insert into auth.users (id, email) values (%s, %s)", (user, user + "@x.az"))
        kimya = conn.execute("insert into subjects (slug, name) values ('kimya', 'Kimya') returning id").fetchone()[0]
        bio = conn.execute("insert into subjects (slug, name) values ('biologiya', 'Biologiya') returning id").fetchone()[0]
        section = conn.execute(
            "insert into topics (subject_id, name, sort_order) values (%s, 'Umumi kimya', 10) returning id", (kimya,)).fetchone()[0]
        t1 = conn.execute(
            "insert into topics (subject_id, parent_id, name, sort_order) values (%s, %s, 'Esas anlayislar', 1) returning id",
            (kimya, section)).fetchone()[0]
        t_empty = conn.execute(
            "insert into topics (subject_id, parent_id, name, sort_order) values (%s, %s, 'Bos movzu', 2) returning id",
            (kimya, section)).fetchone()[0]
        t_flat = conn.execute("insert into topics (subject_id, name, sort_order) values (%s, 'Bolmesiz', 5) returning id", (kimya,)).fetchone()[0]
        t_bio = conn.execute("insert into topics (subject_id, name) values (%s, 'Huceyre') returning id", (bio,)).fetchone()[0]

        conn.execute("insert into storage.buckets (id, name) values ('question-images', 'question-images') on conflict do nothing")
        conn.execute("insert into storage.buckets (id, name) values ('other', 'other')")
        for name, size in (("A.webp", 1000), ("A_izah.webp", 500), ("B.webp", 2000), ("C.webp", 7000)):
            conn.execute("insert into storage.objects (bucket_id, name, metadata) values ('question-images', %s, %s::jsonb)",
                         (name, f'{{"size": {size}}}'))
        conn.execute("insert into storage.objects (bucket_id, name, metadata) values ('other', 'A.webp', '{\"size\": 99999}')")

        def add(code, topic, image=None, solution=None, active=True):
            return conn.execute(
                "insert into questions (code, topic_id, body, options, correct_answer, difficulty, image_path, solution_image_path, is_active) "
                "values (%s, %s, 'x', '{\"A\": \"1\", \"B\": \"2\"}', 'A', 1, %s, %s, %s) returning id",
                (code, topic, image, solution, active)).fetchone()[0]

        q1 = add("Q1", t1, "A.webp", "A_izah.webp")
        q2 = add("Q2", t1, "A.webp")          # same image as Q1: counted once
        q3 = add("Q3", t1, "B.webp")
        add("Q4", t1)                          # no image
        add("Q5", t1, "C.webp", None, active=False)  # inactive, its own image: not counted
        add("Qe", t_empty, None, None, active=False)         # topic with only inactive questions
        add("Qf", t_flat)
        add("Qb", t_bio)

        def catalog(subject, role="authenticated"):
            return attempt(conn, role, user, "select * from get_download_catalog(%s::smallint)", (subject,))

        rows, err = catalog(kimya)
        check("authenticated can call it", err is None and rows is not None)
        by_topic = {r[3]: r for r in rows}
        check("topic without active questions is omitted", t_empty not in by_topic)
        check("other subject is not listed", t_bio not in by_topic)
        check("section topics come first, flat topics (no section) before them",
              [r[3] for r in rows] == [t_flat, t1])
        r1 = by_topic[t1]
        check("section name and topic name", (r1[1], r1[4]) == ("Umumi kimya", "Esas anlayislar"))
        check("flat topic has no section", by_topic[t_flat][0] is None and by_topic[t_flat][1] is None)
        check("counts only active questions", r1[6] == 4)
        check("images are counted once each and an inactive question's own image (C.webp) is excluded",
              r1[8] == 3)  # A.webp, A_izah.webp, B.webp
        check("bytes come from the question-images bucket only", r1[9] == 3500)  # 1000 + 500 + 2000, C.webp (7000) not included
        check("version is a positive number", r1[7] > 0)

        v0 = r1[7]
        rows, _ = catalog(kimya)
        check("version is stable when nothing changed", {r[3]: r for r in rows}[t1][7] == v0)

        conn.execute("select pg_sleep(0.01)")
        conn.execute("update questions set body = 'changed' where id = %s", (q1,))
        v1 = {r[3]: r for r in catalog(kimya)[0]}[t1][7]
        check("editing a question changes the version", v1 != v0)

        conn.execute("select pg_sleep(0.01)")
        conn.execute("update questions set is_active = false where id = %s", (q2,))  # NOT the newest-edited row
        v2 = {r[3]: r for r in catalog(kimya)[0]}[t1][7]
        check("deactivating any question changes the version (students cannot see inactive rows)", v2 != v1)
        check("and the active count drops", {r[3]: r for r in catalog(kimya)[0]}[t1][6] == 3)

        conn.execute("select pg_sleep(0.01)")
        add("Q6", t1)
        v3 = {r[3]: r for r in catalog(kimya)[0]}[t1][7]
        check("adding a question changes the version", v3 != v2)
        check("other topics keep their version",
              {r[3]: r for r in catalog(kimya)[0]}[t_flat][7] == by_topic[t_flat][7])

        _, err = catalog(kimya, "anon")
        check("anon cannot call it", err is not None)

        _, err = attempt(conn, "authenticated", user, "select * from questions where topic_id = %s", (t1,))
        check("(sanity) the question download itself is the normal select", err is None)

        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
