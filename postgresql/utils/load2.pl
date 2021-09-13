#!/usr/bin/perl

use strict;
use warnings;

my %HASH = ();


sub load {
	my ($path) = @_;

	open my $in, "$path" or die "open($path): $!";
	binmode $in, ":crlf:utf8";

	while (<$in>) {
		chomp;
		
		if (/^(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)/) {
			my @a = ($1, $2, $3, $4, $5, $6);
#			my $key = "$a[0]-$a[1]";

			my %sid_hash = ();
			if (exists $HASH{$a[0]}) {
				%sid_hash = \$HASH{$a[0]};
			}
			else {
				$HASH{$a[0]} = \%sid_hash;
			}
			$sid_hash{$a[1]} = \@a;
		}
		else {
			print "[Error] Unknown record (rec=[$_])\n";
		}
	}
	close $in;
}

sub dump {
	for my $key (keys %HASH) {
		my @a = @{$HASH{$key}};

		if ($key =~ /(\w+)-(\d+):(\d+)/) {
			my ($sid, $hh, $mm) = ($1, $2, $3);
#			print "sid=[$sid] time=[$hh-$mm] value=[".(join " ", @a)."]\n";
#			printf "sid=[%s] time=[%02d-%02d] value=[%s]\n", $sid, $hh, $mm, (join " ", @a);
			printf "sid=[%s] time=[%02d-%02d] value=[%s %s %s]\n", $sid, $hh, $mm, $a[5], $a[4], $a[3];
		}
		else {
			print "[Error] Unknown key (key=[$key])\n";
		}
	}
}

load "test.csv";
::dump;
