#!bin/bash
export REFDIR=/media/drew/easystore/ReferenceGenomes/GRCh38
export BEDDIR=$REFDIR/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.bed
export LIFTOVER=$REFDIR/hg19ToHg38.over.chain.gz
export MAPCHAIN=$BEDDIR/map.chain
touch $BEDDIR/3215481_Covered.GRCh38.bed
export NEWBED=$BEDDIR/3215481_Covered.GRCh38.bed

grep ^chr $BEDFILE > $MAPCHAIN
$HOME/toolbin/liftOver $MAPCHAIN $LIFTOVER $NEWBED /dev/stderr
#   liftOver oldFile map.chain newFile unMapped

grep ^chr 3215481_Covered.bed /home/drew/toolbin/liftOver /dev/stdin \
     ../GRCh38/hg19ToHg38.over.chain.gz  3215481_Covered.GRCh38.new.bed
