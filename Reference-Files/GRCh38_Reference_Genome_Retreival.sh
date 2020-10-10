#!bin/bash
# GRCh38 Reference Genome Retreival Script
export REFDIR="/media/drew/easystore/ReferenceGenomes/GRCh38"
cd $REFDIR
ref="$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"

#wget -O- ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz | \
#    gzip -d > $REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
#samtools faidx $REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

# Genetic map
wget https://data.broadinstitute.org/alkesgroup/Eagle/downloads/tables/genetic_map_hg38_withX.txt.gz

# 1000Genomes phase3
# (fixing contig names, removing duplicate variants, removing incomplete variants)
wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr{{1..22},X,Y}_GRCh38.genotypes.20170504.vcf.gz{,.tbi}
for chr in {1..22} X Y; do
  (bcftools view --no-version -h ALL.chr${chr}_GRCh38.genotypes.20170504.vcf.gz | \
    grep -v "^##contig=<ID=[GNh]" | sed 's/^##contig=<ID=MT/##contig=<ID=chrM/;s/^##contig=<ID=\([0-9XY]\)/##contig=<ID=chr\1/'; \
  bcftools annotate --no-version -x INFO/END ALL.chr${chr}_GRCh38.genotypes.20170504.vcf.gz | \
  bcftools view --no-version -H -c 2 | \
  grep -v "[0-9]|\.\|\.|[0-9]" | sed 's/^/chr/') | \
  bcftools norm --no-version -Ou -m -any | \
  bcftools norm --no-version -Ob -o ALL.chr${chr}_GRCh38.genotypes.20170504.bcf -d none -f $ref && \
  bcftools index -f ALL.chr${chr}_GRCh38.genotypes.20170504.bcf
done

# List of common germline duplications and deletions
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/integrated_sv_map/supporting/GRCh38_positions/ALL.wgs.mergedSV.v8.20130502.svs.genotypes.GRCh38.vcf.gz{,.tbi}
bcftools query -i 'AC>1 && END-POS+1>10000 && SVTYPE!="INDEL" && (SVTYPE=="CNV" || SVTYPE=="DEL" || SVTYPE=="DUP")' \
	 -f "chr%CHROM\t%POS0\t%END\t%SVTYPE\n" ALL.wgs.mergedSV.v8.20130502.svs.genotypes.GRCh38.vcf.gz > cnp.grch38.bed

# Minimal divergence intervals from segmental duplications
wget -O- http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/genomicSuperDups.txt.gz | gzip -d |
  awk '!($2=="chrX" && $8=="chrY" || $2=="chrY" && $8=="chrX") {print $2"\t"$3"\t"$4"\t"$30}' > genomicSuperDups.bed

awk '{print $1,$2; print $1,$3}' genomicSuperDups.bed | \
  sort -k1,1 -k2,2n | uniq | \
  awk 'chrom==$1 {print chrom"\t"pos"\t"$2} {chrom=$1; pos=$2}' | \
  bedtools intersect -a genomicSuperDups.bed -b - | \
  bedtools sort | \
  bedtools groupby -c 4 -o min | \
  awk 'BEGIN {i=0; s[0]="+"; s[1]="-"} {if ($4!=x) i=(i+1)%2; x=$4; print $0"\t0\t"s[i]}' | \
  bedtools merge -s -c 4 -o distinct | \
  grep -v "GL\|KI" | bgzip > dup.grch38.bed.gz && \
    tabix -f -p bed dup.grch38.bed.gz


# Download cytoband file
wget -O cytoBand.hg38.txt.gz http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz

# Setup variables
mhc_reg="chr6:27518932-33480487"
kir_reg="chr19:54071493-54992731"
map="$REFDIR/genetic_map_hg38_withX.txt.gz"
kgp_pfx="$REFDIR/ALL.chr"
kgp_sfx="_GRCh38.genotypes.20170504"
rule="GRCh38"
cnp="$REFDIR/cnp.grch38.bed"
dup="$REFDIR/dup.grch38.bed.gz"
cyto="$REFDIR/cytoBand.hg38.txt.gz"
