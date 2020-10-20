#!bin/bash

####################################################                                               
# Set env variables and  work directory                                                            ####################################################                                                                                                            
export REFDIR="/media/drew/easystore/ReferenceGenomes"
export IDXDIR=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export REFFA=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
cd $IDXDIR

#wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr{{1..22},X,Y}_GRCh38.genotypes.20170504.vcf.gz{,.tbi}

#for chr in {1..22} X Y; do
for chr in X Y; do
  (bcftools view --no-version -h ALL.chr${chr}_GRCh38.genotypes.20170504.vcf.gz | \
    grep -v "^##contig=<ID=[GNh]" | sed 's/^##contig=<ID=MT/##contig=<ID=chrM/;s/^##contig=<ID=\([0-9XY]\)/##contig=<ID=chr\1/'; \
  bcftools annotate --no-version -x INFO/END ALL.chr${chr}_GRCh38.genotypes.20170504.vcf.gz | \
  bcftools view --no-version -H -c 2 | \
  grep -v "[0-9]|\.\|\.|[0-9]" | sed 's/^/chr/') | \
  bcftools norm --no-version -Ou -m -any | \
  bcftools norm --no-version -Ob -o ALL.chr${chr}_GRCh38.genotypes.20170504.bcf \
	   -d none -f $REFFA && bcftools index -f ALL.chr${chr}_GRCh38.genotypes.20170504.bcf
done
