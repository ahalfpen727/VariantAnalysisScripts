#!bin/bash

##########################################################################                                                                                                                                         
# set env variable and link ref files                                                                                                                                                                              
###########################################################################                                                                                                                                        

export RSCRIPT=$ANALYSIS/VariantAnalysisScripts/MicroarayScripts/gtc2vcf_plot.R                                                                                                                                    
export REFDIR=/media/drew/easystore/ReferenceGenomes                                                                                                                                                               
export REFIDX=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set                                                                                                                                           
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna                                                                                                                                        
export REFGFF=$REFDIR/GRCh38/Ensembl/Homo_sapiens.GRCh38.fixed.101.gff3.gz                                                                                                                                         
export CLINVCF=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf.gz                                                                                                                                                      
export CLINTBI=$REFDIR/GRCh38/ClinVar/clinvar_20200810.GRCh38.vcf.gz.tbi                                                                                                                                                  
export G1000VCF=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz                                                                                                                                  
export G1000TBI=$REFDIR/1000Genomes/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi                                                                                                                              
export ALLBCF=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.gz                                                                                                                                             
export ALLCSI=$REFDIR/GRCh38/ALL.chrs_GRCh38.genotypes.20170504.bcf.csi                                                                                                                                            
export ACMG59=$REFDIR/GRCh38/acmg59.txt                                                                                                                                                                            

bcftools norm -Ou -m -any $CLINVCF |
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
    --out output
