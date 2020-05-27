# ms-oxprops-db
CSV Database of Exchange properties pulled from various versions of Microsoft's MS-OXPROPS document. This uses the Excel dialect of CSV; other formats may be provided on request.

## Prerequisites
The scripts use bash, Perl, and pdftotext from the poppler suite of PDF tools.

## Procedure
This downloads all known MS-OXPROPS pdfs, converts them to text, and then extracts the database info from all text files.
1. bin/download-pdfs.sh
2. bin/convert-to-text.sh
3. bin/generatedb-all.sh > ms-oxprops.csv

generatedb-all.sh calls generatadb.pl for each text file.

## Command line arguments to generatedb.pl
Run as
	cat ms-oxprops-text-version-of-pdf | bin/generatedb.pl [--help] [--ids] [--keys] [--nodb] [--nofixtypos] [--noheader] [--orphans] [--version=V] [--delim=D]
where

* --delim=D: use D (can be multiple characters) as the delimiter instead of '.'.
* --help: shows info about the command-line options
* --ids: List all the property long IDs, tags, and names found in the table of contents
* --keys: List all keys found (useful during development and to check spelling in new versions of the document. See example below;
* --nodb: Do not print out the database (useful primarily with --ids. --keys, and --orphans)
* --nofixtypos: Do not apply fixes for typos in Property Types and Property Set names
* --noheader: Do not print out the database header
* --orphans: Show any lines which were not processed but might be part of a field (useful during development)
* --version=V: use V for the version in the database

### The --keys option
To check whether there are any typos in the keys in new versions of the document, run generatedb.pl with the --keys option:
```
cat ms-oxprops.txt | bin/generatedb.pl --keys --nodb | sort -u
```

### The --ids option
To generate a list of IDs only, use the --ids option:
```
cat ms-oxprops.txt | bin/generatedb.pl --ids --nodb
```

To get just the LIDs but not the tags or names:
```
cat ms-oxprops.txt | bin/generatedb.pl --ids --nodb |grep PidLid
```

## Motivation
I have been working with Microsoft PST and MSG files (as a hobbyist) for almost a decade, and this document is something I wish I had had from the start. Maybe others will find it useful.

## Releases
### Version 1.0.0 (2020-05-25)
Artifacts are stored on Dropbox. There is no guarantee that older versions of the database will be available due to space constraints.
| Artifact | SHA256 Checksum |
|---|---|
| [ms-oxprops-2020-05-25.csv](https://www.dropbox.com/s/e945bjijzjlaa2n/ms-oxprops-2020-05-25.csv?dl=0) | 46c2fb8445812e1eb8eb5a99c6db4e61ff177c163a460504f8711ecd1ca3e6d2 *ms-oxprops-2020-05-25.csv |
| [ms-oxprops-2020-05-25.csv.zip](https://www.dropbox.com/s/yynqininhauff18/ms-oxprops-2020-05-25.csv.zip?dl=0) | 02ea3276c511b64ff68d786a39bd0e0858a8c04be5b774ae79128b265109c05a *ms-oxprops-2020-05-25.csv.zip |
| [ms-oxprops-2020-05-25.xlsx](https://www.dropbox.com/s/vqivoeba6j4ih9b/ms-oxprops-2020-05-25.xlsx?dl=0) | 3bf09572ac6d3eee84ecf81327afbb94608243698fa83946113d2fd90d531d19 *ms-oxprops-2020-05-25.xlsx |

The Excel version has a filter and fixed top row and first column
