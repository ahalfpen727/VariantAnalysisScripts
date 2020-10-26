# Variant Analysis Workflows
## This repository contains several data analysis workflows for variant discovery. The workflows are designed to identify variants from sequence data produced by  several different NGS techonologies. The pipelines follow the general workflow described by the reference material associated with the Genome Analysis Tool-Kit (GATK) documentation and incorporate their best practices as well.

### GATK's Best Practices Workflow for DNA-Seq Variant Calling
![GBP](/misc/Pipeline-Images/DNA-Seq-variant-calling-pipeline.png)

The pipelines are ordered in a logical sequence for initial discovery of variants in a large cost effective SNP-array followed by validation of the variants via targeted sequencing. In order to perform cost effective targetded sequencing, thorough variant discovery practices are employed to reduce the number of false positive. The pipelines also differ in how the samples are considered which is desribed further in the individual sections for each workflow.

# SNP-array Analysis Pipeline:
## This workflow was designed to use Illumina GSA SNP-array data as input
This pipeline identifies variants from Illumina's Infinium GSA SNP-array IDAT files. The pipeline uses Illumina's proprietary iiap command-line software to convert the IDAT files to GTC files. The rest of the pipeline relies on bcftools plugins and the Genome Analysis Toolkit in order to annotate, phase, filter, and identify variants. The pipeline is more thoroughly described ![here](https://github.com/freeseek/gtc2vcf).

### SNP-array Analysis Overview
![GVC](/misc/Pipeline-Images/gtc2vcf.png)

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

# Targeted Sequencing Pipeline:
## This is a targeted sequencing variant anlysis workflow. This analysis requires I llumina MiSeq or Illumina NextSeq targeted sequencing data as input.
This pipeline identifies variants from targeted sequencing data.For Data produced by an Illumina MiSeq can be input into this pipeline. Infinium GSA SNP array. The pipeline uses Illumina's proprietary iiap command line software to conver the IDAT files to GTCs. The rest of the pipeline relies on bcftools plugins and the Genome Analysis Toolkit in order to identify variants.

### GATK's Germline Variant Discovery for Analysis of a Cohort of Samples
![GVC](/misc/Pipeline-Images/Germline_Cohort_Variant_Discovery.png)

### GATK's Germline Variant Discovery for Analysis of Individuals Samples
![GVS](/misc/Pipeline-Images/Germline_Single_Sample_Variant_Discovery.png)

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
