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

DB="module_02/MMseq2/taxonomy/mmseqs_vrefseq/refseq_viral"
OUTPUT="module_02/MMseq2/results/biome_taxo"
BIOME_DIR="module_02/MMseq2/results/biome_fasta"
mkdir -p "$OUTPUT"
# === Process ===

for query in "$BIOME_DIR"/*.fa "$BIOME_DIR"/*.fasta; do
    # Extract the ecosystem name (ECO) from the filename
    basename_query=$(basename "$query")
    ecosystem_name=$(echo "$basename_query" | cut -d'_' -f1)

    echo "Processing $query (Ecosystem: $ecosystem_name)"

    # Create the database for MMseqs
    mmseqs createdb "$query" "$OUTPUT/indexed"

    # Run taxonomy annotation using MMseqs
    mmseqs taxonomy "$OUTPUT/indexed" "$DB" "$OUTPUT/${ecosystem_name}_res" "$OUTPUT/tmp" --tax-lineage 1 --lca-mode 3

    # Generate the TSV output with results
    mmseqs createtsv "$OUTPUT/indexed" "$OUTPUT/${ecosystem_name}_res" "$OUTPUT/${ecosystem_name}_taxo_results.tsv"

    # Create the taxonomy report
    mmseqs taxonomyreport "$DB" "$OUTPUT/${ecosystem_name}_res" "$OUTPUT/${ecosystem_name}_taxo_report"

    # Clean intermediate results
    rm "$OUTPUT"/"${ecosystem_name}"_res.*
    rm "$OUTPUT"/indexed*
    rm -r "$OUTPUT"/tmp/
done

echo "All files processed!"
