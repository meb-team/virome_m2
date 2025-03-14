#!/bin/bash

#SBATCH --job-name=fasta_seed_creation
#SBATCH --output=logs/fasta_seed_%A_%a.out  
#SBATCH --error=logs/fasta_seed_%A_%a.err
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=fast
#SBATCH --array=0-21

# === Initialisation et sécurité ===
set -e
set -u
set -o pipefail


source miniconda3/bin/activate
conda init
conda activate seqtk_env


REMOTE_PATH="lmge-microstore:huserville/module_01"
scratch="/storage/scratch/$USER"

mkdir -p $scratch/filtering/eco
mkdir -p $scratch/mmseq2/results

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."

rclone sync $REMOTE_PATH/filtering/results/ $scratch/filtering/eco
rclone sync $REMOTE_PATH/mmseq2/results/clusterRes_rep_seq.fasta $scratch/mmseq2/results

ls $scratch/filtering/eco

# === Variable definition ===

TSV_DIR="$scratch/filtering/eco"
FASTA="$scratch/mmseq2/results/clusterRes_rep_seq.fasta"
OUTPUT_DIR="$scratch/module_02/MMseq2/results/eco_fasta"

mkdir -p $OUTPUT_DIR

# === Générer la liste des fichiers TSV ===
TSV_FILES=("$TSV_DIR"/*.tsv)
TSV="${TSV_FILES[$SLURM_ARRAY_TASK_ID]}"  # Sélection du fichier en fonction de l'indice SLURM

# Récupérer le nom du biome sans l'extension
BIOME_NAME=$(basename "$TSV" .tsv | cut -d'_' -f1)

echo "Processing $BIOME_NAME..."

# Définir les fichiers temporaires et de sortie
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

rclone sync $OUTPUT_FASTA lmge-microstore:huserville/module_02/MMseq2/results/eco_fasta
rm $OUTPUT_FASTA

echo "File $OUTPUT_FASTA created for $BIOME_NAME!"

