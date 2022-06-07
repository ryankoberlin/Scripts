#!/usr/bin/perl

#
# Script to find all Perl modules installed on a node.
#

use strict;
use warnings;
use diagnostics;

my $libs;
foreach (@INC) {
	my @out = qx(ls $_);
	foreach (@out) {
		if ($_) {
			$libs .= $_;
		}
	}
}	
my @output = uniq(sort(split(' ', $libs)));
foreach (@output) {
	print $_, "\n";
}

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
