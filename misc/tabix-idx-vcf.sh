#!bin/bash
export REFDIR=/media/drew/easystore/ReferenceGenomes/GRCh38
cd $REFDIR
touch vcf-files.txt
find -iname "*.vcf.gz" -print >  vcf-files.txt
export INPUTFILE=vcf-files.txt
sm_arr=( $(cat $INPUTFILE) )
n=${#sm_arr[@]}
for i in $(seq 1 $n); do
  sm_arr=( $(cat $INPUTFILE) ); \
  sm=${sm_arr[(($i-1))]}; \
  tabix -p vcf $sm
done

