-- Topic results measured against every active question in the topic: 5 right out of 100 is 5%.
-- A question counts once; its latest answer decides whether it is right.
-- topic_mastery stays as it is, because get_daily_set uses it for the daily choice.
create or replace view public.topic_progress with (security_invoker = true) as
with latest as (
  select distinct on (a.user_id, a.question_id) a.user_id, a.question_id, a.is_correct
  from public.answers a
  order by a.user_id, a.question_id, a.answered_at desc, a.id desc
),
totals as (
  select q.topic_id, count(*) as total_questions
  from public.questions q
  where q.is_active
  group by q.topic_id
)
select l.user_id,
  t.subject_id,
  t.id as topic_id,
  t.name as topic_name,
  n.total_questions,
  count(*) as answered,
  count(*) filter (where l.is_correct) as correct
from latest l
join public.questions q on q.id = l.question_id and q.is_active
join public.topics t on t.id = q.topic_id
join totals n on n.topic_id = t.id
group by l.user_id, t.subject_id, t.id, t.name, n.total_questions;

revoke all on public.topic_progress from anon;
grant select on public.topic_progress to authenticated;
