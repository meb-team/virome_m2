#!/bin/bash

#SBATCH --job-name=eggmapper
#SBATCH --ntasks=1
#SBATCH --output=logs/eggmapper_%j.out
#SBATCH --error=logs/eggmapper_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone

source miniconda3/bin/activate
conda init
conda activate eggmapper

# === Variables ===
scratch="/storage/scratch/$USER"
db="$scratch/db"
remote="lmge-microstore:huserville"

mkdir -p $db
mkdir -p $data

# === Process ===

download_eggnog_data.py --data_dir $db -y

rclone copy $db $remote/module_04/eggmapper/db

exit 0
