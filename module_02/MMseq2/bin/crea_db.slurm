#!/bin/bash
#SBATCH --job-name=viral_db_setup
#SBATCH --output=module_02/MMseq2/viral_db_setup.out
#SBATCH --error=module_02/MMseq2/viral_db_setup.err
#SBATCH --time=02:00:00  # Max time execution
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=4 # Nb CPU per tasks
#SBATCH --mem=16G        # RAM memoery

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
TAX_DIR="module_02/MMseq2/taxonomy"
mkdir -p "$TAX_DIR"

# === Process database creation ===
if [ ! -d "$TAX_DIR"/taxdump ];
then
    mkdir "$TAX_DIR"/dl_taxdump
    mkdir "$TAX_DIR"/taxdump

    curl -O "$TAX_DIR"/dl_taxdump/taxdump.zip https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2022-08-01.zip
    unzip -d "$TAX_DIR"/dl_taxdump "$TAX_DIR"/dl_taxdump/taxdump.zip

    mv "$TAX_DIR"/dl_taxdump/names.dmp "$TAX_DIR"/taxdump
    mv "$TAX_DIR"/dl_taxdump/nodes.dmp "$TAX_DIR"/taxdump
    mv "$TAX_DIR"/dl_taxdump/delnodes.dmp "$TAX_DIR"/taxdump
    mv "$TAX_DIR"/dl_taxdump/merged.dmp "$TAX_DIR"/taxdump
    rm -r "$TAX_DIR"/dl_taxdump
fi

if [ ! -d "$TAX_DIR"/mmseqs_vrefseq ];
then
    mkdir "$TAX_DIR"/mmseqs_vrefseq

    curl -O "$TAX_DIR"/mmseqs_vrefseq.tar.gz "https://zenodo.org/record/7044674/files/mmseqs_vrefseq.tar.gz"

    tar -zxvf "$TAX_DIR"/mmseqs_vrefseq.tar.gz -C "$TAX_DIR"
    rm "$TAX_DIR"/mmseqs_vrefseq.tar.gz

    mmseqs createdb "$TAX_DIR"/mmseqs_vrefseq/refseq_viral.faa "$TAX_DIR"/mmseqs_vrefseq/refseq_viral
    mmseqs createtaxdb "$TAX_DIR"/mmseqs_vrefseq/refseq_viral "$TAX_DIR"/mmseqs_vrefseq/tmp --ncbi-tax-dump "$TAX_DIR"/taxdump --tax-mapping-file "$TAX_DIR"/mmseqs_vrefseq/virus.accession2taxid
    mmseqs createindex "$TAX_DIR"/mmseqs_vrefseq/refseq_viral "$TAX_DIR"/mmseqs_vrefseq/tmp

    rm -rf "$TAX_DIR"/mmseqs_vrefseq/tmp "$TAX_DIR"/mmseqs_vrefseq.tar.gz
fi

