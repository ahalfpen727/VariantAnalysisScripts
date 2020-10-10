#!bin/bash
for file in  ~/Downloads/GoodCell-Resources/GuniosAnalysis/ReferenceGenomes/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set/*; do ln -s $file; done

###########################################################################
# PILOT DATA  ## MISEQ DATA                                                            
###########################################################################

cd ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq
pwd
find -iname "*_R1_0012.fastq.gz" | cut -d/ -f2 | cut -d_ -f1 > sm.txt

#for sfx in 1-1 1-2 1-3 2-1 2-2 2-3 2-4 3-1 3-2 3-3; do
#  unzip raw/Batch$sfx.zip
#done
find -iname "*_R1_0[01][12].fastq.gz" | cut -d/ -f4 | cut -d_ -f1 >> sm.txt
for i in sm.txt; do
    echo $i
done

###########################################################################
## FASTQ ALIGNMENT                                                       ##
###########################################################################

for line in sm.txt; do
    mkdir -p ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq/$line
    cd ~/Downloads/GoodCell-Resources/GuniosAnalysis/2019_09/LVB_fastq_Sept2019_concat_fastq/$line
    sm_arr=( $(cat sm.txt) )
    n=${#sm_arr[@]}
    echo $sm_arr
    echo $n
done

# pilot data and MiSeq data
for i in $(seq 1 $n); do
  fastq_arr=( $(find -iname "*_R1_0012.fastq.gz") ); \
  sm_arr=( $(cat sm.txt) ); \
  fastq_r1=${fastq_arr[(($i-1))]}; \
  fastq_r2=${fastq_r1%_R1_0012.fastq.gz}_R2_0012.fastq.gz; \
  sm=${sm_arr[(($i-1))]}; \
  str="@RG\tID:$sm\tPL:ILLUMINA\tPU:$sm\tLB:$sm\tSM:$sm"; \
  bwa mem -M -R "$str" GCA_000001405.15_GRCh38_no_alt_analysis_set.fna $fastq_r1 $fastq_r2 | \
    samtools view -Sb - | \
    samtools sort -o $sm.raw.bam && \
    samtools index -b $sm.raw.bam
done
