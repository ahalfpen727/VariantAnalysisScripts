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
    sm_arr=( $(cat $INPUT_FILE) )
    for pfx in hc m2; do
	input=$(echo ${sm_arr[@]} | sed 's/ /.GRCh38.vcf.gz\/'$pfx'./g;s/^//'$pfx'./;s/$/.GRCh38.vcf.gz/')
	echo $OUTPUT/$input
#	input=$(echo ${sm_arr[@]} | sed 's/ /.GRCh38.vcf.gz vcfs\/'$pfx'./g;s/^/vcfs\/'$pfx'./;s/$/.GRCh38.vcf.gz/')
	bcftools merge --no-version -Ou $OUTPUT/$input | \
	    bcftools norm --no-version -Ou -m- any | \
	    bcftools norm --no-version -Ob -o $pfx.GRCh38.bcf -f $REFFA && \
	    bcftools index -f $pfx.GRCh38.bcf
    done
done
