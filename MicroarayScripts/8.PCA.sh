#!bin/bash
##########################################################################
# set env variable and link ref files
###########################################################################
# see https://github.com/freeseek/mocha
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
export REFMAP=$REFDIR/GRCh38/genetic_map_hg38_withX.gz
export REFDUP=$REFDIR/GRCh38/dup.grch38.bed.gz
export REFCNP=$REFDIR/GRCh38/cnp.grch38.bed.gz
export REFCYTO=$REFDIR/GRCh38/cytoBand.hg38.txt.gz

declare -A gsa=(  ["20180117"]="GSA-24v1_0"  ["20200110"]="GSA_24v2_0" )
declare -A mocha=(  ["20180117"]="Mocha_out"  ["20200110"]="Mocha_out" )
declare -A wdir=( ["20180117"]="2018_07" ["20200110"]="2020_01" )
declare -A bpm=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.bpm" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0_\
A2.bpm" )
declare -A egt=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0\
/GSA-24v2-0_A1_ClusterFile.egt" )
declare -A csv=( ["20180117"]="/media/drew/easystore/ReferenceGenomes/GSA_24v1_0/GSA-24v1-0_A2.csv"  ["20200110"]="/media/drew/easystore/ReferenceGenomes/GSA_24v2_0/GSA-24v2-0\
_A2.csv" )
declare -A sam=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="/media/drew/easystore/ReferenceGenomes/MEGA_8v2_0/CCPMBiobankMEGA2_20002558X3451\83_A1.bam" )

###########################################################################
## RUN MOCHA                                                             ##
###########################################################################

# 8033163000 8033684110 are bad quality
# 8033673352 is 09C98633 with 11p CNN-LOH
# 8037737797 is 305-13251 (MH0201393) with trisomy 8 rescue
# 8037702308 is MH0145622 with ATM deletion on chromosome 11
# 8035158042 is 352-60251 (MH0197311) with multiple chromosome 2 events


