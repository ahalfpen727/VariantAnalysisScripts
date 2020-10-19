#!bin/bash
workdir="~/Downloads/GoodCell-Resources/GuniosAnalysis/"
for file in  $workdir/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/;do
    ln -s $file
done
for file in ~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v1_0/;do
    ln -s $file
done
ln -s $HOME/res/ensembl/Homo_sapiens.GRCh38.fixed.98.gff3.gz
#ln -s $workdir/ReferenceGenomes/clinvar/clinvar_$date.GRCh38.vcf.gz
#ln -s $workdir/ReferenceGenomes/clinvar/clinvar_$date.GRCh38.vcf.gz.tbi
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare	-A bpms=( ["20180117"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egts=( ["20180117"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2_ClusterFile.egt" ["20200110"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2_ClusterFile.egt" )
declare	-A csv=( ["20180117"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv" ["20200110"]="~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################
workdir=" ~/Downloads/GoodCell-Resources/GuniosAnalysis/2018_07/"
cd $workdir
export BCFTOOLS_PLUGINS=$HOME/bin/bcftools/plugins
for pfx in $(dirs); do
    bpm="./GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A1.bpm"
    egt="$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt"
    csv="$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1.csv"
    echo $egt
    echo $csv
    echo $bpm
    bcftools +gtc2vcf --gtcs  GTCs -o maps.tsv
    #/bin/rm *.idat
done
