#!bin/bash
##########################################################################
# set env variable and link ref files
###########################################################################
# see https://github.com/freeseek/mocha
export REFDIR=/media/drew/easystore/ReferenceGenomes
export GSADIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export ANYLDIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/
export ARYDIR=$ANYLDIR/VariantAnalysisScripts/MicroarayScripts/
export MOCHR=$ARYDIR/mocha_plot.R
export GTC2VCF=$ARYDIR/gtc2vcf_plot.R
export PILER=$ARYDIR/pileup_plot.R
export SUMPR=$ARYDIR/summary_plot.R
export REFIDX=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export REFMAP=$REFDIR/GRCh38/genetic_map_hg38_withX.gz
export REFDUP=$REFDIR/GRCh38/dup.grch38.bed.gz
export REFCNP=$REFDIR/GRCh38/cnp.grch38.bed.gz
export REFCYTO=$REFDIR/GRCh38/cytoBand.hg38.txt.gz
cd $GSADIR

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A mocha=(  ["20180117"]="Mocha_out"  ["20200110"]="Mocha_out" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_\
A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0\
/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0\
_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

###########################################################################
## RUN MOCHA                                                             ##
###########################################################################

# 8033163000 8033684110 are bad quality
# 8033673352 is 09C98633 with 11p CNN-LOH
# 8037737797 is 305-13251 (MH0201393) with trisomy 8 rescue
# 8037702308 is MH0145622 with ATM deletion on chromosome 11
# 8035158042 is 352-60251 (MH0197311) with multiple chromosome 2 events


for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    mocha=${mocha[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    mkdir -p $wdir/$mocha
    bcftools annotate --no-version -Ou -x FILTER,^INFO/ALLELE_A,^INFO/ALLELE_B,^FMT/GT,^FMT/BAF,^FMT/LRR $wdir/$wdir.clinvar.GRCh38.bcf |\
	bcftools norm --no-version -d none -Ob -o $wdir/$mocha/$wdir.unphased.GRCh38.bcf && \
	bcftools index -f $wdir/$mocha/$wdir.unphased.GRCh38.bcf
done