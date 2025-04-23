#!/bin/bash

#SBATCH --job-name=gta_results
#SBATCH --ntasks=1
#SBATCH --output=logs/gta_res_%j.out
#SBATCH --error=logs/gta_res_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone

# === Variables ===
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"
data="$scratch/data"
results="$scratch/results"

mkdir -p $results
mkdir -p $data

rclone copy $remote/module_05/gta_hunter/results/ $data

# === Process ===
echo -e "contig\tprediction" > "$results/GTA_prediction.txt"

for file in $scratch/data/*.txt; do

    cat $file | grep '>' |  awk '{print $1 "\t" $10}' >> $results/GTA_prediction.txt

done

rclone copy $results/GTA_prediction.txt $remote/module_05/gta_hunter/prediction

exit 0
