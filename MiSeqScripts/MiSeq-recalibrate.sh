#!bin/bash

###########################################################################
# MISEQ DATA                                                            
# PILOT DATA                                                           
###########################################################################

export REFDIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/

export IDX_DIR=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set

export REF_FILE=$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDX_DIR; do
    ln -s $file
done

cd ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq
find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 >> ../sm.txt

mkdir -P ../MiSeqResults/raw-sams
mkdir -P ../MiSeqResults/raw-bams
mkdir -P ../MiSeqResults/tmp-bams
mkdir -P ../MiSeqResults/idx-bams
###########################################################################
## RECALIBRATE BASE PAIRS                                                ##
###########################################################################

ln -s $HOME/bin/gatk-4.1.3.0
ln -s $HOME/Downloads/GCA_000001405.15_GRCh38_no_alt_analysis_set.dict
ln -s $HOME/res/vqsr/1000G_phase1.snps.high_confidence.hg38.vcf.gz
ln -s $HOME/res/vqsr/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat sm.txt) ); \
  sm=${sm_arr[(($i-1))]}; \
  gatk-4.1.3.0/gatk \
    BaseRecalibrator \
    -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
    -I $sm.tmp.bam \
    --known-sites 1000G_phase1.snps.high_confidence.hg38.vcf.gz \
    -O $sm.grp && \
  gatk-4.1.3.0/gatk \
    ApplyBQSR \
    -R GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
    -I $sm.tmp.bam \
    --bqsr-recal-file $sm.grp \
    -O $sm.bam && \
  samtools index $sm.bam
done
