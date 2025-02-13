#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to create a viral database from RefSeq NCBI. More info here : based on : https://github.com/deng-lab/viroprofiler/blob/main/modules/local/setup_db.nf
# Author  : SERVILLE Hugo, DUMONT Celtill
# Date    : 12/02/2025
# Version : 1.0
# ==========================

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

	wget -O "$TAX_DIR"/dl_taxdump/taxdump.zip https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2022-08-01.zip
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

	wget -O "$TAX_DIR"/mmseqs_vrefseq.tar.gz "https://zenodo.org/record/7044674/files/mmseqs_vrefseq.tar.gz"

	tar -zxvf "$TAX_DIR"/mmseqs_vrefseq.tar.gz -C "$TAX_DIR"
	rm "$TAX_DIR"/mmseqs_vrefseq.tar.gz

	mmseqs createdb "$TAX_DIR"/mmseqs_vrefseq/refseq_viral.faa "$TAX_DIR"/mmseqs_vrefseq/refseq_viral
	mmseqs createtaxdb "$TAX_DIR"/mmseqs_vrefseq/refseq_viral "$TAX_DIR"/mmseqs_vrefseq/tmp --ncbi-tax-dump "$TAX_DIR"/taxdump --tax-mapping-file "$TAX_DIR"/mmseqs_vrefseq/virus.accession2taxid
	mmseqs createindex "$TAX_DIR"/mmseqs_vrefseq/refseq_viral "$TAX_DIR"/mmseqs_vrefseq/tmp

	rm -rf "$TAX_DIR"/mmseqs_vrefseq/tmp "$TAX_DIR"/mmseqs_vrefseq.tar.gz

fi
