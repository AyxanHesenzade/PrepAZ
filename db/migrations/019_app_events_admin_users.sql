-- 019: activity / error log from the app (app_events) + admin tools for accounts.
--   * The app sends events through log_events() (anon too: failed sign-ins happen before there is a session).
--     user_id is taken from the session on the server, never from the client. Nobody but admins can read.
--   * Admin-only (security definer, checked with is_admin()):
--       admin_list_users()                  accounts + confirmation, sign-in method, errors in the last 7 days
--       admin_list_events(...)              the log, newest first, with the account's e-mail
--       admin_set_password(user, password)  new password, the user is signed out on every device
--       admin_confirm_email(user)           marks the e-mail as confirmed (user stuck on "confirm your e-mail")
--       admin_delete_user(user)             deletes the account and all its rows (cascade); admins are refused
--       admin_purge_events(days)            removes log rows older than N days; 0 or null = ALL rows
-- No service_role key is needed: the panel calls these with the admin's own session. Safe to run again.

create table if not exists public.app_events (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  happened_at timestamptz,                         -- phone time (events can be sent later, e.g. after being offline)
  user_id uuid references auth.users (id) on delete cascade,
  device_id text check (char_length(device_id) <= 64),
  kind text not null check (kind in ('auth', 'error', 'crash', 'info')),
  name text not null check (char_length(name) between 1 and 80),
  message text check (char_length(message) <= 1000),
  meta jsonb,
  app_version text check (char_length(app_version) <= 32),
  platform text check (char_length(platform) <= 120)
);
create index if not exists app_events_created_idx on public.app_events (created_at desc);
create index if not exists app_events_user_idx on public.app_events (user_id, created_at desc);
create index if not exists app_events_device_idx on public.app_events (device_id, created_at desc);

alter table public.app_events enable row level security;
revoke all on public.app_events from anon, authenticated;
grant select, delete on public.app_events to authenticated;   -- RLS below: only admins

drop policy if exists "admin reads events" on public.app_events;
create policy "admin reads events" on public.app_events
  for select to authenticated using (public.is_admin());

drop policy if exists "admin deletes events" on public.app_events;
create policy "admin deletes events" on public.app_events
  for delete to authenticated using (public.is_admin());

-- p_events: [{kind, name, message?, meta?, at?}], at most 50 per call. Bad rows are skipped, long texts cut.
-- Spam guard: at most 300 rows per device (or per user) per hour; extra rows are dropped silently.
create or replace function public.log_events(p_events jsonb, p_device text, p_version text, p_platform text)
returns integer
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  device text := left(nullif(btrim(p_device), ''), 64);
  used integer;
  room integer;
  added integer;
begin
  if jsonb_typeof(p_events) is distinct from 'array' then
    return 0;
  end if;
  if me is null and device is null then
    return 0;
  end if;

  select count(*) into used from public.app_events e
   where e.created_at > now() - interval '1 hour'
     and (e.device_id = device or (me is not null and e.user_id = me));
  room := least(300 - used, 50);
  if room <= 0 then
    return 0;
  end if;

  insert into public.app_events (happened_at, user_id, device_id, kind, name, message, meta, app_version, platform)
  select least(coalesce((ev->>'at')::timestamptz, now()), now()),
         me, device, ev->>'kind', left(ev->>'name', 80), left(ev->>'message', 1000),
         case when jsonb_typeof(ev->'meta') = 'object' and pg_column_size(ev->'meta') <= 4000 then ev->'meta' end,
         left(p_version, 32), left(p_platform, 120)
    from (select ev from jsonb_array_elements(p_events) ev limit room) x
   where jsonb_typeof(ev) = 'object'
     and ev->>'kind' in ('auth', 'error', 'crash', 'info')
     and coalesce(ev->>'name', '') <> ''
     and coalesce(ev->>'at', '') ~ '^(\d{4}-\d\d-\d\dT[0-9:.]+(Z|[+-]\d\d:?\d\d)?)?$';
  get diagnostics added = row_count;
  return added;
end $$;

revoke all on function public.log_events(jsonb, text, text, text) from public;
grant execute on function public.log_events(jsonb, text, text, text) to anon, authenticated;

-- every admin function starts with this
create or replace function public.require_admin() returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.admins a where a.user_id = auth.uid()) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
end $$;
revoke all on function public.require_admin() from public, anon;
grant execute on function public.require_admin() to authenticated;

