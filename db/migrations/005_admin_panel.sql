-- Admin panel (React, C:\Users\ayxan.hv\Desktop\PrepAzAdmin): who is an admin and what an admin may do.
-- Normal users keep exactly what they had (read active questions). Everything below is gated by is_admin().
-- Safe to run again.

-- 1) admins: one row per admin user. Rows are added by hand in the SQL Editor (never from the app or the panel).
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;

drop policy if exists "read own admin row" on public.admins;
create policy "read own admin row" on public.admins
  for select to authenticated using (user_id = auth.uid());
grant select on public.admins to authenticated;

create or replace function public.is_admin() returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid())
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- 2) questions: admins see all (also inactive), add and change. Nobody deletes (set is_active = false instead).
grant insert, update on public.questions to authenticated;   -- RLS below decides who may use it

drop policy if exists "admin reads all questions" on public.questions;
create policy "admin reads all questions" on public.questions
  for select to authenticated using (public.is_admin());

drop policy if exists "admin inserts questions" on public.questions;
create policy "admin inserts questions" on public.questions
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admin updates questions" on public.questions;
create policy "admin updates questions" on public.questions
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- 3) subjects (also inactive ones) and topics
drop policy if exists "admin reads all subjects" on public.subjects;
create policy "admin reads all subjects" on public.subjects
  for select to authenticated using (public.is_admin());

grant insert, update on public.topics to authenticated;
drop policy if exists "admin inserts topics" on public.topics;
create policy "admin inserts topics" on public.topics
  for insert to authenticated with check (public.is_admin());
drop policy if exists "admin updates topics" on public.topics;
create policy "admin updates topics" on public.topics
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- 4) images: admins upload/replace files in the question-images bucket (reading is already allowed for signed-in users)
drop policy if exists "admin uploads question images" on storage.objects;
create policy "admin uploads question images" on storage.objects
  for insert to authenticated with check (bucket_id = 'question-images' and public.is_admin());

drop policy if exists "admin replaces question images" on storage.objects;
create policy "admin replaces question images" on storage.objects
  for update to authenticated using (bucket_id = 'question-images' and public.is_admin())
  with check (bucket_id = 'question-images' and public.is_admin());
