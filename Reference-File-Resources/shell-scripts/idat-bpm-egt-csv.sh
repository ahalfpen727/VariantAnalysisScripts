#!bin/bash
declare -A dirs=( ["20180117"]="2018_07" ["20200110"]="2020_01" ["20200302"]="2020_03" ["20200319"]="2020_04" ["20200320"]="2020_05" )
declare	-A bpms=( ["20180117"]="GSA-24v1-0_A2.bpm" ["20200110"]="GSA-24v2-0_A2.bpm" ["20200302"]="GSA-24v2-0_A2.bpm"
                  ["20200319"]="GSA-24v2-0_A2.bpm" ["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.bpm" )
declare -A egts=( ["20180117"]="GSA-24v1-0_A1_ClusterFile.egt" ["20200110"]="GSA-24v2-0_A1_ClusterFile.egt"
                  ["20200302"]="GSA-24v2-0_A1_ClusterFile.egt" ["20200319"]="GSA-24v2-0_A1_ClusterFile.egt"
		  ["20200320"]="Copy of MEGAv2 validation 02-2019_KC.egt" )
declare -A csvs=( ["20180117"]="GSA-24v1-0_A2.csv" ["20200110"]="GSA-24v2-0_A2.csv" ["20200302"]="GSA-24v2-0_A2.csv"
                  ["20200319"]="GSA-24v2-0_A2.csv" ["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.csv" )
declare -A sams=( ["20180117"]="" ["20200110"]="" ["20200302"]="" ["20200319"]="" ["20200320"]="CCPMBiobankMEGA2_20002558X345183_A1.bam" )
declare -A opts=( ["20180117"]="" ["20200110"]="-s ^8033684100" ["20200302"]="" ["20200319"]="" ["20200320"]="" )

for pfx in 20180117 20200110 20200302 20200319 20200320; do
  cd ${dirs[$pfx]}
  ...
  cd ..
done

###########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################

raw="~/Downloads/GoodCell-Resources/GuniosAnalysis"

dir=${dirs["20180117"]}
cd $dir
for idat in $raw/$dir/Raw_Data/202136030091/202136030091_R*C*_*.idat
cd ..

dir=${dirs["20200110"]}
cd $dir
for zip in $raw/$dir/203{408430041,408430049,408430052,408430054,533880001,533880004}\ idat.zip; do unzip "$zip"; done
cd ..

dir=${dirs["20200302"]}
cd $dir
for zip in $raw/$dir/2035338800{74,88}\ iDat.zip; do unzip "$zip"; done
cd ..

dir=${dirs["20200319"]}
cd $dir
for zip in $raw/$dir/2035338900{11,75}\ iDat.zip; do unzip "$zip"; done
cd ..

dir=${dirs["20200320"]}
cd $dir
unzip -j $raw/$dir/LifeVault.zip LifeVault/{202329440117/202329440117,202340640055/202340640055,202340640198/202340640198}_R*C*_*.idat
cd ..

cd ../../illumina/
unzip -j $raw/${dirs["20200320"]}/LifeVault.zip LifeVault/{CCPMBiobankMEGA2_20002558X345183_A1.bpm,CCPMBiobankMEGA2_20002558X345183_A1.csv,"Copy of MEGAv2 validation 02-2019_KC.egt"}
bcftools +gtc2vcf -c CCPMBiobankMEGA2_20002558X345183_A1.csv --fasta-flank | \
  bwa mem -M GCA_000001405.15_GRCh38_no_alt_analysis_set.fna - | \
  samtools view -bS -o CCPMBiobankMEGA2_20002558X345183_A1.bam

###########################################################################
## CONVERT GSA DATA FROM IDAT TO GTC                                     ##
###########################################################################

bpm=${bpms[$pfx]}
egt=${egts[$pfx]}

mkdir -p gtcs
$HOME/bin/iaap-cli/iaap-cli gencall "$bpm" "$egt" gtcs -f . -g
# mono $HOME/bin/autoconvert/AutoConvert.exe . gtcs "$bpm" "$egt"
#/bin/rm *.idat

bcftools +gtc2vcf --gtcs gtcs -o $pfx.gtc.tsv
