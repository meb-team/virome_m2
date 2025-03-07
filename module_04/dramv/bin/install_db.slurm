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
#set -e  # Stop the script if error
#set -u  # Stop the script unknown variables
#set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
output_dir="$scratch/module_04/dramv/db"

mkdir -p $output_dir

# === Process ===
source miniconda3/bin/activate
conda init
conda activate DRAM
echo "Conda environment loaded successfully for Dram-v tool !"

echo "Start the creation of the database"

wget -r -np -nH --cut-dirs=2 -R "index.html*" -P $output_dir/vogdb https://fileshare.lisc.univie.ac.at/vog/latest/
#wget -r -np -nH --cut-dirs=2 -R "index.html*" -P $output_dir/vogdb --no-check-certificate -nv https://fileshare.lisc.univie.ac.at/vog/latest/

echo "AAAAAAAAAAAAAAAAAAAAAAAAA"

DRAM-setup.py prepare_databases --output_dir $output_dir --skip_uniref --threads 20 --vogdb_loc $output_dir/vogdb

echo "BBBBBBBBBBBBBBBBBBBBBBB"

rclone sync $output_dir lmge-microstore:huserville/module_04/dramv/db

rm -r $scratch
