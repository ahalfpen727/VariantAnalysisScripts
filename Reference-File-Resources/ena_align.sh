#!/bin/bash

# USAGE: sh ena_align.sh [Sample]
#
# This simple script automates aligning and filtering Samples from the ENA.  The workflow creates a name ordered BAM using all
# available threads from a group of FASTQ files using the naming convention [Sample]_1.fastq.gz and [Sample]_2.fastq.gz.
# After this the BAM is filtered to only reads on the chrY and chrM regions.  Finally, the flow of control is passed to a 
# modified version of GATK's Best Practices to create a suiteable gVCF and collect some metrics.
gatk4=~/Applications/gatk-4.1.4.1/gatk
reference=/mnt/genomics/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
mills=/mnt/genomics/GRCh38_reference_genome/other_mapping_resources/Mills_and_1000G_gold_standard.indels.b38.primary_assembly.vcf.gz
dbsnp=/mnt/genomics/GRCh38_reference_genome/All_20180418.vcf.gz

# Align the FASTQ files with BWA.  Use a pipe to prepare the resulting SAM stream into a position sorted BAM.
bwa mem -M -t $(nproc) -R '@RG\tID:'${1}'\tSM:'${1}'\tLB:lib1\tPL:illumina\tPU:unit1' $reference ${1}_?.fastq.gz | samtools sort -@ $(nproc) -o ${1}.GRCh38.bam

# Filter the reads to chrY and chrM.  This method preserves mates unlike the "samtools view -b source.bam chrY chrM" method.
(samtools view -H ${1}.GRCh38.bam; samtools view ${1}.GRCh38.bam | grep -P "\tchr(Y|M?)\t") > ${1}.chrYM.sam

# Sort the chrYM SAM by read name - using GATK here because the samtools sort of the same fails validations
$gatk4 SortSam -I ${1}.chrYM.sam -O ${1}.chrYM.bam -SO queryname

# Mark duplicates in the name sorted BAM
$gatk4 --java-options "-Xmx4G" \
	MarkDuplicates -I=$1.chrYM.bam -O=$1.dedup.bam -METRICS_FILE=metrics.txt

# Finally, sort everything back to cooridnates
$gatk4 SortSam -I $1.dedup.bam -O $1.sorted.bam -SORT_ORDER coordinate

# Score bases for systematic error in the Illumina instruments
$gatk4 --java-options "-Xmx8G" BaseRecalibrator -R $reference -O recal_data.table -I $1.sorted.bam \
	--known-sites $mills --known-sites $dbsnp

# Apply base quality score recalibration
$gatk4 --java-options "-Xmx8G" ApplyBQSR \
	-R $reference \
	-I $1.sorted.bam \
	--bqsr-recal-file recal_data.table \
	-O $1.recal.bam

# Produce a gVCF for the YDNA-Warehouse  
$gatk4 --java-options "-Xmx8G" HaplotypeCaller -R $reference \
	-L chrY \
	-L chrY_KI270740v1_random \
	-O $1.b38.g.vcf.gz \
	-I $1.recal.bam \
	-ERC GVCF

# Produce a BED regions file for callable loci
java -jar ~/Applications/GenomeAnalysisTK.jar -T CallableLoci \
	-R $reference \
	-I $1.recal.bam -summary table.txt -o callable_status.bed \
	-L chrY -L chrY_KI270740v1_random

# Collect additional metrics
$gatk4 CollectAlignmentSummaryMetrics -R $reference -I $1.recal.bam -O CASM.txt
$gatk4 CollectInsertSizeMetrics -I $1.recal.bam -O CISM.txt -H IS_histogram.pdf -M 0.5
java -jar ~/Applications/GenomeAnalysisTK.jar -T DepthOfCoverage -R $reference -o coverage -I $1.recal.bam -L chrY

# Re-encode the BAM as a CRAM file
samtools view -T $reference -C -o $1.GRCh38.cram $1.recal.bam
samtools index $1.GRCh38.cram
