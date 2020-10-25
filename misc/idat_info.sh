#!bin/bash
find -iname "*_idat" | xargs > dir.txt
for f in dir.txt; do
    dir=$f
    cd $dir
    find -iname "*.idat" | xargs > files.txt
done
for f in files.txt; do
    bcftools +gtc2vcf -i -g $f
done


