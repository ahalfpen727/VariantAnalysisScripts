# USAGE:  sh prepare_gvcf.sh <sample name>
# CONFIG VARIABLES:  Update to match environment
gatk=~/Genomics/gatk-4.0.4.0/gatk
reference=~/Genomics/Reference/GRCh38/GRCh38_full_analysis_set_plus_decoy_hla.fa
known=~/Genomics/Reference/GRCh38/Mills_and_1000G_gold_standard.indels.b38.primary_assembly.vcf.gz
snpdb=~/Genomics/Reference/GRCh38/ALL_20141222.dbSNP142_human_GRCh38.snps.vcf

$gatk --java-options "-Xmx4G" \
	MarkDuplicates -I=$1.bwa.clean.bam -O=$1.dedup.bam -METRICS_FILE=metrics.txt
     
$gatk --java-options "-Xmx8G" \
	BaseRecalibrator -R $reference -O recal_data.table -I $1.dedup.bam \
	--known-sites $known --known-sites $snpdb

$gatk --java-options "-Xmx8G" ApplyBQSR \
  -R $reference \
  -I $1.dedup.bam \
  --bqsr-recal-file recal_data.table \
  -O $1.recal.bam
  
$gatk --java-options "-Xmx8G" HaplotypeCaller -R $reference \
-L chrY \
-L chrY_KI270740v1_random \
-O $1.b38.g.vcf.gz \
-I $1.recal.bam \
-ERC GVCF