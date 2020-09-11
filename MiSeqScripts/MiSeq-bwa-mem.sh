#!bin/bash
###########################################################################
# MISEQ DATA                                                            
# PILOT DATA                                                           
###########################################################################

export REF_DIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/ReferenceGenomes/

export REF=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

export IDX_DIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set

for file in $IDX_DIR; do
    ln -s $file
done

export WORK_DIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/2019_09
RESULT="MiSeq_BWA_Results"
RESULTS=$WORK_DIR/$RESULT

if [ ! -d "$RESULTS" ]; then
    mkdir -p "$RESULTS"
fi

find -iname "*_R1_0012.fastq.gz" > sm.file.txt
#find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 > sm.txt

for i in $(cat sm.file.txt); do
    basename -s R1_0012.fastq.gz $i > sm.txt
done
	 
###########################################################################
## FASTQ ALIGNMENT                                                       ##
###########################################################################

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_0012.fastq.gz" | grep -v "MPC10\|NA12878\|NA18507") ); \
  sm_arr=( $(cat sm.txt) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_0012.fastq.gz}_R2_0012.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 -o MiSeq_BWA_Results/$sm.raw.sam; \
  samtools view -Sb -o  MiSeq_BWA_Results/$sm.raw.bam; \
  samtools sort -T $sm -O BAM -o MiSeq_BWA_Results/$sm.tmp.bam MiSeq_BWA_Results/$sm.raw.bam; \
  samtools index -b -@ 2 MiSeq_BWA_Results/$sm.raw.bam MiSeq_BWA_Results/$sm.idx.bam
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
