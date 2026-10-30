-- 010: exam goal. Admin keeps the exam periods ("winter", "summer") with one date each; the student picks a
-- period (or writes an own date) and a daily question goal. The real date from DIM is changed in one place for everybody.
--   exam_periods  readable by every signed-in user; only admins change it (rows are never deleted: is_active = false)
--   user_goals    one row per student, he reads/writes only his own
-- The summer default (15 June) is an ASSUMPTION until DIM announces the date. Safe to run again.

create table if not exists public.exam_periods (
  id smallserial primary key,
  code text not null unique check (code ~ '^[a-z0-9_]{2,30}$'),
  name text not null check (char_length(btrim(name)) between 2 and 80),
  exam_date date not null,
  sort_order smallint not null default 0,
  is_active boolean not null default true
);

insert into public.exam_periods (code, name, exam_date, sort_order) values
  ('winter', 'Qış dövrü', date '2027-02-15', 1),
  ('summer', 'Yay dövrü', date '2027-06-15', 2)
on conflict (code) do nothing;

create table if not exists public.user_goals (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  exam_period_id smallint references public.exam_periods (id),
  custom_exam_date date,
  daily_goal smallint not null default 20 check (daily_goal between 5 and 200),
  updated_at timestamptz not null default now()
);

create or replace function public.user_goals_touch() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists user_goals_touch on public.user_goals;
create trigger user_goals_touch before update on public.user_goals
  for each row execute function public.user_goals_touch();

alter table public.exam_periods enable row level security;
alter table public.user_goals enable row level security;

grant select on public.exam_periods to authenticated;
grant insert, update on public.exam_periods to authenticated;   -- RLS below: only admins
grant usage, select on sequence public.exam_periods_id_seq to authenticated;
grant select, insert, update on public.user_goals to authenticated;

drop policy if exists "signed-in reads periods" on public.exam_periods;
create policy "signed-in reads periods" on public.exam_periods
  for select to authenticated using (is_active or public.is_admin());

drop policy if exists "admin adds periods" on public.exam_periods;
create policy "admin adds periods" on public.exam_periods
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admin updates periods" on public.exam_periods;
create policy "admin updates periods" on public.exam_periods
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "own goal read" on public.user_goals;
create policy "own goal read" on public.user_goals
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "own goal add" on public.user_goals;
create policy "own goal add" on public.user_goals
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "own goal change" on public.user_goals;
create policy "own goal change" on public.user_goals
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
