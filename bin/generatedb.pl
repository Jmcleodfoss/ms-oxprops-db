#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

GetOptions(
	'fixtypos!' => \(my $fix_typos = 1),
	'db!' => \(my $show_db = 1),
	'header!' => \(my $show_header = 1),
	'help' => \(my $help),
	'keys' => \(my $show_keys),
	'ids' => \(my $show_ids),
	'orphans' => \(my $show_orphans),
	'version:s' => \(my $version = "")
);

if ($help) {
	print "use\n";
	print "	$0 [--help] | --version=V [--ids] [--keys] [--nodb] [--nofixtypos] [--noheader] [--orphans] [--version=V]\n";
	print "where:\n";
	print "	--help: show this help and exit\n";
	print "	--ids: show all property LIDs, names, and tags\n";
	print "	--keys: show all keys\n";
	print "	--nodb: don't output the database\n";
	print "	--nofixtypos: don't correct recognizeable typos in property type and property set names\n";
	print "	--noheader: suppress header in output\n";
	print "	--orphans: show orphaned lines which might belong to an existing field\n";
	print "	--version=V: use V as the version for this run\n";
	exit;
}

# Start processing
skip_to('^\s*(Table of )?Contents');
skip_to('^\s*(\d\s)?Structures.*[1-9]');

my @id_list;
while(<>){
	/^\s*(\d\s*)?Structure Examples/ and last;
	/^\s*(2\.\d+\s+)?(Pid\w*)\W.*$/ and push @id_list, $2;
}
$show_ids and print "$_\n" foreach(@id_list);

skip_to('^\s?(\d\s)?Structures\s*$');

# Track key_list so we know how many columns we have
my %key_list;

# The entire database
my @data;

# To read in multi-line descriptions etc
my $field = "";

