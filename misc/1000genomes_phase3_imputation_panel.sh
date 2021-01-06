#!bin/bash
export WORKDIR=/media/drew/easystore/ReferenceGenomes/GRCh38
export WORKFILE=$WORKDIR/ALL.chrs_GRCh38.genotypes.20170504.bcf

cd $WORKDIR
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr{{1..22}.phase3_shapeit2_mvncall_integrated_v5a,X.phase3_shapeit2_mvncall_integrated_v1b,Y.phase3_integrated_v2a}.20130502.genotypes.vcf.gz{,.tbi}
for chr in {1..22} X Y; do
  bcftools view --no-version -Ou -c 2 ALL.chr${chr}.phase3*integrated_v[125][ab].20130502.genotypes.vcf.gz | \
  bcftools norm --no-version -Ou -m -any | \
  bcftools norm --no-version -Ob -o ALL.chr${chr}.phase3_integrated.20130502.genotypes.bcf -d none -f human_g1k_v37.fasta && \
  bcftools index -f ALL.chr${chr}.phase3_integrated.20130502.genotypes.bcf
done

for chr in {1..22} X; do
  if [ $chr == "X" ]; then
    bcftools +fixploidy --no-version ALL.chr$chr.phase3_integrated.20130502.genotypes.bcf -- -f 2 | \
      sed -e 's/\t0\/0/\t0|0/' -e 's/\t1\/1/\t1|1/' > tmp.chr$chr.GRCh37.vcf
  else
    bcftools view --no-version ALL.chr$chr.phase3_integrated.20130502.genotypes.bcf -o tmp.chr$chr.GRCh37.vcf
  fi
  minimac4 \ # Minimac3-omp
    --refHaps tmp.chr$chr.GRCh37.vcf \
    --processReference \
    --myChromosome $chr \
    --prefix ALL.chr$chr.phase3_integrated.20130502.genotypes \
    --noPhoneHome
  /bin/rm tmp.chr$chr.GRCh37.vcf
done
