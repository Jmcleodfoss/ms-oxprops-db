#!/usr/bin/perl
# Given two "properties" files formatted as csv showing the property name in the first column,
# determine which rows appear in the first but not the second, and which in the second bu not the first.

use strict;

my %properties;
open(FH, "<", $ARGV[0]);
while(<FH>) {
	chomp;
	my @row = split ",";
	@{$properties{shift @row}} = @row;
}
close FH;

open(FH, "<", $ARGV[1]);
print "Properties in $ARGV[1] not in $ARGV[0]\n";
while(<FH>) {
	my ($tagname, $tag, $typecode, $datatyoe, $psetid, $pset)  = split ",";

	exists $properties{$tagname} or print;
# check for discrepancies
	exists $properties{$tagname} and delete $properties{$tagname};
}

print "\nProperties in $ARGV[0] not in $ARGV[1]\n";
foreach my $key (keys %properties) {
	printf "%s\n", join(",", @{$properties{$key}});
}
