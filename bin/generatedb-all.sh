#!/bin/bash
# run generatedb.pl on all versions in order

declare header=""

for f in text/*; do
	version=`basename ${f%.txt}`
	cat $f | bin/generatedb.pl --version=$version $header $*
	header="--noheader"
done
