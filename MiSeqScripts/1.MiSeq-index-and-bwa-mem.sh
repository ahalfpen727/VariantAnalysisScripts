#!bin/bash

###########################################################################
# Load Indexes and create input file
###########################################################################
export REF_DIR=/media/drew/easystore/ReferenceGenomes/
export IDX_DIR=$REF_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export IDX_BASE=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REF=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDX_DIR; do
    ln -s $IDX_DIR/$file
done

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="LVB_fastq_Sept2019" ["2019_12"]="LVB_fastq_Dec2019" )

###########################################################################
# MISEQ FASTQ ALIGNMENT                                                   
###########################################################################

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    cd $miseqdir
    export WORK_DIR=./$datadir
    mkdir -p ./MiSeq_Results_out
    touch ./sm.file.txt
    touch ./sm.txt
    export INPUT_FILE=./sm.file.txt
    export INPUTFILE=./sm.txt
    export RESULTS=MiSeq_Results_out
    find -iname "*_R1_*.fastq.gz" > $INPUT_FILE
#    cut -d/ -f2 $INPUT_FILE | cut -d_ -f1 > $INPUTFILE
    for i in $(cat $INPUT_FILE); do
	basename -s "R1_001.fastq.gz" $i >> $INPUTFILE
    done
    sm_arr=( $(cat $INPUTFILE) )
    n=${#sm_arr[@]}
    for i in $(seq 1 $n); do
	fastq_arr=( $(find -iname "*_R1_*.fastq.gz") ); \
	sm_arr=( $(cat $INPUTFILE) ); \
	fastq_r1=${fastq_arr[(($i-1))]}; \
	fastq_r2=${fastq_r1%_R1_001.fastq.gz}_R2_001.fastq.gz; \
	sm=${sm_arr[(($i-1))]}; \
	str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
	bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 | samtools view -Sb - | \
	    samtools sort - -o $RESULTS/$sm.raw.bam &&  \
	    samtools index -b -@ 2 $RESULTS/$sm.raw.bam
    done
done
