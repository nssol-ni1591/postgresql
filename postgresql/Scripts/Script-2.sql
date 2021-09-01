drop procedure if exists test2(text);
drop procedure test2(text);

create or replace PROCEDURE test2(IN name text) as $$
declare male TEXT;
declare female TEXT;
DECLARE SQL TEXT;
begin
	SQL := 'select k.moderator_female, k.moderator_male INTO male, female from ' || name || ' k';
	execute sql;
	RAISE INFO 'msg：%, %', male, female;
end;
$$ language plpgsql;

CREATE OR REPLACE PROCEDURE test2(IN name text) as $$
--DECLARE cur CURSOR FOR SELECT * FROM name;
--DECLARE rec record;
DECLARE
	cur CURSOR FOR SELECT * FROM kohaku;
	rec record;
BEGIN
	FOR rec IN cur LOOP
		RAISE INFO '% : % : %', rec.timeid, rec.broadcastdate, rec.winner;
		IF rec.winner = '10' THEN 
			INSERT INTO kohaku2 values(rec.timeid, rec.broadcastdate, 'MALE');
		ELSE 
			INSERT INTO kohaku2 values(rec.timeid, rec.broadcastdate, 'FEMALE');
		END IF;
	END LOOP;
EXCEPTION 
  WHEN undefined_table THEN 
  RAISE EXCEPTION 'ストアド内でエラーが発生しました。'
    using detail = 'パラメーター: ' || name;
END;
$$ language plpgsql;

CREATE OR REPLACE PROCEDURE test2(IN name text) as $$
DECLARE
	st TEXT;
	st2 TEXT;
	rec record;
	cur refCURSOR;
BEGIN
--
--	結果を格納するテーブルの初期化
--	st := 'delete ' || name;
--	EXECUTE st;
--	EXECUTE 'delete from kohaku2';
--
--	deleteは効率が悪いのでtruncateを使う
	EXECUTE 'truncate kohaku2';
--
--	動的SQL
	st := 'SELECT * FROM ' || name;
--	OPEN cur FOR EXECUTE st;
--	FOR rec IN cur LOOP
--
--  暗黙のカーソルを使用
	FOR rec IN EXECUTE st LOOP
		RAISE INFO '% : % : %', rec.timeid, rec.broadcastdate, rec.winner;
--
--	winnerを変換して結果テーブルに格納
		IF rec.winner = '10' THEN 
			INSERT INTO kohaku2 values(rec.timeid, rec.broadcastdate, 'MALE');
		ELSE 
			INSERT INTO kohaku2 values(rec.timeid, rec.broadcastdate, 'FEMALE');
		END IF;
	END LOOP;
--	CLOSE cur;
EXCEPTION 
  WHEN undefined_table THEN 
  RAISE EXCEPTION 'ストアド内でエラーが発生しました。'
    using detail = 'パラメーター: ' || name;
END;
$$ language plpgsql;

call test2 ('kohaku');
SELECT * FROM kohaku2;
SELECT * FROM t_kohaku;

CREATE OR REPLACE PROCEDURE test2(IN name text) as $$
DECLARE
	st TEXT;
	st2 TEXT;
	rec record;
	cur refCURSOR;
BEGIN
--
--	結果を一時テーブルに格納するためtempテーブルの準備
	DROP TABLE if EXISTS t_kohaku;
	CREATE TEMP TABLE t_kohaku (id integer, date date, winner varchar(10));
--
--	動的SQL
--	※EXECUTEのusingはテーブルには使用できない
--	selectのcase に変換を行う caseには条件も使用可
	st := 'SELECT timeid, broadcastdate as date,
		case winner
			when ''10'' then ''male''
			when ''20'' then ''female''
			else ''foo''
		end as winner
		FROM ' || name;
	FOR rec IN EXECUTE st LOOP
		INSERT INTO t_kohaku values(rec.timeid, rec.date, rec.winner);
	END LOOP;
--
--	結果テーブルの出力
--	group by を使ってみる
	st := 'SELECT winner, 
			count(*) as c, 
			max(date) as max, 
			min(date) as min 
		FROM t_kohaku GROUP BY winner';
	FOR rec IN EXECUTE st LOOP
		RAISE INFO '% : % : % - %', rec.winner, rec.c, rec.min, rec.max;
	END LOOP;
EXCEPTION 
	WHEN undefined_table THEN 
		RAISE EXCEPTION 'ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || name;
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'data not found in [%]', name;
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'not unique in [%]', myname;
END;
$$ language plpgsql;


SELECT winner, count(winner) FROM kohaku2 GROUP BY winner;

drop table kohaku2;
create table kohaku2(
    id integer not null primary key,  /** 開催回 */
    date date not null,   /** 放送日 */
    winner varchar(10)               /** 勝者 */
);

SELECT timeid, broadcastdate, winner FROM kohaku;

SELECT timeid,
		broadcastdate,
		case winner
			when '10' then 'male'
			when '20' then 'female'
			else 'foo'
		end
	FROM kohaku;

/*
 * 既存の行を置き換えてマージ操作を実現する
 * https://docs.aws.amazon.com/ja_jp/redshift/latest/dg/merge-replacing-existing-rows.html
 */

CREATE OR REPLACE PROCEDURE test2(IN name text) as $$
DECLARE
	st TEXT;
	rec record;
	cur refCURSOR;
BEGIN
--
--	結果を一時テーブルに格納するためtempテーブルの準備
	DROP TABLE if EXISTS t_kohaku;
	CREATE TEMP TABLE t_kohaku (LIKE kohaku, win varchar(10));
--
--	WHEN winner = '10' then win := 'MALE', WHEN winner = '20' then win := 'FEMALE'
--	INSERT INTO t_kohaku SELECT *, 'MALE'   FROM kohaku WHERE winner = '10';
--	INSERT INTO t_kohaku SELECT *, 'FEMALE' FROM kohaku WHERE winner = '20';
--
--	selectのcase に変換を行う caseには条件も使用可
	INSERT INTO t_kohaku
		SELECT *,
			case winner
				when '10' then 'MALE'
				when '20' then 'FEMALE'
				else 'foo'
			END
		FROM kohaku;
--
--	結果テーブルの出力
--	group by を使ってみる
	st := 'SELECT win, 
			count(*) as c, 
			max(broadcastdate) as max, 
			min(broadcastdate) as min 
		FROM t_kohaku GROUP BY win';
	FOR rec IN EXECUTE st LOOP
		RAISE INFO '% : % : % - %', rec.win, rec.c, rec.min, rec.max;
	END LOOP;
--	DROP TABLE if EXISTS t_kohaku;
EXCEPTION 
	WHEN undefined_table THEN 
		RAISE EXCEPTION 'ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || name;
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'data not found in [%]', name;
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'not unique in [%]', name;
END;
$$ language plpgsql;

call test2 ('kohaku');

