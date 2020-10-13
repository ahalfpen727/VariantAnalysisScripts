# Variant Analysis Workflows
## This repository contains several several (in-progess) data analysis workflows for the analysis of variants from different sources of sequencing data
![GATK Variant Calling Best Practices Pipeline for DNA-seq](https://github.com/ahalfpen727/VariantAnalysisScripts/blob/master/Reference-Files/DNA-Seq-variant-calling-pipeline.png)

## Illumina Infinium GSA microarray Analysis:
### This is a DNA-Seq variant microarray analysis designed for operation with data produced from the Illumina Infinimum GSA microarray beadchip.
1) Convert IDAT to GTC
2) Convert GTC to VCF
3) Annotate variants
4) Extract ACMG59 table
5) Perform SNP QC
6) Phase genotypes
7) Run MoChA
8) Compute principal components and ancestry
9) Extract final tables
10) Generate MoChA call plots

## Targeted sequencing Analysis Steps:
### This is a targeted sequencing workflow. It is designed for the analysis of either Illumina MiSeq or Illumina NextSeq targeted sequencing datA.
1) Align data (BWA)
2) Remove duplicates
3) Recalibrate base pairs
4) Estimate target coverages
5) Run Mutect2 (gatk)
6) Merge calls
7) Annotate variants
8) Extract final table (ACMG59)
9) Generate IGV plots