-- replaces PrepAzAdmin/supabase/admin_list_users.sql (same name, more fields)
create or replace function public.admin_list_users()
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform public.require_admin();
  return (
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'id', u.id,
        'contact', coalesce(u.email::text, u.phone::text),
        'created_at', u.created_at,
        'last_sign_in_at', u.last_sign_in_at,
        'email_confirmed_at', u.email_confirmed_at,
        'providers', coalesce(u.raw_app_meta_data->'providers', '[]'::jsonb),
        'is_anonymous', u.is_anonymous,
        'is_admin', a.user_id is not null,
        'errors_7d', (select count(*) from public.app_events e
                       where e.user_id = u.id and e.kind in ('error', 'crash')
                         and e.created_at > now() - interval '7 days'),
        'auth_fails_7d', (select count(*) from public.app_events e
                           where e.user_id = u.id and e.kind = 'auth' and e.name like '%failed'
                             and e.created_at > now() - interval '7 days'),
        'last_event_at', (select max(e.created_at) from public.app_events e where e.user_id = u.id)
      ) order by u.created_at desc), '[]'::jsonb)
      from auth.users u
      left join public.admins a on a.user_id = u.id
  );
end $$;
revoke all on function public.admin_list_users() from public, anon;
grant execute on function public.admin_list_users() to authenticated;

-- p_user: one account (null = all); p_kind: 'auth' | 'error' | 'crash' | 'info' (null = all);
-- p_before: paging, rows older than this id. At most 500 rows.
create or replace function public.admin_list_events(p_user uuid default null, p_kind text default null,
                                                    p_limit integer default 200, p_before bigint default null)
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform public.require_admin();
  return (
    select coalesce(jsonb_agg(to_jsonb(r) order by r.id desc), '[]'::jsonb)
      from (select e.id, e.created_at, e.happened_at, e.user_id, e.device_id, e.kind, e.name, e.message, e.meta,
                   e.app_version, e.platform, u.email::text as contact
              from public.app_events e
              left join auth.users u on u.id = e.user_id
             where (p_user is null or e.user_id = p_user)
               and (p_kind is null or e.kind = p_kind)
               and (p_before is null or e.id < p_before)
             order by e.id desc
             limit least(greatest(coalesce(p_limit, 200), 1), 500)) r
  );
end $$;
revoke all on function public.admin_list_events(uuid, text, integer, bigint) from public, anon;
grant execute on function public.admin_list_events(uuid, text, integer, bigint) to authenticated;

-- Supabase Auth checks bcrypt hashes; pgcrypto's crypt(..., gen_salt('bf')) makes the same kind.
-- Supabase already has pgcrypto in the "extensions" schema; this only matters on a fresh database.
do $$
begin
  if to_regprocedure('extensions.crypt(text, text)') is null then
    create extension if not exists pgcrypto with schema extensions;
  end if;
end $$;

create or replace function public.admin_set_password(p_user uuid, p_password text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform public.require_admin();
  if char_length(coalesce(p_password, '')) < 6 or char_length(p_password) > 72 then
    raise exception 'password_length' using errcode = '22023';
  end if;
  update auth.users
     set encrypted_password = extensions.crypt(p_password, extensions.gen_salt('bf', 10)),
         updated_at = now()
   where id = p_user;
  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;
  delete from auth.sessions where user_id = p_user;   -- refresh tokens go with the sessions (cascade)
end $$;
revoke all on function public.admin_set_password(uuid, text) from public, anon;
grant execute on function public.admin_set_password(uuid, text) to authenticated;

create or replace function public.admin_confirm_email(p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform public.require_admin();
  update auth.users set email_confirmed_at = coalesce(email_confirmed_at, now()), updated_at = now()
   where id = p_user;
  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;
end $$;
revoke all on function public.admin_confirm_email(uuid) from public, anon;
grant execute on function public.admin_confirm_email(uuid) to authenticated;

create or replace function public.admin_delete_user(p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform public.require_admin();
  if exists (select 1 from public.admins where user_id = p_user) then
    raise exception 'admin_account' using errcode = '42501';
  end if;
  delete from auth.users where id = p_user;
  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;
end $$;
revoke all on function public.admin_delete_user(uuid) from public, anon;
grant execute on function public.admin_delete_user(uuid) to authenticated;

create or replace function public.admin_purge_events(p_days integer) returns integer
language plpgsql security definer set search_path = '' as $$
declare removed integer;
begin
  perform public.require_admin();
  if coalesce(p_days, 0) <= 0 then
    delete from public.app_events where true;   -- "where true": safe-update guards refuse a bare delete
  else
    delete from public.app_events where created_at < now() - make_interval(days => p_days);
  end if;
  get diagnostics removed = row_count;
  return removed;
end $$;
revoke all on function public.admin_purge_events(integer) from public, anon;
grant execute on function public.admin_purge_events(integer) to authenticated;
