#!/bin/bash

#SBATCH --job-name=filtering
#SBATCH --ntasks=1
#SBATCH --output=logs/filtering_%j.out
#SBATCH --error=logs/filtering_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

module load rclone

source miniconda3/bin/activate
conda init
conda activate stat

# === Variable ===
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"
data="$scratch/data"
results="$scratch/results"

mkdir -p $data
mkdir -p $results

echo "Synchronizing data..."
rclone copy $remote/module_04/eggmapper/results/annotations/.emapper.annotations $data
rclone copy $remote/module_01/annotate/results/contig_eco_list.tsv $data

# === Process ===

echo "Start the filtering..."
grep -v '^##' "$data/.emapper.annotations" > "$data/emapper_cleaned.tsv"

./module_04/eggmapper/bin/AMG_prediction.py -o $results -a $data/emapper_cleaned.tsv -ko module_04/eggmapper/data/VIBRANT_AMGs.tsv -e $data/contig_eco_list.tsv

rclone copy $results/filtered_eggmapper_annotations.tsv $remote/module_04/eggmapper/results/AMG
rclone copy $results/AMG.tsv $remote/module_04/eggmapper/results/AMG

exit 0


