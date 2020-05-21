#!/usr/bin/perl
# For use with the various versions of MS-OXPROPS.
# 1. Download the pdf file to process
# 2. Convert it to text using pdftotext (part of the poppler suite of pdf manipulation tools)
# 3. Run this program to extract the tags and LIDs in the same format as pstreader/extras/properties.csv
use strict;

# Skip forward to "Structures" section
while(<>) {
	/^.?(2 )?Structures$/ and last;
}

while(<>) {
	/^\d+ of \d+$/ and next;
	/^$/ and next;
	chomp;

	/^\s?(2\.\d+ )?(PidLid[^\s]*)\s*$/ and process_lid($2);
	/^\s?(2\.\d+ )?(PidTag[^\s]*)\s*$/ and process_tag($2);
	/^\s?(2\.\d+ )?(PidName[^\s]*)\s*$/ and process_name($2);
}

sub process_lid {
	my $name = $_[0];
	my $lid;
	my $pset;
	my $psetid;
	my $datatype;
	my $typecode;
	while(<>) {
		/Canonical [Nn]ame: (.*)$/ and ($1 eq $name or die "Canonical name >$1< does not match section title >$name<\n");
		/Property set: (PS[^ ]*) {([^}]*)}$/ and $pset = $1 and $psetid = $2;
		/Property long ID \(LID\): (0x.*).*$/ and $lid = $1;
		/Data type: ([^,]*), (0x.*)$/ and $datatype = $1 and $typecode = $2;
		/^\s*2\.\d*\s$/ || /^\s*Alternate names:/ and print "$name,$lid,$1,$2,$pset,$psetid\n" and return;
	}
}

sub process_name {
	my $name = $_[0];
	my $pset;
	my $psetid;
	my $datatype;
	my $typecode;
	while(<>) {
		/Canonical [Nn]ame: (.*)$/ and ($1 eq $name or die "Canonical name >$1< does not match section title >$name<\n");
		/Property set: (PS[^ ]*) {([^}]*)}$/ and $pset = $1 and $psetid = $2;
		/Data type: ([^,]*), (0x.*)$/ and $datatype = $1 and $typecode = $2;
		/^\s*2\.\d*\s$/ and print "$name,n/a,$datatype,$typecode,$pset,$psetid\n" and return;
	}
}

sub process_tag {
	my $name = $_[0];
	my $tag;
	my $datatype;
	my $typecode;
	while(<>) {
		/Canonical [Nn]ame: (.*)$/ and ($1 eq $name or die "Canonical name >$1< does not match section title >$name<\n");
		/Property ID: (0x.*).*$/ and $tag = $1;
		/Data type: ([^,]*), (0x.*)$/ and $datatype = $1 and $typecode = $2;
		/^\s*2\.\d*\s$/ and print "$name,$tag,$datatype,$typecode,,\n" and return;
	}
}
