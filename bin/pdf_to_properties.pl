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

my $processing = "none";
my $name;
my $id;
my $psetid;
my $guid;
my $datatype;
my $typecode;
my $savename;
my $save;

while(<>) {
	/^\d+ of \d+$/ and next;
	/^$/ and next;
	/Change Tracking/ and last;
	chomp;

	if (/^\s?(2\.\d+ )?(Pid(Lid|Name|Tag)[^\s]*)\s*$/) {
		length $name and $savename = $2 and $save = $processing;
		$processing = processing_type($2);
	}

	if (/Canonical [Nn]ame: (.*)$/) {
		if (length $name && $name ne $1) {
			$savename = $1;
			$save = $processing;
		} else {
			$name = $1;
		}
		$processing = processing_type($1);
	}

	/Property set: (PS[^ ]*) {([^}]*)}$/ and $psetid = $1 and $guid = $2;
	/Property (long )?ID( \(LID\))?: (0x.*).*$/ and $id = $3;
	/Data type: ([^,]*), (0x.*)$/ and $datatype = $1 and $typecode = $2;

	if ($save eq "lid" || ($processing eq "lid" && length $name && length $id && length $psetid && length $guid && length $datatype && length $typecode)) {
		print "$name,$id,$datatype,$typecode,$psetid,$guid\n";
		$processing = "reset";
	}

	if ($save eq "name" || ($processing eq "name" && length $name && length $psetid && length $guid && length $datatype && length $typecode)) {
		print "$name,n/a,$datatype,$typecode,$psetid,$guid\n";
		$processing = "reset";
	}

	if ($save eq "tag" || ($processing eq "tag" && length $name && length $id && length $datatype && length $typecode)) {
		print "$name,$id,$datatype,$typecode,,\n";
		$processing = "reset";
	}

	if ($processing eq "reset") {
		$processing = $save;
		$name = $savename;
		$id = "";
		$psetid = "";
		$guid = "";
		$datatype = "";
		$typecode = "";
		$save = "";
		$savename = "";
	}
}

sub processing_type($) {
	$_[0] =~ /PidLid/ and return "lid";
	$_[0] =~ /PidName/ and return "name";
	$_[0] =~ /PidTag/ and return "tag";
}
