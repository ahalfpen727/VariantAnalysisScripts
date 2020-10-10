#!bin/bash

###########################################################################                        
# Load Indexes and create input file                                                               
###########################################################################                        
export BASE_DIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir
export WORK_DIR=$BASE_DIR/MiSeq_Data/2019_09/LVB_fastq_Sept2019/concat_fastq
export RESULTS=$BASE_DIR/MiSeq_Data/MiSeq_Results_out
export REF_DIR=/media/drew/easystore/ReferenceGenomes/
export IDX_DIR=$REF_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export IDX_BASE=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REF=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

sm_arr=( $(cat ../sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat ../sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  java -jar $HOME/toolbin/picard.jar MarkDuplicates I=$sm.raw.bam O=$sm.tmp.bam M=$sm.txt && \
      samtools index $sm.tmp.bam
done
