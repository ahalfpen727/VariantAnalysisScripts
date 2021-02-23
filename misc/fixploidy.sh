#!bin/bash
 bcftools +fixploidy --no-version ALL.chrs_GRCh38.genotypes.20170504.bcf | sed 's/0\/0/0|0/g;s/1\/1/1|1/g' | bref3 >>  ALL.chrs_GRCh38.genotypes.20170504.bref3 
