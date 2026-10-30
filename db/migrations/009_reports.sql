-- 009: problem reports from the app: a wrong question ("question") or a bug in the app ("app").
-- A signed-in user can only ADD a report (as himself); only admins read, change the status and delete.
-- A description is required (10-1000 characters). At most 10 reports per user per hour (spam guard).
-- The question is stored by id AND by code (the code stays readable even if the question is later removed). Safe to run again.

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind text not null check (kind in ('question', 'app')),
  question_id uuid references public.questions (id) on delete set null,
  question_code text,
  message text not null check (char_length(btrim(message)) between 10 and 1000),
  app_version text,
  status text not null default 'new' check (status in ('new', 'seen', 'done')),
  admin_note text,
  created_at timestamptz not null default now(),
  check ((kind = 'question') = (question_code is not null))
);
create index if not exists reports_status_created_idx on public.reports (status, created_at desc);

-- security definer: the user cannot read reports (RLS), but the guard must count them
create or replace function public.reports_rate_limit() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.reports where user_id = new.user_id and created_at > now() - interval '1 hour') >= 10 then
    raise exception 'too_many_reports' using errcode = 'P0001';
  end if;
  return new;
end $$;
drop trigger if exists reports_rate_limit on public.reports;
create trigger reports_rate_limit before insert on public.reports
  for each row execute function public.reports_rate_limit();

alter table public.reports enable row level security;
grant insert on public.reports to authenticated;
grant select, update, delete on public.reports to authenticated;   -- RLS below: only admins

drop policy if exists "users add own report" on public.reports;
create policy "users add own report" on public.reports
  for insert to authenticated with check (user_id = auth.uid() and status = 'new' and admin_note is null);

drop policy if exists "admin reads reports" on public.reports;
create policy "admin reads reports" on public.reports
  for select to authenticated using (public.is_admin());

drop policy if exists "admin updates reports" on public.reports;
create policy "admin updates reports" on public.reports
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin deletes reports" on public.reports;
create policy "admin deletes reports" on public.reports
  for delete to authenticated using (public.is_admin());
