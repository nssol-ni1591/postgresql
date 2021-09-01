-- JOIN
--スキーマの作成から ...

-bash-4.2$ psql -U postgres
psql (13.3)
Type "help" for help.

testdb=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 testdb    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 testdb2   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
(5 rows)

testdb=# \dn
  List of schemas
  Name  |  Owner
--------+----------
 public | postgres
(1 row)

testdb=#
testdb=# create schema join_sc;
CREATE SCHEMA
testdb=# \dn
  List of schemas
  Name   |  Owner
---------+----------
 join_sc | postgres
 public  | postgres
(2 rows)

testdb=# \dt
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | category | table | postgres
 public | date     | table | postgres
 public | event    | table | postgres
 public | kohaku   | table | postgres
 public | kohaku2  | table | postgres
 public | listing  | table | postgres
 public | sales    | table | postgres
 public | users    | table | postgres
 public | venue    | table | postgres
(9 rows)

testdb=# 
testdb=# set search_path to join_sc,public;
SET
testdb=# create table join_sc.users (id int not null primary key, name text);
CREATE TABLE
testdb=# create table posts (id int primary key not null, body text, user_id int not null unique);
CREATE TABLE
testdb=# \dt
           List of relations
 Schema  |   Name   | Type  |  Owner
---------+----------+-------+----------
 join_sc | posts    | table | postgres
 join_sc | users    | table | postgres
 public  | category | table | postgres
 public  | date     | table | postgres
 public  | event    | table | postgres
 public  | kohaku   | table | postgres
 public  | kohaku2  | table | postgres
 public  | listing  | table | postgres
 public  | sales    | table | postgres
 public  | venue    | table | postgres
(10 rows)

testdb=#
testdb=# insert into users values (1, 'taro');
INSERT 0 1
testdb=# insert into users values (2, 'jiro');
INSERT 0 1
testdb=# insert into users values (3, 'hanako');
INSERT 0 1
testdb=# insert into posts values (1, 'Hello', 3);
INSERT 0 1
testdb=# insert into posts values (2, 'Hi', 1);
INSERT 0 1
testdb=# insert into posts values (3, 'Good', 2);
INSERT 0 1
testdb=#

testdb=# select * from users;
 id |  name
----+--------
  1 | taro
  2 | jiro
  3 | hanako
(3 rows)

testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
(3 rows)

testdb=#

-- UNIQUE制約を削除したい
-- ポイント：DROPするのはColumn名ではなくIndex名

testdb=# insert into posts values (4, 'Why?', 2);
ERROR:  duplicate key value violates unique constraint "posts_user_id_key"
DETAIL:  Key (user_id)=(2) already exists.
testdb=# \d posts
               Table "join_sc.posts"
 Column  |  Type   | Collation | Nullable | Default
---------+---------+-----------+----------+---------
 id      | integer |           | not null |
 body    | text    |           |          |
 user_id | integer |           | not null |
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
    "posts_user_id_key" UNIQUE CONSTRAINT, btree (user_id)

testdb=# alter table posts drop constraint posts_user_id_key;
ALTER TABLE
testdb=# \d posts
               Table "join_sc.posts"
 Column  |  Type   | Collation | Nullable | Default
---------+---------+-----------+----------+---------
 id      | integer |           | not null |
 body    | text    |           |          |
 user_id | integer |           | not null |
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)

testdb=# insert into posts values (4, 'Why?', 2);
INSERT 0 1
testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
  4 | Why?  |       2
(4 rows)

testdb=#

-- INNER JOIN(内部結合)

JOINは先ほど使っていたもので、内部結合をします。
補足: JOIN と INNER JOINは同じです！

【特徴】
1. 右テーブルの行数に合わせて左テーブルの行数を複製する
2. 結合相手がいない行は結合結果から消滅する

【INNER JOINの挙動①】右テーブルの行数に合わせて左テーブルの行数を複製する
testdb=# insert into posts values (4, 'Why?', 2);
INSERT 0 1
testdb=# select * from users join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
  2 | jiro   |  4 | Why?  |       2
(4 rows)

testdb=#

【INNER JOINの挙動②】 結合相手がいない行は結合結果から消滅する
testdb=# insert into users values(4, 'saito');
INSERT 0 1
testdb=# select * from users;
 id |  name
----+--------
  1 | taro
  2 | jiro
  3 | hanako
  4 | saito
(4 rows)

testdb=# delete from posts where id=4;
DELETE 1
testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
(3 rows)

