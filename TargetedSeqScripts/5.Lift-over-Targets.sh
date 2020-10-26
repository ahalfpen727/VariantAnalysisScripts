#!bin/bash
export REFDIR=/media/drew/easystore/ReferenceGenomes
export BEDDIR=/media/drew/easystore/ReferenceGenomes/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.bed
export LIFTOVER=$REFDIR/GRCh38/hg19ToHg38.over.chain.gz
export MAPCHAIN=$BEDDIR/map.chain
touch $BEDDIR/3215481_Covered.GRCh38.bed
export NEWBED=$BEDDIR/3215481_Covered.GRCh38.bed

grep ^chr $BEDFILE > $MAPCHAIN
liftOver $MAPCHAIN $LIFTOVER $NEWBED /dev/stderr
#   liftOver oldFile map.chain newFile unMapped
