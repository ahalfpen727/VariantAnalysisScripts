#!bin/bash

###########################################################################
# Export Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.9.0/gatk
export REFDIR=/media/drew/easystore/ReferenceGenomes/
export BEDDIR=$REFDIR/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.GRCh38.bed
export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export WORKDIR=/media/drew/easystore/Current-Analysis/AnalysisBaseDir/MiSeq_Data
cd $WORKDIR
###########################################################################
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A mutect=( ["2019_09"]="MiSeq_Results_out" ["2019_12"]="MiSeq_Results_out" )
declare -A mutect2=( ["2019_09"]="Mutect2_out" ["2019_12"]="Mutect2_out" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    mutect=${mutect[$pfx]}
    mutect2=${mutect2[$pfx]}
    cd $miseqdir
    pwd
    export OUTPUT=$mutect/$mutect2
    cd $OUTPUT
    pwd
    export INPUT_FILE=../../sm.txt
    sm_arr=( $(cat $INPUT_FILE) )
    inpt=${sm_arr[@]}
    for pfx in hc m2; do
	input=$(echo $inpt | sed 's/ /.GRCh38.vcf.gz vcfs\/'$pfx'./g;s/^/vcfs\/'$pfx'./;s/$/.GRCh38.vcf.gz/')
	bcftools merge --no-version -Ou $input | \
	    bcftools norm --no-version -Ou -m -any  | \
	    bcftools norm --no-version -Ob -o $pfx.GRCh38.bcf -f $REFFA && \
	    bcftools index -f $pfx.GRCh38.bcf
    done
done