for pfx in 20180117 20200110; do
    wdir=${wdir[$pfx]}
    gsa=${gsa[$pfx]}
    mocha=${mocha[$pfx]}
    bpm=${bpm[$pfx]}
    egt=${egt[$pfx]}
    csv=${csv[$pfx]}
    sam=${sam[$pfx]}
    mkdir -p $mocha
    export MDIR=$wdir/$mocha
    awk -F"\t" 'NR>1 && $21>.9 {print $1}' $wdir.gtc.tsv | sed 's/\.gtc$//' | sort | join -t$'\t' - <(sort map.tsv) | cut -f2 > $wdir.pass
    n=$(cat $wdir.pass | wc -l);
    ns=$((n*98/100));
    echo '##INFO=<ID=JK,Number=1,Type=Float,Description="Jukes Cantor">' | \
	bcftools annotate --no-version -Ou -a $REFDUP -c CHROM,FROM,TO,JK -h /dev/stdin -S $wdir.pass $MDIR/$wdir.unphased.GRCh38.bcf | \
	bcftools +fill-tags --no-version -Ou -t ^Y,MT,chrY,chrM -- -t NS,ExcHet | \
	bcftools +mochatools --no-version -Ou -- -x $wdir.sex -G | \
	bcftools annotate --no-version -Ob -o $MDIR/$wdir.xcl.GRCh38.bcf \
		 -i 'FILTER!="." && FILTER!="PASS" || JK<.02 || NS<'$ns' || ExcHet<1e-6 || AC_Sex_Test>6' \
		 -x FILTER,^INFO/JK,^INFO/NS,^INFO/ExcHet,^INFO/AC_Sex_Test && \
	bcftools index -f $MDIR/$wdir.xcl.GRCh38.bcf
    kgp_pfx="$REFDIR/ALL.chrs_GRCh38.genotypes.20170504.bcfs/ALL.chr"
    kgp_sfx="_GRCh38.genotypes.20170504"
    for chr in {1..22} X; do
	$eagle --geneticMapFile $REFMAP --outPrefix $MDIR/$wdir.chr$chr.GRCh38 --numThreads 2 --vcfRef $kgp_pfx${chr}$kgp_sfx.bcf --vcfTarget $MDIR/$wdir.unphased.GRCh38.bcf --vcfOutFormat b --noImpMissing \
	      --outputUnphased --vcfExclude $MDIR/$wdir.xcl.GRCh38.bcf --chrom $chr --pbwtIters 3 && bcftools index -f $MDIR/$wdir.chr$chr.GRCh38.bcf
    done
    bcftools view --no-version -Ob -o $MDIR/$wdir.other.GRCh38.bcf -t ^$(seq -s, 1 22),X,$(seq -f chr%.0f -s, 1 22),chrX $MDIR/$wdir.unphased.GRCh38.bcf && \
	bcftools index $MDIR/$wdir.other.GRCh38.bcf
    bcftools concat --no-version -Ou $MDIR/$wdir.{chr{{1..22},X},other}.GRCh38.bcf | \
	bcftools +mochatools --no-version -Ob -o $MDIR/$wdir.GRCh38.bcf -- -f $REFFA && \
	bcftools index $MDIR/$wdir.GRCh38.bcf
    bcftools +mocha --no-version -Ob -o $MDIR/$wdir.mocha.GRCh38.bcf --threads 1 --rules GRCh38 --variants ^$$MDIR/$wdir.xcl.GRCh38.bcf -m $MDIR/$wdir.mocha.tsv -g $MDIR/$wdir.stats.tsv \
	     -u $MDIR/$wdir.ucsc.bed -p $REFCNP --LRR-weight 0.2 --order-LRR-GC 2 $MDIR/$wdir.GRCh38.bcf && \
	bcftools index $MDIR/$wdir.mocha.GRCh38.bcf
    cat $MDIR/$wdir.mocha.tsv | awk -v pfx="$pfx" 'NR==1 {print $0"\tURL"} \
    	NR>1 && $21!~"CNP" && ($6>1e6 || $6>5e5 && $14<2) && ($16>50 || $17>20) \
	{print $0"\thttps://personal.broadinstitute.org/giulio/goodcell/$mocha/"pfx"."$1"_"$3"_"$4"_"$5".png"}' > $MDIR/$wdir.large.mocha.tsv
    ln -s $MDIR/$wdir.stats.tsv
    $SUMPR --stats $MDIR/$wdir.stats.tsv --calls $MDIR/$wdir.mocha.tsv --pdf $MDIR/$wdir.summary.pdf
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test.png --vcf $MDIR/$wdir.mocha.GRCh38.bcf --samples 8033684140 --regions chr1:145696087-248956422
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test2.png --vcf $MDIR/$wdir.mocha.GRCh38.bcf --samples 8033684079 --regions chr15:19847685-101991189
    $MOCHR --mocha --cytoband $REFCYTO --png /tmp/test3.png --vcf $MDIR/$wdir.mocha.GRCh38.bcf --samples 8037702308 --regions chr12:0-56613214
done


###########################################################################
## COMPUTE PRINCIPAL COMPONENTS AND ANCESTRY                             ##
###########################################################################

# see https://github.com/freeseek/kgp2anc

ln -s $HOME/res/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
ln -s $HOME/res/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai

vcf2plink.py --build b38 --ref GCA_000001405.15_GRCh38_no_alt_analysis_set.fna --out $pfx --impute-sex .6 .6 --vcf $pfx.clinvar.GRCh38.bcf
markerqc.sh $pfx out/$pfx $HOME/res/ld.grch38.bed
kgpmerge.sh $pfx kgp/$pfx $HOME/res/kgp/kgp.array.grch38 out/$pfx.prune.in
kgp2pc.py --grm-bin kgp/$pfx --fam kgp/$pfx.fam --out kgp/$pfx --pop $HOME/res/kgp/kgp.pop
pc2anc.R kgp/$pfx.all.pca $HOME/res/kgp/kgp.anc $pfx.anc.tsv
