#!bin/bash

export VCF_DIR=/media/drew/easystore/ReferenceGenomes/VCFs/

for file in $VCF_DIR/"*.vcf{.gz}{.tbi}"; do
    tabix -p vcf $file
fi
    
