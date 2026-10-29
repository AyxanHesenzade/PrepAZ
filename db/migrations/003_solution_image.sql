-- 003: image of the official explanation (kəsrlər, cədvəllər və stoxiometrik qeydlər mətndə pozulur).
-- The text column `solution` stays as the fallback; the app shows the image when solution_image_path is set.
--
-- get_daily_set returns `setof questions`, so it MUST be recreated together with the new column
-- (otherwise it fails with "return type mismatch"). Body is identical to the production function
-- apart from the extra column at the end of the select list.
-- Safe to run more than once. Does not touch subjects.is_active.

alter table questions add column if not exists solution_image_path text;

create or replace function get_daily_set(p_subject smallint, p_limit integer default 20)
 returns setof questions language sql stable set search_path to 'public' as $$
  with
  due as (
    select q.*, 0 as prio, rq.due_at::text as k
      from review_queue rq join questions q on q.id = rq.question_id
     where rq.user_id = auth.uid() and rq.due_at <= current_date
       and q.is_active and q.topic_id in (select id from topics where subject_id = p_subject)
  ),
  weak as (
    select t.id as topic_id, coalesce(m.mastery_pct, -1) as pct
      from topics t
      left join topic_mastery m on m.topic_id = t.id and m.user_id = auth.uid()
     where t.subject_id = p_subject
  ),
  fresh as (
    select q.*, 1 as prio, lpad((w.pct + 1)::text, 4, '0') || random()::text as k
      from questions q join weak w on w.topic_id = q.topic_id
     where q.is_active
       and not exists (select 1 from answers a
                        where a.user_id = auth.uid() and a.question_id = q.id
                          and a.answered_at > now() - interval '14 days')
       and not exists (select 1 from due d where d.id = q.id)
  )
  select id, code, topic_id, type, body, image_path, options, correct_answer, difficulty,
         solution, exam_levels, groups, year, source, source_ref, avg_time_sec,
         is_active, created_at, updated_at, solution_image_path
    from (select * from due union all select * from fresh) x
   order by prio, k
   limit p_limit
$$;
