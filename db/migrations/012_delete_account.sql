-- Lets a signed-in user delete their own account. Their profile, answers, review queue,
-- goals, reports and consent rows go with it through "on delete cascade".
-- Admins are refused so that nobody loses panel access by accident.
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
begin
  if me is null then
    raise exception 'not_signed_in';
  end if;
  if exists (select 1 from public.admins where user_id = me) then
    raise exception 'admin_account';
  end if;
  delete from auth.users where id = me;
end $$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
