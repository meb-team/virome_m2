#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to cluster the annotated viral predicted contigs.
# Author  : SERVILLE Hugo
# Date    : 04/03/2025
# Version : 1.0
# ==========================

#SBATCH --job-name=clustering
#SBATCH --ntasks=1
#SBATCH --output=logs/clustering_%j.out
#SBATCH --error=logs/clustering_%j.err
#SBATCH --cpus-per-task=40
#SBATCH --mem=128G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


module load MMseqs2/13-45111
#module load MMseqs2/10-6d92c

# === Variable definition ===
output_dir="module_01/MMseq2/results"
LOCAL_DIR="/storage/scratch/$USER/module_01/annotate/results"
REMOTE_PATH="lmge-microstore:huserville/module_01/annotate/results"

mkdir -p "$output_dir"

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone sync "$REMOTE_PATH" "$LOCAL_DIR"

fasta_input="$LOCAL_DIR/all_annotated_contigs.fasta"

# === Process MMseq2 ===

echo "Starting clustering..."

mmseqs easy-linclust "$fasta_input" "$output_dir/clusterRes" "$output_dir/tmp" --min-seq-id 0.95 -c 0.85 --cov-mode 1

echo "End of the clustering !"

rclone copy $output_dir lmge-microstore:huserville/module_01/mmseq2/results
rm -r $output_dir
rm -r $LOCAL_DIR

exit 0

