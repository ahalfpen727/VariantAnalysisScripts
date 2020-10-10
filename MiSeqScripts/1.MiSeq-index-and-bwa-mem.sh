#!bin/bash

###########################################################################
# Load Indexes and create input file
###########################################################################
export BASE_DIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir
export WORK_DIR=$BASE_DIR/MiSeq_Data
export REF_DIR=/media/drew/easystore/ReferenceGenomes/
export IDX_DIR=$REF_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set/
export IDX_BASE=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REF=$IDX_DIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna

for file in $IDX_DIR; do
    ln -s $IDX_DIR/$file
done

#mkdir -p $WORK_DIR/2019_12/LVB_fastq_Dec2019/concat_fastq
#for pfxx in 1-1 1-2 1-3 2-1 2-2 2-3 2-4 3-1 3-2 3-3; do
#    export workdir=$WORK_DIR/2019_12/Batch$pfxx/FASTQ
#    mv $workdir/*fastq.gz $WORK_DIR/2019_12/LVB_fastq_Dec2019/concat_fastq
#done

declare -A miseqdir=( ["2019_09"]="2019_09" ["2019_12"]="2019_12" )
declare -A datadir=( ["2019_09"]="LVB_fastq_Sept2019/concat_fastq" ["2019_12"]="/LVB_fastq_Dec2019/concat_fastq" )
for pfx in 2019_09 2019_12; do
    miseqdir=${miseqdir[$pfx]}
    datadir=${datadir[$pfx]}
    mkdir -p $WORK_DIR/$miseqdir/MiSeq_Results_out
    export RESULTS=$WORK_DIR/$miseqdir/MiSeq_Results_out
    touch $WORK_DIR/$miseqdir/sm.txt
    touch $WORK_DIR/$miseqdir/sm.file.txt
    export INPUT_FILE=$WORK_DIR/$miseqdir/sm.file.txt
    export INPUTFILE=$WORK_DIR/$miseqdir/sm.txt
    export INPUT_DIR=$WORK_DIR/$miseqdir/$datadir
    find $INPUT_DIR -iname "*_R1_0[01][12].fastq.gz" | cut -d/ -f2 | cut -d_ -f1 > $INPUTFILE
    #######################
    # MISEQ FASTQ ALIGNMENT                                                   
    #######################
    sm_arr=( $(cat $INPUTFILE) )
    n=${#sm_arr[@]}
    # pilot data and MiSeq data
    for i in $(seq 1 $n); do
	fastq_arr=( $(find -iname "*_R1_0012.fastq.gz") ); \
	sm_arr=( $(cat $INPUTFILE) ); \
	fastq_r1=${fastq_arr[(($i-1))]}; \
	fastq_r2=${fastq_r1%_R1_0012.fastq.gz}_R2_0012.fastq.gz; \
	sm=${sm_arr[(($i-1))]}; \
	str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
	bwa mem -M -R "$str" $REF $fastq_r1 $fastq_r2 | samtools view -Sb - | \
	    samtools sort - -o $RESULTS/$sm.raw.bam &&  \
	    samtools index -b -@ 2 $RESULTS/$sm.raw.bam
    done
done
