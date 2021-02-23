#!bin/bash

##########################################################################
# set env variable and link ref files
###########################################################################
export ANALYSIS=/media/drew/easystore/Current-Analysis/AnalysisBaseDir
export GSADIR=/media/drew/easystore/Current-Analysis/AnalysisBaseDir/GSA_Data
export REFDIR=/media/drew/easystore/ReferenceGenomes
export REFIDX=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$REFIDX/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFGFF=$REFDIR/GRCh38/Ensembl/Homo_sapiens.GRCh38.fixed.101.gff3.gz
export CLINVCF=$REFDIR/GRCh38/ClinVar/clinvar_20200810.vcf.gz
export CLINTBI=$REFDIR/GRCh38/ClinVar/clinvar_20200810.vcf.gz.tbi
export G1000VCF=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export G1000TBI=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi
export ALLBCF=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.gz
export ALLCSI=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.csi
export ACMG59=$REFDIR/GRCh38/acmg59.txt
export RSCRIPT=$ANALYSIS/VariantAnalysisScripts/MicroarayScripts/gtc2vcf_plot.R

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="$REFDIR/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="$REFDIR/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.bpm" )
declare -A egt=( ["20180117"]="$REFDIR/GRCh38/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="$REFDIR/GRCh38/GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="$REFDIR/GRCh38/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="$REFDIR/GRCh38/GSA_24v2_0/GSA-24v2-0_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="$REFDIR/GRCh38/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )
declare -A opts=( ["20180117"]="" ["20200110"]="-s ^8033684100" )

###########################################################################
## EXTRACT ACMG59 TABLE                     
###########################################################################

# seq-rs587779333.1 seem monomorphic for the wrong allele
# rs80357962 and rs886040223 seem to be too polymorphic to be BRCA1 frameshift variants

hdr="SAMPLE\tGT\tGQ\tCHROM\tPOS_GRCh38\tID\tREF\tALT\tKGP_AF\tEAS_AF\tEUR_AF\tAFR_AF\tAMR_AF\tSAS_AF\tEXAC_AF\tURL\tCLNDN\tCLNSIG\tGENEINFO\tMC\tCSQ"
fmt="[%SAMPLE\t%GT\t%GQ\t%CHROM\t%POS\t%ID\t%REF\t%ALT\t%KGP_AF\t%EAS_AF\t%EUR_AF\t%AFR_AF\t%AMR_AF\t%SAS_AF\t%EXAC_AF\thttps://www.ncbi.nlm.nih.gov/clinvar/variation/%VARIATIONID\t%CLNDN\t%CLNSIG\t%GENEINFO\t%\MC\t%INFO/BCSQ\n]"


for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    opt=${opts[$pfx]}
    cd $wdir
    export VCFOUT=BCF_and_VCF_Files
    touch $pfx.acmg59.tsv
    touch $wdir.acmg59.tsv
    mkdir -p $VCFOUT
    (echo -e "$hdr"; \
     bcftools view --no-version -Ou -c 1 -i 'CLNDN!="." && \
     	      (CLNSIG=="Pathogenic" || CLNSIG=="Likely_pathogenic" || CLNSIG=="Pathogenic/Likely_pathogenic") && \
	      ID!="rs59684335" && ID!="seq-rs786202200" && ID!="seq-rs797045904" &&  ID!="seq-rs730880361" && \
	      ID!="seq-rs727503172" && ID!="seq-rs397515087" && ID!="seq-rs587779333.1" && ID!="rs80357962" && ID!="rs886040223"' $VCFOUT/$wdir.clinvar.GRCh38.bcf | \
	 bcftools query $opt -f "$fmt" -i 'GT!="./." & GT!="0/0"' | awk -v pfx="$wdir" 'NR==FNR {x[$1]++} \
	 	  NR>FNR {split($19,a,"|"); for (i in a) {split(a[i],b,":");
		   if (b[1] in x) print $0"\thttps://personal.broadinstitute.org/giulio/goodcell/mocha/"pfx"."$6".png"}}' $ACMG59 -) | grep -v ^203533890075 > $pfx.acmg59.tsv
    mkdir -p pngs
    for snp in chr19:44908684:rs429358 chr7:6009019:seq-rs587779333.1 chr17:43092919:rs80357962 chr17:43082452:rs886040223 $(tail -n+2 $wdir.acmg59.tsv | cut -f4-6 | tr '\t' ':' | sort | uniq); do
	chr=$(echo $snp | cut -d: -f1)
	pos=$(echo $snp | cut -d: -f2)
	id=$(echo $snp | cut -d: -f3)
	$RSCRIPT --illumina --vcf $VCFOUT/$wdir.clinvar.GRCh38.bcf --chrom $chr --pos $pos --id $id --png pngs/$wdir.$id.png
    done
    cd ../
done
