#!bin/bash

###########################################################################
# Export Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.8.1/gatk
export REFDIR=/media/drew/easystore/ReferenceGenomes/
export BEDDIR=$REFDIR/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.GRCh38.bed
export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export WORKDIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/MiSeq_Data
cd $WORKDIR
###########################################################################
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A mutect2=( ["2019_09"]="MiSeq_Results_out/Mutect2_out" ["2019_12"]="MiSeq_Results_out/Mutect2_out" )
declare -A v2s=( ["2019_09"]="MiSeq_Results_out/4.V2_BAMs" ["2019_12"]="MiSeq_Results_out/4.V2_BAMs" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    mutect2=${mutect2[$pfx]}
    v2s=${v2s[$pfx]}
    cd $miseqdir
    export INPUT_FILE=sm.txt
    export INPUTDIR=$v2s
    export OUTPUT=$mutect2
    mkdir -p $OUTPUT
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    echo $n
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) );
	sm=${sm_arr[(($i-1))]};
	$GATK HaplotypeCaller --max-reads-per-alignment-start 0 -R $REFFA -I $INPUTDIR/$sm.v2.bam \
	      -O $OUTPUT/hc.$sm.GRCh38.vcf.gz -L $BEDFILE --create-output-variant-index true
    done
done
