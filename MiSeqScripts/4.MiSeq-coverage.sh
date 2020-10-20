#!bin/bash

###########################################################################
# MISEQ DATA                                                            
# PILOT DATA                                                           
###########################################################################

export REFDIR=/media/drew/easystore/ReferenceGenomes/
export BEDDIR=/media/drew/easystore/ReferenceGenomes/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.bed
export IDXDIR=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFILE=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$IDXDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai

for file in $IDXDIR; do
    ln -s $file
done

#cd ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq
#find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 >> ../sm.txt

###########################################################################
## COMPUTE COVERAGE OVER TARGETS                                         ##
###########################################################################

sm_arr=( $(cat sm.txt) )
n=${#sm_arr[@]}
for sm in ${sm_arr[@]}; do
  bedtools coverage -g $REFFAI -sorted -a $BEDFILE -b $sm.bam -mean | \
  cut -f5 > $sm.cov
done
(echo -en "CHROM\tBEG\tEND\tNAME\t"; tr '\n' '\t' < sm.txt | sed 's/\t$/\n/'; \
 paste $BEDFILE $(cat sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')) \
    > 3215481_Covered.GRCh38.tsv
#/bin/rm $(cat sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')
