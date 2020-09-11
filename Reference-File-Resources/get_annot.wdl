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

workflow get_annot {
  input {
    Int? build # 37 or 38
    Int? release_override
    Int? clinvar_date # yyyymmdd
    File? in_fasta_ref
    File? in_fasta_fai
    Boolean kgp = true
  }

  if (!defined(in_fasta_ref) || !defined(in_fasta_fai)) {
    call get_ref {
      input:
        build = build
    }
  }

  call get_genbank {
    input:
      build = build,
      release_override = release_override
  }

  call get_clinvar {
    input:
      build = build,
      date = clinvar_date,
      fasta_fai = select_first([in_fasta_fai, get_ref.fasta_fai])
  }

  call get_acmg59 {
    input:
      fasta_ref = select_first([in_fasta_ref, get_ref.fasta_ref]),
      gff3_file = get_genbank.gff3_file,
      clinvar_vcf_file = get_clinvar.vcf_file,
      clinvar_vcf_idx = get_clinvar.vcf_idx
  }

  if (kgp) {
    call get_kgp {
      input:
        build = build
    }
  }

  output {
    File? fasta_ref = get_ref.fasta_ref
    File? fasta_fai = get_ref.fasta_fai
    File gff3_file = get_genbank.gff3_file
    Int? date = get_clinvar.date
    File clinvar_vcf_file = get_clinvar.vcf_file
    File clinvar_vcf_idx = get_clinvar.vcf_idx
    File acmg59_vcf_file = get_acmg59.vcf_file
    File acmg59_vcf_idx = get_acmg59.vcf_idx
    File? kgp_vcf_file = get_kgp.vcf_file
    File? kgp_vcf_idx = get_kgp.vcf_idx
  }
}

task get_ref {
  input {
    Int build = 38
  }

  String url = if build == 38 then "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz"
    else "ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz"

  command <<<
    set -euo pipefail
    wget -O- ~{url} | \
      gzip -d > ~{basename(url, ".gz")}
    samtools faidx ~{basename(url, ".gz")}
  >>>

  output {
    File fasta_ref = basename(url, ".gz")
    File fasta_fai = basename(url, ".gz") + ".fai"
  }
}

task get_genbank {
  input {
    Int build = 38
    Int? release_override
  }

  Int release = select_first([release_override, if build == 37 then 87 else 100])
  String url = "ftp://ftp.ensembl.org/pub/" + (if build == 37 then "grch37/current/gff3" else "current_gff3") +
    "/homo_sapiens/Homo_sapiens.GRCh" + build + "." + release + ".gff3.gz"

  command <<<
    set -euo pipefail
    wget -O- ~{url}~{if !(build != 38) then " | gzip -d | \\\n" +
      "  sed -e 's/^##sequence-region   \\([0-9XY]\\)/##sequence-region   chr\\1/' \\\n" +
      "  -e 's/^##sequence-region   MT/##sequence-region   chrM/' \\\n" +
      "  -e 's/^\\([0-9XY]\\)/chr\\1/' -e 's/^MT/chrM/' | gzip\\\n" else ""} > ~{basename(url)}
  >>>

  output {
    File gff3_file = basename(url)
  }
}

task get_clinvar {
  input {
    Int build = 38
    Int? date
    File fasta_fai
  }

  String url = "ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh" + build +
    (if defined(date) then "/weekly/clinvar_" + date + ".vcf.gz" else "/clinvar.vcf.gz")

  command <<<
    set -euo pipefail
    wget -O tmp.vcf.gz ~{url}
    bcftools reheader --fai ~{fasta_fai} tmp.vcf.gz | \
      gzip -d | ~{if !(build != 38) then "\n  grep -v ^NW_009646201.1 | \\\n" +
      "  sed -e 's/^/chr/' -e 's/^chr#/#/' -e 's/^chrMT/chrM/' | " else ""}\
      awk -F"\t" -v OFS="\t" '$0=="##ID=<Description=\"ClinVar Variation ID\">" {
      print "##INFO=<ID=VARIATIONID,Number=1,Type=Integer,Description=\"the ClinVar Variation ID\">"}
      $0!~"^#" {$8="VARIATIONID="$3";"$8; $3="."} $0!="##ID=<Description=\"ClinVar Variation ID\">" {print}' | \
      bcftools view --no-version --output-type b --output ~{basename(url, ".vcf.gz")}.bcf
    rm tmp.vcf.gz
    bcftools index ~{basename(url, ".vcf.gz")}.bcf
    bcftools view --no-version --header-only ~{basename(url, ".vcf.gz")}.bcf | grep ^##fileDate= | cut -d= -f2 | tr -d '-'
  >>>

  output {
    Int date = read_int(stdout())
    File vcf_file = basename(url, ".vcf.gz") + ".bcf"
    File vcf_idx = basename(url, ".vcf.gz") + ".bcf.csi"
  }
}

