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
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

ln -s $HOME/res/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}
for sm in ${sm_arr[@]}; do
  bedtools coverage -g GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai -sorted -a 3215481_Covered.GRCh38.bed -b $sm.bam -mean | \
  cut -f5 > $sm.cov
done
(echo -en "CHROM\tBEG\tEND\tNAME\t"; tr '\n' '\t' < sm.txt | sed 's/\t$/\n/'; \
paste 3215481_Covered.GRCh38.bed $(cat sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')) \
  > 3215481_Covered.GRCh38.tsv
/bin/rm $(cat sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')
