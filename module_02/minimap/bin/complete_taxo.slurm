#!/bin/bash

#SBATCH --job-name=complete_taxo
#SBATCH --ntasks=1
#SBATCH --output=logs/complete_%j.out
#SBATCH --error=logs/complete_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


module load gcc/8.1.0
module load python/3.7.1
module load numpy
module load pandas

# === Variables ===
REMOTE_PATH="lmge-microstore:huserville"
scratch="/storage/scratch/$USER"
OUTPUT_DIR="$scratch/module_02/complete"

mkdir -p $scratch/mapping
mkdir -p $scratch/eco
mkdir -p $scratch/info
mkdir -p $OUTPUT_DIR

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone sync $REMOTE_PATH/module_02/minimap/results/ $scratch/mapping
rclone sync $REMOTE_PATH/module_02/MMseq2/results/rebuild_taxo/ $scratch/eco
rclone sync $REMOTE_PATH/module_02/minimap/imgvr_db/IMGVR_all_Sequence_information.tsv $scratch/info

# === Process ===

./module_02/minimap/bin/complete_taxo.py -p $scratch/eco -o $OUTPUT_DIR -m $scratch/mapping -i $scratch/info/IMGVR_all_Sequence_information.tsv

rclone sync $OUTPUT_DIR $REMOTE_PATH/module_02/minimap/res_complete_taxo

exit 0

