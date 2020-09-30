#!bin/bash
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                    
# set env variable and link ref files
###########################################################################
export REFDIR="/media/drew/easystore/ReferenceGenomes"
export wrkdr="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data"
cd $wrkdr
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpms=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egts=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csvs=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################
for pfx in 20180117 20200110; do
    dir=${dirs[$pfx]}
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    mkdir -p $wrkdr/$dir/GTCs
    $HOME/toolbin/iaap-cli/iaap-cli gencall $bpm $egt $wrkdr/$dir/GTCs -f $wrkdr/$dir/Raw_Data/ -g
    bcftools +gtc2vcf --gtcs  $wrkdr/$dir/GTCs -o $wrkdr/$dir/$dir.gtc.tsv
done
