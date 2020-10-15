#!bin/bash
# Reference Genome Retreival Script
export REFDIR="/media/drew/easystore/ReferenceGenomes/GRCh37"
cd $REFDIR
# GRCh37
wget -O- ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz | gzip -d > human_g1k_v37.fasta
samtools faidx human_g1k_v37.fasta

# Genetic map
wget https://data.broadinstitute.org/alkesgroup/Eagle/downloads/tables/genetic_map_hg19_withX.txt.gz

# 1000 Genomes project phase 3
for chr in {1..22} X Y; do
    bcftools view --no-version -Ou -c 2 ALL.chr${chr}.phase3*integrated_v[125][ab].20130502.genotypes.vcf.gz | \
	bcftools norm --no-version -Ou -m -any | \
	bcftools norm --no-version -Ob -o ALL.chr${chr}.phase3_integrated.20130502.genotypes.bcf -d none -f human_g1k_v37.fasta && \
	bcftools index -f ALL.chr${chr}.phase3_integrated.20130502.genotypes.bcf
done

# List of common germline duplications and deletions
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/integrated_sv_map/ALL.wgs.mergedSV.v8.20130502.svs.genotypes.vcf.gz{,.tbi}
bcftools query -i 'AC>1 && END-POS+1>10000 && SVTYPE!="INDEL" && (SVTYPE=="CNV" || SVTYPE=="DEL" || SVTYPE=="DUP")' \
	 -f "%CHROM\t%POS0\t%END\t%SVTYPE\n" ALL.wgs.mergedSV.v8.20130502.svs.genotypes.vcf.gz > cnp.grch37.bed

# Minimal divergence intervals from segmental duplications
wget -O- http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/genomicSuperDups.txt.gz | gzip -d |
  awk '!($2=="chrX" && $8=="chrY" || $2=="chrY" && $8=="chrX") {print $2"\t"$3"\t"$4"\t"$30}' > genomicSuperDups.bed

awk '{print $1,$2; print $1,$3}' genomicSuperDups.bed | \
  sort -k1,1 -k2,2n | uniq | \
  awk 'chrom==$1 {print chrom"\t"pos"\t"$2} {chrom=$1; pos=$2}' | \
  bedtools intersect -a genomicSuperDups.bed -b - | \
  bedtools sort | \
  bedtools groupby -c 4 -o min | \
  awk 'BEGIN {i=0; s[0]="+"; s[1]="-"} {if ($4!=x) i=(i+1)%2; x=$4; print $0"\t0\t"s[i]}' | \
  bedtools merge -s -c 4 -o distinct | \
  sed 's/^chr//' | grep -v gl | bgzip > dup.grch37.bed.gz && \
  tabix -f -p bed dup.grch37.bed.gz

# Download cytoband file
wget -O cytoBand.hg19.txt.gz http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz


# Setup variables
ref="$REFDIR/human_g1k_v37.fasta"
mhc_reg="6:27486711-33448264"
kir_reg="19:54574747-55504099"
map="$REFDIR/genetic_map_hg19_withX.txt.gz"
kgp_pfx="$REFDIR/ALL.chr"
kgp_sfx=".phase3_integrated.20130502.genotypes"
rule="GRCh37"
cnp="$REFDIR/cnp.grch37.bed"
dup="$REFDIR/dup.grch37.bed.gz"
cyto="$REFDIR/cytoBand.hg19.txt.gz"
