#!bin/bash
export LOGFILE="logs.txt"
export ERRFILE="errors.txt"
touch $LOGFILE
touch $ERRFILE
sm_arr=( $(cat ../sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat ../sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  java -jar $HOME/picard.jar MarkDuplicates I=$sm.raw.bam O=$sm.tmp.bam M=$sm.bam && \
      samtools index $sm.tmp.bam
done
