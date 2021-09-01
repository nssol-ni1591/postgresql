-- csv出力

\COPY ({SQL文(SELECT文)}) TO '{出力先csvファイルのフルパス}' WITH CSV DELIMITER ',' HEADER
\COPY kohaku TO stdout WITH CSV DELIMITER '|'

-- カラム名のcsv出力
SELECT * FROM information_schema.COLUMNS WHERE table_name = 'kohaku';

psql -d testdb -U postgres -c 'select * from kohaku;' -A -F'|' -t
psql -d testdb -U postgres -c "copy kohaku to stdout (format csv, delimiter '|')"

psql -d testdb -U postgres -c "SELECT table_name, column_name FROM information_schema.COLUMNS WHERE table_name = 'kohaku';" -A -F'.' -t


-- テーブルのカラム名を出力
CREATE OR REPLACE FUNCTION col_list(IN table_name TEXT)
RETURNS TABLE (
	col_name TEXT
) AS $$
DECLARE
	rec record;
	st TEXT;
BEGIN
-- where句ではパラメータ置換、
	st := 'SELECT table_name, column_name FROM information_schema.COLUMNS WHERE table_name = $1';
	RAISE info 'statemante=[%]', st;
	FOR rec IN EXECUTE st USING table_name LOOP
		col_name := rec.table_name || '.' || rec.column_name;
		RETURN NEXT;
	END LOOP;
EXCEPTION
	WHEN undefined_table THEN
		RAISE EXCEPTION 'col_list: ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || table_name;
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'data not found in [%]', table_name;
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'not unique in [%]', table_name;
	WHEN OTHERS THEN
		RAISE INFO 'col_list: SQLSTATE=[%] SQLERRM=[%]', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM col_list('kohaku');

psql -d testdb -U postgres -c "select col_list('kohaku')" -A

-- テーブルのカラムを','で結合した文字列に変換する
CREATE OR REPLACE FUNCTION col_list2(IN table_name TEXT)
RETURNS TEXT AS $$
DECLARE
	rec record;
	str TEXT := '';
	a TEXT[];
BEGIN
	EXECUTE 'select array_agg(col_list) from col_list($1)' USING table_name INTO a;
	SELECT array_to_string(a, ',') INTO str;
	RETURN str;
EXCEPTION 
	WHEN undefined_table THEN 
		RAISE EXCEPTION 'col_list2: ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || table_name;
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'data not found in [%]', table_name;
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'not unique in [%]', table_name;
	WHEN OTHERS THEN
		RAISE INFO 'col_list2: SQLSTATE=[%] SQLERRM=[%]', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

select array_agg(col_list) from col_list('kohaku');
select col_list2('kohaku');

-- テーブルのカラムを表示するselect文を生成する
CREATE OR REPLACE FUNCTION col_list3(IN table_name TEXT)
RETURNS TEXT AS $$
DECLARE
	rec record;
--	str TEXT;
	str2 TEXT;
BEGIN
--	SELECT * INTO str FROM col_list2(table_name);
--	str2 := 'select ' || str || ' from ' || table_name;
	str2 := 'select ' 
		|| (SELECT * FROM col_list2(table_name))
		|| ' from ' || table_name;
--
--	RAISE info 'sql=[%]', str2;
--	FOR rec IN EXECUTE str2 LOOP
--		RAISE info 'rec=[%]', rec;
--	END LOOP;
	RETURN str2;
EXCEPTION 
	WHEN undefined_table THEN 
		RAISE EXCEPTION 'col_list3: ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || table_name;
	WHEN NO_DATA_FOUND THEN
		RAISE EXCEPTION 'data not found in [%]', table_name;
	WHEN TOO_MANY_ROWS THEN
		RAISE EXCEPTION 'not unique in [%]', table_name;
	WHEN OTHERS THEN
		RAISE INFO 'col_list3: SQLSTATE=[%] SQLERRM=[%]', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;

select col_list3('kohaku');


-- 指定されたテーブルの一部のカラム（固定）を表示するselectを実行する
DROP FUNCTION col_list4(text);
CREATE OR REPLACE FUNCTION col_list4(IN table_name TEXT)
RETURNS TABLE (
	id int,
	b_date date,
	winner CHARACTER(2)
) AS $$
DECLARE
	rec record;
