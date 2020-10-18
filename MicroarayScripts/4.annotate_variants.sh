#!bin/bash

##########################################################################
# set env variable and link ref files
###########################################################################

export GSADIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export REFDIR=/media/drew/easystore/ReferenceGenomes
export CLINGCF=$REFDIR/GRCh38/clinvar.GRCh38.vcf.gz
export ALLGCF=$REFDIR/GRCh38/All_human_9606_b144_GRCh38p2.2015.vcf.gz
export REFIDX=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFGFF=$REFDIR/ensembl/Homo_sapiens.GRCh38.fixed.98.gff3.gz
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

cd $REFDIR/GRCh38
touch sm.file.txt
touch sm.txt
export INPUTFILE=./sm.file.txt
export INPUT_FILE=./sm.txt

find -iname "*.vcf.gz" > $INPUTFILE
for i in $(cat $INPUTFILE); do
    tabix -p $i
done

cd $GSADIR

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_\
A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0\
/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0\
_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

##########################################################################
## Annotate variants using reference VCFs
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
    list="KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
    bcftools annotate --no-version -Ou -a $ALLGCF -c $list $wdir.$gsa.GRCh38.bcf | \
    bcftools csq --no-version -Ob -o $wdir.GRCh38.bcf -f $REFFA -g $REFGFF \
		 -b -l -n 128 && bcftools index -f $wdir.$gsa.GRCh38.bcf
    list="VARIATIONID,EXAC_AF:=AF_EXAC,CLNDN,CLNSIG,GENEINFO,MC,RS"
    bcftools annotate --no-version -Ob -o $wdir.clinvar.GRCh38.bcf  \
	     -a $CLINGCF -c $list $wdir.$gsa.GRCh38.bcf && \
	bcftools index -f $wdir.clinvar.GRCh38.bcf
done
