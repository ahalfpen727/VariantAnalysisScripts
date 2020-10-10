#!bin/bash
## RECALIBRATE BASE PAIRS
export REFDIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes
for file in $REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/*; do ln -s $file; done       
ln -s $HOME/gatk-4.1.3.0/gatk                                                                          
ln -s $REFDIR/HG38/1000G_phase1.snps.high_confidence.hg38.vcf                                       
ln -s $REFDIR/HG38/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi                                   
                                                                                                       
sm_arr=( $(cat ../sm.txt) )                                                                            
n=${#sm_arr[@]}                                                                                        
#for i in $(seq 1 $n); do                                                                               
#  sm_arr=( $(cat ../sm.txt) ); \                                                                       
#  sm=${sm_arr[(($i-1))]}; \                                                                            
#  $HOME/gatk-4.1.7.0/gatk BaseRecalibrator -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
#  -I $sm.tmp.bam --known-sites $REFDIR/HG38/1000G_phase1.snps.high_confidence.hg38.vcf -O $sm.grp
#done
for i in $(seq 1 $n); do                                                                               
  sm_arr=( $(cat ../sm.txt) ); \                                                                        
  sm=${sm_arr[(($i-1))]}; \
  $HOME/gatk-4.1.7.0/gatk ApplyBQSR -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
  -I $sm.tmp.bam --bqsr-recal-file $sm.grp -O $sm.v2.bam && samtools index $sm.bam                                  
done                   
