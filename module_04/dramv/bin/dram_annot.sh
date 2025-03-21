#!/bin/bash

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

# === Variables ===
fasta="module_02/MMseq2/results/eco_fasta"
output_dir="module_04/dramv/results"

mkdir -p $output_dir

conda activate DRAM



# === Process each FASTA file sequentially ===
for file in $fasta/*.fa; do
    echo "Processing: $file"

    ecosystem=$(basename "$file" | cut -d'_' -f1)
    eco_output_dir="$output_dir/$ecosystem"

    mkdir -p "$eco_output_dir"
    DRAM-v.py annotate -i "$file" -o "$eco_output_dir/annotation" --threads 16

    DRAM.py distill -i "$eco_output_dir/annotation/annotations.tsv" \
        -o "$eco_output_dir/genome_summaries"

done

exit 0
