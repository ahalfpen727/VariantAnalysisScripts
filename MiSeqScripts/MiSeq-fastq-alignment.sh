#!bin/bash

###########################################################################
# MISEQ DATA                                                            
# PILOT DATA                                                           
###########################################################################

export REFDIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/

export IDX_DIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set

export REF_FILE=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDX_DIR; do
    ln -s $file
done

cd ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq
find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 >> ../sm.txt

mkdir -P ../MiSeqResults/raw-sams
mkdir -P ../MiSeqResults/raw-bams
mkdir -P ../MiSeqResults/tmp-bams
mkdir -P ../MiSeqResults/idx-bams

#for sfx in 1-1 1-2 1-3 2-1 2-2 2-3 2-4 3-1 3-2 3-3; do
#  unzip raw/Batch$sfx.zip
#done

#find -iname "*_R1_0[01][12].fastq.gz" | grep -v "MPC10\|NA12878\|NA18507" | cut -d/ -f4 | cut -d_ -f1 >> sm.txt

## NEXTSEQ DATA                                                         
#unzip FASTQ_Part1.zip
#unzip FASTQ_Part2.zip
#find -iname "*_R1_001.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 >> sm.txt

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
  bwa mem -M -R "$str" $IDX_DIR $fastq_r1 $fastq_r2 -o ../MiSeqResults/raw-sam/$sm.raw.sam
  samtools view -Sb -o  ../MiSeqResults/raw-bam/$sm.raw.bam
  samtools sort -T $sm -O BAM -o ../MiSeqResults/tmp-bam/$sm.tmp.bam ../MiSeqResults/raw-bam/$sm.raw.bam
  samtools index -b -@ 2 ../MiSeqResults/raw-bam/$sm.raw.bam ../MiSeqResults/idx-bam/$sm.idx.bam
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
