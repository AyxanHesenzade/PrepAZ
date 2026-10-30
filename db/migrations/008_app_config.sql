-- 008: app update settings, one row. The app reads it at start (also before sign-in, so anon may read):
--   min_version    older apps must update (blocking screen)
--   latest_version older apps get a dismissible "new version" notice
--   update_url     where the update button goes (APK link now, Play Store later)
-- Versions look like 0.0.1 or 0.0.1+2 (with build). Only admins change it. Safe to run again.

create table if not exists public.app_config (
  id smallint primary key default 1 check (id = 1),
  min_version text not null default '0.0.0' check (min_version ~ '^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$'),
  latest_version text not null default '0.0.0' check (latest_version ~ '^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$'),
  update_url text check (update_url is null or update_url ~ '^https?://'),
  updated_at timestamptz not null default now()
);

insert into public.app_config (id) values (1) on conflict (id) do nothing;

create or replace function public.app_config_touch() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists app_config_touch on public.app_config;
create trigger app_config_touch before update on public.app_config
  for each row execute function public.app_config_touch();

alter table public.app_config enable row level security;
grant select on public.app_config to anon, authenticated;
grant update on public.app_config to authenticated;   -- RLS below decides who may use it

drop policy if exists "everybody reads app config" on public.app_config;
create policy "everybody reads app config" on public.app_config
  for select to anon, authenticated using (true);

drop policy if exists "admin updates app config" on public.app_config;
create policy "admin updates app config" on public.app_config
  for update to authenticated using (public.is_admin()) with check (public.is_admin());
