#!bin/bash

###########################################################################
# Export Env Variables
###########################################################################

export GATK=$HOME/toolbin/gatk-4.1.8.1/gatk
export REFDIR=/media/drew/easystore/ReferenceGenomes
export GFFGZ=$REFDIR/GRCh38/Ensembl/Homo_sapiens.GRCh38.fixed.101.gff3.gz
export IDXDIR=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export CLINVCF=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf
export CLINGZ=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf.gz
export CLINTBI=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf.gz.tbi
export VCF1000G=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export TBI1000G=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
export ALLBCF=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf
export ALLGZ=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.gz
export ALLCSI=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.csi

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="MiSeq_Results_out/Mutect2_out" ["2019_12"]="MiSeq_Results_out/Mutect2_out" )

for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    cd $miseqdir
    for pfx in hc m2; do
	list="KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
	touch $datadir/$pfx.csq.GRCh38.bcf
	bcftools annotate --no-version -Ou -a $ALLGZ -c $list $datadir/$pfx.GRCh38.bcf | \
	    bcftools csq --no-version -Ob -o $datadir/$pfx.csq.GRCh38.bcf -f $REFFA -g $GFFGZ -b -l -n 64 \
		     -s - && bcftools index -f $datadir/$pfx.csq.GRCh38.bcf
	list="VARIATIONID,EXAC_AF:=AF_EXAC,CLNDN,CLNSIG,GENEINFO,MC,RS"
	touch $datadir/$pfx.clinvar.GRCh38.bcf
	bcftools annotate --no-version -Ob -o $datadir/$pfx.clinvar.GRCh38.bcf -a $CLINGZ -c $list  $datadir/$pfx.csq.GRCh38.bcf
	bcftools index -f $datadir/$pfx.clinvar.GRCh38.bcf
    done
    cd ../
done
