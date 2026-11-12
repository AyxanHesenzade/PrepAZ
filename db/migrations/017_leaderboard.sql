-- Leaderboard ("Yarış"): per subject, this week and all time.
-- A player joins once with a unique nickname plus first and last name.
-- Only the nickname is ever shown to other users; first/last name stay private (owner + admin).
-- Score = number of distinct active questions the user has answered correctly at least once.
-- Weekly score counts a question only if its FIRST correct answer falls in this week (Asia/Baku, Monday start),
-- so re-solving the same questions never adds points.
-- Requires 005_admin_panel.sql (is_admin()). Safe to run twice.

create table if not exists public.leaderboard_players (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  nickname text not null
    check (nickname ~ '^[A-Za-z0-9_.ƏəÜüÖöĞğİıŞşÇç]{3,20}$'),
  first_name text not null check (char_length(btrim(first_name)) between 2 and 40),
  last_name text not null check (char_length(btrim(last_name)) between 2 and 40),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- "Ali" and "ali" are the same nickname
create unique index if not exists leaderboard_players_nickname_key
  on public.leaderboard_players (lower(nickname));

drop trigger if exists trg_leaderboard_players_touch on public.leaderboard_players;
create trigger trg_leaderboard_players_touch before update on public.leaderboard_players
  for each row execute function touch_updated_at();

alter table public.leaderboard_players enable row level security;

drop policy if exists leaderboard_players_select on public.leaderboard_players;
create policy leaderboard_players_select on public.leaderboard_players
  for select to authenticated using (user_id = auth.uid() or public.is_admin());

drop policy if exists leaderboard_players_insert on public.leaderboard_players;
create policy leaderboard_players_insert on public.leaderboard_players
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists leaderboard_players_update on public.leaderboard_players;
create policy leaderboard_players_update on public.leaderboard_players
  for update to authenticated
  using (user_id = auth.uid() or public.is_admin())
  with check (user_id = auth.uid() or public.is_admin());

-- no delete policy: the row goes away with the account (cascade from auth.users)
revoke all on public.leaderboard_players from anon, authenticated;
grant select, insert, update on public.leaderboard_players to authenticated;

-- Top p_limit players (max 100) plus the caller's own row when it is outside the top.
-- Ties: whoever reached the score first ranks higher.
create or replace function public.get_leaderboard(
  p_subject smallint,
  p_period text default 'week',
  p_limit integer default 50
)
returns table (rank bigint, nickname text, score bigint, is_me boolean)
language sql stable security definer set search_path = public as $$
  with since as (
    select case when p_period = 'week'
      then date_trunc('week', now() at time zone 'Asia/Baku') at time zone 'Asia/Baku'
      else '-infinity'::timestamptz
    end as t
  ),
  firsts as (
    select a.user_id, a.question_id, min(a.answered_at) as at
    from answers a
    join questions q on q.id = a.question_id and q.is_active
    join topics tp on tp.id = q.topic_id and tp.subject_id = p_subject
    where a.is_correct
    group by a.user_id, a.question_id
  ),
  scores as (
    select f.user_id, count(*) as score, max(f.at) as reached_at
    from firsts f, since s
    where f.at >= s.t
    group by f.user_id
  ),
  ranked as (
    select row_number() over (order by sc.score desc, sc.reached_at asc, lower(p.nickname)) as rank,
      p.nickname, sc.score, p.user_id = auth.uid() as is_me
    from scores sc
    join leaderboard_players p on p.user_id = sc.user_id
  )
  select r.rank, r.nickname, r.score, r.is_me
  from ranked r
  where auth.uid() is not null
    and (r.rank <= least(greatest(p_limit, 1), 100) or r.is_me)
  order by r.rank;
$$;

revoke all on function public.get_leaderboard(smallint, text, integer) from public, anon;
grant execute on function public.get_leaderboard(smallint, text, integer) to authenticated;
