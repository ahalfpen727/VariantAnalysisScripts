#!bin/bash

###########################################################################
# set env variables for index locations
###########################################################################
export GSADIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export MEGADIR=/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0
export REFDIR=/media/drew/easystore/ReferenceGenomes
export INDEXDIR=$REF_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export ref=$INDEX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export reffai=$INDEX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai

for file in $INDEXDIR; do
    ln -s $file
done

###########################################################################
# CONVERT DATA FROM GTC TO VCF
###########################################################################

#bcftools +gtc2vcf -c $MEGA_DIR/CCPMBiobankMEGA2_20002558X345183_A1.csv --fasta-flank | \
#  bwa mem -M $ref - | samtools view -bS -o $MEGA_DIR/CCPMBiobankMEGA2_20002558X345183_A1.bam

declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X345183_A1.bam" )

###########################################################################
# Run gtc2vcf on GTC directory
###########################################################################

for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    export GSA_DIR=$GSADIR/$wdir
    cd $GSA_DIR
    touch $wdir.$gsa.bcf
    if [ -n "$sam" ]; then \
	# bcftools +gtc2vcf --no-version -Ou -f $ref -b $bpm -e $egt -c $csv -g GTCs -x $wdir.tsv | \
	bcftools +gtc2vcf --no-version -Ou -f $ref -b "$bpm" -c $csv -e "$egt" -s "$sam" -g GTCs -x $pfx.sex; \
    else \
	bcftools +gtc2vcf --no-version -Ou -f $ref -b "$bpm" -c $csv -e "$egt" -g GTCs -x $pfx.sex; \
    fi | \
	bcftools sort -Ou -T ./bcftools-sort.XXXXXX | \
	bcftools reheader -s $pfx.map.tsv | \
	bcftools norm --no-version -Ob -o $wdir.$gsa.GRCh38.bcf -f $ref -c x && \
	bcftools index -f $wdir.$gsa.GRCh38.bcf
        # bcftools +gtc2vcf --no-version -c $csv -s $sam -o ${csv%.csv}.GRCh38.csv
done
