#!bin/bash
##########################################################################
# set env variable and link ref files
###########################################################################
# see https://github.com/freeseek/mocha
export BCFTOOLS_PLUGINS="/home/drew/toolbin/bcftools/plugins/"
export REFDIR=/media/drew/easystore/ReferenceGenomes
export GSADIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/GSA_Data
export ANYLDIR=/media/drew/easystore/GoodCell-Resources/AnalysisBaseDir/
export ARYDIR=$ANYLDIR/VariantAnalysisScripts/MicroarayScripts/
export MOCHR=$ARYDIR/mocha_plot.R
export GTC2VCF=$ARYDIR/gtc2vcf_plot.R
export PILER=$ARYDIR/pileup_plot.R
export SUMPR=$ARYDIR/summary_plot.R
export REFIDX=$REFDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set
export REFFA=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
export REFFAI=$REFIDX/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
export REFMAP=$REFDIR/GRCh38/genetic_map_hg38_withX.txt.gz
export REFDUP=$REFDIR/GRCh38/dup.grch38.bed.gz
export REFCNP=$REFDIR/GRCh38/cnp.grch38.bed.gz
export REFCYTO=$REFDIR/GRCh38/cytoBand.hg38.txt.gz

for f in $BCFTOOLS_PLUGINS; do
    ln -s $f
