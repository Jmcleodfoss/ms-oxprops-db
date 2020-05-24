#!/bin/bash
# Download all known versions of MS-OXPROPS as PDFs.

if [ ! -d pdfs ]; then
	mkdir pdfs || { echo "Could not create pdfs dir"; exit 1; }
fi

pushd pdfs

# Latest version is stored without a suffix for the version.
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d.pdf
mv '[MS-OXPROPS].pdf' '[MS-OXPROPS]-190618.pdf'

## Remaining versions all have suffixes which map to releases as shown in https://docs.microsoft.com/en-us/openspecs/exchange_server_protocols/ms-oxprops/f6ab1613-aefe-447d-a49c-18217230b148
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-190319.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-181001.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-180724.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-171212.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-171013.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-160914.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-160613.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-150914.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-150526.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-150316.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-141030.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-140731.pdf
# No PDF for v 16.1 (2014-04-30)
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-140210.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-131118.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-130726.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-130211.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-121008.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-120716.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-120427.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-120120.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-111007.pdf
# No PDF for v 10 (2011-08-05)
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-110318.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-101103.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-100804.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-100505.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-100210.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-091104.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-090715.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-090410.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-090304.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-090204.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-081203.pdf
# PDF for v 1.03 (2008-01-10)
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-080903.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-080806.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-080627.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-080425.pdf
wget https://interoperability.blob.core.windows.net/files/MS-OXPROPS/%5bMS-OXPROPS%5d-080404.pdf

popd
