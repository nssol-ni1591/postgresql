-- データロード
truncate kohaku;
copy kohaku from '/tmp/kohaku.txt' (format csv, delimiter '|', quote '''') ;
select * from kohaku;

drop function if exists test(text);

create or replace function test(in name text)
returns table(
	female text,
	male text
) as $$
declare rec record;
declare sql TEXT;
begin
	sql := 'select k.moderator_female, k.moderator_male from ' || name || ' k';
	for rec in
		execute sql
--		select  k.moderator_female, k.moderator_male from kohaku k
	loop
		female := rec.moderator_female;
		male := rec.moderator_male;
		return next;
	end loop;
return;
exception
  when undefined_table then
  raise exception 'ストアド内でエラーが発生しました。'
    using detail = 'パラメーター: ' || name;
end;
$$ language plpgsql;


select test ('kohaku');
select test ('abc');

select * from test ('abc');

select * from test ('kohaku');

select moderator_female, moderator_male from kohaku;

SELECT k.moderator_female FROM kohaku k ;

