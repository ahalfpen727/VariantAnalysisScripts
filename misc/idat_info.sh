#!bin/bash
touch dir.txt
touch files.txt
find -iname "*_idat" | xargs > dir.txt
cd ./Raw_Data
for f in dir.txt; do
    myidat=basename $f
    bcftools +gtc2vcf -i -g $myidat
done


