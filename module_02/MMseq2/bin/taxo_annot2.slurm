#!/bin/bash

#SBATCH --job-name=taxo_annot
#SBATCH --output=logs/taxo_annotation_%A_%a.out
#SBATCH --error=logs/taxo_annotation_%A_%a.err
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=16 # Nb CPUs per tasks
#SBATCH --mem=128G         # RAM memory
#SBATCH --time=3-00:00:00
#SBATCH --partition=lmge


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variables are used
set -o pipefail


# === Variable definition ===
REMOTE_PATH="lmge-microstore:huserville"    # REMOTE CLOUD
scratch="/storage/scratch/$USER"

mkdir -p $scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq
mkdir -p $scratch/module_02/MMseq2/results/eco_fasta

rclone copy $REMOTE_PATH/module_02/MMseq2/taxonomy/mmseqs_vrefseq/ $scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq
rclone copy $REMOTE_PATH/module_02/MMseq2/results/eco_fasta $scratch/module_02/MMseq2/results/eco_fasta

DB="$scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq/refseq_viral"        # PATH TO REFSEQ DB
OUTPUT="$scratch/results"                                         # PATH TO OUTPUT
BIOME_DIR="$scratch/module_02/MMseq2/results/eco_fasta"           # PATH TO FASTA CREATED PREVIOUSLY WITH tax_fasta.slurm

mkdir -p "$OUTPUT"

module load MMseqs2/10-6d92c


# === Process each FASTA file ===

mmseqs createindex $DB scratch/db

for query in "$BIOME_DIR"/*.fa; do
    [ -e "$query" ] || continue  # Skip if no FASTA files are found
    
    basename_query=$(basename "$query")
    ecosystem_name=$(echo "$basename_query" | cut -d'_' -f1)
    
    mkdir -p "$OUTPUT/$ecosystem_name"
    
    # Créer la base de données pour MMseqs
    mmseqs createdb "$query" "$OUTPUT/$ecosystem_name/indexed"
    
    # Exécuter l'annotation taxonomique avec MMseqs
    mmseqs taxonomy "$OUTPUT/$ecosystem_name/indexed" "$DB" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/tmp" --tax-lineage 1 --lca-mode 3 --threads 16
    
    # Générer le fichier TSV avec les résultats
    mmseqs createtsv "$OUTPUT/$ecosystem_name/indexed" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_results.tsv"
    
    # Créer le rapport taxonomique
    mmseqs taxonomyreport "$DB" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_report"
    
    # Copier les résultats vers le stockage distant
    rclone copy "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_results.tsv" "$REMOTE_PATH/module_02/MMseq2/results/eco_taxo/$ecosystem_name"
    rclone copy "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_report" "$REMOTE_PATH/module_02/MMseq2/results/eco_taxo/$ecosystem_name"
    
    # Nettoyer les résultats intermédiaires
    rm "$OUTPUT/$ecosystem_name/${ecosystem_name}_res."*
    rm "$OUTPUT/$ecosystem_name/indexed"*
    rm -r "$OUTPUT/$ecosystem_name/tmp/"
    
done

