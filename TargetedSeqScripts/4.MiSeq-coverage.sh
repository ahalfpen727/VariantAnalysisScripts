#!bin/bash

###########################################################################
# Export Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.8.1/gatk
export REFDIR=/media/drew/easystore/ReferenceGenomes/
export BEDDIR=$REFDIR/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.bed

export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export WORKDIR=/media/drew/easystore/Current-Analysis/AnalysisBaseDir/MiSeq_Data
###########################################################################
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="MiSeq_Results_out/3.GRP_BAMs" ["2019_12"]="MiSeq_Results_out/3.GRP_BAMs" )
declare -A coverage=( ["2019_09"]="MiSeq_Results_out/Coverage_out" ["2019_12"]="MiSeq_Results_out/Coverage_out" )
declare -A v2s=( ["2019_09"]="MiSeq_Results_out/4.V2_BAMs" ["2019_12"]="MiSeq_Results_out/4.V2_BAMs" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    coverage=${coverage[$pfx]}
    cd $WORKDIR/$miseqdir
    export INPUT_FILE=$WORKDIR/$miseqdir/sm.txt
    export OUTPUT=$WORKDIR/$miseqdir/$coverage
    mkdir -p $OUTPUT
    touch $OUTPUT/$sm.cov
    export INPUTDIR=$datadir
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    echo $n
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) );
	sm=${sm_arr[(($i-1))]};
	echo $sm
	pwd
	bedtools coverage -g $REFFAI -sorted -a $BEDFILE -b $INPUTDIR/$sm.bam -mean | \
	    cut -f5 >  $OUTPUT/$sm.cov
    done
    (echo -en "CHROM\tBEG\tEND\tNAME\t"; tr '\n' '\t' < sm.txt | sed 's/\t$/\n/'; \
     paste $BEDFILE $(cat sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')) \
	>  $OUTPUT/3215481_Covered.GRCh38.tsv
done
