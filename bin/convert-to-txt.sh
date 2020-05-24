#!/bin/bash
# Convert all downloaded version pdfs to text files

if [ ! -d text ]; then
	mkdir text || { echo "Could not create text dir"; exit 1; }
fi

for f in pdfs/*; do
	dest=${f##*-}
	dest=text/${dest%.*}.txt
	pdftotext "$f" $dest
done
