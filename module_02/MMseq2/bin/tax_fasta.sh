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
TSV_DIR="module_01/filtering/results/biome"
FASTA="module_01/MMseq2/results/clusterRes_rep_seq.fasta"
OUTPUT_DIR="module_02/MMseq2/results/biome_fasta"
mkdir -p "$OUTPUT_DIR"

# === Process ===

for TSV in "$TSV_DIR"/*.tsv; do
    # Récupérer le nom du biome sans l'extension
    BIOME_NAME=$(basename "$TSV" .tsv)

    echo "Processing $BIOME_NAME..."

    # Définir les fichiers temporaires
    CONTIG_IDS="$OUTPUT_DIR/${BIOME_NAME}_contig_ids.txt"
    CLEANED_FASTA="$OUTPUT_DIR/${BIOME_NAME}_cleaned_fasta.fa"
    OUTPUT_FASTA="$OUTPUT_DIR/${BIOME_NAME}_tax_fasta_seed.fa"

    # Extraction des IDs et nettoyage du FASTA
    cut -f1 "$TSV" > "$CONTIG_IDS"
    sed 's/==.*//' "$FASTA" > "$CLEANED_FASTA"

    # Filtrage des séquences
    seqtk subseq "$CLEANED_FASTA" "$CONTIG_IDS" > "$OUTPUT_FASTA"

    # Suppression des fichiers temporaires
    rm "$CONTIG_IDS" "$CLEANED_FASTA"

    echo "File $OUTPUT_FASTA created!"
done

echo "Processing completed!"
