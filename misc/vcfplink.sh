#!bin/bash
export REFFA=/media/drew/easystore/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for chr in {1..22} X; do
    bgzip -f chr$chr.1kg.phase3.v5a.vcf
    tabix -f chr$chr.1kg.phase3.v5a.vcf.gz
    bcftools norm -Ou -m -any chr$chr.1kg.phase3.v5a.vcf.gz |
      bcftools norm -Ou -f $REFFA |
    bcftools annotate -Ob -x ID \
      -I +'%CHROM:%POS:%REF:%ALT' |
    $HOME/toolbin/plink --bcf /dev/stdin \
      --keep-allele-order \
      --vcf-idspace-to _ \
      --const-fid \
      --allow-extra-chr 0 \
      --split-x b37 no-fail \
      --make-bed \
      --out kgp.chr$chr
done
