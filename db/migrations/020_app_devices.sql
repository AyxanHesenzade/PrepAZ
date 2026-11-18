-- 020: which phone a log came from (brand, model, Android, screen, font size, RAM...).
-- One row per installation (device_id = random id of the app install, not the phone's real id), NOT per event:
-- the log stays small on the free database. Written by the app through log_events(..., p_info), read by admins only.
-- Needs 019. Safe to run again. Old app versions keep calling the 4-argument log_events (still there).

create table if not exists public.app_devices (
  device_id text primary key check (char_length(device_id) between 1 and 64),
  user_id uuid references auth.users (id) on delete set null,   -- the last account seen on this install
  info jsonb not null default '{}'::jsonb check (pg_column_size(info) <= 3000),
  first_seen timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists app_devices_user_idx on public.app_devices (user_id, updated_at desc);

alter table public.app_devices enable row level security;
revoke all on public.app_devices from anon, authenticated;
grant select, delete on public.app_devices to authenticated;   -- RLS below: only admins

drop policy if exists "admin reads devices" on public.app_devices;
create policy "admin reads devices" on public.app_devices
  for select to authenticated using (public.is_admin());

drop policy if exists "admin deletes devices" on public.app_devices;
create policy "admin deletes devices" on public.app_devices
  for delete to authenticated using (public.is_admin());

-- Same as the 4-argument version, plus p_info: the phone's details. Written only when they changed
-- (or the account on the install changed), and only when the call was not rate limited.
create or replace function public.log_events(p_events jsonb, p_device text, p_version text, p_platform text, p_info jsonb)
returns integer
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  device text := left(nullif(btrim(p_device), ''), 64);
  added integer;
begin
  added := public.log_events(p_events, p_device, p_version, p_platform);
  if added > 0 and device is not null and jsonb_typeof(p_info) = 'object' and pg_column_size(p_info) <= 3000 then
    insert into public.app_devices as d (device_id, user_id, info)
    values (device, me, p_info)
    on conflict (device_id) do update
      set info = excluded.info, user_id = coalesce(excluded.user_id, d.user_id), updated_at = now()
      where d.info is distinct from excluded.info
         or (excluded.user_id is not null and d.user_id is distinct from excluded.user_id);
  end if;
  return added;
end $$;

revoke all on function public.log_events(jsonb, text, text, text, jsonb) from public;
grant execute on function public.log_events(jsonb, text, text, text, jsonb) to anon, authenticated;

-- 019's list + the device of every event
create or replace function public.admin_list_events(p_user uuid default null, p_kind text default null,
                                                    p_limit integer default 200, p_before bigint default null)
returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform public.require_admin();
  return (
    select coalesce(jsonb_agg(to_jsonb(r) order by r.id desc), '[]'::jsonb)
      from (select e.id, e.created_at, e.happened_at, e.user_id, e.device_id, e.kind, e.name, e.message, e.meta,
                   e.app_version, e.platform, u.email::text as contact, d.info as device
              from public.app_events e
              left join auth.users u on u.id = e.user_id
              left join public.app_devices d on d.device_id = e.device_id
             where (p_user is null or e.user_id = p_user)
               and (p_kind is null or e.kind = p_kind)
               and (p_before is null or e.id < p_before)
             order by e.id desc
             limit least(greatest(coalesce(p_limit, 200), 1), 500)) r
  );
end $$;

-- 019's list + the account's most recent device
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
        'last_event_at', (select max(e.created_at) from public.app_events e where e.user_id = u.id),
        'device', (select d.info from public.app_devices d where d.user_id = u.id
                    order by d.updated_at desc limit 1)
      ) order by u.created_at desc), '[]'::jsonb)
      from auth.users u
      left join public.admins a on a.user_id = u.id
  );
end $$;

-- "Bütün logları sil" (p_days <= 0) also forgets the devices
create or replace function public.admin_purge_events(p_days integer) returns integer
language plpgsql security definer set search_path = '' as $$
declare removed integer;
begin
  perform public.require_admin();
  if coalesce(p_days, 0) <= 0 then
    delete from public.app_events where true;   -- "where true": safe-update guards refuse a bare delete
    get diagnostics removed = row_count;
    delete from public.app_devices where true;
  else
    delete from public.app_events where created_at < now() - make_interval(days => p_days);
    get diagnostics removed = row_count;
  end if;
  return removed;
end $$;
