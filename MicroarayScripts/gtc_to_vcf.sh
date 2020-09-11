#!bin/bash
export REFDIR="$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes"
ref="$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A gsadir=( ["20180117"]="GSA_24v1_0" ["20200110"]="GSA_24v2_0" )
declare	-A bpms=( ["20180117"]="GSA_24v1_0/GSA-24v2-0_A1.bpm" ["20200110"]="GSA_24v2_0/GSA-24v2-0_A1.bpm" )
declare -A egts=( ["20180117"]="GSA_24v1_0/GSA-24v2-0_A1_ClusterFile.egt" ["20200110"]="GSA_24v2_0/GSA-24v2-0_A1_ClusterFile.egt" )
for file in $REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set; do
    ln -s $file
done
##########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################
for pfx in 20200110; do
  bpm=${bpms[$pfx]}
  egt=${egts[$pfx]}
  csv=${csvs[$pfx]}
  sam=${sams[$pfx]}
  gsadir=${gsadir[$pfx]}
done
  
ln -s $REFDIR/$bpm
ln -s $REFDIR/$egt
ln -s $REFDIR/$csv

if [ -n "$sam" ]; then
  ln -s "../../$sam"
fi

bcftools +gtc2vcf -f $ref  -b $REFDIR/$bpm -e $REFDIR/$egt -x $pfx.sex --output-type v -g GTCs -o $gsadir.vcf
    # bcftools +gtc2vcf --no-version -c $csv -s $sam -o ${csv%.csv}.GRCh38.csv
if [ -n "$ref" ]; then \
  bcftools +gtc2vcf -f $ref  -b $REFDIR/$bpm -e $REFDIR/$egt -x $pfx.sex --output-type v -g GTCs -o $gsadir.vcf -x $pfx.sex; \
else \
  bcftools +gtc2vcf -f $ref  -b $REFDIR/$bpm -e $REFDIR/$egt -x $pfx.sex --output-type v -g GTCs -o $gsadir.vcf -x $pfx.sex; \
fi | \
  bcftools sort -Ou -T ./bcftools-sort.XXXXXX | \
  bcftools reheader -s map.tsv | \
  bcftools norm --no-version -Ob -o $pfx.GRCh38.bcf -c x -f $ref && \
  bcftools index -f $pfx.GRCh38.bcf

# bcftools +gtc2vcf --no-version -c $csv -s $sam -o ${csv%.csv}.GRCh38.csv

###########################################################################
## ANNOTATE VARIANTS                                                     ##
###########################################################################

ln -s $HREFDIR/ensembl/Homo_sapiens.GRCh38.fixed.98.gff3
ln -s $REFDIR/clinvar/clinvar.GRCh38.vcf
ln -s $REFDIR/clinvar/clinvar.GRCh38.vcf.gz.tbi
ln -s $REFDIR/ALL.GRCh38_sites.20170504.bcf
ln -s $REFDIR/ALL.GRCh38_sites.20170504.bcf.csi

list="KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
bcftools annotate --no-version -Ou -a ALL.GRCh38_sites.20170504.bcf -c $list $pfx.GRCh38.bcf | \
  bcftools csq --no-version -Ob -o $pfx.csq.GRCh38.bcf -f GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
  -g Homo_sapiens.GRCh38.fixed.98.gff3.gz -b -l -n 128 && \
  bcftools index -f $pfx.csq.GRCh38.bcf && \
  /bin/rm $pfx.GRCh38.bcf{,.csi}

list="VARIATIONID,EXAC_AF:=AF_EXAC,CLNDN,CLNSIG,GENEINFO,MC,RS"
bcftools annotate --no-version -Ob -o $pfx.clinvar.GRCh38.bcf -a clinvar.GRCh38.vcf.gz -c $list $pfx.csq.GRCh38.bcf && \
  bcftools index -f $pfx.clinvar.GRCh38.bcf && \
  /bin/rm $pfx.csq.GRCh38.bcf{,.csi}
