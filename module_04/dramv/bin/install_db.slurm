#!/bin/bash

#SBATCH --job-name=populate_table
#SBATCH --ntasks=1
#SBATCH --output=logs/populate_%j.out
#SBATCH --error=logs/populate_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
output_dir="$scratch/module_04/dramv/db"

# === Process ===

conda activate DRAM
echo "Conda environment loaded successfully for Dram-v tool !"

echo "Start the creation of the database"
DRAM-setup.py prepare_databases --output_dir $output_dir

rclone sync $output_dir lmge-microstore:huserville

rm -r $scratch
