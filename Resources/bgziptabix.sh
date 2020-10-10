#!/bin/bash

# bgzip vcf file and pipe to tabix for indexing
# use case: cat uncompressed.vcf | bash bgziptabix.sh [un]compresssed.vcf.gz

file=$1
bgzip >$file
tabix -f -p vcf $file
