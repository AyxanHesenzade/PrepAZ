-- 015: question images are stored as WebP (about 44% of the PNG size).
-- Renames questions.image_path / solution_image_path from NAME.png to NAME.webp, but ONLY when the .webp file
-- already exists in the question-images bucket, so a half-finished upload never leaves a broken link.
-- Order: 1) upload the .webp files (upload_images.py --folder out/webp --upload)
--        2) run this migration  3) check the app  4) delete the old .png files (upload_images.py --delete-png).
-- Safe to run more than once. Rows whose .webp is not uploaded yet keep the .png path.

update questions q
   set image_path = regexp_replace(q.image_path, '\.png$', '.webp')
 where q.image_path ~ '\.png$'
   and exists (select 1 from storage.objects o
                where o.bucket_id = 'question-images'
                  and o.name = regexp_replace(q.image_path, '\.png$', '.webp'));

update questions q
   set solution_image_path = regexp_replace(q.solution_image_path, '\.png$', '.webp')
 where q.solution_image_path ~ '\.png$'
   and exists (select 1 from storage.objects o
                where o.bucket_id = 'question-images'
                  and o.name = regexp_replace(q.solution_image_path, '\.png$', '.webp'));
