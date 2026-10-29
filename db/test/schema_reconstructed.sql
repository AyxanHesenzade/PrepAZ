-- RECONSTRUCTED from the production introspection dump (2026-10, SQL Editor query by the owner).
-- Tables, constraints, indexes, triggers, functions, view and policies follow the dump exactly.
-- ASSUMED (not in the dump): enum labels and table grants. Used only by local tests.
-- Real enum labels must be confirmed; import_questions.py checks them in the generated SQL before writing.

create type question_type as enum ('qapali', 'aciq_eded', 'yazili');
create type exam_level as enum ('buraxilis', 'qebul');          -- ASSUMED labels
create type session_kind as enum ('mesq', 'sinaq');             -- ASSUMED labels

create table subjects (
  id smallserial primary key,
  slug text not null unique,
  name text not null,
  sort_order smallint not null default 0,
  is_active boolean not null default false
);

create table topics (
  id serial primary key,
  subject_id smallint not null references subjects(id) on delete cascade,
  parent_id integer references topics(id) on delete cascade,
  name text not null,
  sort_order smallint not null default 0,
  unique nulls not distinct (subject_id, parent_id, name)
);
create index topics_subject_id_idx on topics (subject_id);

create table questions (
  id uuid primary key default gen_random_uuid(),
  code text unique,
  topic_id integer not null references topics(id) on delete restrict,
  type question_type not null default 'qapali',
  body text not null,
  image_path text,
  options jsonb,
  correct_answer text not null,
  difficulty smallint not null,
  solution text,
  exam_levels exam_level[] not null default '{}',
  groups smallint[] not null default '{}',
  year smallint,
  source text,
  source_ref text,
  avg_time_sec integer,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint questions_difficulty_check check (difficulty >= 1 and difficulty <= 5),
  constraint qapali_has_options check (type <> 'qapali' or options is not null),
  constraint qapali_answer_in_options check (type <> 'qapali' or options ? correct_answer)
);
create index questions_topic_id_idx on questions (topic_id) where is_active;
create index questions_exam_levels_idx on questions using gin (exam_levels);
create index questions_groups_idx on questions using gin (groups);

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  grade smallint check (grade >= 5 and grade <= 11),
  exam_level exam_level,
  exam_group smallint check (exam_group >= 1 and exam_group <= 5),
  exam_date date,
  target_score smallint,
  daily_minutes smallint not null default 45,
  streak_days integer not null default 0,
  last_active date,
  created_at timestamptz not null default now()
);

create table sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  kind session_kind not null,
  subject_id smallint references subjects(id),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  time_limit_sec integer,
  score numeric
);
create index sessions_user_id_started_at_idx on sessions (user_id, started_at desc);

create table answers (
  id bigserial primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  question_id uuid not null references questions(id) on delete cascade,
  session_id uuid references sessions(id) on delete set null,
  given_answer text,
  is_correct boolean not null default false,
  time_ms integer check (time_ms >= 0),
  answered_at timestamptz not null default now(),
  client_id uuid unique
);
create index answers_user_id_answered_at_idx on answers (user_id, answered_at desc);
create index answers_user_id_question_id_idx on answers (user_id, question_id);

create table review_queue (
  user_id uuid not null references profiles(id) on delete cascade,
  question_id uuid not null references questions(id) on delete cascade,
  due_at date not null,
  interval_days smallint not null default 1,
  streak smallint not null default 0,
  primary key (user_id, question_id)
);
create index review_queue_user_id_due_at_idx on review_queue (user_id, due_at);

create view topic_mastery as
 SELECT a.user_id,
    t.subject_id,
    t.id AS topic_id,
    t.name AS topic_name,
    count(*) AS answered,
    count(*) FILTER (WHERE a.is_correct) AS correct,
    round(((100.0 * (count(*) FILTER (WHERE a.is_correct))::numeric) / (count(*))::numeric), 0) AS mastery_pct
   FROM (( SELECT an.user_id,
            an.is_correct,
            q.topic_id,
            row_number() OVER (PARTITION BY an.user_id, q.topic_id ORDER BY an.answered_at DESC) AS rn
           FROM (answers an
             JOIN questions q ON ((q.id = an.question_id)))) a
     JOIN topics t ON ((t.id = a.topic_id)))
  WHERE (a.rn <= 30)
  GROUP BY a.user_id, t.subject_id, t.id, t.name;

