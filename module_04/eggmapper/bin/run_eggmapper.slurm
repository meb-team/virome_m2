#!/bin/bash

#SBATCH --job-name=run_egg
#SBATCH --ntasks=1
#SBATCH --output=logs/run_eggmapper_%j.out
#SBATCH --error=logs/run_eggmapper_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --partition=lmge

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
rm -rf $scratch
remote="lmge-microstore:huserville"
db="$scratch/db"
data="$scratch/data"
results="$scratch/results"

mkdir -p $db
mkdir -p $data
mkdir -p $results

echo "Synchronizing distant files..."
rclone copy $remote/module_04/eggmapper/db $db
rclone copy $remote/module_04/prodigual/results/sequences_proteines.faa $data

# === Process ===
echo "Run emapper.."

emapper.py -i $data/sequences_proteines.faa -o $results/ --cpu 32 --data_dir $db

echo "Copy results.."
rclone copy $results $remote/module_04/eggmapper/results/annotations

exit 0