BEGIN
-- 以下はNG ... FORの場合はINにrefcursorは使用できない => OPENとFORは組み合わせて使用できない?
--	OPEN cur FOR SELECT * FROM kohaku;
--	SQLエラー [42601]: ERROR: cursor FOR loop must use a bound cursor variable
-- 以下はOK
--	FOR rec IN SELECT * FROM kohaku LOOP
--		RAISE info 'rec=[%]', rec;
--	END LOOP;
	FOR rec IN EXECUTE col_list3(table_name) LOOP
--		RAISE info 'rec=[%]', rec;
		id := rec.timeid;
		b_date := rec.broadcastdate;
		winner := rec.winner;
		RETURN NEXT;
	END LOOP;
EXCEPTION 
	WHEN undefined_table THEN 
		RAISE EXCEPTION 'col_list4: ストアド内でエラーが発生しました。' using detail = 'パラメーター: ' || table_name;
END;
$$ LANGUAGE plpgsql;

select col_list4('kohaku');
select col_list4('abc');


-- refcursorで返却（自動カーソル生成）
-- refcursorを使用する場合はトランザクション内で実行する必要がある
CREATE OR REPLACE FUNCTION col_list5(IN table_name TEXT)
RETURNS refcursor AS $$
DECLARE
	cur refcursor;
	st TEXT;
BEGIN
	EXECUTE 'SELECT col_list3($1)' INTO st USING table_name;
	OPEN cur FOR EXECUTE st;
	RETURN cur;
END;
$$ LANGUAGE plpgsql;


testdb=*# begin;
BEGIN
testdb=*# select col_list5('kohaku');
INFO:  statemante=[SELECT table_name, column_name FROM information_schema.COLUMNS WHERE table_name = $1]
INFO:  sql=[select kohaku.timeid,kohaku.broadcastdate,kohaku.moderator_female,kohaku.moderator_male,kohaku.finalist_female,kohaku.finalist_male,kohaku.winner,kohaku.get_record,kohaku.viewership from kohaku]
      col_list5
---------------------
 <unnamed portal 39>
(1 row)

testdb=*# fetch all in "<unnamed portal 39>";
 timeid | broadcastdate | moderator_female | moderator_male | finalist_female  |
 finalist_male | winner | get_record | viewership
--------+---------------+------------------+----------------+------------------+
---------------+--------+------------+------------
      1 | 1951-01-03    | 加藤道子         | 藤倉修一       | 渡辺はま子       |
 藤山一郎      | 20     | f          |        0.0
      2 | 1952-01-03    | 丹下キヨ子       | 宮田輝         | 渡辺はま子       |
 藤山一郎      | 20     | f          |        0.0
      3 | 1953-01-02    | 本田寿賀         | 高橋圭三       | 笠置シヅ子       |
 灰田勝彦      | 20     | f          |        0.0
      4 | 1953-12-31    | 水の江瀧子       | 高橋圭三       | 淡谷のり子       |
 藤山一郎      | 10     | f          |        0.0
      5 | 1954-12-31    | 福士夏江         | 高橋圭三       | 渡辺はま子       |
 霧島昇        | 10     | f          |        0.0
      6 | 1955-12-31    | 宮田輝           | 高橋圭三       | 二葉あき子       |
 藤山一郎      | 10     | f          |        0.0
      7 | 1956-12-31    | 宮田輝           | 高橋圭三       | 笠置シヅ子       |
 灰田勝彦      | 20     | f          |        0.0
      8 | 1957-12-31    | 水の江瀧子       | 高橋圭三       | 美空ひばり       |
 三橋美智也    | 10     | f          |        0.0
      9 | 1958-12-31    | 黒柳徹子         | 高橋圭三       | 美空ひばり       |
 三橋美智也    | 10     | f          |        0.0
     10 | 1959-12-31    | 中村メイコ       | 高橋圭三       | 美空ひばり       |
testdb=*# abort;
ROLLBACK
testdb=#


-- refcursorで返却（カーソル名を指定）
-- refcursorを使用する場合はトランザクション内で実行する必要がある
CREATE OR REPLACE FUNCTION col_list6(IN table_name TEXT, IN refcursor)
RETURNS refcursor AS $$
DECLARE
	st TEXT;
