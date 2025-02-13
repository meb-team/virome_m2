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
FASTA="module_01/annotate/results/all_annotated_contigs.fasta"
OUTPUT="module_02/MMseq2/results"
mkdir -p "$OUTPUT"

# === Process ===
cut -f1 "$TSV" > "$OUTPUT"/contig_ids.txt

declare -A sequences
current_id=""

while IFS= read -r line; do
    if [[ $line == ">"* ]]; then
        current_id=$(echo "$line" | sed -E 's/>([^=]+)==.*/\1/')
        sequences["$current_id"]=""
    elif [[ -n "$current_id" ]]; then
        sequences["$current_id"]+="$line"
    fi
done < "$FASTA"

echo "" > "$OUTPUT/tax_fasta_seed.fa"
while IFS= read -r id; do
    if [[ -n "${sequences[$id]}" ]]; then
        echo ">$id" >> "$OUTPUT/tax_fasta_seed.fa"
        echo "${sequences[$id]}" >> "$OUTPUT/tax_fasta_seed.fa"
    fi
done < "$OUTPUT"/contig_ids.txt

rm contig_ids.txt

echo "File {$OUTPUT}/tax_fasta_seed.fa created !"
