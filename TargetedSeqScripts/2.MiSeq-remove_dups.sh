#!bin/bash

###########################################################################
# MISEQ DATA                                                            
###########################################################################

export REFDIR=/media/drew/easystore/ReferenceGenomes/
export IDX_DIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REF=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export WORK_DIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/MiSeq_Data

for file in $IDX_DIR; do
    ln -s $file
done

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="MiSeq_Results_out" ["2019_12"]="MiSeq_Results_out" )

###########################################################################
## REMOVE DUPLICATES                                                     ##
###########################################################################

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    export WORKDIR=$WORK_DIR/$miseqdir
    export INPUT_FILE=$WORKDIR/sm.txt
    cd $WORKDIR
    mkdir -p $datadir/2.TMP_DUP_BAMS
    export INPUT=$datadir/1.RAW_BAMS
    export OUTPUT=$datadir/2.TMP_DUP_BAMS
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) ); \
	sm=${sm_arr[(($i-1))]}; \
	java -jar $HOME/toolbin/picard.jar MarkDuplicates I=$INPUT/$sm.raw.bam  \
	    O=$OUTPUT/$sm.tmp.bam M=$OUTPUT/$sm.dups_metrics.txt && \
	    samtools index $OUTPUT/$sm.tmp.bam
    done
done
