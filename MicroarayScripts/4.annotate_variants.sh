#!bin/bash

##########################################################################
# set env variable and link ref files
###########################################################################
    
export REFDIR=/media/drew/easystore/ReferenceGenomes
export REFIDX=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFGFF=$REFDIR/GRCh38/Ensembl/Homo_sapiens.GRCh38.fixed.101.gff3.gz
export CLINVCF=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf.gz
export CLINTBI=$REFDIR/GRCh38/ClinVar/clinvar_20200810.vcf.gz.tbi
export G1000VCF=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export G1000TBI=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
export ALLBCF=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.gz
export ALLCSI=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.csi

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/GRCh38/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

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
    cd $wdir
    mkdir -p BCF_and_VCF_Files
    export VCFOUT=BCF_and_VCF_Files
    export INDIR=GTC2VCF
    export list1="KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
    export list2="EXAC_AF:=AF_EXAC,CLNDN,CLNSIG,GENEINFO,MC,RS"
    bcftools annotate --no-version -Ou -a $ALLBCF -c $list1 $INDIR/$wdir.$gsa.GRCh38.bcf | \
	bcftools csq --no-version -Ob -o $VCFOUT/$wdir.$gsa.csq.GRCh38.bcf -f $REFFA -g $REFGFF -b -l -n 128 && \
	bcftools index -f  $VCFOUT/$wdir.$gsa.csq.GRCh38.bcf
    bcftools annotate --no-version -Ob -o $VCFOUT/$wdir.clinvar.GRCh38.bcf -a $CLINVCF -c $list2  $VCFOUT/$wdir.$gsa.csq.GRCh38.bcf && \
	bcftools index -f  $VCFOUT/$wdir.clinvar.GRCh38.bcf
    cd ../
done

