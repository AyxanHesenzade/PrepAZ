-- 002: private Storage bucket for question images.
-- Signed-in users may READ images. Nobody can write through the API: there is intentionally no
-- insert/update/delete policy, so only service_role (upload script) and the Supabase dashboard can upload.
-- Safe to run more than once. Does not touch subjects.is_active or any other table.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('question-images', 'question-images', false, 2097152, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "question images read" on storage.objects;
create policy "question images read" on storage.objects
  for select to authenticated
  using (bucket_id = 'question-images');
