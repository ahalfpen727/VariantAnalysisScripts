###########################################################################
## DOWNLOAD TABLES                                                       ##
###########################################################################

# install software
sudo apt-get install libreoffice-calc pdftk poppler-utils wget xlsx2csv

# Rodríguez-Santiago et al. 2010
wget -q https://ars.els-cdn.com/content/image/1-s2.0-S0002929710003058-mmc1.pdf
(pdftk 1-s2.0-S0002929710003058-mmc1.pdf cat 15 output - | pdftotext - - | grep -v ^$ |
  awk '{mod=0}
       NR==3 {x[0"_"0]=$0}
       NR==4 {x[0"_"1]=$0} 
       NR==5 {x[0"_"2]=$1; x[0"_"3]=$2; x[0"_"4]=$3; x[0"_"5]=$4}
       NR>=6 && NR<=29 {shift=6; mod=6; row=1; col=0}
       NR>=30 && NR<=35 {shift=30; mod=6; row=1; col=5}
       NR>=36 && NR<=95 {shift=36; mod=15; row=8; col=0}
       NR>=96 && NR<=110 {shift=96; mod=15; row=8; col=5}
       NR==111 {x[18"_"4]=$0}
       NR==112 {x[0"_"6]=$0}
       NR==113 {x[0"_"7]=$0}
       NR>=114 && NR<=157 {shift=114; mod=22; row=1; col=6}
       NR==158 {x[0"_"8]=$0}
       NR==159 {x[0"_"8]=x[0"_"8]" "$0}
       NR>=160 && NR<=181 {shift=160; mod=22; row=1; col=8}
       NR==182 {x[0"_"9]=$0}
       NR==183 {x[0"_"9]=x[0"_"9]" "$0}
       NR>=184 && NR<=205 {shift=184; mod=22; row=1; col=9}
       NR==206 {x[0"_"10]=$0}
       NR==207 {x[0"_"10]=x[0"_"10]" "$0}
       NR>=208 && NR<=229 {shift=208; mod=22; row=1; col=10}
       NR==230 {x[0"_"11]=$0}
       NR==231 {x[0"_"12]=$1; x[0"_"13]=$2; x[0"_"14]=$3}
       NR==232 {x[0"_"15]=$0}
       NR==233 {x[0"_"16]=$0}
       NR==234 {x[0"_"11]=x[0"_"11]" "$1
                x[0"_"12]=x[0"_"12]" "$2
                x[0"_"13]=x[0"_"13]" "$3
                x[0"_"14]=x[0"_"14]" "$4
                x[0"_"15]=x[0"_"15]" "$5
                x[0"_"16]=x[0"_"16]" "$6}
       mod {x[(NR-shift)%mod+row"_"int((NR-shift)/mod)+col]=$0}
       NR>=235 && NR<=366 {x[int((NR-235)/6)+1"_"(NR-235)%6+11]=$0}
  END {for (i=0; i<=5; i++) x[7"_"i]=x[6"_"i]
      for (i=0; i<=22; i++) {for (j=0; j<=16; j++) printf x[i"_"j]"\t"; printf "\n"}}'
pdftk 1-s2.0-S0002929710003058-mmc1.pdf cat 16 output - | pdftotext - - | grep -v ^$ |
  awk '{mod=0}
       NR>=7 && NR<=17 {shift=7; mod=11; row=0; col=0}
       NR>=18 && NR<=25 {shift=18; mod=8; row=12; col=0}
       NR>=27 && NR<=46 {shift=27; mod=20; row=0; col=1}
       NR>=48 && NR<=87 {shift=48; mod=20; row=0; col=2}
       NR==88 {x[9"_"4]=$0}
       NR==89 {x[13"_"4]=$0}
       NR==90 {x[14"_"4]=$0}
       NR>=91 && NR<=110 {shift=91; mod=20; row=0; col=5}
       NR>=118 && NR<=217 {shift=118; mod=20; row=0; col=6}
       NR>=222 && NR<=261 {shift=222; mod=20; row=0; col=11}
       NR>=264 && NR<=293 {shift=264; mod=20; row=0; col=13}
       NR>=294 && NR<=302 {shift=294; mod=9; row=11; col=14}
       NR>=306 && NR<=345 {shift=306; mod=20; row=0; col=15}
       mod {x[(NR-shift)%mod+row"_"int((NR-shift)/mod)+col]=$0}
  END {sub("a","",x[10"_"1]); x[11"_"0]=x[10"_"0]; sub(",",".",x[17"_"8])
      for (i=0; i<=19; i++) {for (j=0; j<=16; j++) printf x[i"_"j]"\t"; printf "\n"}}') |
  tr -d , > rodriguez2010.hg18.tsv
/bin/rm 1-s2.0-S0002929710003058-mmc1.pdf

# Jacobs et al. 2012
wget -q http://www.nature.com/ng/journal/v44/n6/extref/ng.2270-S2.xls
localc --convert-to xlsx ng.2270-S2.xls
xlsx2csv -d tab -s 1 ng.2270-S2.xlsx | sed 's/\t$//' > jacobs2012.hg18.tsv
/bin/rm ng.2270-S2.xls{,x}

# Laurie et al. 2012
wget -q http://www.nature.com/ng/journal/v44/n6/extref/ng.2271-S2.xlsx
xlsx2csv -d tab -s 1 ng.2271-S2.xlsx > laurie2012.hg18.tsv
/bin/rm ng.2271-S2.xlsx

# Schick et al. 2013
wget -qO journal.pone.0059823.s004.docx http://journals.plos.org/plosone/article/file?type=supplementary\&id=info:doi/10.1371/journal.pone.0059823.s004
lowriter --convert-to txt journal.pone.0059823.s004.docx
cat journal.pone.0059823.s004.txt | tail -n+257 | head -n-113 | awk 'NR%9 {printf "%s\t", $0} NR%9==0' > schick2013.hg18.tsv
/bin/rm journal.pone.0059823.s004.{docx,txt}

# Bonnefond et al. 2013
wget -q http://www.nature.com/ng/journal/v45/n9/extref/ng.2700-S1.pdf
(pdftk ng.2700-S1.pdf cat 2 output - | pdftotext - - | sed -e 's/Size of CME (kb)/Size_of_CME_(kb)/g' -e 's/CME Type/CME_Type/g' \
  -e 's/Cells (%)/Cells_ (%)/g' | tr -d ' ' | tr -d '\r' | grep -v ^$ | tail -n+4 | head -n-4 |
  awk '$1=="T2D" || $1=="Position" || $1=="Abnormal" {printf $1" "; next} $1=="status" || NR%8!=4 {printf $1"\t"; next} NR%8==4'
pdftk ng.2700-S1.pdf cat 3 output - | pdftotext - - | tr -d ' ' | tr -d '\r' | grep -v ^$ | head -n-5 |
  awk 'NR>8 && NR<=32 {x[NR]=$1; next} NR==33 {for (i=0; i<3; i++) {for (j=0; j<7; j++) printf x[9+i+3*j]"\t"; print x[30+i]}}
  NR%8 {printf $1"\t"} NR%8==0') > bonnefond2013.hg18.tsv
/bin/rm ng.2700-S1.pdf

# Machiela et al. 2015
wget -q --user-agent="" http://www.sciencedirect.com/science/MiamiMultiMediaURL/1-s2.0-S0002929715000191/1-s2.0-S0002929715000191-mmc2.xlsx/276895/html/S0002929715000191/09ad26f15211e9135284ebae1234467e/mmc2.xlsx
xlsx2csv -d tab -s 2 mmc2.xlsx > machiela2015.hg18.tsv
/bin/rm mmc2.xlsx

# Vattathil et al. 2016
wget -q --user-agent="" http://www.sciencedirect.com/science/MiamiMultiMediaURL/1-s2.0-S0002929716000549/1-s2.0-S0002929716000549-mmc2.xlsx/276895/html/S0002929716000549/c996055918bf844ab624aec4657de800/mmc2.xlsx
xlsx2csv -d tab -s 1 mmc2.xlsx > vattathil2016.hg18.tsv
/bin/rm mmc2.xlsx

###########################################################################
## LIFTOVER TO HG19 AND HG38                                             ##
###########################################################################

# download software
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
chmod a+x liftOver
wget -q http://hgdownload.cse.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg{19,38}.over.chain.gz

declare -A i=( ["rodriguez2010"]=6 ["jacobs2012"]=8 ["laurie2012"]=6 ["schick2013"]=3 ["bonnefond2013"]=2 ["machiela2015"]=3 ["vattathil2016"]=2 )
declare -A j=( ["rodriguez2010"]=7 ["jacobs2012"]=9 ["laurie2012"]=7 ["schick2013"]=5 ["bonnefond2013"]=4 ["machiela2015"]=4 ["vattathil2016"]=3 )
declare -A k=( ["rodriguez2010"]=8 ["jacobs2012"]=10 ["laurie2012"]=8 ["schick2013"]=6 ["bonnefond2013"]=5 ["machiela2015"]=5 ["vattathil2016"]=4 )

minMatch=0.3
for ref in 19 38; do
  for pfx in rodriguez2010 jacobs2012 laurie2012 schick2013 bonnefond2013 machiela2015 vattathil2016; do
    tail -n+2 $pfx.hg18.tsv | cut -f ${i[$pfx]},${j[$pfx]},${k[$pfx]} |
      awk -F"\t" -v OFS="\t" '{print "chr"$1,$2,$3,"chr"$1":"$2"-"$3}'
  done |
    ./liftOver \
    -minMatch=$minMatch \
    /dev/stdin \
    hg18ToHg$ref.over.chain.gz \
    newFile.hg$ref \
    unMapped.hg$ref
done
join -a1 -a2 -1 4 -2 4 -e nan -o 0,1.1,1.2,1.3,2.1,2.2,2.3 -t $'\t' \
  <(sort -k4,4 newFile.hg19) <(sort -k4,4 newFile.hg38) > lift.tsv

for pfx in rodriguez2010 jacobs2012 laurie2012 schick2013 bonnefond2013 machiela2015 vattathil2016; do
  awk -F"\t" -v i=${i[$pfx]} -v j=${j[$pfx]} -v k=${k[$pfx]} -v OFS="\t" '
    NR==FNR {start_hg19[$1]=$3; end_hg19[$1]=$4; start_hg38[$1]=$6; end_hg38[$1]=$7}
    NR>FNR && FNR==1 {print $0,"Start (GRCh37)","End (GRCh37)","Start (GRCh38)","End (GRCh38)"}
    NR>FNR && FNR>1 {sv="chr"$i":"$j"-"$k;
    print $0,start_hg19[sv],end_hg19[sv],start_hg38[sv],end_hg38[sv]}' \
      lift.tsv $pfx.hg18.tsv > $pfx.tsv
done

/bin/rm {newFile,unMapped}.hg{19,38} liftOver hg18ToHg{19,38}.over.chain.gz

###########################################################################
## GENERATE EXCEL SPREADSHEETS                                           ##
###########################################################################

# download software
sudo apt-get install python3-xlsxwriter
wget -q https://raw.githubusercontent.com/freeseek/gwaspipeline/master/csv2xlsx.py
chmod a+x csv2xlsx.py

./csv2xlsx.py \
  -d tab \
  -b -w 1.3 -f 1 0 \
  -o prev_calls.xlsx \
  -i {rodriguez2010,jacobs2012,laurie2012,schick2013,bonnefond2013,machiela2015,vattathil2016}.tsv \
  -t "Rodriguez-Santiago et al. 2010" "Jacobs et al. 2012" "Laurie et al. 2012" "Schick et al. 2013" \
     "Bonnefond et al. 2013" "Machiela et al. 2015" "Vattathil et al. 2016"

###########################################################################
## GENERATE FILES THAT CAN BE USED WITHIN THE UCSC BROWSER               ##
###########################################################################

declare -A i=( ["rodriguez2010"]=6 ["jacobs2012"]=8 ["laurie2012"]=6 ["schick2013"]=3 ["bonnefond2013"]=2 ["machiela2015"]=3 ["vattathil2016"]=2 )
declare -A j=( ["rodriguez2010"]=7 ["jacobs2012"]=9 ["laurie2012"]=7 ["schick2013"]=5 ["bonnefond2013"]=4 ["machiela2015"]=4 ["vattathil2016"]=3 )
declare -A k=( ["rodriguez2010"]=8 ["jacobs2012"]=10 ["laurie2012"]=8 ["schick2013"]=6 ["bonnefond2013"]=5 ["machiela2015"]=5 ["vattathil2016"]=4 )
declare -A l=( ["rodriguez2010"]=2 ["jacobs2012"]=12 ["laurie2012"]=12 ["schick2013"]=-1 ["bonnefond2013"]=7 ["machiela2015"]=7 ["vattathil2016"]=9 )
declare -A n=( ["rodriguez2010"]=17 ["jacobs2012"]=13 ["laurie2012"]=13 ["schick2013"]=9 ["bonnefond2013"]=8 ["machiela2015"]=11 ["vattathil2016"]=9 )

for pfx in rodriguez2010 jacobs2012 laurie2012 schick2013 bonnefond2013 machiela2015 vattathil2016; do
  awk -F"\t" -v OFS="\t" -v i=${i[$pfx]} -v j=${j[$pfx]} -v k=${k[$pfx]} -v l=${l[$pfx]} \
    'NR>1 {print $1,$i,$j,$k,$l}' $pfx.hg18.tsv | sed 's/^[A-Z]*/'${pfx:0:1}'/'
done | sed -e 's/UPD\(\/IBD\)\?/neutral/' -e 's/duplication/gain/' -e 's/deletion/loss/' -e 's/trisomy/gain/' \
  -e 's/aupd/neutral/' -e 's/CNLOH/neutral/' -e 's/complex/undetermined/' |
  awk -F"\t" -v OFS="\t" '{print "chr"$2,$3,$4,$1,0,".",$3,$4,tolower($5)}' > prev_calls.hg18.tsv

awk -F"\t" -v OFS="\t" 'NR==FNR {j[$1]=$3; k[$1]=$4}
  NR>FNR {sv=$1":"$2"-"$3; $2=j[sv]; $3=k[sv]; $7=j[sv]; $8=k[sv]; print}' \
  lift.tsv prev_calls.hg18.tsv > prev_calls.hg19.tsv

awk -F"\t" -v OFS="\t" 'NR==FNR {j[$1]=$6; k[$1]=$7}
  NR>FNR {sv=$1":"$2"-"$3; $2=j[sv]; $3=k[sv]; $7=j[sv]; $8=k[sv]; print}' \
  lift.tsv prev_calls.hg18.tsv > prev_calls.hg38.tsv

declare -A  name=( ["gain"]="Duplications" ["loss"]="Deletions" ["neutral"]="Uniparental disomy"  ["undetermined"]="Undetermined" )
declare -A color=( ["gain"]="0,0,255"      ["loss"]="255,0,0"   ["neutral"]="0,255,0"             ["undetermined"]="127,127,127"  )

for ref in 18 19 38; do
  for type in gain loss neutral undetermined; do
    echo "track name=mSV_$type description=\"${name[$type]}\" visibility=4 priority=1 itemRgb=\"On\""
    grep $type$ prev_calls.hg$ref.tsv | grep -v nan | sed 's/'$type'$/'${color[$type]}'/'
  done > prev_calls.hg$ref.bed
done

###########################################################################
## MANUSCRIPT TABLES FOR LOH ET AL. 2018                                 ##
###########################################################################

# install software
sudo apt-get install wget

# Loh et al. 2018
scp giulio@silver.broadinstitute.org:/fg/aprice/poru/mosaic/supp.tab .

# download software
wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
chmod a+x liftOver
wget -q http://hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz

awk -F"\t" 'NR>1 {printf "chr%s\t%d\t%d\tchr%s:%s-%s\n",$5,1e6*$6,1e6*$7,$5,$6,$7}' supp.tab |
  ./liftOver \
    -minMatch=0.3 \
    /dev/stdin \
    hg19ToHg38.over.chain.gz \
    newFile.hg38 \
    unMapped.hg38

awk -F"\t" -v OFS="\t" 'NR==FNR {start_hg38[$4]=$2; end_hg38[$4]=$3}
  NR>FNR && FNR==1 {$6="Start (GRCh37)"; $7="End (GRCh37)"; print $0,"Start (GRCh38)","End (GRCh38)"}
  NR>FNR && FNR>1 {sv="chr"$5":"$6"-"$7; $6=sprintf("%d",$6*1e6); $7=sprintf("%d",$7*1e6)
  if (sv in start_hg38) print $0,start_hg38[sv],end_hg38[sv]
  else print $0,"nan","nan"}' newFile.hg38 supp.tab |
  sed 's/unknown/undetermined/' > loh2018.tsv

/bin/rm {newFile,unMapped}.hg38

# download software
sudo apt-get install python3-xlsxwriter
wget -q https://raw.githubusercontent.com/freeseek/gwaspipeline/master/csv2xlsx.py
chmod a+x csv2xlsx.py

./csv2xlsx.py \
  -d tab \
  -b -w 1.3 -f 1 0 \
  -o loh2018.xlsx \
  -i loh2018.tsv \
  -t "Loh et al. 2018"

declare -A  name=( ["gain"]="Duplications" ["loss"]="Deletions" ["neutral"]="Uniparental disomy"  ["undetermined"]="Undetermined" )
declare -A color=( ["gain"]="0,0,255"      ["loss"]="255,0,0"   ["neutral"]="0,255,0"             ["undetermined"]="127,127,127"  )
declare -A j=( ["19"]=6 ["38"]=16 )
declare -A k=( ["19"]=7 ["38"]=17 )

for ref in 19 38; do
  for type in gain loss neutral undetermined; do
    echo "track name=mSV_$type description=\"${name[$type]}\" visibility=4 priority=1 itemRgb=\"On\""
    grep $type loh2018.tsv | grep -v nan | sed 's/'$type'/'${color[$type]}'/' |
      awk -F"\t" -v OFS="\t" -v j=${j[$ref]} -v k=${k[$ref]} '{print "chr"$5,$j,$k,$1,0,".",$j,$k,$11}'
  done > loh2018.hg$ref.bed
done
