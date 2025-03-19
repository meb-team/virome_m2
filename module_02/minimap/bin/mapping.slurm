#!/bin/bash

#SBATCH --job-name=minimap
#SBATCH --output=logs/minimap_%A_%a.out
#SBATCH --error=logs/minimap_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast
#SBATCH --array=0-XXXX

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone
module load minimap2/2.24

# === Variable definition ===

