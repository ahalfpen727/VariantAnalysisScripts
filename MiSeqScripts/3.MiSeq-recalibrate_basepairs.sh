#!bin/bash

###########################################################################
# Export MISEQ Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.8.1/gatk
export WORKDIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/MiSeq_Data
export REFDIR=/media/drew/easystore/ReferenceGenomes/
export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export VCF1000G=$REFDIR/GRCh38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export TBI1000G=$REFDIR/GRCh38/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi

for file in $IDXDIR; do
    ln -s $file
done

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="MiSeq_Results_out" ["2019_12"]="MiSeq_Results_out" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    export WORK_DIR=$WORKDIR/$miseqdir
    export INPUT_FILE=$WORK_DIR/sm.txt
    cd $WORK_DIR
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) );
	sm=${sm_arr[(($i-1))]};
	$GATK BaseRecalibrator -R $REFFA -I $datadir/$sm.tmp.bam --known-sites $VCF1000G \
	      -O $datadir/$sm.grp && \
	$GATK ApplyBQSR -R $REFFA -I $datadir/$sm.tmp.bam \
	      --bqsr-recal-file $datadir/$sm.grp -O $datadir/$sm.bam && \
	    samtools index $datadir/$sm.bam
    done
done

