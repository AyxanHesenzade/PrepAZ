-- Two more open question types. Numeric answers (aciq_eded) already exist.
--   coxlu_secim:    correct_answer = '135' or '1,3,5'. Order and repeats do not matter.
--   uygunlasdirma:  correct_answer = 'E;A;BC' (rows by position, ';' between rows).
--                   options = {"1": "ABCDE", "2": "ABCDE", "3": "ABCDE"} (row -> letters offered).
-- Safe to run twice. The new enum labels are only compared as text here, so one transaction is enough.

alter type question_type add value if not exists 'coxlu_secim';
alter type question_type add value if not exists 'uygunlasdirma';

create or replace function sorted_chars(p text) returns text
 language sql immutable set search_path to 'public' as $$
  select coalesce(string_agg(c, '' order by c), '')
    from (select distinct c from regexp_split_to_table(coalesce(p, ''), '') as c where c <> '') s
$$;

create or replace function normalize_matching(p text) returns text
 language sql immutable set search_path to 'public' as $$
  select string_agg(sorted_chars(regexp_replace(r.part, '[^A-Z]', '', 'g')), ';' order by r.n)
    from regexp_split_to_table(coalesce(p, ''), ';') with ordinality as r(part, n)
$$;

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
    new.is_correct := case when norm_given ~ '^-?[0-9]+(\.[0-9]+)?$'
                           then norm_given::numeric = norm_right::numeric
                           else false end;
  elsif q.type::text = 'coxlu_secim' then
    norm_given := sorted_chars(regexp_replace(norm_given, '[^0-9]', '', 'g'));
    norm_right := sorted_chars(regexp_replace(norm_right, '[^0-9]', '', 'g'));
    new.is_correct := norm_given <> '' and norm_given = norm_right;
  elsif q.type::text = 'uygunlasdirma' then
    new.is_correct := norm_given ~ '[A-Z]' and normalize_matching(norm_given) = normalize_matching(norm_right);
  else
    new.is_correct := norm_given <> '' and norm_given = norm_right;
  end if;
  return new;
end $$;
