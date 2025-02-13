#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to create a fasta file containing representative contigs (seed) isolated at the end of the module_01.
# Author  : SERVILLE Hugo
# Date    : 13/02/2025
# Version : 1.0
# ==========================


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


# === Variable definition ===
TSV="module_01/filtering/results/filtered_representative_cluster.tsv"
FASTA="module_01/MMseq2/results/clusterRes_rep_seq.fasta"
OUTPUT="module_02/MMseq2/results"
mkdir -p "$OUTPUT"

# === Process ===

cut -f1 "$TSV" > "$OUTPUT/contig_ids.txt"
sed 's/==.*//' "$FASTA" > "$OUTPUT/cleaned_fasta.fa"

seqtk subseq "$OUTPUT/cleaned_fasta.fa" "$OUTPUT/contig_ids.txt" > "$OUTPUT/tax_fasta_seed.fa"

rm "$OUTPUT/contig_ids.txt" "$OUTPUT/cleaned_fasta.fa"

echo "File $OUTPUT/tax_fasta_seed.fa created !"
