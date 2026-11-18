"""Local test of db/migrations/019_app_events_admin_users.sql on a throw-away PostgreSQL.

Usage: python test_migration_019.py
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


def attempt(conn, role, user_id, sql, params=()):
    conn.execute(f"set role {role}")
    conn.execute("select set_config('request.jwt.claim.sub', %s, false)", (user_id or "",))
    try:
        cur = conn.execute(sql, params)
        return (cur.fetchall() if cur.description else cur.rowcount, None)
    except psycopg.errors.Error as e:
        return (None, type(e).__name__)
    finally:
        conn.execute("reset role")


def one(conn, sql, params=()):
    return conn.execute(sql, params).fetchone()[0]


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        # the parts of Supabase's auth schema this migration touches
        conn.execute("""
            create schema if not exists extensions;
            alter table auth.users add column if not exists phone text,
              add column if not exists encrypted_password text, add column if not exists created_at timestamptz default now(),
              add column if not exists updated_at timestamptz, add column if not exists last_sign_in_at timestamptz,
              add column if not exists email_confirmed_at timestamptz, add column if not exists raw_app_meta_data jsonb,
              add column if not exists is_anonymous boolean default false;
            -- pgserver has no pgcrypto: a stand-in with the same shape ($2a$10$ + salt), verifiable the same way
            create or replace function extensions.gen_salt(text, integer) returns text language sql as
              $f$ select '$2a$' || lpad($2::text, 2, '0') || '$' || left(md5(random()::text), 22) $f$;
            create or replace function extensions.crypt(text, text) returns text language sql as
              $f$ select left($2, 29) || md5($1 || left($2, 29)) $f$;
            create table if not exists auth.sessions (id uuid primary key default gen_random_uuid(),
              user_id uuid references auth.users (id) on delete cascade);
        """)
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        migrations = ROOT / "db" / "migrations"
        for name in ("005_admin_panel", "009_reports", "010_exam_goals", "011_legal_acceptances"):
            conn.execute((migrations / f"{name}.sql").read_text(encoding="utf-8"))
        migration = (migrations / "019_app_events_admin_users.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        admin, user, other = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user, other):
            conn.execute("insert into auth.users (id, email, raw_app_meta_data) values (%s, %s, %s)",
                         (u, u + "@x.az", json.dumps({"providers": ["email"]})))
            conn.execute("insert into profiles (id) values (%s) on conflict do nothing", (u,))
            conn.execute("insert into auth.sessions (user_id) values (%s)", (u,))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))
        conn.execute("insert into reports (user_id, kind, message) values (%s, 'app', 'long enough text')", (user,))

        log = "select public.log_events(%s::jsonb, %s, '1.7.0+13', 'android 14')"
        events = json.dumps([
            {"kind": "auth", "name": "sign_in_failed", "message": "x" * 5000, "meta": {"email": "a@b.az"},
             "at": "2026-01-02T10:00:00.000Z"},
            {"kind": "error", "name": "PostgrestException", "meta": {"where": "home"}},
            {"kind": "hack", "name": "bad kind"},
            {"kind": "info", "name": ""},
            {"kind": "info", "name": "bad time", "at": "yesterday"},
            "not an object",
        ])

        # writing
        rows, err = attempt(conn, "anon", None, log, (events, "device-1"))
        check("anon can log with a device id", err is None and rows == [(2,)])
        check("anon rows have no user", one(conn, "select count(*) from app_events where user_id is null") == 2)
        check("long message is cut to 1000", one(conn, "select max(char_length(message)) from app_events") == 1000)
        check("phone time kept", one(conn, "select count(*) from app_events where happened_at = '2026-01-02T10:00:00Z'") == 1)
        rows, err = attempt(conn, "anon", None, log, (events, None))
        check("anon without device id writes nothing", rows == [(0,)])
        rows, err = attempt(conn, "authenticated", user, log, (events, "device-2"))
        check("user rows get the session's user id", err is None and
              one(conn, "select count(*) from app_events where user_id = %s", (user,)) == 2)
        rows, err = attempt(conn, "authenticated", user, log, ('{"kind": "info"}', "device-2"))
        check("non-array input writes nothing", rows == [(0,)])
        _, err = attempt(conn, "authenticated", user, "insert into app_events (kind, name) values ('info', 'x')")
        check("direct insert forbidden", err is not None)
        future = json.dumps([{"kind": "info", "name": "future", "at": "2099-01-01T00:00:00Z"}])
        attempt(conn, "authenticated", user, log, (future, "device-2"))
        check("future phone time is clamped", one(conn, "select happened_at <= now() from app_events where name = 'future'"))

        many = json.dumps([{"kind": "info", "name": f"e{i}"} for i in range(80)])
        rows, _ = attempt(conn, "anon", None, log, (many, "spam"))
        check("at most 50 per call", rows == [(50,)])
        for _ in range(10):
            attempt(conn, "anon", None, log, (many, "spam"))
        check("at most 300 per device per hour", one(conn, "select count(*) from app_events where device_id = 'spam'") == 300)

        # reading
        rows, err = attempt(conn, "authenticated", user, "select count(*) from app_events")
        check("user reads nothing", rows == [(0,)])
        rows, err = attempt(conn, "anon", None, "select count(*) from app_events")
        check("anon cannot read", err is not None)
        rows, err = attempt(conn, "authenticated", admin, "select count(*) from app_events")
        check("admin reads all", err is None and rows[0][0] > 300)

        for fn in ("admin_list_users()", "admin_list_events()", f"admin_set_password('{other}', 'secret1')",
                   f"admin_confirm_email('{other}')", f"admin_delete_user('{other}')", "admin_purge_events(30)"):
            _, err = attempt(conn, "authenticated", user, f"select public.{fn}")
            _, err_anon = attempt(conn, "anon", None, f"select public.{fn}")
            check(f"{fn}: user and anon refused", err is not None and err_anon is not None)

        rows, err = attempt(conn, "authenticated", admin, "select public.admin_list_users()")
        users = {u["id"]: u for u in rows[0][0]}
        check("admin lists every account", err is None and len(users) == 3)
        check("list shows errors and auth fails of 7 days", users[user]["errors_7d"] == 1 and users[user]["auth_fails_7d"] == 1)
        check("list shows admin flag and providers", users[admin]["is_admin"] and users[user]["providers"] == ["email"])

        rows, err = attempt(conn, "authenticated", admin, "select public.admin_list_events(%s::uuid, 'auth', 10)", (user,))
        check("events filtered by user and kind, with e-mail",
              err is None and len(rows[0][0]) == 1 and rows[0][0][0]["contact"] == user + "@x.az")
        total = one(conn, "select count(*) from app_events")
        rows, _ = attempt(conn, "authenticated", admin, "select public.admin_list_events(null, null, 9999)")
        check("huge limit is accepted (capped at 500)", len(rows[0][0]) == min(total, 500))
        rows, _ = attempt(conn, "authenticated", admin, "select public.admin_list_events(null, null, 100)")
        page = rows[0][0]
        check("limit and newest first", len(page) == 100 and page[0]["id"] > page[-1]["id"])
        rows, _ = attempt(conn, "authenticated", admin, "select public.admin_list_events(null, null, 500, %s)", (page[-1]["id"],))
        check("paging with p_before", all(e["id"] < page[-1]["id"] for e in rows[0][0]) and len(rows[0][0]) > 0)

        # password
        _, err = attempt(conn, "authenticated", admin, "select public.admin_set_password(%s, '123')", (user,))
        check("short password refused", err is not None)
        _, err = attempt(conn, "authenticated", admin, "select public.admin_set_password(%s, 'yeni-parol')", (user,))
        check("admin sets password", err is None)
        check("bcrypt hash that matches", one(conn, "select encrypted_password = extensions.crypt('yeni-parol', encrypted_password) "
                                                 "and encrypted_password like '$2a$10$%%' from auth.users where id = %s", (user,)))
        check("user signed out everywhere", one(conn, "select count(*) from auth.sessions where user_id = %s", (user,)) == 0)
        check("other sessions kept", one(conn, "select count(*) from auth.sessions where user_id = %s", (other,)) == 1)
        _, err = attempt(conn, "authenticated", admin, "select public.admin_set_password(%s, 'yeni-parol')", (str(uuid.uuid4()),))
        check("unknown user: error", err is not None)

        # e-mail confirmation
        _, err = attempt(conn, "authenticated", admin, "select public.admin_confirm_email(%s)", (other,))
        check("admin confirms e-mail", err is None and
              one(conn, "select email_confirmed_at is not null from auth.users where id = %s", (other,)))

        # delete
        _, err = attempt(conn, "authenticated", admin, "select public.admin_delete_user(%s)", (admin,))
        check("admin account cannot be deleted", err is not None and one(conn, "select count(*) from auth.users where id = %s", (admin,)) == 1)
        _, err = attempt(conn, "authenticated", admin, "select public.admin_delete_user(%s)", (user,))
        check("admin deletes a user", err is None)
        for table, column in (("auth.users", "id"), ("profiles", "id"), ("reports", "user_id"), ("app_events", "user_id")):
            check(f"{table}: rows of the deleted user gone",
                  one(conn, f"select count(*) from {table} where {column} = %s", (user,)) == 0)
        check("other user untouched", one(conn, "select count(*) from auth.users where id = %s", (other,)) == 1)

        # purge
        conn.execute("update app_events set created_at = now() - interval '40 days' where device_id = 'spam'")
        rows, err = attempt(conn, "authenticated", admin, "select public.admin_purge_events(30)")
        check("purge removes old rows only", err is None and rows == [(300,)] and one(conn, "select count(*) from app_events") > 0)

        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
