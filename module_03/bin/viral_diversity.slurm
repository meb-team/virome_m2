#!/bin/bash

#SBATCH --job-name=diversity
#SBATCH --ntasks=1
#SBATCH --output=logs/diversity_%j.out
#SBATCH --error=logs/diversity_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


source miniconda3/bin/activate
conda init
conda activate diversity

# === Variables ===
scratch="/storage/scratch/$USER"
path="$scratch/input"
OUTPUT_DIR="$scratch/diversity/res"

mkdir -p $OUTPUT_DIR
mkdir -p $path


# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone copy lmge-microstore:huserville/module_02/MMseq2/results/rebuild_taxo $path

# === Process ===

./module_03/bin/viral_diversity.py -i $path -o $OUTPUT_DIR

rclone sync $OUTPUT_DIR lmge-microstore:huserville/module_03/diversity/results

rm -r $OUTPUT_DIR

exit 0

