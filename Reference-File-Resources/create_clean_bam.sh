# USAGE:  sh create_clean_bam.sh <sample name>
# Based on https://software.broadinstitute.org/gatk/documentation/article.php?id=6483
# CONFIG VARIABLES:  Update to match environment
gatk=~/Genomics/gatk-4.0.4.0/gatk
reference=~/Genomics/Reference/GRCh38_full_analysis_set_plus_decoy_hla.fa
tmp_dir=/Volumes/External/tmp

# Mark the Illumina adapters (if present.  The sequencing lab should have removed them
# prior to delivering the results.)
$gatk --java-options "-Xmx8G" MarkIlluminaAdapters \
-I=$1.unmapped.bam \
-O=$1.markilluminaadapters.bam \
-M=$1.markilluminaadapters.metrics.txt \
-TMP_DIR=$tmp_dir

# Perform a piped operation that trims the Illumina adapters from the reads, aligns them
# to the target reference, and creates a clean BAM sorted by coordinate for variant discovery.
$gatk --java-options "-Xmx8G" SamToFastq \
-I=$1.markilluminaadapters.bam \
-FASTQ=/dev/stdout \
-CLIPPING_ATTRIBUTE=XT -CLIPPING_ACTION=2 -INTERLEAVE=true -NON_PF=true \
-TMP_DIR=$tmp_dir | \
~/Genomics/bwa/bwa mem -M -t 7 -p $reference /dev/stdin | \
$gatk --java-options "-Xmx16G" MergeBamAlignment \
-ALIGNED_BAM=/dev/stdin \
-UNMAPPED_BAM=$1.unmapped.bam \
-OUTPUT=$1.bwa.clean.bam \
-R=$reference -CREATE_INDEX=true -ADD_MATE_CIGAR=true \
-CLIP_ADAPTERS=false -CLIP_OVERLAPPING_READS=true \
-INCLUDE_SECONDARY_ALIGNMENTS=true -MAX_INSERTIONS_OR_DELETIONS=-1 \
-PRIMARY_ALIGNMENT_STRATEGY=MostDistant -ATTRIBUTES_TO_RETAIN=XS \
-TMP_DIR=$tmp_dir