#!bin/bash
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                    
# set env variable and link ref files
###########################################################################
export REFDIR="/media/drew/easystore/ReferenceGenomes"
export wrkdr="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/GSA_Data"
declare -A dir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpms=( ["20180117"]="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egts=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csvs=( ["20180117"]="/media/drew/easystore/Current-Analysis/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.csv" )
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################
cd $wrkdr
for pfx in 20180117 20200110; do
    dr=${dir[$pfx]}
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    mkdir -P ./$dir/GTCs
    iaap_gencall $bpm $egt $dr/GTCs -f $dr/Raw_Data/ -g
    bcftools +gtc2vcf --gtcs  $dr/GTCs -o $dr/$pfx.gtc.tsv
done

for pfx in 20180117 20200110; do
    dr=${dir[$pfx]}
    cd $dr
    touch files.txt
    find -iname "*.idat" | xargs > files.txt
    for f in files.txt; do
	bcftools +gtc2vcf -i -g $f
    done
    cd ../
done
