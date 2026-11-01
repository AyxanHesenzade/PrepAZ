-- Who accepted which version of the terms and privacy policy, and when.
-- Written after sign-in; the time comes from the server and rows cannot be changed.
create table if not exists public.legal_acceptances (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  version smallint not null check (version > 0),
  accepted_at timestamptz not null default now(),
  primary key (user_id, version)
);

alter table public.legal_acceptances enable row level security;

revoke all on public.legal_acceptances from authenticated;
grant select on public.legal_acceptances to authenticated;
grant insert (user_id, version) on public.legal_acceptances to authenticated;

drop policy if exists "own acceptance read" on public.legal_acceptances;
create policy "own acceptance read" on public.legal_acceptances
  for select to authenticated using (user_id = auth.uid() or public.is_admin());

drop policy if exists "own acceptance add" on public.legal_acceptances;
create policy "own acceptance add" on public.legal_acceptances
  for insert to authenticated with check (user_id = auth.uid());
