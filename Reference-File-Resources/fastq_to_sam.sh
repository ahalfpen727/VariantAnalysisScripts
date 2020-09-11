# USAGE: sh fastq_to_sam.sh <fastq1> <fastq2> <sample_name> <read_group> <platform_unit>
gatk=~/Genomics/gatk-4.0.4.0/gatk
$gatk --java-options "-Xmx8G" FastqToSam \
    -FASTQ=$1 \
    -FASTQ2=$2 \
    -OUTPUT=$3.unmapped.bam \
    -READ_GROUP_NAME=$4 \
    -SAMPLE_NAME=$3 \
    -LIBRARY_NAME=$3 \
    -PLATFORM_UNIT=$5 \
    -PLATFORM=illumina