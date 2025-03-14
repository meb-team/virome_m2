#!/bin/bash

#SBATCH --job-name=rebuild
#SBATCH --ntasks=1
#SBATCH --output=logs/rebuild_%j.out
#SBATCH --error=logs/rebuild_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


module load gcc/8.1.0
module load python/3.7.1
module load numpy
module load pandas

# === Variables ===
scratch="/storage/scratch/$USER"
path="$scratch/input"
OUTPUT_DIR="$scratch/build/res"

mkdir -p $OUTPUT_DIR
mkdir -p $path

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone copy lmge-microstore:huserville/module_02/MMseq2/results/eco_taxo $path

# === Process ===

./module_02/MMseq2/bin/building_res.py -i $path -o $OUTPUT_DIR

rclone sync $OUTPUT_DIR lmge-microstore:huserville/module_02/MMseq2/results/rebuild_taxo

rm -r $OUTPUT_DIR

exit 0

