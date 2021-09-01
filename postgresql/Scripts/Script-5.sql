-- Amazon Redshift 入門ガイド

-- チケット販売システム

-- チケット購入者
drop table if exists users;
create table users (
	userid integer not null PRIMARY key,
	username char(8),
	firstname varchar(30),
	lastname varchar(30),
	city varchar(30),
	state char(2),
	email varchar(100),
	phone char(14),
	likesports boolean,
	liketheatre boolean,
	likeconcerts boolean,
	likejazz boolean,
	likeclassical boolean,
	likeopera boolean,
	likerock boolean,
	likevegas boolean,
	likebroadway boolean,
	likemusicals boolean
);

-- 会場
drop table if exists venue;
create table venue (
	venueid smallint not null PRIMARY key,
	venuename varchar(100),
	venuecity varchar(30),
	venuestate char(2),
	venueseats integer
);

-- 種別
drop table if exists category;
create table category (
	catid smallint not null PRIMARY key,
	catgroup varchar(10),
	catname varchar(10),
	catdesc varchar(50)
);

-- 開催日付
drop table if exists date;
create table date (
	dateid smallint not null PRIMARY key,
	caldate date not null,
	day character(3) not null,
	week smallint not null,
	month character(5) not null,
	qtr character(5) not null,
	year smallint not null,
	holiday boolean default('N')
);

-- イベント情報
drop table if exists event;
create table EVENT (
	eventid integer not null PRIMARY key,
	venueid smallint not null,
	catid smallint not null,
	dateid smallint not null,
	eventname varchar(200),
	starttime timestamp,

--	FOREIGN KEY (venueid) REFERENCES venue (venueid),
--	FOREIGN KEY (dateid) REFERENCES date (dateid),
--	FOREIGN KEY (catid) REFERENCES category (catid)
);

-- 売上一覧表？
drop table if exists listing;
create table listing (
	listid integer not null PRIMARY key,
	sellerid integer not null,
	eventid integer not null,
	dateid smallint not null,
	numtickets smallint not null,
	priceperticket decimal(8,2),
	totalprice decimal(8,2),
	listtime timestamp,
	FOREIGN KEY (dateid) REFERENCES date(dateid)

--	FOREIGN KEY (sellerid) REFERENCES users (userid),
--	FOREIGN KEY (eventid) REFERENCES date (eventid),
);

-- 販売価格 or 販売者
drop table if exists sales;
create table sales (
	salesid integer not NULL PRIMARY key,
	listid integer not null,
	sellerid integer not null,
	buyerid integer not null,
	eventid integer not null,
	dateid smallint not null,
	qtysold smallint not null,
	pricepaid decimal(8,2),
	commission decimal(8,2),
	saletime timestamp,
	FOREIGN KEY(dateid) REFERENCES date(dateid),
	FOREIGN KEY(listid) REFERENCES listing(listid)

--	FOREIGN KEY(sellerid) REFERENCES users(userid),
--	FOREIGN KEY(buyerid) REFERENCES users(userid),
--	FOREIGN KEY (eventid) REFERENCES date (eventid),
);

TRUNCATE venue;
copy venue from '/var/lib/pgsql/tickitdb/venue_pipe.txt' (delimiter '|', header false, format csv);

/* psqlを使用する場合は「\copy」ならば相対パスが使用できる
testdb=# \copy venue from 'venue_pipe.txt' (delimiter '|', header false, format csv);
COPY 202
testdb=# \copy category from 'category_pipe.txt' (delimiter '|', header false, format csv);
COPY 11
testdb=# \copy date from 'date2008_pipe.txt' (delimiter '|', header false, format csv);
COPY 365
testdb=# \copy event from 'allevents_pipe.txt' (delimiter '|', header false, format csv);
COPY 8798
testdb=# \copy listing from 'listings_pipe.txt' (delimiter '|', header false, format csv);
COPY 192497
testdb=# \copy sales from 'sales_tab.txt' (delimiter E'\t', header false, format csv);
COPY 172456
*/

--外部キー制約の追加
ALTER TABLE テーブル名
ADD FOREIGN KEY (外部キーを付けるテーブルの列名) 
REFERENCES 参照先テーブル名 (参照先列名);
--外部キー制約の削除
ALTER TABLE テーブル名 DROP CONSTRAINT 外部キー名;

