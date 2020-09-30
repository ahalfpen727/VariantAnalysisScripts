#!bin/bash

###########################################################################
# CONVERT DATA FROM GTC TO VCF                                          
# set index dir location env variables etc
###########################################################################

export WORK_DIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export INDEX_DIR=/media/drew/easystore/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set
export ref=$INDEX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REF_DIR=/media/drew/easystore/ReferenceGenomes

for file in $INDEX_DIR; do
    ln -s $file
done

declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A rfdir=( ["20180117"]="GSA_24v1_0" ["20200110"]="GSA_24v2_0" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.bam" )
declare -A opts=( ["20180117"]="" ["20200110"]="-s ^8033684100" ["20200320"]="CCPMBiobank_MEGA2_A1.bpm" )

###########################################################################
# Run gtc2vcf on GTC directory
###########################################################################

for pfx in 20180117 20200110; do
    workdir=$WORK_DIR/${wdir[$pfx]}
    wdr=${wdir[$pfx]}
    refdir=${rfdir[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    touch $workdir/$wdr.index.GRCh38.bcf
    ln -s $workdir/$wdr.index.GRCh38.bcf
    export TMP_DIR=$workdir/bcftools-sort.XXXXXX
    bcftools +gtc2vcf --gtcs $workdir/GTCs -o $workdir/$wdr.maps.tsv
    bcftools +gtc2vcf -Ou -f $ref -b $bpm  -e $egt -x $workdir/$wdr.sex -g $workdir/GTCs -o $workdir/$wdr.GRCh38.bcf | \
    bcftools sort -Ou -T $TMP_DIR | \
    bcftools reheader -s $workdir/$wdr.map.tsv | \
    bcftools norm --no-version -Ou -o  $workdir/$wdr.GRCh38.bcf -c x -f $ref && \
    bcftools index -f  $workdir/$wdr.index.GRCh38.bcf
    bcftools +gtc2vcf --no-version -c $csv -s $sam -o ${csv%.csv}.GRCh38.csv
done
