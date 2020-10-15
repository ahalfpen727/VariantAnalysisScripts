#!bin/bash

export WORKDIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/MiSeq_Data
declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="LVB_fastq_Sept2019" ["2019_12"]="LVB_fastq_Dec2019" )

###########################################################################
# Create one sm.txt input file for each MiSeq  MISEQ Data input dirs
###########################################################################

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    export WORK_DIR=$WORKDIR/$miseqdir
    cd $WORK_DIR
    touch ./sm.file.txt
    touch ./sm.txt
    export INPUT_FILE=./sm.file.txt
    export INPUTFILE=./sm.txt
    find -iname "*_R1_*.fastq.gz" > $INPUT_FILE
    for i in $(cat $INPUT_FILE); do
	basename -s "R1_001.fastq.gz" $i >> $INPUTFILE
    done
done