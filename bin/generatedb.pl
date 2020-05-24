#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

# Command-line arguments
# Show all keys found if true;
#my $keys = '';

# List bare IDs if true;
#my $ids = '';

# Emit database if true (default);
#my $db = '';

GetOptions(
	'db!' => \(my $db = 1),
	'header!' => \(my $header = 1),
	'help' => \(my $help),
	'keys' => \(my $keys),
	'ids' => \(my $ids),
	'version:s' => \(my $version = "")
);

if ($help) {
	print "use\n";
	print "	$0 [--help] | --version=V [--ids] [--keys] [--nodb]\n";
	print "where:\n";
	print "	--help: show this help and exit\n";
	print "	--ids: show all property LIDs, names, and tags\n";
	print "	--keys: show all keys\n";
	print "	--nodb: don't output the database\n";
	print "	--noheader: suppress header in output\n";
	print "	--version=V: use V as the version for this run";
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
$ids and print "$_\n" foreach(@id_list);

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
	$i > scalar @id_list and printf "bailing %d >= %d too high\n", $i, scalar @id_list and last;

	if ($i+1 < scalar @id_list && $_ =~ /^\s*(2\.\d+\s+)?$id_list[$i+1]\s*$/){
 		! exists $data[$i]->{'Canonical Name'} and $data[$i]->{'Canonical Name'} = $id_list[$i];
		++$i;
	}

	if (/^\s*([^:]*)\s?:\s+(.*$)$/){
		my ($key, $value) = ($1, $2);
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
		$data[$i]->{$key_unique} = $value;
		$key_list{$key_unique} = 1;
	} elsif ($field ne ""){
		/^\s?2\.\d+/ and next;
		/^Pid/ and next;
		/^^\s*$/ and next;
		/^\[MS-OXPROPS/ and next;
		/^Exchange Server Protocols Master Property List/ and next;
		/^Copyright/ and next;
		/^\d+ \/ \d+$/ and next;

		$data[$i]->{$field} .= ' ' . $_ and next;
	}
}
#print Dumper(@data);

if ($keys){
	print "\nKeys";
	$version ne "" and print " ($version)";
	print "\n----\n";
	print "$_\n" foreach(sort keys %key_list);
}
$db or exit;

if ($header) {
	my @headings = ( 'Canonical Name', 'ID / LID', 'Data Type Name', 'Data Type Code', 'Property Set Name', 'Property Set GUID', 'Property Name', 'Alternate Name(s)', 'Area', 'Defining Reference(s)', 'Consuming Reference(s)', 'Release', 'WebDAV', 'Description');
	$version ne "" and push @headings, 'Version';
	print (join ',', @headings);
	print "\n";
}

$i = 0;
while (scalar @data){
#printf "%d (%d remaining) id %s found %s\n", $i, scalar @data, $id_list[$i], Dumper($data[$i]); ++$i;
	my $r =  shift @data;

	my @output;
	exists $r->{'Canonical Name'} or die 'No Canonical Name';
	push @output, $r->{'Canonical Name'};

	push @output, exists $r->{'ID / LID'} ? $r->{'ID / LID'} : '';

	if (exists $r->{'Data Type'}){
		if ($r->{'Data Type'} =~ /(\S*),\s*(\S*)$/){
			push @output, ($1, $2);
		} else {
			push @output, ($r->{'Data Type'}, '');
		}
	} else {
		push @output, ('', '');
	}

	if (exists $r->{'Property set'}){
		$r->{'Property set'} =~ /(\w*)\s\{([^\}]*)\}/ and push @output, $1 and push @output, $2;
	} else {
		push @output, ('', '');
	}

	push @output, exists $r->{'Property Name'} ? $r->{'Property name'} : "";
	push @output, exists $r->{'Alternate names'} ? $r->{'Alternate names'} : "";;
	push @output, exists $r->{'Area'} ? $r->{'Area'} : '';
	push @output, exists $r->{'Defining Reference(s)'} ? $r->{'Defining Reference(s)'} : '';
	push @output, exists $r->{'Consuming Reference(s)'} ? $r->{'Consuming Reference(s)'} : '';
	push @output, exists $r->{'Release'} ? $r->{'Release'} : '';
	push @output, exists $r->{'WebDAV'} ? $r->{'WebDAV'} : '';
	push @output, exists $r->{'Description'} ? $r->{'Description'} : '';
	$version ne "" and push @output, $version;

	print (join ',', @output);
	print "\n";
}

sub skip_to {
	my $regex = shift @_;
	while(<>){
		/$regex/ and return;
	}
}