testdb=# select * from users join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
(3 rows)

testdb=#

-- 内部結合と外部結合

テーブルの結合には大きく分けて、内部結合(INNER JOIN)と外部結合(OUTER JOIN)の2種類があります。

内部結合では、どちらかのテーブルに存在しない場合は結合結果から消滅されるという挙動をしていましたね。

外部結合では、内部結合のように条件に一致させた状態で結合してくれるのに加え、
どちらかのテーブルに存在しないもの、NULLのものに関しても強制的に取得してくれます。
外部結合にはLEFT JOIN、RIGHT JOIN, FULL JOINの3種類があります。

LEFT JOIN  => LEFT OUTER JOIN
RIGHT JOIN => RIGHT OUTER JOIN
FULL JOIN  => FULL OUTER JOIN

-- LEFT JOIN(左外部結合)

左外部結合のことで、左のテーブルは全て表示します。

testdb=# select * from users;
 id |  name
----+--------
  1 | taro
  2 | jiro
  3 | hanako
  4 | saito
(4 rows)

testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
(3 rows)

testdb=# select * from users left join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
  4 | saito  |    |       |
(4 rows)

testdb=#


-- RIGHT JOIN（右外部結合)

右のテーブルを全て表示して結合します。

testdb=# delete from users where id=4;
DELETE 1
testdb=# insert into posts values (4, 'Sorry', 4);
INSERT 0 1
testdb=# select * from users;
 id |  name
----+--------
  1 | taro
  2 | jiro
  3 | hanako
(3 rows)

testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
  4 | Sorry |       4
(4 rows)

testdb=# select * from users right join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
    |        |  4 | Sorry |       4
(4 rows)

testdb=#


-- ざっくりまとめ

内部結合・・・ 結合すべき行が見つからなかった場合にその行は消滅する。
外部結合・・・ 結合すべき行が見つからなくても諦めず、全ての値がNULLである行を生成して結合する

【結合の種類】
名前 		種類 		内容

JOIN 		内部結合 	・右テーブルの行数に合わせて左テーブルの行数を複製する
				・結合相手がいない行は結合結果から消滅する
LEFT JOIN 	左外部結合 	・左の行は強制的に全て表示する
				・条件に合わないものは、右テーブルに値が全てNULLである行を生成して結合する
RIGHT JOIN 	右外部結合 	・右の行は強制的に全て表示する
				・条件に合わないものは、右テーブルに値が全てNULLである行を生成して結合する
FULL JOIN 	完全外部結合 	・左右の全テーブルを全て表示させる

testdb=# insert into users values(5, 'saito');
INSERT 0 1
testdb=# select * from users;
 id |  name
----+--------
  1 | taro
  2 | jiro
  3 | hanako
  5 | saito
(4 rows)

testdb=# select * from posts;
 id | body  | user_id
----+-------+---------
  1 | Hello |       3
  2 | Hi    |       1
  3 | Good  |       2
  4 | Sorry |       4
(4 rows)

-- (INNER)JOIN
testdb=# select * from users join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
(3 rows)

-- LEFT JOIN
testdb=# select * from users left join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
  5 | saito  |    |       |
(4 rows)

-- RIGHT JOIN
testdb=# select * from users right join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
    |        |  4 | Sorry |       4
(4 rows)

-- FULL JOIN
testdb=# select * from users full join posts on users.id = posts.user_id;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  3 | hanako |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
    |        |  4 | Sorry |       4
  5 | saito  |    |       |
(5 rows)

testdb=#

-- CROSS JOIN
-- すべての行同士の結合なのでON句は使用できない
testdb=# select * from users cross join posts ;
 id |  name  | id | body  | user_id
----+--------+----+-------+---------
  1 | taro   |  1 | Hello |       3
  1 | taro   |  2 | Hi    |       1
  1 | taro   |  3 | Good  |       2
  1 | taro   |  4 | Sorry |       4
  2 | jiro   |  1 | Hello |       3
  2 | jiro   |  2 | Hi    |       1
  2 | jiro   |  3 | Good  |       2
  2 | jiro   |  4 | Sorry |       4
  3 | hanako |  1 | Hello |       3
  3 | hanako |  2 | Hi    |       1
  3 | hanako |  3 | Good  |       2
  3 | hanako |  4 | Sorry |       4
  5 | saito  |  1 | Hello |       3
  5 | saito  |  2 | Hi    |       1
  5 | saito  |  3 | Good  |       2
  5 | saito  |  4 | Sorry |       4
(16 rows)