BEGIN
	EXECUTE 'SELECT col_list3($1)' INTO st USING table_name;
	OPEN $2 FOR EXECUTE st;
	RETURN $2;
END;
$$ LANGUAGE plpgsql;

\pset pager OFF
begin;
select col_list6('kohaku', 'cur');
fetch all in cur;
ABORT;

DROP FUNCTION print_col(TEXT);
CREATE OR REPLACE PROCEDURE print_col(IN table_name TEXT) AS $$
DECLARE
	rec record;
--	rec1 record;
--	rec2 record;
--	rec3 record;
--	rec4 record;
--	rec5 record;
--	rec6 record;
--	rec7 record;
--
	cur1 refcursor;
-- ここは宣言なのでEXECUTEは使用できない
	cur2 CURSOR FOR SELECT * FROM kohaku LIMIT 5 OFFSET 5;
	cur3 CURSOR FOR SELECT * FROM kohaku LIMIT 5 OFFSET 10;
-- col_list5()はカーソルを生成するのでCURSOR FORは使用できない
	cur4 REFCURSOR;
	cur5 REFCURSOR;
	cur6 REFCURSOR;
	cur7 REFCURSOR ;
	st TEXT;
	ix int;
BEGIN
-- col_list5()はカーソルを返却するので、FORやOPEN CURSORは使用できない
-- なので、EXECUTE INTOで直接refcursorに代入してFETCHで使用する
	RAISE info '(1) --------------------------------';
	EXECUTE 'select col_list5($1)' INTO cur1 USING table_name;
	ix := 1;
	LOOP 
		FETCH cur1 INTO rec;
		IF NOT FOUND THEN
			EXIT;
		END IF;
		IF ix > 5 THEN 
			EXIT;
		END IF;
		RAISE info 'rec1=[%]', rec;
		ix := ix + 1;
	END LOOP;
	CLOSE cur1;
--
-- バウンドカーソルをLOOP FETCHで使用する
	RAISE info '(2) --------------------------------';
	OPEN cur2;
	LOOP 
		FETCH cur2 INTO rec;
		IF NOT FOUND THEN
			EXIT;
		END IF;
		RAISE info 'rec2=[%]', rec;
	END LOOP;
	CLOSE cur2;
--
-- バウンドカーソルをFOR INで使用する
	RAISE info '(3) --------------------------------';
	FOR rec IN cur3 LOOP 
		RAISE info 'rec3=[%]', rec;
	END LOOP;
--
-- ResultSetをOPEN CURSORで使用する
	RAISE info '(4) --------------------------------';
	EXECUTE 'select col_list3($1)' USING table_name INTO st;
	OPEN cur4 FOR EXECUTE st || ' LIMIT 5 OFFSET 15';
	LOOP 
		FETCH cur4 INTO rec;
		IF NOT FOUND THEN
			EXIT;
		END IF;
		RAISE info 'rec4=[%]', rec;
	END LOOP;
	CLOSE cur4;
--
-- ResultSetをFORで使用する
	RAISE info '(5) --------------------------------';
	EXECUTE 'SELECT col_list3($1)' INTO st USING table_name, '5';
	FOR rec IN EXECUTE st || ' LIMIT 5 OFFSET 20' LOOP
		RAISE info 'rec5=[%]', rec;
	END LOOP;
--
--
--	RAISE info '(7) --------------------------------';
--
-- エラーになるパターン：
-- SQLエラー [42601]: ERROR: cursor FOR loop must use a bound cursor variable
-- (a)EXECUTE結果をrefcursorに代入した変数をFORで使用することはできない
--	FOR rec1 IN cur1 LOOP 
--		RAISE info 'rec1=[%]', rec1;
--	END LOOP;
-- (b)FOR INにREFCURSORを使用できない（CURSORは使用可能）
--	OPEN cur7 FOR SELECT * FROM kohaku;
--	FOR rec7 IN cur7 LOOP 
--		RAISE info 'rec7=[%]', rec7;
--	END LOOP;
--
	RAISE info '(END)';
EXCEPTION 
	WHEN OTHERS THEN
		RAISE INFO 'SQLSTATE=[%] SQLERRM=[%]', SQLSTATE, SQLERRM;
END;
$$ LANGUAGE plpgsql;
