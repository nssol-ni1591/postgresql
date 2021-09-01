drop function tblrecct();

-- raiseで表名とレコード数を出力
CREATE OR replace FUNCTION tblrecct() RETURNS int AS $$
DECLARE
	rec record;
	cu refcursor;
	rec2 record;
	ct int;
	rcd int := 0;
BEGIN
	FOR rec IN
--  	select * from pg_tables where not tablename like 'pg%' AND not tablename like 'sql_%'
		SELECT * FROM pg_tables WHERE NOT tablename LIKE 'sql_%'
			ORDER BY tableowner, tablename LOOP
		OPEN cu FOR EXECUTE 'select count(*) as ct from ' || rec.tablename;
		FETCH cu INTO rec2;
		IF NOT FOUND THEN
			ct := 0;
		ELSE
			ct := rec2.ct;
		END IF;
		CLOSE cu;
		rcd := rcd + 1;
		RAISE INFO '[%] tablename=[%] rows=[%]', rcd, rec.tablename, ct;
		RAISE debug 'tablename= %  ct= %', rec.tablename, ct;
	END LOOP;
	RETURN rcd;
EXCEPTION
	WHEN undefined_table THEN
	RAISE EXCEPTION 'ストアド内でエラーが発生しました。'
		USING detail = 'パラメーター: ' || rec.tablename;
END;
$$ LANGUAGE plpgsql;

SELECT tblrecct();
SELECT 'rcd=[' || tblrecct() || ']';


DROP FUNCTION tblrecct2() ;

CREATE OR REPLACE FUNCTION tblrecct2() 
RETURNS table (schema TEXT, name text, count int) AS $$
DECLARE
	rec record;
	num int;	-- レコード数
	ix int := 0;	-- テーブル数
BEGIN
--
	FOR rec IN SELECT * FROM pg_tables 
		WHERE NOT tablename LIKE 'sql_%' ORDER BY tableowner, tablename loop
-- into句を使用することで、実行結果を直接変数に代入する
		EXECUTE 'select count(*) as ct from ' || rec.tablename
			INTO num;
/*
		OPEN cu FOR EXECUTE 'select count(*) as ct from ' || rec.tablename;
		FETCH cu INTO rec2;
		IF NOT FOUND THEN
			ct := 0;
		ELSE
			ct := rec2.ct;
		END IF;
		CLOSE cu;
*/
		ix := ix + 1;
		RAISE INFO '[%] tablename=[%] rows=[%]', ix, rec.tablename, num;
		schema := rec.schemaname;
		name := rec.tablename;
		count := num;
		RETURN NEXT;
	END LOOP;
	RAISE INFO 'finished tblrecct2() table_num=[%]', ix;
	RETURN ;
EXCEPTION
	WHEN undefined_table THEN
	RAISE EXCEPTION 'ストアド内でエラーが発生しました。'
		USING detail = 'テーブル名: ' || rec.tablename;
END;
$$ LANGUAGE plpgsql;

SELECT tblrecct2();
SELECT * from tblrecct2();

SELECT * FROM pg_tables;
SELECT * FROM pg_tables WHERE tablename like 't_%';

DROP TABLE pg_temp_8.t_kohaku;
