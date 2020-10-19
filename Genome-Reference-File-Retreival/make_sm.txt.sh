#!bin/bash
touch sm.file.txt
touch sm.txt
export INPUT_FILE=sm.file.txt
export INPUTFILE=sm.txt
find -iname "*_R1_*.fastq.gz" > $INPUT_FILE
for i in $(cat $INPUT_FILE); do
    basename -s "R1_001.fastq.gz" $i >> $INPUTFILE
    #    cut -d/ -f2 $INPUT_FILE | cut -d_ -f1 > $INPUTFILE
done
