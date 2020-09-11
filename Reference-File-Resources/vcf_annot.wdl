version development

## Copyright (c) 2020 Giulio Genovese
##
## Version 2020-07-31
##
## Contact Giulio Genovese <giulio.genovese@gmail.com>
##
## This WDL downloads reference, Genbank, ClinVar, 1000 Genomes, and gnomAD resources
##
## Cromwell version support
## - Successfully tested on v52
##
## Distributed under terms of the MIT License

workflow vcf_annot {
  input {
    Int? build
    File vcf_file
    File vcf_idx
    File fasta_ref
    File fasta_fai
    File gff3_file
    File clinvar_vcf_file
    File clinvar_vcf_idx
    File acmg59_vcf_file
    File acmg59_vcf_idx
    File kgp_vcf_file
    File kgp_vcf_idx
    File gnomad_vcf_file
    File gnomad_vcf_idx
  }

  call vcf_annot {
    input:
      build =  build,
      vcf_file = vcf_file,
      vcf_idx = vcf_idx,
      fasta_ref = fasta_ref,
      fasta_fai = fasta_fai,
      gff3_file = gff3_file,
      clinvar_vcf_file = clinvar_vcf_file,
      clinvar_vcf_idx = clinvar_vcf_idx,
      kgp_vcf_file = kgp_vcf_file,
      kgp_vcf_idx = kgp_vcf_idx,
      gnomad_vcf_file = gnomad_vcf_file,
      gnomad_vcf_idx = gnomad_vcf_idx,
      acmg59_vcf_file = acmg59_vcf_file,
      acmg59_vcf_idx = acmg59_vcf_idx
  }

  output {
    File annot_vcf_file = vcf_annot.annot_vcf_file
    File annot_vcf_idx = vcf_annot.annot_vcf_idx
    File cln_tsv_file = vcf_annot.cln_tsv_file
  }
}

task vcf_annot {
  input {
    Int build = 38
    File vcf_file
    File vcf_idx
    File fasta_ref
    File fasta_fai
    File gff3_file
    File clinvar_vcf_file
    File clinvar_vcf_idx
    File acmg59_vcf_file
    File acmg59_vcf_idx
    File kgp_vcf_file
    File kgp_vcf_idx
    File gnomad_vcf_file
    File gnomad_vcf_idx
    String clinvar_cols = "VARIATIONID,CLNDN,CLNSIG,GENEINFO,MC"
    String kgp_cols = "KGP_AF:=AF,EAS_AF,EUR_AF,AFR_AF,AMR_AF,SAS_AF"
    String gnomad_cols = "ID,GNOMAD_AF:=AF"
  }

  String filebase = basename(vcf_file, ".bcf")

  command <<<
    set -euo pipefail
    bcftools csq --no-version --output-type b --output "~{filebase}.csq.bcf" --fasta-ref "~{fasta_ref}" --gff-annot "~{gff3_file}" --brief-predictions --local-csq --ncsq 64 "~{vcf_file}"
    bcftools index "~{filebase}.csq.bcf"
    rm "~{vcf_file}" "~{vcf_idx}" "~{fasta_ref}" "~{fasta_fai}" "~{gff3_file}"

    list="~{clinvar_cols}"
    bcftools annotate --no-version --output-type b --output "~{filebase}.cln.bcf" --annotations "~{clinvar_vcf_file}" --columns $list "~{filebase}.csq.bcf"
    bcftools index "~{filebase}.cln.bcf"
    rm "~{filebase}.csq.bcf"{,.csi} "~{clinvar_vcf_file}" "~{clinvar_vcf_idx}"

    bcftools annotate --no-version --output-type b --output "~{filebase}.acmg59.bcf" --annotations "~{acmg59_vcf_file}" --mark-sites ACMG59 "~{filebase}.cln.bcf"
    bcftools index "~{filebase}.acmg59.bcf"
    rm "~{filebase}.cln.bcf"{,.csi} "~{acmg59_vcf_file}" "~{acmg59_vcf_idx}"

    list="~{kgp_cols}"
    bcftools annotate --no-version --output-type b --output "~{filebase}.kgp.bcf" --annotations "~{kgp_vcf_file}" --columns $list "~{filebase}.acmg59.bcf"
    bcftools index "~{filebase}.kgp.bcf"
    rm "~{filebase}.acmg59.bcf"{,.csi} "~{kgp_vcf_file}" "~{kgp_vcf_idx}"

    list="~{gnomad_cols}"
    bcftools annotate --no-version --output-type b --output "~{filebase}.annot.bcf" --annotations "~{gnomad_vcf_file}" --columns $list "~{filebase}.kgp.bcf"
    bcftools index "~{filebase}.annot.bcf"
    rm "~{filebase}.kgp.bcf"{,.csi} "~{gnomad_vcf_file}" "~{gnomad_vcf_idx}"

    url="https://www.ncbi.nlm.nih.gov/clinvar/variation/"
    fmt="%CHROM\t%POS\t%ID\t%REF\t%ALT\t%GNOMAD_AF\t%KGP_AF\t%EAS_AF\t%EUR_AF\t%AFR_AF\t%AMR_AF\t%SAS_AF\t$url%VARIATIONID\t%CLNSIG\t%GENEINFO\t%MC\t%ACMG59[\t%GT\t%AD]\n"
    bcftools query --format "$fmt" --print-header --include 'GT!="0/0" & GT!="./."' "~{filebase}.annot.bcf" | \
      sed 's/\[[1-9][0-9]*\]//g;s/\tPOS\t/\tPOS_GRCh~{build}\t/;s/\thttps:\/\/www.ncbi.nlm.nih.gov\/clinvar\/variation\/VARIATIONID\t/\tURL\t/' | \
      tail -c+3 | grep "^CHROM\|Pathogenic\|Likely_pathogenic" > "~{filebase}.cln.tsv"
  >>>

  output {
    File annot_vcf_file = filebase + ".annot.bcf"
    File annot_vcf_idx = filebase + ".annot.bcf.csi"
    File cln_tsv_file = filebase + ".cln.tsv"
  }
}