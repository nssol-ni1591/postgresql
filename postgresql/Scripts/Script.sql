-- インストール

[root@cent7-2003 ~]# yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
[root@cent7-2003 ~]# yum list postgresql
[root@cent7-2003 ~]# yum search postgresql13
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: centos.usonyx.net
======================================= N/S matched: postgresql13 ========================================
postgresql13.x86_64 : PostgreSQL client programs and libraries
postgresql13-contrib.x86_64 : Contributed source and binaries distributed with PostgreSQL
postgresql13-devel.x86_64 : PostgreSQL development header files and libraries
postgresql13-docs.x86_64 : Extra documentation for PostgreSQL
postgresql13-libs.x86_64 : The shared libraries required for any PostgreSQL clients
postgresql13-llvmjit.x86_64 : Just-in-time compilation support for PostgreSQL
postgresql13-odbc.x86_64 : PostgreSQL ODBC driver
postgresql13-plperl.x86_64 : The Perl procedural language for PostgreSQL
postgresql13-plpython3.x86_64 : The Python3 procedural language for PostgreSQL
postgresql13-pltcl.x86_64 : The Tcl procedural language for PostgreSQL
postgresql13-server.x86_64 : The programs needed to create and run a PostgreSQL server
postgresql13-test.x86_64 : The test suite distributed with PostgreSQL

  Name and summary matches only, use "search all" for everything.

    
[root@cent7-2003 ~]# yum install postgresql13
[root@cent7-2003 ~]# rpm -qa | grep postgres
postgresql13-13.3-1PGDG.rhel7.x86_64
postgresql13-libs-13.3-1PGDG.rhel7.x86_64
[root@cent7-2003 ~]# yum install postgresql13-server
[root@cent7-2003 ~]# psql --version
psql (PostgreSQL) 13.3
[root@cent7-2003 ~]#
[root@cent7-2003 ~]# /usr/pgsql-13/bin/
clusterdb                   pg_controldata              pg_upgrade
createdb                    pg_ctl                      pg_verifybackup
createuser                  pg_dump                     pg_waldump
dropdb                      pg_dumpall                  postgres
dropuser                    pg_isready                  postgresql-13-check-db-dir
initdb                      pg_receivewal               postgresql-13-setup
pg_archivecleanup           pg_resetwal                 postmaster
pg_basebackup               pg_restore                  psql
pgbench                     pg_rewind                   reindexdb
pg_checksums                pg_test_fsync               vacuumdb
pg_config                   pg_test_timing
[root@cent7-2003 ~]# /usr/pgsql-13/bin/postgresql-13-setup initdb
Initializing database ... OK

[root@cent7-2003 ~]#

[root@cent7-2003 ~]# systemctl start postgresql-13
[root@cent7-2003 ~]# systemctl status postgresql-13

[root@cent7-2003 ~]# su - postgres
Last login: Wed Aug  4 02:46:01 JST 2021 on pts/0
-bash-4.2$
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)

-bash-4.2$ logout


-- 必要最低限の設定

bash-4.2$ cd /var/lib/pgsql/
-bash-4.2$ ls
13  create_sales.ddl  data  initdb.log  tickitdb  tickitdb.zip
-bash-4.2$ ls -l
total 10588
drwx------.  4 postgres postgres       51 Aug  6 02:32 13
-rw-r--r--.  1 postgres postgres      284 Aug  8 21:59 create_sales.ddl
drwx------. 15 postgres postgres     4096 Aug  6 02:11 data
-rw-------.  1 postgres postgres     1266 Aug  4 02:43 initdb.log
drwxr-xr-x.  2 postgres postgres      255 Aug 12 22:23 tickitdb
-rw-r--r--.  1 postgres postgres 10828492 Aug  8 12:52 tickitdb.zip
-bash-4.2$ cd 13
-bash-4.2$ ls
backups  data  initdb.log
-bash-4.2$ ls -la
total 8
drwx------.  4 postgres postgres   51 Aug  6 02:32 .
drwx------.  5 postgres postgres  185 Aug 12 22:23 ..
drwx------.  2 postgres postgres    6 May 13 23:12 backups
drwx------. 20 postgres postgres 4096 Aug 18 18:02 data
-rw-------.  1 postgres postgres  918 Aug  6 02:32 initdb.log
-bash-4.2$ cd data/
-bash-4.2$ ls
base              pg_hba.conf.org  pg_snapshots  pg_wal
current_logfiles  pg_ident.conf    pg_stat       pg_xact
global            pg_logical       pg_stat_tmp   postgresql.auto.conf
log               pg_multixact     pg_subtrans   postgresql.conf
pg_commit_ts      pg_notify        pg_tblspc     postgresql.conf.org
pg_dynshmem       pg_replslot      pg_twophase   postmaster.opts
pg_hba.conf       pg_serial        PG_VERSION    postmaster.pid
-bash-4.2$ diff postgresql.conf.org postgresql.conf
779a780,783
>
> # 2021/08/05 add by gohdo
> listen_addresses = '*'
>
-bash-4.2$ diff pg_hba.conf.org pg_hba.conf
93a94,98
>
> # 2021/08/05 add gohdo
> local all all     trust
> host  all all all trust
>
-bash-4.2$

-- 起動と停止
[root@cent7-2003 ~]# systemctl start postgresql-13
[root@cent7-2003 ~]# systemctl stop postgresql-13


-bash-4.2$ psql -U postgres
psql (13.3)
Type "help" for help.

postgres=# create database testdb2;
CREATE DATABASE
postgres=# \l
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

postgres=#
postgres=# \c testdb
You are now connected to database "testdb" as user "postgres".
testdb=# \d
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

testdb=# \q
bash-4.2$ 

