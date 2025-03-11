#!/bin/bash

#SBATCH --job-name=dram_annot
#SBATCH --ntasks=1
#SBATCH --output=logs/dramannot_%A_%a.out
#SBATCH --error=logs/dramannot_%A_%a.err
#SBATCH --cpus-per-task=8
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
db="$scratch/module_04/dramv/db"

mkdir -p $fasta
mkdir -p $db
mkdir -p $output_dir

rclone copy lmge-microstore:huserville/module_02/MMseq2/results/eco_fasta $fasta --multi-thread-streams 1
rclone copy lmge-microstore:huserville/module_04/dramv/db $db --multi-thread-streams 1

source miniconda3/bin/activate
conda init
conda activate DRAM

# === Process ===

fasta_files=($fasta/*.fa)
file="${fasta_files[$SLURM_ARRAY_TASK_ID-1]}"

ecosystem=$(basename "$file" | cut -d'_' -f1)

eco_output_dir="$output_dir/$ecosystem"
mkdir -p "$eco_output_dir"


DRAM.py annotate -i $file -o $eco_output_dir/annotation

DRAM.py distill -i $eco_output_dir/annotation/annotations.tsv -o $eco_output_dir/genome_summaries --trna_path $eco_output_dir/annotation/trnas.tsv --rrna_path $eco_output_dir/annotation/rrnas.tsv

rm -rf $scratch

exit 0
