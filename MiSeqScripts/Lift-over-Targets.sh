#!bin/bash
export REFDIR=/media/drew/easystore/ReferenceGenomes
export BEDDIR=/media/drew/easystore/ReferenceGenomes/BEDs
export BEDFILE=$BEDDIR/3215481_Covered.bed
export LIFTOVER=$REFDIR/GRCh38/hg19ToHg38.over.chain.gz

touch $BEDDIR/3215481_Covered.GRCh38.bed
export NEWBED=$BEDDIR/3215481_Covered.GRCh38.bed

grep ^chr $BEDFILE | liftOver /dev/stdin $LIFTOVER hg19ToHg38.over.chain.gz $NEWBED /dev/stderr
