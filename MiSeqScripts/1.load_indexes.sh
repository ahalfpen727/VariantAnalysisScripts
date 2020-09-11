#!bin/bash
RESULTS="/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/MiSeq_Results_out"
export WORK_DIR=/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/2019_09/LVB_fastq_Sept2019/concat_fastq

if [ ! -d "$RESULTS" ]; then
    mkdir -p "$RESULTS"
fi

find $WORK_DIR  -iname "*_R1_0012.fastq.gz" -print > '/media/drew/easystore/GoodCell-Resources/DrewsAnalysis/MiSeq_Data/sm.file.txt'

export REF_DIR=/media/drew/easystore/ReferenceGenomes/
export IDX_DIR=/media/drew/easystore/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export REF_FA=/media/drew/easystore/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDX_DIR; do
    ln -s $file
done
