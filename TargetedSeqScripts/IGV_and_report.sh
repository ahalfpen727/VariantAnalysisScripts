#!bin/bash

###########################################################################
## IGV PLOTS                                                             ##
###########################################################################

set="pilot"
set="miseq"
set="nextseq"

mkdir -p pngs
for pfx in hc m2; do
  tail -n+2 $pfx.bad.GRCh38.tsv | awk -F"\t" -v set="$set" '
  BEGIN {print "genome https://s3.amazonaws.com/igv.org.genomes/hg38/hg38.genome";
  print "expand \"Gene\""; print "maxPanelHeight 1600"}
  BEGIN {print "new"; print "goto chr17:7675020-7675120"; print "load MH0138820.bam";
  print "sort base"; print "snapshot pngs/"set".MH0138820.chr17.7675070.png"}
  {print "new"; print "goto "$7":"$8-50"-"$8+50; print "load "$1".bam";
  print "sort base"; print "snapshot pngs/"set"."$1"."$7"."$8".png"}
  END {print "exit"}' > igv.batch
  (Xvfb :1024 -screen 0 2560x1600x24 &)
  DISPLAY=:1024 $HOME/toolbin/IGV_Linux_2.8.0/igv.sh -b igv.batch
done

###########################################################################
## FINAL REPORT                                                          ##
###########################################################################

csv2xlsx.py -d tab -w 1.3 -b -f 1 0 -o target.GRCh38.xlsx -i \
  2019_09/{3215481_Covered,{hc,m2}.bad}.GRCh38.tsv \
  2019_12/{3215481_Covered,{hc,m2}.bad}.GRCh38.tsv \
  2020_02/{3215481_Covered,{hc,m2}.bad}.GRCh38.tsv -t \
  "Pilot coverage" "Pilot HaplotypeCaller" "Pilot Mutect2" \
  "MiSeq coverage" "MiSeq HaplotypeCaller" "MiSeq Mutect2" \
  "NextSeq coverage" "NextSeq HaplotypeCaller" "NextSeq Mutect2"
scp target.GRCh38.xlsx 2019_09/pngs/pilot.*.png 2019_12/pngs/miseq.*.png 2020_02/pngs/nextseq.*.png \
  giulio@xfer3.broadinstitute.org:public_html/goodcell/target/
