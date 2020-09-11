#!bin/bash

###########################################################################
# MISEQ DATA                                                            
# PILOT DATA                                                           
###########################################################################

export REFDIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/

export IDX_DIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set

export REF=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

export WORK_DIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09

for file in $IDX_DIR; do
    ln -s $file
done

mkdir $( "-P ../MiSeqResults/BAMs" )

find -iname "*_R1_0012.fastq.gz" > sm.file.txt
find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 > ../sm.txt

###########################################################################
## FASTQ ALIGNMENT                                                       ##
###########################################################################

sm_arr=( $(cat ../sm.txt) )
n=${#sm_arr[@]}

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_0012.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
  sm_arr=( $(cat ../sm.txt) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_0012.fastq.gz}_R2_0012.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" $IDX_DIR $fastq_r1 $fastq_r2 -o ../MiSeqResults/BAMs/$sm.raw.sam
  samtools view -Sb -o  ../MiSeqResults/BAMs/$sm.raw.bam
  samtools sort -T $sm -O BAM -o ../MiSeqResults/BAMs/$sm.tmp.bam ../MiSeqResults/BAMs/$sm.raw.bam
  samtools index -b -@ 2 ../MiSeqResults/BAMs/$sm.raw.bam ../MiSeqResults/BAMs/$sm.idx.bam
done

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_001.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
  sm_arr=( $(cat sm.txt) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_001.fastq.gz}_R2_001.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 | \
    samtools view -Sb - | \
    samtools sort  -o $sm.raw.bam && \
    samtools index $sm.raw.bam
done

###########################################################################
## REMOVE DUPLICATES                                                     ##
###########################################################################

ln -s $HOME/bin/picard.jar

sm_arr=( $(cat ../sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat ../sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  java \
    -jar picard.jar \
    MarkDuplicates \
    I=$sm.raw.bam \
    O=$sm.tmp.bam \
    M=$sm.txt && \
  samtools index $sm.tmp.bam
done
