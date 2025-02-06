#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to cluster the annotated viral predicted contigs.
# Author  : SERVILLE Hugo
# Date    : 04/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===

fasta_input="module_01/annotate/results/all_annotated_contigs.fasta"
output_dir="module_01/MMseq2/results"

mkdir -p "$output_dir"

# Process MMseq2 ===

echo "Starting clustering..."

mmseqs easy-linclust "$fasta_input" "$output_dir/clusterRes" "$output_dir/tmp" --min-seq-id 0.95 -c 0.85 --cov-mode 1


echo "End of the clustering !"

exit 0
