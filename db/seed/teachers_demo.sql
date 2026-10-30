-- DEMO teachers (fake data) to see how the section looks and is managed. Test Supabase only.
-- Photos: upload tools/teachers/upload/*.png to the teacher-photos bucket. Delete these rows (or set is_active = false) before release.
insert into public.teachers (full_name, subject_label, lesson_mode, address, phone, about, offer, photo_path, consent, is_active, sort_order)
select * from (values
  ('Nümunə Müəllim', 'Kimya müəllimi', 'both', 'Bakı, Nərimanov rayonu', '+994501112233',
   'NÜMUNƏ: 10 illik təcrübə, buraxılış və qəbul imtahanlarına hazırlıq.', 'Həftədə 3 dərs, qrup (6 nəfər) və fərdi. Qiymət üçün zəng edin.', 'demo-kimya.png', true, true, 1),
  ('Nümunə Biologiya', 'Biologiya müəllimi', 'online', null, '+994552223344',
   'NÜMUNƏ: yalnız online dərslər, tibb istiqaməti.', 'Hər gün 19:00-dan sonra, fərdi dərs.', 'demo-biologiya.png', true, true, 2),
  ('Nümunə Əyani', 'Riyaziyyat müəllimi', 'in_person', 'Bakı, Yasamal rayonu', '+994703334455',
   'NÜMUNƏ: şəkilsiz nümunə (ilk hərf göstərilir).', null, null, true, true, 3)
) as v(full_name, subject_label, lesson_mode, address, phone, about, offer, photo_path, consent, is_active, sort_order)
where not exists (select 1 from public.teachers t where t.full_name = v.full_name);