# Index into the @id_list read from the table of contents;
my $i = 0;
while(<>){
	chomp;
	/^\s*Security\s*$/ || /^\s*(\d+\s+)?Structure Examples\s*$/ and last;
	$i > scalar @id_list and printf "bailing i = %d >= max number expected %d\n", $i, scalar @id_list and last;

	if ($i+1 < scalar @id_list && $_ =~ /^\s*(2\.\d+\s+)?$id_list[$i+1]\s*$/){
 		! exists $data[$i]->{'Canonical Name'} and $data[$i]->{'Canonical Name'} = $id_list[$i];
		$field = "";
		++$i;
	}

	if (/^\s*([^:]*)\s?:\s+(.*$)$/){
		my ($key, $value) = ($1, $2);

		# part of footer
		$key =~ /Release/ and next;

		my $key_unique = $key;

		$field = "";

		$key =~ /^Alternate\ [Nn]ames?\s*/ and $key_unique = 'Alternate Name(s)' and $field = $key_unique;
		$key =~ /^Canonical\ [Nn]ame\s*/ and $key_unique = 'Canonical Name';
		$key =~ /^Consuming\ [Rr]eferences?\s*/ and $key_unique = 'Consuming Reference(s)' and $field = $key_unique;
		$key =~ /Da?ta [Tt]yp?e/ and $key_unique = 'Data Type';
		$key =~ /^Defining\ [Rr]eferences?\s*/ and $key_unique = 'Defining Reference(s)';
		$key =~ /^Descripti?on\s*/ and $key_unique = 'Description' and $field = $key_unique;
		$key =~ /Property ID/ and $key_unique = 'ID / LID';
		$key =~ /Proper?ty lo?ng ID ?\(LID\)/ and $key_unique = 'ID / LID';
		$key =~ /Prope?r?t?y\ ?s?et/ and $key_unique = 'Property set';
		$key =~ /References?/ and $key_unique = 'Reference(s)';
		$key =~ /WebDAV/ and $field = 'WebDAV';

		$value =~ s/"""//g;
		$value =~ s/"ÿ""//g;

		# Handle a formatting problems in very early versions of the document: the first Pid section title on a page is followed immediately by
		# the second Pid section title, followed by the data for the first Pid Listed and then the data for the second.
		$key_unique eq 'Canonical Name' && $id_list[$i] ne $value && $id_list[$i-1] eq $value and --$i;
		$key_unique eq 'Canonical Name' && $id_list[$i] ne $value && $id_list[$i+1] eq $value and ++$i;

		$data[$i]->{$key_unique} = $value;
		$key_list{$key_unique} = 1;
	} elsif ($field ne ""){
		/^\s?2\.\d+/ and next;
		/^Pid/ and next;
		/^^\s*$/ and next;
		/^\[MS-OXPROPS/ and next;
		/^Exchange Server Protocols Master Property List/ and next;
		/^Office Exchange Protocols Master Property List Specification/ and next;
		/^Copyright/ and next;
		/^\d+ \/ \d+$/ and next;
		/^\d+ of \d+$/ and next;

		$data[$i]->{$field} .= ' ' . $_ and next;

		$show_orphans and printf "\, \$\n";
	}
}

if ($show_keys){
	print "\nKeys";
	$version ne "" and print " ($version)";
	print "\n----\n";
	print "$_\n" foreach(sort keys %key_list);
}
$show_db or exit;

if ($show_header) {
	my @headings = ( 'Canonical Name', 'ID / LID', 'Data Type Name', 'Data Type Code', 'Property Set Name', 'Property Set GUID', 'Property Name', 'Alternate Name(s)', 'Area', 'Defining Reference(s)', 'Consuming Reference(s)', 'WebDAV', 'Description');
	$version ne "" and push @headings, 'Version';
	print (join ',', @headings);
	print "\n";
}

while (scalar @data){
	my $r =  shift @data;

	my @output;
	exists $r->{'Canonical Name'} or die 'No Canonical Name';
	push @output, csv_escape($r->{'Canonical Name'});

	push @output, exists $r->{'ID / LID'} ? $r->{'ID / LID'} : '';

	if (exists $r->{'Data Type'}){
		if ($r->{'Data Type'} =~ /(\S*),\s*(\S*)$/){
			my ($typename, $typecode) = ($1, $2);
			if ($fix_typos){
				$typename =~ s/^P?typBinary/PtypBinary/;
				$typename =~ s/^P?ty?pBoolean/PtypBoolean/;
				$typename =~ s/^P?ty?pInteger32/PtypInteger32/;
				$typename =~ s/^P?typMultipleInteger32/PtypMultipleInteger32/;
				$typename =~ s/^P?ty?p?e?Sd?tring/PtypString/;
				$typename =~ s/Pty?pTime/PtypTime/;
				$typename =~ s/0x001EPtypEmbeddedTable/PtypEmbeddedTable/;
			}
			push @output, (csv_escape($typename), csv_escape($typecode));
		} else {
			push @output, (csv_escape($r->{'Data Type'}), '');
		}
	} else {
		push @output, ('', '');
	}

	if (exists $r->{'Property set'}){
		if ($r->{'Property set'} =~ /(\w*)\s?\{([^\}]*)\}?/) {
			my ($ps, $guid) = ($1, $2);
			if ($fix_typos){
				$ps =~ s/P?SE?T?I?D/PSETID/;
				$ps =~ s/Addrss/Address/;
				$ps =~ s/Appintment/Appointment/;
				$ps =~ s/Asistant/Assistant/;
				$ps =~ s/Meting/Meeting/;
				$ps =~ s/Shring/Sharing/;
			}
			push @output, (csv_escape($ps), csv_escape($guid));
		} else {
			$fix_typos and $r->{'Property set'} =~ s/PSETIC/PSETID/;
			push @output, (csv_escape($r->{'Property set'}), '');
		}
	} else {
		push @output, ('', '');
	}

	push @output, exists $r->{'Property name'}		? csv_escape($r->{'Property name'}): "";
	push @output, exists $r->{'Alternate Name(s)'}		? csv_escape($r->{'Alternate Name(s)'}): "";
	push @output, exists $r->{'Area'}			? csv_escape($r->{'Area'}) : '';
	push @output, exists $r->{'Defining Reference(s)'}	? csv_escape($r->{'Defining Reference(s)'}) : '';
	push @output, exists $r->{'Consuming Reference(s)'}	? csv_escape($r->{'Consuming Reference(s)'}) : '';
	push @output, exists $r->{'WebDAV'}			? csv_escape($r->{'WebDAV'}) : '';
	push @output, exists $r->{'Description'}		? csv_escape($r->{'Description'}) : '';
	$version ne "" and push @output, csv_escape($version);
	print (join ',', @output);
	print "\n";
exit;
}

sub skip_to {
	my $regex = shift @_;
	while(<>){
		/$regex/ and return;
	}
}

sub csv_escape {
	my $old = shift @_;
	$old =~ s/"/""/g;
	$old =~ s/^0/'0/;
	return ('"' . $old . '"');
}