ALTER TABLE event ADD FOREIGN KEY (venueid) REFERENCES venue (venueid);
ALTER TABLE event ADD FOREIGN KEY (dateid) REFERENCES date (dateid);
ALTER TABLE event ADD FOREIGN KEY (catid) REFERENCES category (catid);

testdb=# ALTER TABLE event ADD FOREIGN KEY (dateid) REFERENCES date (dateid);
ALTER TABLE
testdb=# ALTER TABLE event ADD FOREIGN KEY (catid) REFERENCES category (catid);
ALTER TABLE
testdb=# ALTER TABLE event ADD FOREIGN KEY (venueid) REFERENCES venue (venueid);
ERROR:  insert or update on table "event" violates foreign key constraint "event_venueid_fkey"
DETAIL:  Key (venueid)=(64) is not present in table "venue".
/*
 venueid=64に対するレコードがvenueテーブルに存在しない といエラー
 insert into venue values (64, 'Add by gohdo', 'Tokyo', 'JP');
 insert into venue values (12, 'Add by gohdo', 'Tokyo', 'JP');
 insert into venue values (51, 'Add by gohdo', 'Tokyo', 'JP');
*/

-- FOREIGN KEY の参照確認
-- トランザクション側テーブルからマスターテーブルにLEFT JOINしたでJOIN KEYがNULLのレコードが対象
testdb=# select listid, userid from listing l left join users u on l.sellerid=u.userid where listid is null;
 listid | userid
--------+--------
(0 rows)

testdb=# select count(*), e.venueid from event e left join venue v on e.venueid=v.venueid where v.venueid is null group by e.venueid;
 count | venueid
-------+---------
    56 |      64
(1 row)

testdb=#

select count(*), l.sellerid FROM listing l LEFT JOIN users u ON l.sellerid = u.userid WHERE l.sellerid IS NULL GROUP BY l.sellerid;
select count(*), l.eventid  FROM listing l LEFT JOIN event e ON l.eventid = e.eventid WHERE l.eventid IS NULL GROUP BY l.eventid;
select count(*), l.dateid   FROM listing l LEFT JOIN date  d ON l.dateid = d.dateid   WHERE l.dateid IS NULL GROUP BY l.dateid;

ALTER TABLE listing ADD FOREIGN KEY (sellerid) REFERENCES users (userid);
ALTER TABLE listing ADD FOREIGN KEY (eventid)  REFERENCES event (eventid);
ALTER TABLE listing ADD FOREIGN KEY (dateid)   REFERENCES date  (dateid);


select count(*), s.sellerid FROM sales s LEFT JOIN users u ON s.sellerid = u.userid  WHERE s.sellerid IS NULL GROUP BY s.sellerid;
select count(*), s.buyerid  FROM sales s LEFT JOIN users u ON s.buyerid  = u.userid  WHERE s.buyerid  IS NULL GROUP BY s.buyerid;
select count(*), s.eventid  FROM sales s LEFT JOIN event e ON s.eventid  = e.eventid WHERE s.eventid  IS NULL GROUP BY s.eventid;

ALTER TABLE sales ADD FOREIGN KEY (sellerid) REFERENCES users(userid);
ALTER TABLE sales ADD FOREIGN KEY (buyerid)  REFERENCES users(userid);
ALTER TABLE sales ADD FOREIGN KEY (eventid)  REFERENCES event(eventid);

-- usernameが同じでuseridが異なるレコードの有無
testdb=# select * from  (select count(*) as c, u.username as n from users u group by username) as t where c<>1;
 c | n
---+---
(0 rows)

testdb=# select userid, username from users where username = 'JSG99FHE';
 userid | username
--------+----------
      1 | JSG99FHE
(1) rows)

testdb=# insert into users values (49991, 'JSG99FHE', 'Kou', 'Gohdo', 'Tokyo', 'JP');
INSERT 0 1
testdb=# select * from (select count(*) as c, u.username as n from users u group by username) as t where c<>1;
 c |    n
---+----------
 2 | JSG99FHE
(1 row)

testdb=#
