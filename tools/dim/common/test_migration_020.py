"""Local test of db/migrations/020_app_devices.sql (on top of 019) on a throw-away PostgreSQL.

Usage: python test_migration_020.py
"""
import json
import sys
import tempfile
import uuid
from pathlib import Path

import pgserver
import psycopg

from test_migration_019 import DB_DIR, ROOT, attempt

failures = []


def check(name, ok):
    print(("PASS " if ok else "FAIL ") + name)
    if not ok:
        failures.append(name)


def one(conn, sql, params=()):
    return conn.execute(sql, params).fetchone()[0]


def main():
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:
        srv = pgserver.get_server(tmp)
        conn = psycopg.connect(srv.get_uri(), autocommit=True)
        conn.execute((DB_DIR / "supabase_stub.sql").read_text(encoding="utf-8"))
        conn.execute("""
            create schema if not exists extensions;
            create or replace function extensions.gen_salt(text, integer) returns text language sql as
              $f$ select '$2a$' || lpad($2::text, 2, '0') || '$' || left(md5(random()::text), 22) $f$;
            create or replace function extensions.crypt(text, text) returns text language sql as
              $f$ select left($2, 29) || md5($1 || left($2, 29)) $f$;
            alter table auth.users add column if not exists phone text,
              add column if not exists encrypted_password text, add column if not exists created_at timestamptz default now(),
              add column if not exists updated_at timestamptz, add column if not exists last_sign_in_at timestamptz,
              add column if not exists email_confirmed_at timestamptz, add column if not exists raw_app_meta_data jsonb,
              add column if not exists is_anonymous boolean default false;
            create table if not exists auth.sessions (id uuid primary key default gen_random_uuid(),
              user_id uuid references auth.users (id) on delete cascade);
        """)
        conn.execute((DB_DIR / "schema_reconstructed.sql").read_text(encoding="utf-8"))
        migrations = ROOT / "db" / "migrations"
        for name in ("005_admin_panel", "019_app_events_admin_users"):
            conn.execute((migrations / f"{name}.sql").read_text(encoding="utf-8"))
        migration = (migrations / "020_app_devices.sql").read_text(encoding="utf-8")
        conn.execute(migration)
        conn.execute(migration)  # safe to run twice

        admin, user = str(uuid.uuid4()), str(uuid.uuid4())
        for u in (admin, user):
            conn.execute("insert into auth.users (id, email) values (%s, %s)", (u, u + "@x.az"))
        conn.execute("insert into admins (user_id) values (%s)", (admin,))

        events = json.dumps([{"kind": "error", "name": "x"}])
        phone = {"brand": "samsung", "model": "SM-A515F", "android": "13", "sdk": 33, "screen": "411x914"}
        log5 = "select public.log_events(%s::jsonb, %s, '1.7.0+13', 'android', %s::jsonb)"
        log4 = "select public.log_events(%s::jsonb, %s, '1.7.0+13', 'android')"

        rows, err = attempt(conn, "anon", None, log5, (events, "dev-1", json.dumps(phone)))
        check("anon logs with device info", err is None and rows == [(1,)])
        check("device row written without a user",
              one(conn, "select info->>'model' from app_devices where device_id = 'dev-1' and user_id is null") == "SM-A515F")
        rows, err = attempt(conn, "anon", None, log4, (events, "dev-1"))
        check("old 4-argument call still works", err is None and rows == [(1,)])

        stamp = one(conn, "select updated_at from app_devices where device_id = 'dev-1'")
        attempt(conn, "authenticated", user, log5, (events, "dev-1", json.dumps(phone)))
        check("sign-in links the install to the account",
              one(conn, "select user_id::text from app_devices where device_id = 'dev-1'") == user)
        stamp2 = one(conn, "select updated_at from app_devices where device_id = 'dev-1'")
        attempt(conn, "authenticated", user, log5, (events, "dev-1", json.dumps(phone)))
        check("same info: no rewrite", one(conn, "select updated_at from app_devices where device_id = 'dev-1'") == stamp2
              and stamp2 >= stamp)
        attempt(conn, "anon", None, log5, (events, "dev-1", json.dumps(phone)))
        check("signed-out call keeps the last account",
              one(conn, "select user_id::text from app_devices where device_id = 'dev-1'") == user)
        phone["screen"] = "914x411"
        attempt(conn, "authenticated", user, log5, (events, "dev-1", json.dumps(phone)))
        check("changed info is updated", one(conn, "select info->>'screen' from app_devices where device_id = 'dev-1'") == "914x411")

        rows, _ = attempt(conn, "anon", None, log5, ('[{"kind":"bad","name":"x"}]', "dev-2", json.dumps(phone)))
        check("nothing logged -> no device row", rows == [(0,)] and
              one(conn, "select count(*) from app_devices where device_id = 'dev-2'") == 0)
        attempt(conn, "anon", None, log5, (events, "dev-3", json.dumps({"x": "y" * 5000})))
        check("oversized info is ignored, event still logged",
              one(conn, "select count(*) from app_devices where device_id = 'dev-3'") == 0 and
              one(conn, "select count(*) from app_events where device_id = 'dev-3'") == 1)
        attempt(conn, "anon", None, log5, (events, "dev-4", '"text"'))
        check("non-object info is ignored", one(conn, "select count(*) from app_devices where device_id = 'dev-4'") == 0)

        _, err = attempt(conn, "authenticated", user, "select count(*) from app_devices")
        rows, _ = attempt(conn, "authenticated", user, "select count(*) from app_devices")
        check("user reads no devices", rows == [(0,)])
        _, err = attempt(conn, "authenticated", user, "insert into app_devices (device_id) values ('z')")
        check("direct insert forbidden", err is not None)

        rows, err = attempt(conn, "authenticated", admin, "select public.admin_list_events(%s::uuid, null, 50)", (user,))
        check("events carry the device", err is None and rows[0][0][0]["device"]["model"] == "SM-A515F")
        rows, err = attempt(conn, "authenticated", admin, "select public.admin_list_users()")
        users = {u["id"]: u for u in rows[0][0]}
        check("users carry their last device", err is None and users[user]["device"]["screen"] == "914x411"
              and users[admin]["device"] is None)
        _, err = attempt(conn, "authenticated", user, "select public.admin_list_events()")
        check("non-admin still refused", err is not None)

        conn.execute("delete from auth.users where id = %s", (user,))
        check("deleting the account keeps the install row, without the user",
              one(conn, "select user_id from app_devices where device_id = 'dev-1'") is None)

        rows, err = attempt(conn, "authenticated", admin, "select public.admin_purge_events(30)")
        check("purge 30 days keeps devices", err is None and one(conn, "select count(*) from app_devices") > 0)
        rows, err = attempt(conn, "authenticated", admin, "select public.admin_purge_events(0)")
        check("delete all removes events and devices", err is None and
              one(conn, "select count(*) from app_events") == 0 and one(conn, "select count(*) from app_devices") == 0)

        print(f"\n{len(failures)} failures")
        sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