done

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A mocha=(  ["20180117"]="Mocha_out"  ["20200110"]="Mocha_out" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="$REFDIR/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="$REFDIR/GSA_24v2_0/GSA-24v2-0_\
A2.bpm" )
declare -A egt=( ["20180117"]="$REFDIR/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="$REFDIR/GSA_24v2_0\
/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="$REFDIR/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="$REFDIR/GSA_24v2_0/GSA-24v2-0\
_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="$REFDIR/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

###########################################################################
## RUN MOCHA                                                             ##
###########################################################################

for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    mocha=${mocha[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    mkdir -p $wdir/$mocha
    cd $GSADIR/$wdir
    touch $wdir.gtc.tsv
    touch $wdir.pass
    touch $wdir.sex
    touch $wdir.xcl.GRCh38.bcf
    touch $mocha/$wdir.xcl.GRCh38.bcf
    touch $wdir/$wdir.pass
    touch $mocha/$wdir.chr$chr.GRCh38
    touch $mocha/$wdir.unphased.GRCh38.bcf
    awk -F"\t" 'NR>1 && $21>.9 {print $1}' $wdir.gtc.tsv | sed 's/\.gtc$//' | sort | join -t$'\t' - <(sort map.tsv) | cut -f2 > $wdir.pass
    n=$(cat $wdir.pass | wc -l);
    ns=$((n*98/100));
    print $n
    echo '##INFO=<ID=JK,Number=1,Type=Float,Description="Jukes Cantor">' | \
	bcftools annotate --no-version -Ou -a $REFDUP -c CHROM,FROM,TO,JK -h /dev/stdin -S $wdir.pass $mocha/$wdir.unphased.GRCh38.bcf | \
	bcftools +fill-tags --no-version -Ou -t ^Y,MT,chrY,chrM -- -t NS,ExcHet | \
	bcftools +mochatools --no-version -Ou -- -x $wdir.sex -G | \
	bcftools annotate --no-version -Ob -o $mocha/$wdir.xcl.GRCh38.bcf \
		 -i 'FILTER!="." && FILTER!="PASS" || JK<.02 || NS<'$ns' || ExcHet<1e-6 || AC_Sex_Test>6' \
		 -x FILTER,^INFO/JK,^INFO/NS,^INFO/ExcHet,^INFO/AC_Sex_Test && \
    bcftools index -f $mocha/$wdir.xcl.GRCh38.bcf
    kgp_pfx="$REFDIR/ALL.chrs_GRCh38.genotypes.20170504.bcfs/ALL.chr"
    kgp_sfx="_GRCh38.genotypes.20170504"
    for chr in {1..22} X; do
	touch  $kgp_pfx${chr}$kgp_sfx.bcf
	touch $mocha/$wdir.chr$chr.GRCh38
	touch $mocha/$wdir.unphased.GRCh38.bcf
	touch  $mocha/$wdir.xcl.GRCh38.bcf
	touch  $mocha/$wdir.chr$chr.GRCh38.bcf
	$eagle --geneticMapFile $REFMAP --outPrefix $mocha/$wdir.chr$chr.GRCh38 --numThreads 2 --vcfRef $kgp_pfx${chr}$kgp_sfx.bcf --vcfTarget $mocha/$wdir.unphased.GRCh38.bcf --vcfOutFormat b --noImpMissing --outputUnphased --vcfExclude $mocha/$wdir.xcl.GRCh38.bcf --chrom $chr --pbwtIters 3 && bcftools index -f $mocha/$wdir.chr$chr.GRCh38.bcf
    done
    touch $mocha/$wdir.mocha.tsv
    touch $mocha/$wdir.other.GRCh38.bcf
    touch $mocha/$wdir.unphased.GRCh38.bcf
    touch $mocha/$wdir.other.GRCh38.bcf
    bcftools view --no-version -Ob -o $mocha/$wdir.other.GRCh38.bcf -t ^$(seq -s, 1 22),X,$(seq -f chr%.0f -s, 1 22),chrX $mocha/$wdir.unphased.GRCh38.bcf && \
	bcftools index $mocha/$wdir.other.GRCh38.bcf
    touch $mocha/$wdir.{chr{{1..22},X},other}.GRCh38.bcf
    touch $mocha/$wdir.mocha.GRCh38.bcf
    touch $mocha/$wdir.mocha.tsv
    touch $mocha/$wdir.GRCh38.bcf
    bcftools concat --no-version -Ou $mocha/$wdir.{chr{{1..22},X},other}.GRCh38.bcf | \
	bcftools +mochatools --no-version -Ob -o $mocha/$wdir.GRCh38.bcf -- -f $REFFA && \
	bcftools index $mocha/$wdir.GRCh38.bcf
    touch $mocha/$wdir.mocha.GRCh38.bcf
    touch $mocha/$wdir.mocha.tsv
    touch $mocha/$wdir.xcl.GRCh38.bcf
    touch $mocha/$wdir.ucsc.bed
    touch $mocha/$wdir.stats.tsv
    touch $mocha/$wdir.mocha.tsv
    bcftools +mocha --no-version -Ob -o $mocha/$wdir.mocha.GRCh38.bcf --threads 1 --rules GRCh38 --variants ^$$mocha/$wdir.xcl.GRCh38.bcf -m $mocha/$wdir.mocha.tsv -g $mocha/$wdir.stats.tsv -u $mocha/$wdir.ucsc.bed -p $REFCNP --LRR-weight 0.2 --order-LRR-GC 2 $mocha/$wdir.GRCh38.bcf && bcftools index $mocha/$wdir.mocha.GRCh38.bcf
    cat $mocha/$wdir.mocha.tsv | awk -v pfx="$wdir" 'NR==1 {print $0"\tURL"} \
    	NR>1 && $21!~"CNP" && ($6>1e6 || $6>5e5 && $14<2) && ($16>50 || $17>20) \
	{print $0"\thttps://personal.broadinstitute.org/giulio/goodcell/$mocha/"pfx"."$1"_"$3"_"$4"_"$5".png"}' > $wdir/$wdir.large.mocha.tsv
    touch $mocha/$wdir.stats.tsv
    touch $mocha/$wdir.mocha.tsv
    touch $mocha/$wdir.mocha.GRCh38.bcf
    touch $mocha/$wdir.summary.pdf
    $SUMPR --stats $mocha/$wdir.stats.tsv --calls $mocha/$wdir.mocha.tsv --pdf $wdir/$wdir.summary.pdf
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test.png --vcf $mocha/$wdir.mocha.GRCh38.bcf --samples 8033684140 --regions chr1:145696087-248956422
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test2.png --vcf $mocha/$wdir.mocha.GRCh38.bcf --samples 8033684079 --regions chr15:19847685-101991189
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test3.png --vcf $mocha/$wdir.mocha.GRCh38.bcf --samples 8037702308 --regions chr12:0-56613214
done
