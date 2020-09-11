This repository contains several workflows for NGS data. There is a workflow for
the analysis of MiSeq or NextSeq Data and a seperate workflow for the
analysis of Illumina Infinimum GSA microarray data

DNA microarray Analysis Steps:
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

Targeted sequencing Analysis Steps:
1) Align data (BWA)
2) Remove duplicates
3) Recalibrate base pairs
4) Estimate target coverages
5) Run Mutect2 (gatk)
6) Merge calls
7) Annotate variants
8) Extract final table (ACMG59)
9) Generate IGV plots

