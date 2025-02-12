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

# === Process database creation ===
if [ ! -d "$TAX_DIR" ];
then
	mkdir "$TAX_DIR";
fi

if [ ! -d "$TAX_DIR"/taxdump ];
then
	mkdir dl_taxdump
	mkdir "$TAX_DIR"/taxdump
	cd "$TAX_DIR"/dl_taxdump

	wget -O taxdump.zip https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2022-08-01.zip
	unzip taxdump.zip

	mv names.dmp nodes.dmp delnodes.dmp merged.dmp ../"$TAX_DIR"/taxdump
	cd ..
	rm -r dl_taxdump
fi

if [ ! -d "$TAX_DIR"/mmseqs_vrefseq ];
then
	mkdir "$TAX_DIR"/mmseqs_vrefseq

	wget -O "$TAX_DIR"/mmseqs_vrefseq.tar.gz "https://zenodo.org/record/7044674/files/mmseqs_vrefseq.tar.gz"

	tar -zxvf "$TAX_DIR"/mmseqs_vrefseq.tar.gz -C "$TAX_DIR"
	rm "$TAX_DIR"/mmseqs_vrefseq.tar.gz
	cd "$TAX_DIR"/mmseqs_vrefseq

	mmseqs createdb refseq_viral.faa refseq_viral
	mmseqs createtaxdb refseq_viral tmp --ncbi-tax-dump ../taxdump --tax-mapping-file virus.accession2taxid
	mmseqs createindex refseq_viral tmp

	rm -rf tmp mmseqs_vrefseq.tar.gz
	cd ../../
fi
