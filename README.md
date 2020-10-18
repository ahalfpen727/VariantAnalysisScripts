# Variant Analysis Workflows
## This repository contains several several data analysis workflows which I am currently writing. The workflows are designed to analysze variants in data produced by several different NGS techonologies. The pipelines follow the same general workflow and incorporate the best practices described in resources produced by the makers and maintainers of the Genome Analysis Toolkit (GATK)

![GATK's Best Practices Workflow for DNA-Seq Variant Calling](/Pipeline-Overview-and-Related-Resources/Pipeline-Images/DNA-Seq-variant-calling-pipeline.png)

The pipelines are ordered in a logical sequence for initial discovery of variants in a large cost effective SNP-array followed by validation of the variants via targeted sequencing. In order to perform cost effective targetded sequencing, thorough variant discovery practices are employed to reduce the number of false positive. The pipelines also differ in how the samples are considered which is desribed further in the individual sections for each workflow.

## SNP-array Analysis Pipeline:
### This is workflow was designed to take Infinium GSA SNP-array data from Illumina beadchips as input.

![GATK's Germline Variant Discovery for Analysis of a Cohort of Samples](/Pipeline-Overview-and-Related-Resources/Pipeline-Images/Germline_Cohort_Variant_Discovery.png)

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

![GATK's Germline Variant Discovery for Analysis of Individuals Samples](/Pipeline-Overview-and-Related-Resources/Pipeline-Images/Germline_Single_Sample_Variant_Discovery.png)

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
