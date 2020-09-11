#!bin/bash

###########################################################################
# CONVERT DATA FROM GTC TO VCF                                          
# set index dir location env variables etc
###########################################################################

export INDEX_DIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFDIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/ReferenceGenomes

for file in $INDEX_DIR; do
    ln -s $file
done

ref=$INDEX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare	-A refdir=( ["20180117"]="GSA_24v1_0" ["20200110"]="GSA_24v2_0" )
declare	-A bpm=( ["20180117"]="GSA-24v1-0_A1.bpm" ["20200110"]="GSA-24v2-0_A1.bpm" ) 
declare -A egt=( ["20180117"]="GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="GSA-24v1-0_A1.csv" ["20200110"]="GSA-24v2-0_A1.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ) #["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.bam" )
#declare -A opts=( ["20180117"]="" ["20200110"]="-s ^8033684100" )
#["20200320"]="CCPMBiobank_MEGA2_A1.bpm" )

for pfx in 20180117; do
    wdir=${wdir[$pfx]}
    refdir=${refdir[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
done

touch $HOME/Downloads/GoodCell-Resources/GuliosAnalysis/$wdir/$pfx.index.GRCh38.bcf
ln -s $HOME/Downloads/GoodCell-Resources/GuliosAnalysis/$wdir/$pfx.index.GRCh38.bcf
export TMP_DIR=$HOME/Downloads/GoodCell-Resources/GuliosAnalysis/$wdir/bcftools-sort.XXXXXX

###########################################################################
# Run gtc2vcf on GTC directory
###########################################################################

bcftools +gtc2vcf -Ou -f $ref -b $REFDIR/$refdir/$bpm  -e $REFDIR/$refdir/$egt -x $pfx.sex -g GTCs -o $pfx.GRCh38.bcf | \
    bcftools sort -Ou -T $TMP_DIR | \
    bcftools reheader -s ../map.tsv | \
    bcftools norm --no-version -Ou -o $pfx.GRCh38.bcf -c x -f $ref && \
    bcftools index -f $pfx.index.GRCh38.bcf
