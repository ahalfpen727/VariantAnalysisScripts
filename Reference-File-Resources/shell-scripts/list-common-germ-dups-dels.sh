#!bin/bash
# List of common germline duplications and deletions
bcftools query -i 'AC>1 && END-POS+1>10000 && SVTYPE!="INDEL" && (SVTYPE=="CNV" || SVTYPE=="DEL" || SVTYPE=="DUP")' \
  -f "%CHROM\t%POS0\t%END\t%SVTYPE\n" ALL.wgs.mergedSV.v8.20130502.svs.genotypes.vcf.gz > cnp.grch37.bed
