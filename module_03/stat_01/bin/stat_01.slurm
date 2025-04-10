#!/bin/bash

#SBATCH --job-name=stat_01
#SBATCH --output=logs/stat01_%a.out
#SBATCH --error=logs/stat01_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone

source miniconda3/bin/activate
conda init
conda activate stat

# === Variable definition ===

remote="lmge-microstore:huserville"
scratch="/storage/scratch/$USER"
path="$scratch/data"
output_dir="module_03/stat_01/results"

mkdir -p $output_dir
mkdir -p $path

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone copy $remote/module_01/filtering/results/ $path

# === Process ===

echo "Begin the statistical analysis for module_01..."

./module_03/stat_01/bin/stat_01.py -i $path -o $output_dir
rclone sync $output_dir $remote/module_03/stat_01/results

exit 0
