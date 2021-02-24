#!bin/bash
##########################################################################
# set env variable and link ref files
###########################################################################
export REFDIR=/media/drew/easystore/ReferenceGenomes/GRCh38
export REFIDX=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export REFMAP=$REFDIR/genetic_map_hg38_withX.gz
export REFDUP=$REFDIR/dup.grch38.bed.gz
export REFCNP=$REFDIR/cnp.grch38.bed.gz
export REFCYTO=$REFDIR/cytoBand.hg38.txt.gz
export ANALYSIS=/media/drew/easystore/Current-Analysis/AnalysisBaseDir
export SCRIPTDIR=$ANALYSIS/VariantAnalysisScripts/MicroarayScripts/
export MOCHR=$SCRIPTDIR/mocha_plot.R
export GTC2VCF=$SCRIPTDIR/gtc2vcf_plot.R
export PILER=$SCRIPTDIR/pileup_plot.R
export SUMPR=$SCRIPTDIR/summary_plot.R

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A mocha=(  ["20180117"]="Mocha_out"  ["20200110"]="Mocha_out" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/GRCh38/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

###########################################################################
## RUN MOCHA                                                             ##
###########################################################################

for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    mocha=${mocha[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    cd $wdir
    mkdir -p $mocha
    export VCFDIR=GTC2VCF
    bcftools annotate --no-version -Ou -x ID,QUAL,FILTER,^INFO/ALLELE_A,^INFO/ALLELE_B,^INFO/GC,^FMT/GT,^FMT/BAF,^FMT/LRR $VCFDIR/$wdir.$gsa.GRCh38.bcf |\
	bcftools norm --no-version -d none -Ob -o $VCFDIR/$wdir.$gsa.GRCh38.bcf && \
	bcftools index -f $VCFDIR/$wdir.$gsa.GRCh38.bcf
    cd ../
done
