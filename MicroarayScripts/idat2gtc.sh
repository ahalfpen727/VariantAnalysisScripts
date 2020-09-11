#!bin/bash

###########################################################################
## Set Env Variable                                                      ##
###########################################################################
export REFDIR="/media/drew/easystore/ReferenceGenomes"
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpms=( ["20180117"]="GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egts=( ["20180117"]="GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="GSA_24v2_0/\GSA-24v2-0_A1_ClusterFile.egt" )
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                    ##
##########################################################################
export wrkdir="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data"
#for pfx in $(dirs); do
for pfx in 20180117; do
    dir=${dirs[$pfx]}
    workdir=$wrkdir/$dir
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    echo $egt; echo $bpm
    cd $workdir
    mkdir GTCs
    $HOME/toolbin/iaap-cli/iaap-cli gencall $REFDIR/$bpm $REFDIR/$egt $workdir/GTCs -f Raw_Data/ -g
    $bcftools +gtc2vcf --gtcs  GTCs -o $workdir/$pfx.gtc.tsv
done

for pfx in 20200110; do
    dir=${dirs[$pfx]}
    workdir=$wrkdir/$dir
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    echo $egt; echo $bpm; echo $workdir
    cd $workdir
    mkdir GTCs
done

find -iname "*idat" | xargs > dir.txt
for f in dir.txt; do
    dir=$f
    cd $dir
    find -iname "*.idat" | xargs > files.txt
done
for f in files.txt; do
    bcftools +gtc2vcf -i -g $f
done

for dirname in *idat; do
    $HOME/toolbin/iaap-cli/iaap-cli gencall $REFDIR/$bpm $REFDIR/$egt GTCs -f $dirname  -g
done
