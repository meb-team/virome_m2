#!/bin/bash

#SBATCH --job-name=visu_diversity
#SBATCH --ntasks=1
#SBATCH --output=logs/v_diversity_%j.out
#SBATCH --error=logs/v_diversity_%j.err
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
conda activate stat

# === Variables ===
scratch="/storage/scratch/$USER"
path="$scratch/input"
OUTPUT_DIR="module_03/figure"

mkdir -p $OUTPUT_DIR
mkdir -p $path


# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone copy lmge-microstore:huserville/module_03/diversity/results/ $path

# === Process ===

./module_03/bin/diversity/visu.py -i $path/jaccard_beta.tsv -o $OUTPUT_DIR

rclone sync $OUTPUT_DIR lmge-microstore:huserville/module_03/diversity/visu

rm -rf $scratch

exit 0

