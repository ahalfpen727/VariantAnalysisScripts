#!bin/bash

###########################################################################
# Load Indexes and create input file
###########################################################################

export RESULTS="/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/MiSeq_Results_out"
export WORK_DIR=/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/2019_09/LVB_fastq\
_Sept2019/concat_fastq

if [ ! -d "$RESULTS" ]; then
    mkdir -p "$RESULTS"
fi

export IDX=/media/drew/easystore/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export IDXBASE=/media/drew/easystore/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis\
_set/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REF=/media/drew/easystore/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis\
_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDXBASE; do
    ln -s $IDXBASE/$file
done
touch /media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/sm.file.txt
touch /media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/sm.txt
export INPUT_FILE=/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/sm.file.txt
export INPUTFILE=/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/sm.txt
find $WORK_DIR  -iname "*_R1_0012.fastq.gz" -print > $INPUTFILE

for i in $(cat $INPUTFILE); do
    basename -s R1_0012.fastq.gz $i > $INPUT_FILE
done

###########################################################################
# MISEQ FASTQ ALIGNMENT                                                       ##
###########################################################################

sm_arr=( $(cat $INPUT_FILE) )
n=${#sm_arr[@]}

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_0012.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
  sm_arr=( $(cat $INPUT_FILE) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_0012.fastq.gz}_R2_0012.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 | samtools view -Shb - >  $RESULTS/$sm.bam; \
  samtools sort  $RESULTS/$sm.bam -o $RESULTS/$sm.sorted.bam &&  \
  samtools index -b -@ 2 $RESULTS/$sm.sorted.bam
done

# pilot data and MiSeq data
#for i in $(seq 1 $n); do
#  fastq_arr=( $(find -iname "*_R1_001.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
#  sm_arr=( $(cat sm.txt) ); \
#  fastq_r1=${fastq_arr[(($i-1))]}; \
#  fastq_r2=${fastq_r1%_R1_001.fastq.gz}_R2_001.fastq.gz; \
#  sm=${sm_arr[(($i-1))]}; \
#  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
#  bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 | \
#    samtools view -Sb - | \
#    samtools sort  -o $sm.raw.bam && \
#    samtools index $sm.raw.bam
#done
