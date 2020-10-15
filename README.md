# Variant Analysis Workflows
## This repository contains several several (in-progess) data analysis workflows for the analysis of variants from several different sources of sequencing data. The pipelines follow the same general workflow (pictured below).
![Variant Calling General Pipeline](/Reference-Files/variant-calling-pipeline.jpeg)

## SNP-array Pipeline:
### This is a SNP-array analysis workflow. This pipeline identifies variants from Illumina Infinium GSA SNP-array beadchips.
1) Convert IDAT to GTC (Illumina's iaap-cli gencall)
2) Convert GTC to VCF (bcftools +gtc2vcf)
3) Annotate variants (bcftools annotate)
4) Extract ACMG59 table (bcftools view & bcftools query)
5) Perform SNP QC (GATK)
6) Phase genotypes 
7) Run MoChA (MoChA)
8) Compute principal components and ancestry
9) Extract final tables
10) Generate MoChA call plots (MoChA)

## Targeted Sequencing Pipeline:
### This is a targeted sequencing variant anlysis workflow. This analysis required I llumina MiSeq or Illumina NextSeq targeted sequencing data as input.

1) Align data (BWA MEM)
2) Remove duplicates (picard)
3) Recalibrate base pairs (GATK)
4) Estimate target coverages (bdetools coverage)
5) Run Mutect2 (GATK)
6) HaplotypeCaller (GATK)
7) Merge calls (bcftools merge)
8) Annotate variants (bcftools annotate & bcftools csq)
9) Extract final table with ACMG59 (bcftools query)
9) Generate IGV plots (IGV)

