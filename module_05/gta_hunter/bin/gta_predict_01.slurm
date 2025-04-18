#!/bin/bash

#SBATCH --job-name=gta_hunter
#SBATCH --ntasks=1
#SBATCH --output=logs/gta_%j.out
#SBATCH --error=logs/gta_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone

# === Variables ===
scratch="/storage/scratch/$USER"

mkdir -p $scratch/data
mkdir -p $scratch/results

# === Process ===
# Load the file.faa for each prediction tools for each ecosystem
