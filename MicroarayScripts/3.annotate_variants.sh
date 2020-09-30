#!bin/bash
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                    
# set env variable and link ref files
###########################################################################
export REFDIR="/media/drew/easystore/ReferenceGenomes"
export REFIDX=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export wrkdr="/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data"
export REFFA="$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
export REFGFF=$REFDIR/ensembl/Homo_sapiens.GRCh38.fixed.98.gff3
for f in $REFIDX/; do
    ln -s $f
done

for f in $REFDIR/VCFs; do
    ln -s $f
done

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
    list="KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
    bcftools annotate --no-version -Ou -a $REFDIR/VCFs/ALL_20180418.vcf.gz \
	     -c $list $wrkdr/$dir/$pfx.GRCh38.bcf | \
	bcftools csq --no-version -Ob -o $wrkdr/$dir/$pfx.GRCh38.bcf.gz \
		 -f $REFFA -g $REFGFF -b -l -n 128 && \
	bcftools index -f $wrkdr/$dir/$pfx.GRCh38.bcf.gz
done

for pfx in 20180117 20200110; do
    dir=${dirs[$pfx]}
    bpm=${bpms[$pfx]}
    egt=${egts[$pfx]}
    list="VARIATIONID,EXAC_AF:=AF_EXAC,CLNDN,CLNSIG,GENEINFO,MC,RS"
    bcftools annotate --no-version -Ob -o $wrkdr/$dir/$pfx.clinvar.GRCh38.bcf  \
	     -a $REFDIR/VCFs/clinvar.GRCh38.vcf -c $list $wrkdr/$dir/$pfx.GRCh38.bcf.gz && \
	bcftools index -f $wrkdr/$dir/$pfx.clinvar.GRCh38.bcf
done
