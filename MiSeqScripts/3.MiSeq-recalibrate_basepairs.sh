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

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="MiSeq_Results_out" ["2019_12"]="MiSeq_Results_out" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    cd $miseqdir
    mkdir -p $datadir/3.GRP_BAMs
    export OUTDIR=$datadir/3.GRP_BAMs
    export INPUT_FILE=sm.txt
    export INPUTDIR=$datadir/2.TMP_DUP_BAMs
    sm_arr=( $(cat $INPUT_FILE) )
    n=${#sm_arr[@]}
    for i in $(seq 1 $n); do
	sm_arr=( $(cat $INPUT_FILE) );
	sm=${sm_arr[(($i-1))]};
	$GATK BaseRecalibrator -R $REFFA -I $INPUTDIR/$sm.tmp.bam --known-sites $VCF1000G \
	      -O $OUTDIR/$sm.grp && \
	$GATK ApplyBQSR -R $REFFA -I $INPUTDIR/$sm.tmp.bam \
	      --bqsr-recal-file $OUTDIR/$sm.grp -O $OUTDIR/$sm.bam && \
	    samtools index $OUTDIR/$sm.bam
    done
done

