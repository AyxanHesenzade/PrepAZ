-- 016: catalog for the offline download screen (subject -> section -> topic).
-- For every topic of a subject that has active questions it returns: how many questions, a version number,
-- and how many image files / bytes the download would take. The app compares `version` with the one stored on
-- the phone: different = "update available".
--
-- version = microseconds of the newest questions.updated_at of the topic, INCLUDING inactive questions
-- (touch_updated_at fires on every update, so adding, editing or deactivating a question changes it).
-- That is why the function is security definer: through RLS a student would not see deactivated questions
-- and could miss the change. It returns only counts and sizes, never question data.
-- The questions themselves are downloaded with the normal select on `questions` (students already read them,
-- answer key included), so no new data is exposed.
-- Safe to run more than once.

create or replace function public.get_download_catalog(p_subject smallint)
returns table (
  section_id integer,
  section_name text,
  section_sort smallint,
  topic_id integer,
  topic_name text,
  topic_sort smallint,
  question_count integer,
  version bigint,
  image_count integer,
  image_bytes bigint
)
language sql stable security definer set search_path = '' as $$
  with agg as (
    select q.topic_id,
           (count(*) filter (where q.is_active))::integer as question_count,
           floor(extract(epoch from max(q.updated_at)) * 1000000)::bigint as version
      from public.questions q
     group by q.topic_id
  ),
  imgs as (
    select distinct q.topic_id, p.path
      from public.questions q
     cross join lateral unnest(array[q.image_path, q.solution_image_path]) as p(path)
     where q.is_active and p.path is not null
  ),
  img_sum as (
    select i.topic_id,
           count(*)::integer as image_count,
           coalesce(sum((o.metadata ->> 'size')::bigint), 0)::bigint as image_bytes
      from imgs i
      left join storage.objects o on o.bucket_id = 'question-images' and o.name = i.path
     group by i.topic_id
  )
  select s.id, s.name, s.sort_order,
         t.id, t.name, t.sort_order,
         a.question_count, a.version,
         coalesce(m.image_count, 0), coalesce(m.image_bytes, 0)
    from public.topics t
    join agg a on a.topic_id = t.id
    left join img_sum m on m.topic_id = t.id
    left join public.topics s on s.id = t.parent_id
   where t.subject_id = p_subject
     and a.question_count > 0
   order by s.sort_order nulls first, s.name nulls first, t.sort_order, t.name;
$$;

revoke all on function public.get_download_catalog(smallint) from public, anon;
grant execute on function public.get_download_catalog(smallint) to authenticated;
