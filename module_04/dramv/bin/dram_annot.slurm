#!/bin/bash

#SBATCH --job-name=dram_annot
#SBATCH --ntasks=1
#SBATCH --output=logs/dramannot_%j.out
#SBATCH --error=logs/dramannot_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --partition=fast
#SBATCH --array=1-22

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
output_dir="module_04/dramv/results/"
fasta="$scratch/fasta"

if [ -d "$output_dir" ]; then
  rm -rf "$output_dir"/*
else
  mkdir -p "$output_dir"
fi

if [ -d "$fasta" ]; then
  rm -rf "$fasta"/*
else
  mkdir -p "$fasta"
fi

rclone copy lmge-microstore:huserville/module_02/MMseq2/results/eco_fasta $fasta

source miniconda3/bin/activate
conda init
conda activate DRAM

# === Process ===

fasta_files=($fasta/*.fa)
file="${fasta_files[$SLURM_ARRAY_TASK_ID-1]}"

ecosystem=$(basename "$file" | cut -d'_' -f1)

eco_output_dir="$output_dir/$ecosystem"
mkdir -p "$eco_output_dir"


DRAM.py annotate -i $query -o $eco_output_dir/annotation

DRAM.py distill -i $eco_output_dir/annotation/annotations.tsv -o $eco_output_dir/genome_summaries --trna_path $eco_output_dir/annotation/trnas.tsv --rrna_path $eco_output_dir/annotation/rrnas.tsv

rm -rf $scratch

exit 0
