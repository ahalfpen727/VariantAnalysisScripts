###########################################################################
## DOWNLOAD CLINVAR ANNOTATIONS                                          ##
###########################################################################

date="20200127"

mkdir -p $HOME/res/clinvar && cd $HOME/res/clinvar

/bin/rm clinvar_$date.vcf.gz{,.md5,.tbi}

wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar_$date.vcf.gz{,.md5,.tbi}
zcat clinvar_$date.vcf.gz | \
  awk -F"\t" -v OFS="\t" '$0~"##INFO=<ID=AF_ESP" {
  print "##INFO=<ID=VARIATIONID,Number=1,Type=Integer,Description=\"the ClinVar Variation ID\">"}
  $0!~"^#" {$8="VARIATIONID="$3";"$8; $3="."} {print}' | \
  bcftools view --no-version -Oz -o clinvar_$date.GRCh37.vcf.gz && \
  bcftools index -ft clinvar_$date.GRCh37.vcf.gz
/bin/rm clinvar_$date.vcf.gz{,.md5,.tbi}

/bin/rm clinvar_$date.vcf.gz{,.md5,.tbi}

wget ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar_$date.vcf.gz{,.md5,.tbi}
zcat clinvar_$date.vcf.gz | sed -e 's/^/chr/' -e 's/^chr#/#/' -e 's/^chrMT/chrM/' | \
  awk -F"\t" -v OFS="\t" '$0~"##INFO=<ID=AF_ESP" {
  print "##INFO=<ID=VARIATIONID,Number=1,Type=Integer,Description=\"the ClinVar Variation ID\">"}
  $0!~"^#" {$8="VARIATIONID="$3";"$8; $3="."} {print}' | bgzip > clinvar_$date.GRCh38.vcf.gz
tabix -f clinvar_$date.GRCh38.vcf.gz

/bin/rm clinvar_$date.vcf.gz{,.md5,.tbi}

###########################################################################
## DOWNLOAD ENSEMBL GENE MODELS                                          ##
###########################################################################

mkdir -p $HOME/res/ensembl && cd $HOME/res/ensembl

wget ftp://ftp.ensembl.org/pub/release-98/gff3/homo_sapiens/Homo_sapiens.GRCh38.98.gff3.gz
zcat Homo_sapiens.GRCh38.98.gff3.gz | \
  sed -e 's/^##sequence-region   \([0-9XY]\)/##sequence-region   chr\1/' \
  -e 's/^##sequence-region   MT/##sequence-region   chrM/' \
  -e 's/^\([0-9XY]\)/chr\1/' -e 's/^MT/chrM/' | gzip > Homo_sapiens.GRCh38.fixed.98.gff3.gz

###########################################################################
## RESOURCES FOR MOCHA                                                   ##
###########################################################################

# https://github.com/freeseek/mocha#download-resources-for-grch38

###########################################################################
## RESOURCES FOR GATK                                                    ##
###########################################################################

wget -P $HOME/res https://github.com/broadinstitute/picard/releases/download/2.19.0/picard.jar

wget -P $HOME/res https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip
unzip -od $HOME/res $HOME/res/gatk-4.1.3.0.zip

mkdir -p $HOME/res/vqsr
wget -P $HOME/res/vqsr ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/{hapmap_3.3,1000G_omni2.5,1000G_phase1.snps.high_confidence,Mills_and_1000G_gold_standard.indels,Axiom_Exome_Plus.genotypes.all_populations.poly}.hg38.vcf.gz{,.csi}

wget -P $HOME/bin http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
chmod a+x $HOME/bin/liftOver
wget -P $HOME/res http://hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
