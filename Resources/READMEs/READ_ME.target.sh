#!bin/bash
## PILOT DATA

#tar xzvf LVB_fastq_Sept2019.tar.gz
find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 > sm.txt

## MISEQ DATA                                                            
#for sfx in 1-1 1-2 1-3 2-1 2-2 2-3 2-4 3-1 3-2 3-3; do
#  unzip raw/Batch$sfx.zip
#done
#find -iname "*_R1_0[01][12].fastq.gz" | grep -v "MPC10\|NA12878\|NA18507" | cut -d/ -f4 | cut -d_ -f1 > sm.txt
find -iname "*_R1_0[01][12].fastq.gz" | cut -d/ -f4 | cut -d_ -f1 > sm.txt

## NEXTSEQ DATA


###########################################################################
## FASTQ ALIGNMENT                                                       ##
###########################################################################

for file in $REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/*; do ln -s $file; done

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_001.fastq.gz" ) ); \
#  fastq_arr=( $(find -iname "*_R1_001.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
  sm_arr=( $(cat sm.txt) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_001.fastq.gz}_R2_001.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" GCA_000001405.15_GRCh38_no_alt_analysis_set.fna $fastq_r1 $fastq_r2 | \
    samtools view -Sb - | \
    samtools sort - -o $sm.raw.bam && \
    samtools index $sm.raw.bam
done


###########################################################################
## REMOVE DUPLICATES                                                     ##
###########################################################################

ln -s $HOME/bin/picard.jar

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  java \
    -jar picard.jar \
    MarkDuplicates \
    I=$sm.raw.bam \
    O=$sm.tmp.bam \
    M=$sm.txt && \
  samtools index $sm.tmp.bam
done

###########################################################################
## RECALIBRATE BASE PAIRS                                                ##
###########################################################################

for file in $REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/*; do ln -s $file; done

ln -s $HOME/gatk-4.1.7.0/gatk-package-4.1.7.0-local.jar
ln -s $REFDIR/HG38/1000G_phase1.snps.high_confidence.hg38.vcf
#ln -s $REFDIR/HG38/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  $HOME/gatk-4.1.7.0/gatk-package-4.1.7.0-local.jar \
    BaseRecalibrator \
    -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
    -I $sm.tmp.bam \
    --known-sites 1000G_phase1.snps.high_confidence.hg38.vcf \
    -O $sm.grp && \
  gatk-4.1.7.0/gatk \
    ApplyBQSR \
    -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
    -I $sm.tmp.bam \
    --bqsr-recal-file $sm.grp \
    -O $sm.bam && \
  samtools index $sm.index.bam
done
