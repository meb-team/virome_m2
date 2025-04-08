#!/bin/bash

#SBATCH --job-name=dram_annot
#SBATCH --ntasks=1
#SBATCH --output=logs/dramannot_%j.out
#SBATCH --error=logs/dramannot_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
output_dir="$scratch/module_04/dramv/results"
fasta="$scratch/fasta"
db="$scratch/module_04/dramv/db"

mkdir -p $fasta
mkdir -p $db
mkdir -p $output_dir

echo "Synchronizing distant files..."
rclone copy lmge-microstore:huserville/module_02/MMseq2/results/eco_fasta $fasta
rclone copy lmge-microstore:huserville/module_04/dramv/db $db

source miniconda3/bin/activate
conda init
conda activate DRAM14

module load seqkit/0.15.0

DRAM-setup.py import_config --config_loc module_04/dramv/CONFIG/my_old_config.txt

# === Process each FASTA file sequentially ===
for file in $fasta/*.fa; do
    echo "Processing: $file"

    seqkit rmdup -s -o temp.fa $file
    mv temp.fa $file

    ecosystem=$(basename "$file" | cut -d'_' -f1)
    eco_output_dir="$output_dir/$ecosystem"

    mkdir -p "$eco_output_dir"

    DRAM-v.py annotate -i "$file" -o "$eco_output_dir/annotation" --threads 32

    DRAM-v.py distill -i "$eco_output_dir/annotation/annotations.tsv" \
        -o "$eco_output_dir/genome_summaries"

    rclone copy $eco_output_dir lmge-microstore:huserville/module_04/dramv/results/$ecosytem
    rm -r $eco_output_dir

done

rm -rf "$scratch"

exit 0