task get_acmg59 {
  input {
    File fasta_ref
    File gff3_file
    File clinvar_vcf_file
    File clinvar_vcf_idx
  }

#  Array[String] acmg59 = ["ACTA2", "ACTC1", "APC", "APOB", "ATP7B", "BMPR1A", "BRCA1", "BRCA2", "CACNA1S", "COL3A1",
#    "DSC2", "DSG2", "DSP", "FBN1", "GLA", "KCNH2", "KCNQ1", "LDLR", "LMNA", "MEN1",
#    "MLH1", "MSH2", "MSH6", "MUTYH", "MYBPC3", "MYH11", "MYH7", "MYL2", "MYL3", "NF2",
#    "OTC", "PCSK9", "PKP2", "PMS2", "PRKAG2", "PTEN", "RB1", "RET", "RYR1", "RYR2",
#    "SCN5A", "SDHAF2", "SDHB", "SDHC", "SDHD", "SMAD3", "SMAD4", "STK11", "TGFBR1", "TGFBR2",
#    "TMEM43", "TNNI3", "TNNT2", "TP53", "TPM1", "TSC1", "TSC2", "VHL", "WT1"]

  command <<<
    set -euo pipefail
    bcftools csq \
      --no-version \
      --output-type u \
      --fasta-ref"~{fasta_ref}" \
      --gff-annot "~{gff3_file}" \
      --brief-predictions \
      --local-csq \
      --ncsq 64 \
      ~{clinvar_vcf_file} | \
    bcftools +split-vep \
      --output-type u \
      --annotation BCSQ \
      --columns gene \
      --duplicate \
      --include 'gene=="ACTA2" || gene=="ACTC1" || gene=="APC" || gene=="APOB" || gene=="ATP7B" || gene=="BMPR1A" || gene=="BRCA1" || gene=="BRCA2" || gene=="CACNA1S" || gene=="COL3A1" || gene=="DSC2" || gene=="DSG2" || gene=="DSP" || gene=="FBN1" || gene=="GLA" || gene=="KCNH2" || gene=="KCNQ1" || gene=="LDLR" || gene=="LMNA" || gene=="MEN1" || gene=="MLH1" || gene=="MSH2" || gene=="MSH6" || gene=="MUTYH" || gene=="MYBPC3" || gene=="MYH11" || gene=="MYH7" || gene=="MYL2" || gene=="MYL3" || gene=="NF2" || gene=="OTC" || gene=="PCSK9" || gene=="PKP2" || gene=="PMS2" || gene=="PRKAG2" || gene=="PTEN" || gene=="RB1" || gene=="RET" || gene=="RYR1" || gene=="RYR2" || gene=="SCN5A" || gene=="SDHAF2" || gene=="SDHB" || gene=="SDHC" || gene=="SDHD" || gene=="SMAD3" || gene=="SMAD4" || gene=="STK11" || gene=="TGFBR1" || gene=="TGFBR2" || gene=="TMEM43" || gene=="TNNI3" || gene=="TNNT2" || gene=="TP53" || gene=="TPM1" || gene=="TSC1" || gene=="TSC2" || gene=="VHL" || gene=="WT1"' | \
    bcftools norm \
      --no-version \
      --output-type u \
      --rm-dup exact | \
    bcftools annotate \
      --no-version \
      --output-type b \
      --output "~{basename(clinvar_vcf_file, ".bcf")}.acmg59.bcf" \
      --remove INFO
    bcftools index "~{basename(clinvar_vcf_file, ".bcf")}.acmg59.bcf"
  >>>

  output {
    File vcf_file = basename(clinvar_vcf_file, ".bcf") + ".acmg59.bcf"
    File vcf_idx = basename(clinvar_vcf_file, ".bcf") + ".acmg59.bcf.csi"
  }
}

task get_kgp {
  input {
    Int build = 38
  }

  String url = if build == 38 then "http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr{{1..22},X,Y}_GRCh38_sites.20170504.vcf.gz"
    else "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.wgs.phase3_shapeit2_mvncall_integrated_v5b.20130502.sites.vcf.gz"

  command <<<
    set -euo pipefail
    ~{if !(build != 38) then "wget " + url + "\n" +
      "bcftools merge --no-version " + basename(url) + " | \\\n" +
      "  grep -v \"^##contig=<ID=[GNh]\" | \\\n" +
      "  sed 's/^##contig=<ID=MT/##contig=<ID=chrM/;s/^##contig=<ID=\\([0-9XY]\\)/##contig=<ID=chr\\1/;s/^\\([1-9XY]\\)/chr\\1/' | \\\n" +
      "  bcftools view --no-version --output-type b --output ALL.GRCh38_sites.20170504.bcf\n" +
      "bcftools index ALL.GRCh38_sites.20170504.bcf\n" +
      "rm " + basename(url)
    else "wget -O- " + url + " | \\\n" +
      "  bcftools view --no-version --output-type b --output " + basename(url, ".gz") + ".bcf\n" +
      "bcftools index " + basename(url, ".gz") + ".bcf"}
  >>>

  output {
    File vcf_file = if build == 38 then "ALL.GRCh38_sites.20170504.bcf" else basename(url, ".gz") + ".bcf"
    File vcf_idx = if build == 38 then "ALL.GRCh38_sites.20170504.bcf.csi" else basename(url, ".gz") + ".bcf.csi"
  }
}

#task get_gnomad {
#  input {
#    Int build = 38
#  }
#
#  String url = "https://storage.cloud.google.com/gatk-best-practices/somatic-" +
#    if build == 38 then "hg38/af-only-gnomad.hg38.vcf.gz" else "b37/af-only-gnomad.raw.sites.vcf"
#  String ext = if build == 38 then ".tbi" else ".idx"
#
#  command <<<
#    set -euo pipefail
#    wget -O- ~{url} | \
#      bcftools view --no-version --output-type b --output ~{basename(basename(url, ".gz"), ".vcf")}.bcf
#    bcftools index ~{basename(basename(url, ".gz"), ".vcf")}.bcf
#  >>>
#
#  output {
#    File vcf_file = basename(basename(url, ".gz"), ".vcf") + ".bcf"
#    File vcf_idx = basename(basename(url, ".gz"), ".vcf") + ".bcf.csi"
#  }
#}
