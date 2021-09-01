-- 既存のテーブルからCREATE文の生成

SELECT * FROM information_schema.COLUMNS WHERE table_name = 'kohaku';

-- 既存テーブルと同じ定義の異なるテーブル名のCREATE文を生成する
DROP FUNCTION make_table(TEXT, TEXT);
CREATE OR REPLACE FUNCTION make_table(IN table_name TEXT, IN new_name TEXT)
RETURNS TABLE (
	st TEXT
) AS $$
DECLARE
--	flag boolean := FALSE;
	rec record;
--	col_name TEXT;
--	col_type TEXT;
--	col_opt  TEXT;
	tmp TEXT;
BEGIN
	st := 'drop table if exists ' || new_name || ';';
	RETURN NEXT;
	st := 'create table ' || new_name || ' (';
	RETURN NEXT;
--
	st := '    ';
	FOR rec IN EXECUTE 'SELECT * FROM information_schema.COLUMNS WHERE table_name = $1'
		USING table_name LOOP
-- 文字列の結合
--	連結要素にNULLが含まれる場合、"||"による結合は結果が"NULL"になるので条件判定が必要
--	concat(...)で結合する場合、NULLは無視されるので無条件に実行できる
--
-- column_name
--		col_name := rec.column_name;
		st := concat(st, rec.column_name);
--		RAISE info 'st=[%]', st;
-- data_type
		IF rec.data_type = 'character' THEN
--			col_type := 'char(' || rec.character_maximum_length || ')';
--			st := concat(st, ' char(' || rec.character_maximum_length || ')');
			st := concat(st, ' char(', rec.character_maximum_length, ')');
		ELSIF rec.data_type = 'character varying' THEN
--			col_type := 'varchar(' || rec.character_maximum_length || ')';
--			st := concat(st, ' varchar(' || rec.character_maximum_length || ')');
			st := concat(st, ' varchar(', rec.character_maximum_length, ')');
		ELSIF rec.data_type = 'numeric' THEN
--			col_type := 'decimal(' || rec.numeric_precision || ',' || rec.numeric_scale || ')';
--			st := concat(st, ' decimal(' || rec.numeric_precision || ',' || rec.numeric_scale || ')');
			st := concat(st, ' decimal(', rec.numeric_precision, ',', rec.numeric_scale, ')');
		ELSE
--			col_type := rec.data_type;
			st := concat(st, ' ', rec.data_type);
		END IF;
--　NOT NULL
--		col_opt := '';
		IF rec.is_nullable = 'NO' THEN
--			col_opt := col_opt || ' NOT NULL';
			st := concat(st, ' NOT NULL');
		END IF;
--　xxx KEY
		EXECUTE 'SELECT tc.constraint_type
			FROM information_schema.table_constraints tc
			INNER JOIN information_schema.constraint_column_usage ccu
				ON (tc.table_catalog=ccu.table_catalog
				and tc.table_schema=ccu.table_schema
				and tc.table_name=ccu.table_name
				and tc.constraint_name=ccu.constraint_name)
			WHERE tc.table_catalog=$1
			  and tc.table_schema=$2
			  and tc.table_name=$3
			  and ccu.column_name=$4'
			INTO tmp
			USING rec.table_catalog, rec.table_schema, rec.table_name, rec.column_name;
--		IF tmp IS NOT NULL THEN
--			col_opt := col_opt || ' ' || tmp;
			st := concat(st, ' ', tmp);
--		END IF;
--		st := st || col_name || ' ' || col_type || col_opt;
--		RAISE info 'st=[%]', st;
		RETURN NEXT;
-- 初期化
		st := '  , ';
	END LOOP;
	st := ');';
	RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION make_table(TEXT);
CREATE OR REPLACE FUNCTION make_table(IN table_name TEXT)
RETURNS TABLE (
	st TEXT
) AS $$
DECLARE
	rec record;
BEGIN
	FOR rec IN SELECT * FROM make_table(table_name, table_name) LOOP
		st := rec.st;
		RETURN NEXT;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

select * from make_table('kohaku');
select * from make_table('kohaku', 'kohaku3');
select * from make_table('listing', 'kohaku3');

SELECT ccu.column_name as COLUMN_NAME
	FROM information_schema.table_constraints tc
	INNER JOIN information_schema.constraint_column_usage ccu
		ON (tc.table_catalog=ccu.table_catalog
		and tc.table_schema=ccu.table_schema
		and tc.table_name=ccu.table_name
		and tc.constraint_name=ccu.constraint_name)
	WHERE tc.table_catalog='データベース名'
	  and tc.table_schema='スキーマ名'
	  and tc.table_name='テーブル名'
	  and tc.constraint_type='PRIMARY KEY'
;

SELECT ccu.column_name as COLUMN_NAME, tc.constraint_type
  FROM information_schema.table_constraints tc
    INNER JOIN information_schema.constraint_column_usage ccu
	    ON (tc.table_catalog=ccu.table_catalog
		and tc.table_schema=ccu.table_schema
		and tc.table_name=ccu.table_name
		and tc.constraint_name=ccu.constraint_name
		)
  WHERE tc.table_catalog='testdb'
	and tc.table_schema='public'
	and tc.table_name='kohaku'
--	and tc.constraint_type='PRIMARY KEY'
;


select * from `information_schema`.table_constraints
where
table_schema = "{スキーマ名}" and
constraint_type="FOREIGN KEY"
;

SELECT * FROM information_schema.table_constraints
	WHERE table_schema = 'public' 
--	  AND constraint_type='FOREIGN KEY'
;
