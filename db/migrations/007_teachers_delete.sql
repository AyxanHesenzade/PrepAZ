-- 007: an admin may delete a teacher (and the teacher's photo file). Normal users still cannot. Safe to run again.

grant delete on public.teachers to authenticated;   -- RLS below decides who may use it

drop policy if exists "admin deletes teachers" on public.teachers;
create policy "admin deletes teachers" on public.teachers
  for delete to authenticated using (public.is_admin());

drop policy if exists "admin deletes teacher photos" on storage.objects;
create policy "admin deletes teacher photos" on storage.objects
  for delete to authenticated using (bucket_id = 'teacher-photos' and public.is_admin());

-- Storage needs to see a file before it can delete or replace it, so the admin also gets select on this bucket.
drop policy if exists "admin reads teacher photos" on storage.objects;
create policy "admin reads teacher photos" on storage.objects
  for select to authenticated using (bucket_id = 'teacher-photos' and public.is_admin());
