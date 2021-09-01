#!/usr/bin/perl

use strict;
use warnings;
use DBI;


my $host = "192.168.10.135";
my $port = 5432;
my $dbname = "testdb";
my $rolename = "postgres";
my $password = "postgres";
my $url = "dbi:Pg:dbname=$dbname;host=$host;port=$port";

my $con = DBI->connect($url, $rolename, $password, {
	PrintError => 0,
	RaiseError => 0,
}) or die "connection: $!";

$con->{AutoCommit} = 0;

# 自動エラーチェック（エラー発生時エラー内容を自動的に出力）を有効にする
$con->{PrintError} = 1;

my $row;
#$row = $con->do("INSERT INTO users VALUES (5, 'abc')")
#	or warn "エラーコード: ", $con->state(), "\n", $con->errstr(), "\n";

$row = $con->do("UPDATE join_sc.users SET name=concat(name, 'x') WHERE id=5")
	or warn "エラーコード: ", $con->state(), "\n", $con->errstr(), "\n";

my $stmt = $con->prepare("SELECT * FROM join_sc.users");
$stmt->execute()
	or warn "エラーコード: ", $con->state(), "\n", $con->errstr(), "\n";

while (my @row = $stmt->fetchrow_array) {
	print "id=[$row[0]] name=[$row[1]](".(length $row[1]).")\n";
}

$con->commit;

$con->disconnect
	or warn "データベースの切断に失敗: $DBI::errstr\n";

1;
