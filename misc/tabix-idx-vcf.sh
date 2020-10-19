#!bin/bash
export REFDIR=$HOME/easystore/ReferenceGenomes/
cd $REFDIR

tabix -p vcf < find -iname "*.vcf.gz"
