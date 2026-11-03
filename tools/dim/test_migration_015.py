"""Local test of db/migrations/015_webp_images.sql on a throw-away PostgreSQL.

Usage: python test_migration_015.py
"""
import sys
import tempfile
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


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        conn.execute("alter table questions add column if not exists solution_image_path text")
        migration = (ROOT / "db" / "migrations" / "015_webp_images.sql").read_text(encoding="utf-8")

        conn.execute("insert into storage.buckets (id, name) values ('question-images', 'question-images') on conflict do nothing")
        conn.execute("insert into storage.buckets (id, name) values ('other', 'other')")
        for name in ("A.png", "A.webp", "A_izah.webp", "C.png", "C.webp", "D.webp"):
            conn.execute("insert into storage.objects (bucket_id, name) values ('question-images', %s)", (name,))
        conn.execute("insert into storage.objects (bucket_id, name) values ('other', 'E.webp')")

        subject = conn.execute("insert into subjects (slug, name) values ('kimya', 'Kimya') returning id").fetchone()[0]
        topic = conn.execute("insert into topics (subject_id, name) values (%s, 'T') returning id", (subject,)).fetchone()[0]

        def add(code, image, solution=None):
            conn.execute(
                "insert into questions (code, topic_id, body, options, correct_answer, difficulty, image_path, solution_image_path) "
                "values (%s, %s, 'x', '{\"A\": \"1\", \"B\": \"2\"}', 'A', 1, %s, %s)",
                (code, topic, image, solution),
            )

        add("Q-A", "A.png", "A_izah.png")   # both .webp uploaded
        add("Q-B", "B.png")                 # B.webp not uploaded yet
        add("Q-C", "C.webp")                # already webp
        add("Q-E", "E.png")                 # E.webp exists only in ANOTHER bucket
        add("Q-N", None)                    # no image

        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        def path(code, col="image_path"):
            return conn.execute(f"select {col} from questions where code = %s", (code,)).fetchone()[0]

        check("png path with an uploaded webp is renamed", path("Q-A") == "A.webp")
        check("explanation path is renamed too", path("Q-A", "solution_image_path") == "A_izah.webp")
        check("png path without an uploaded webp stays unchanged", path("Q-B") == "B.png")
        check("existing webp path is untouched", path("Q-C") == "C.webp")
        check("webp in another bucket does not count", path("Q-E") == "E.png")
        check("question without image stays null", path("Q-N") is None)
        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
