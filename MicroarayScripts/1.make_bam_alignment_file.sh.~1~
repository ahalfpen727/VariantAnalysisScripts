#!bin/bash

##########################################################################
# set env variable and link ref files
###########################################################################
export REFDIR="/media/drew/easystore/ReferenceGenomes/GCA_000001405.15_GRCh38_no_alt_analysis_set"
export REFFA="$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
export WORKDIR="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data"

declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A GSADIR=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0" )
declare -A gsa=( ["20180117"]="GSA_24v1_0"  ["20200110"]="GSA_24v2_0" )

for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    GSADIR=${GSADIR[$pfx]}
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    csv=${csv[$pfx]}
    export WORK_DIR=$WORKDIR/$wdir
    cd $WORK_DIR
    touch $GSADIR/$gsa.alignment_file.bam
    export BAMFILE=$GSADIR/$gsa.alignment_file.bam
    bcftools +gtc2vcf -c $csv --fasta-flank | \
	bwa mem -M $REFFA - | \
	samtools view -bS -o $BAMFILE
done
