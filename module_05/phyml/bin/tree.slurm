#!/bin/bash

#SBATCH --job-name=phyml
#SBATCH --ntasks=1
#SBATCH --output=logs/phyml_%j.out
#SBATCH --error=logs/phyml_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone
module load gcc/4.8.4
module load openmpi/1.8.4
module load phyml/3.3.20170530

# === Variables ===
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"

data="$scratch/msa"
results="$scratch/phyml"

mkdir -p $data
mkdir -p $results

rclone copy XX

# === Process ===
