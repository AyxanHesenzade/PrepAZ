-- 006: recommended teachers, managed from the admin panel and shown in the app ("Tövsiyə olunan müəllimlər").
-- Signed-in users see only active teachers who agreed to be shown (consent). Admins (is_admin()) see and change everything.
-- Nobody deletes a row: set is_active = false. Photos: public bucket teacher-photos (a teacher's photo is shown to everybody
-- in the app anyway, so a plain link is enough; only admins can upload). Safe to run again.

create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (length(btrim(full_name)) > 0),
  subject_label text not null check (length(btrim(subject_label)) > 0),     -- e.g. 'Kimya müəllimi'
  lesson_mode text not null check (lesson_mode in ('in_person', 'online', 'both')),
  address text,                                                              -- where the lessons are (in-person)
  phone text not null check (phone ~ '^\+?[0-9 ()-]{7,20}$'),
  about text,
  offer text,                                                                -- group, time, price ...
  photo_path text,                                                           -- file name inside the teacher-photos bucket
  consent boolean not null default false,                                    -- the teacher agreed to show data and photo
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.teachers_touch() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists teachers_touch on public.teachers;
create trigger teachers_touch before update on public.teachers
  for each row execute function public.teachers_touch();

alter table public.teachers enable row level security;
grant select on public.teachers to authenticated;
grant insert, update on public.teachers to authenticated;   -- RLS below decides who may use it

drop policy if exists "users read shown teachers" on public.teachers;
create policy "users read shown teachers" on public.teachers
  for select to authenticated using (is_active and consent);

drop policy if exists "admin reads all teachers" on public.teachers;
create policy "admin reads all teachers" on public.teachers
  for select to authenticated using (public.is_admin());

drop policy if exists "admin inserts teachers" on public.teachers;
create policy "admin inserts teachers" on public.teachers
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admin updates teachers" on public.teachers;
create policy "admin updates teachers" on public.teachers
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- photos
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('teacher-photos', 'teacher-photos', true, 1048576, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "admin uploads teacher photos" on storage.objects;
create policy "admin uploads teacher photos" on storage.objects
  for insert to authenticated with check (bucket_id = 'teacher-photos' and public.is_admin());

drop policy if exists "admin replaces teacher photos" on storage.objects;
create policy "admin replaces teacher photos" on storage.objects
  for update to authenticated using (bucket_id = 'teacher-photos' and public.is_admin())
  with check (bucket_id = 'teacher-photos' and public.is_admin());
