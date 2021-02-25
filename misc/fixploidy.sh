#!bin/bash
export REFDIR=/media/drew/easystore/ReferenceGenomes
export CLINVCF=$REFDIR/GRCh38/ClinVar/clinvar_20200810.vcf.gz
export CLINTBI=$REFDIR/GRCh38/ClinVar/clinvar_20200810.vcf.gz.tbi
export G1000VCF=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export G1000TBI=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
export ALLBCF=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.gz
export ALLCSI=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.csi
export ACMG59=$REFDIR/GRCh38/acmg59.txt


#bcftools +fixploidy --no-version $ALLBCF | sed 's/0\/0/0|0/g;s/1\/1/1|1/g' | bref3 >>  ALL.chrs_GRCh38.genotypes.20170504.bref3 
$HOME/toolbin/imp5Converter --h $ALLBCF --o $REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.imp
bcftools view --no-version $ALLBCF | java -jar $HOME/toolbin/bref3.jar  > $REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.bref3 
    bcftools +fixploidy --no-version $REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.bref3 | \
    sed 's/0\/0/0|0/g;s/1\/1/1|1/g' | java -jar $HOME/toolbin/bref3.jar > $REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.fixed.bref3
