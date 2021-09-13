#!/usr/bin/perl

use strict;
use warnings;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

# キー置換ルール
my %REPL_KEYS = (
	"AAA-3:05" => "AAA-3:00",
);

# 出力ファイル名ルール
my %OUTFILES = (
	"AAA-1:00" => "impr_AAA_to_sss_1.py",
	"AAA-2:00" => "impr_AAA_to_sss_2.py",
	"AAA-3:00" => "impr_AAA_to_sss_3.py",
	"BBB-4:00" => "impr_BBB_to_sss_1.py",
	"BBB-12:00" => "impr_BBB_to_sss_2.py",
);

my %HASH = ();


sub load {
	my ($path) = @_;

	open my $in, "$path" or die "open($path): $!";
	binmode $in, ":crlf:utf8";

	while (<$in>) {
		chomp;
		
		if (!/^(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)/) {
			print "[Error] Illegal record (rec=[$_])\n";
			next;
		}

		my @a = ($1, $2, $3, $4, $5, $6);
		my $key = "$a[0]-$a[1]";
		$key = "$REPL_KEYS{$key}" if (exists $REPL_KEYS{$key});

#		if (!exists $HASH{$key}) {
#			@{$HASH{$key}} = ();
#		}
		push @{$HASH{$key}}, \@a;
	}
	close $in;
}

sub dump {
	for my $key (keys %HASH) {
		if ($key !~ /(\w+)-(\d+):(\d+)/) {
			print "[Error] Illegal key (key=[$key])\n";
			next;
		}

		my ($sid, $hh, $mm) = ($1, $2, $3);

		my @b = @{$HASH{$key}};

		my $fmt  = "sid=[%s] time=[%02d-%02d] value=[%s %s %s]\n";
		my $fmt2 = "                       value=[%s %s %s]\n";
		my $flag = 0;
		for my $c (@b) {
			my @a = @{$c};
			if ($flag) {
				printf $fmt2, $a[5], $a[4], $a[3];
			}
			else {
				printf $fmt, $sid, $hh, $mm, $a[5], $a[4], $a[3];
			}
			$flag = 1;
		}
	}
}

sub header {
	my ($sid, $hh, $mm) = @_;
	return "sid=[$sid] hh=[$hh] mm=[$mm]\n";
}
sub body {
	my (@rec) = @_;
	return "rec=[@rec]";
}
sub footer {
	my (@rec) = @_;
	return "redshift_$rec[0]_$rec[2]";
}

sub output {
	for my $key (keys %HASH) {

		if (!exists $OUTFILES{$key}) {
			print "[Error] outfile not found (key=[$key])\n";
			next;
		}
		my $file = $OUTFILES{$key};

		if ($key !~ /(\w+)-(\d+):(\d+)/) {
			print "[Error] Illegal key (key=[$key])\n";
			next;
		}
		my ($sid, $hh, $mm) = ($1, $2, $3);

		print "-----------------------\n";
		print ">>> file=[$file]\n";

		# header
		print "###############\n";
		print "# header\n";
		print "###############\n";
		print header $sid, $hh, $mm;
		print "\n";

		# body
		print "###############\n";
		print "# body\n";
		print "###############\n";
		my @b = @{$HASH{$key}};
		for my $c (@b) {
			my @a = @{$c};
			print (body @a);
			print "\n";
		}
		print "\n";

		# footer
		print "###############\n";
		print "# footer\n";
		print "###############\n";
		@b = @{$HASH{$key}};
		for my $c (@b) {
			my @a = @{$c};
			print footer @a;
			print "\n";
		}
		print "\n";
	}
	
}

load "test.csv";
#::dump;
output;