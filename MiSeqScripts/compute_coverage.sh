#!bin/bash
export REFDIR="$HOME/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes"
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A gsadir=( ["20180117"]="GSA_24v1_0" ["20200110"]="GSA_24v2_0" )
declare -A bpms=( ["20180117"]="GSA_24v1_0/GSA-24v1-0_A1.bpm" ["20200110"]="GSA_24v2_0/GSA-24v2-0_A1.bpm" )
declare -A egts=( ["20180117"]="GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="GSA_24v2_0/GSA-24v2-0_A1_Clu\
sterFile.egt" )
for file in $REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set; do
    ln -s $file
done
   
for pfx in 20180117; do
  bpm=${bpms[$pfx]}
  egt=${egts[$pfx]}
  csv=${csvs[$pfx]}
  sam=${sams[$pfx]}
  gsadir=${gsadir[$pfx]}
done
bwadir=bwa-bams
ref=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
reffai=$REFDIR/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
sm_arr=( $(cat /sm.txt) )
n=${#sm_arr[@]}
for sm in ${sm_arr[@]}; do
  bedtools coverage -g $reffai -sorted -bed 3215481_Covered.GRCh38.bed $$bwadir/$sm.v2.bam -mean | \
  cut -f5 > $sm.cov
done
#(echo -en "CHROM\tBEG\tEND\tNAME\t"; tr '\n' '\t' < sm.txt | sed 's/\t$/\n/'; \
#paste Coverage.GRCh38.bed $(cat ../sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')) \
#  > Coverage.GRCh38.tsv
#/bin/rm $(cat ../sm.txt | sed 's/$/.cov/' | tr '\n' '\t' | sed 's/\t$/\n/')

###########################################################################
## CLEAN UP                                                              ##
###########################################################################

sm_arr=( $(cat ../sm.txt) )
n=${#sm_arr[@]}
for i in $(seq 0 $((n-1))); do \
  sm=${sm_arr[$i]}; \
#  /bin/rm ${sm}_S*_R[12]_001.fastq.gz
#  /bin/rm $sm.{v2,raw,tmp}.bam{,.bai}; \
done
