#!/bin/bash
# Extract properties from the textified pdf files

for f in text/*.txt; do
	cat "$f" | ./pdf_to_properties.pl > "properties/properties-$(basename $f)"
done