create or replace function touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;

create or replace function check_answer() returns trigger
 language plpgsql security definer set search_path to 'public' as $$
declare
  q questions%rowtype;
  norm_given text;
  norm_right text;
begin
  select * into q from questions where id = new.question_id;
  if q.type = 'yazili' then
    new.is_correct := coalesce(new.is_correct, false);   -- sonradan insan yoxlayır
    return new;
  end if;
  norm_given := upper(regexp_replace(coalesce(new.given_answer, ''), '\s', '', 'g'));
  norm_right := upper(regexp_replace(q.correct_answer, '\s', '', 'g'));
  if q.type = 'aciq_eded' then
    norm_given := replace(norm_given, ',', '.');
    norm_right := replace(norm_right, ',', '.');
    new.is_correct := norm_given ~ '^-?[0-9]+(\.[0-9]+)?$'
                      and norm_given::numeric = norm_right::numeric;
  else
    new.is_correct := norm_given <> '' and norm_given = norm_right;
  end if;
  return new;
end $$;

create or replace function handle_answer() returns trigger
 language plpgsql security definer set search_path to 'public' as $$
declare
  cur  review_queue%rowtype;
  last date;
begin
  -- 1) aralıqlı təkrar
  select * into cur from review_queue
   where user_id = new.user_id and question_id = new.question_id;

  if not new.is_correct then
    insert into review_queue (user_id, question_id, due_at, interval_days, streak)
    values (new.user_id, new.question_id, current_date + 1, 1, 0)
    on conflict (user_id, question_id)
    do update set due_at = current_date + 1, interval_days = 1, streak = 0;
  elsif found then
    if cur.streak + 1 >= 4 then
      delete from review_queue                       -- 4 dəfə ardıcıl düz → öyrənilib
       where user_id = new.user_id and question_id = new.question_id;
    else
      update review_queue
         set streak        = cur.streak + 1,
             interval_days = case cur.interval_days when 1 then 3 when 3 then 7 else 14 end,
             due_at        = current_date + case cur.interval_days when 1 then 3 when 3 then 7 else 14 end
       where user_id = new.user_id and question_id = new.question_id;
    end if;
  end if;

  -- 2) seriya (streak)
  select last_active into last from profiles where id = new.user_id;
  if last is null or last < current_date - 1 then
    update profiles set streak_days = 1, last_active = current_date where id = new.user_id;
  elsif last = current_date - 1 then
    update profiles set streak_days = streak_days + 1, last_active = current_date where id = new.user_id;
  end if;

  return new;
end $$;

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
         is_active, created_at, updated_at
    from (select * from due union all select * from fresh) x
   order by prio, k
   limit p_limit
$$;

create trigger trg_questions_touch before update on questions for each row execute function touch_updated_at();
create trigger trg_answer_check before insert on answers for each row execute function check_answer();
create trigger trg_answer_review after insert on answers for each row execute function handle_answer();

alter table subjects enable row level security;
alter table topics enable row level security;
alter table questions enable row level security;
alter table profiles enable row level security;
alter table sessions enable row level security;
alter table answers enable row level security;
alter table review_queue enable row level security;

create policy "read subjects" on subjects for select to authenticated using (is_active);
create policy "read topics" on topics for select to authenticated using (true);
create policy "read questions" on questions for select to authenticated using (is_active);
create policy "own profile read" on profiles for select to authenticated using (id = auth.uid());
create policy "own profile update" on profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "own sessions" on sessions for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own answers insert" on answers for insert to authenticated with check (user_id = auth.uid());
create policy "own answers read" on answers for select to authenticated using (user_id = auth.uid());
create policy "own reviews" on review_queue for select to authenticated using (user_id = auth.uid());

-- ASSUMED grants (the dump does not list them)
grant select on subjects, topics, questions, topic_mastery, review_queue to authenticated;
grant select, update on profiles to authenticated;
grant select, insert, update on sessions to authenticated;
grant select, insert on answers to authenticated;
grant usage on all sequences in schema public to authenticated;
grant execute on function get_daily_set(smallint, integer) to authenticated;
