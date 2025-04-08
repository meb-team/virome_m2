#!/bin/bash

#SBATCH --job-name=install_vs2
#SBATCH --output=logs/install_vs2_%A_%a.out
#SBATCH --error=logs/install_vs2_%A_%a.err
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
conda activate vs2

# === Variable definition ===

scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"

mkdir -p $scratch/vs2_db

# === Process ===

virsorter setup -d $scratch/vs2_db -j 4

rclone sync $scratch/vs2_db $remote/module_04/dramv/vs2_db

exit 0
