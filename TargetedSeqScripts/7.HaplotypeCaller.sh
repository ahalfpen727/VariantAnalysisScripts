#!bin/bash

###########################################################################
# Export Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.9.0/gatk
export REFDIR=/media/drew/easystore/ReferenceGenomes/GRCh38
export BEDDIR=$REFDIR/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.GRCh38.bed
export NEWBED=$BEDDIR/3215481_Covered.GRCh38.new.bed
export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai

###########################################################################
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A miseqout=(["2019_09"]="MiSeq_Results_out" ["2019_12"]="MiSeq_Results_out" )
declare -A mutect2=( ["2019_09"]="Mutect2_out" ["2019_12"]="Mutect2_out" )
declare -A hcs=( ["2019_09"]="Haplotype-Caller" ["2019_12"]="Haplotype-Caller" )
declare -A sms=( ["2019_09"]="4.V2_BAMs" ["2019_12"]="4.V2_BAMs" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    miseqout=${miseqout[$pfx]}
    mutect2=${mutect2[$pfx]}
    hcs=${hcs[$pfx]}
    sms=${sms[$pfx]}
    cd $miseqdir/$miseqout
    mkdir -P $mutect2
    mkdir -P $sms
    mkdir -P $hcs
    export INPUT_FILE=../sm.txt
    export INPUTDIR=$sms
    export OUTPUTDIR=$hcs
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    echo $n
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) );
	sm=${sm_arr[(($i-1))]};
	$GATK HaplotypeCaller --max-reads-per-alignment-start 0 -R $REFFA \
	      -I $INPUTDIR/$sm.v2.bam -O $OUTPUTDIR/hc.$sm.GRCh38.vcf.gz -L $BEDFILE \
	      --create-output-variant-index true
    done
    cd ../../
done
