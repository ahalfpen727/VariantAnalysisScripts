#!bin/bash
# CONVERT DATA FROM GTC TO VCF

###########################################################################
# set env variables for index locations
###########################################################################
export GSA_DIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export MEGA_DIR=/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0
export REF_DIR=/media/drew/easystore/ReferenceGenomes
export INDEX_DIR=$REF_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export ref=$INDEX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $INDEX_DIR; do
    ln -s $file
done

#bcftools +gtc2vcf -c $MEGA_DIR/CCPMBiobankMEGA2_20002558X345183_A1.csv --fasta-flank | \
#  bwa mem -M $ref - | samtools view -bS -o $MEGA_DIR/CCPMBiobankMEGA2_20002558X345183_A1.bam


declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data/2018_07/GenomeStudio_Files/Manifest_Files/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.bam" )
declare -A opts=( ["20180117"]="" ["20200110"]="-s ^8033684100" ["20200320"]="CCPMBiobank_MEGA2_A1.bpm" )

###########################################################################
# Run gtc2vcf on GTC directory
###########################################################################

for pfx in 20180117 20200110; do
    workdir=$GSA_DIR/${wdir[$pfx]}
    wdr=${wdir[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    touch $wdr.GRCh38.bcf
    touch $wdr.index.GRCh38.bcf
    if [ -n "$sam" ]; then \
	bcftools +gtc2vcf -Ou -f $ref -b $bpm -e $egt -c $csv -s $sam --gtcs $workdir/GTCs -x $workdir/$wdr.sex;
    else \
	bcftools +gtc2vcf -Ou -f $ref -b $bpm -e $egt -c $csv --gtcs $workdir/GTCs -x $workdir/$wdr.sex; \
    fi | \
	bcftools sort -Oz -T ./bcftools-sort.XXXXXX | \
	bcftools reheader -s $workdir/$wdr.map.tsv | \
	bcftools norm --no-version -Ou -o  $workdir/$wdr.GRCh38.bcf -c x -f $ref && \
	bcftools index -f  $workdir/$wdr.GRCh38.bcf
#        bcftools +gtc2vcf --no-version -c $csv -s $sam -o ${csv%.csv}.GRCh38.csv
done
