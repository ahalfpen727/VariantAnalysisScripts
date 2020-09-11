#!bin/bash
export VCF_DIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/VCFs/

tabix -p vcf < find -iname "*.vcf.gz"
