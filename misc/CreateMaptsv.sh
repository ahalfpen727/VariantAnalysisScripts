#!bin/bash

##############################################################################
# Set env variables
##############################################################################

export date="20200810"
export wrkdr="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/GSA_Data"
export REFDIR="/media/drew/easystore/ReferenceGenomes"
export REFGFF=$REFDIR/Ensembl/Homo_sapiens.GRCh38.fixed.101.gff3.gz
export REFVCF=$REFDIR/GRCh38/clinvar_$date.GRCh38.vcf.gz
export REFTBI=$REFDIR/GRCh38/clinvar_$date.GRCh38.vcf.gz.tbi

##############################################################################
# create arrays
##############################################################################

declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare	-A bpms=( ["20180117"]="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egts=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2_ClusterFile.egt" )
declare	-A csvs=( ["20180117"]="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )

##############################################################################
# iterate over data
##############################################################################

find -iname "*_idat" | xargs $wrkdr/$wdir/dir.txt

for f in $wrkdr/$wdir/dir.txt; do
    dir=$f
    cd $dir
    touch $wrkdr/$wdir/files.txt
    find -iname "*.idat" | xargs > $wrkdr/$wdir/files.txt
done

for f in $wrkdr/$wdir/files.txt; do
	bcftools +gtc2vcf -i -g $f
done


for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    csv=${csvs[$pfx]}
    touch $wrkdr/$wdir/dir.txt
    cd $wrkdr/$wdir
    bcftools +gtc2vcf --gtcs  GTCs -o $wdir.maps.tsv
done
