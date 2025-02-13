#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to annotate the viral fasta sequences with taxonomic annotations, using MMseq2 and Refseq viral database.
# Author  : SERVILLE Hugo, DUMONT Celtill
# Date    : 13/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
query="module_02/MMseq2/results/tax_fasta_seed.fa"
DB="module_02/MMseq2/taxonomy/mmseqs_vrefseq/refseq_viral"
OUTPUT="module_02/MMseq2/results"
# === Process ===
mmseqs createdb "$query" "$OUTPUT/indexed" # Creation of a mmseq2 format file from a fasta file
mmseqs taxonomy "$OUTPUT/indexed" "$DB" "$OUTPUT" "$OUTPUT/tmp" --tax-lineage 1 --lca-mode 3 # annotation 
mmseqs createtsv "$OUTPUT/indexed" "$OUTPUT" taxo_results.tsv # compute a TSV as result
mmseqs taxonomyreport "$DB" "$OUTPUT" taxo_report
