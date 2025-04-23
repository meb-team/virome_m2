#!/bin/bash

#SBATCH --job-name=create_db
#SBATCH --ntasks=1
#SBATCH --output=logs/createdb_%j.out
#SBATCH --error=logs/createdb_%j.err
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
output_dir="$scratch/module_04/dramv/db"
home="/home/$USER"
path_dram="module_04/dramv/bin/dram_1.5.0--pyhdfd78af_0.sif"

if [ -d "$output_dir" ]; then
  rm -rf "$output_dir"/*
else
  mkdir -p "$output_dir"
fi

source miniconda3/bin/activate
conda init
conda activate DRAM14

# === Process ===

echo "Start the creation of the database"

DRAM-setup.py prepare_databases --output_dir $output_dir --skip_uniref --threads 20

#singularity exec --bind $output_dir $path_dram DRAM-setup.py prepare_databases --output_dir $output_dir --skip_uniref --threads 20

rclone sync $output_dir lmge-microstore:huserville/module_04/dramv/db

rm -r $scratch
