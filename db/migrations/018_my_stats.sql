-- "İrəliləyiş" tab: the caller's own statistics for one subject, computed on the server.
-- Days are counted in Asia/Baku time. Only the caller's answers are read (security invoker + RLS + explicit filter).
--   answered / correct      every answer in the subject (repeats included)
--   questions_tried/solved  distinct ACTIVE questions; the latest answer decides "solved"
--   questions_total         active questions in the subject; topics_total = topics that have one
--   best_streak             longest run of consecutive days with at least one answer (all subjects)
--   days                    the last p_days days (1..31, oldest first), zero days included
-- Safe to run twice.

create or replace function public.get_my_stats(p_subject smallint, p_days integer default 14)
returns jsonb
language sql stable security invoker set search_path = public as $$
  with mine as (
    select a.question_id, a.is_correct, a.answered_at, q.is_active,
           (a.answered_at at time zone 'Asia/Baku')::date as day
    from answers a
    join questions q on q.id = a.question_id
    join topics t on t.id = q.topic_id and t.subject_id = p_subject
    where a.user_id = auth.uid()
  ),
  latest as (
    select distinct on (m.question_id) m.question_id, m.is_correct
    from mine m
    where m.is_active
    order by m.question_id, m.answered_at desc
  ),
  span as (
    select (now() at time zone 'Asia/Baku')::date - g as day
    from generate_series(0, least(greatest(coalesce(p_days, 14), 1), 31) - 1) as g
  ),
  daily as (
    select s.day,
           count(m.question_id) as answered,
           count(m.question_id) filter (where m.is_correct) as correct
    from span s
    left join mine m on m.day = s.day
    group by s.day
  ),
  active_days as (
    select distinct (a.answered_at at time zone 'Asia/Baku')::date as day
    from answers a
    where a.user_id = auth.uid()
  ),
  runs as (
    select count(*) as len
    from (select d.day - (row_number() over (order by d.day))::integer as grp from active_days d) x
    group by x.grp
  ),
  bank as (
    select count(*) as questions, count(distinct q.topic_id) as topics
    from questions q
    join topics t on t.id = q.topic_id and t.subject_id = p_subject
    where q.is_active
  )
  select jsonb_build_object(
    'answered', (select count(*) from mine),
    'correct', (select count(*) from mine where is_correct),
    'questions_tried', (select count(*) from latest),
    'questions_solved', (select count(*) from latest where is_correct),
    'questions_total', (select questions from bank),
    'topics_total', (select topics from bank),
    'best_streak', coalesce((select max(len) from runs), 0),
    'days', coalesce(
      (select jsonb_agg(jsonb_build_object('day', d.day, 'answered', d.answered, 'correct', d.correct)
                        order by d.day)
         from daily d),
      '[]'::jsonb)
  )
  where auth.uid() is not null;
$$;

revoke all on function public.get_my_stats(smallint, integer) from public, anon;
grant execute on function public.get_my_stats(smallint, integer) to authenticated;
