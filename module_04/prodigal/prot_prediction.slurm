#!/bin/bash

#SBATCH --job-name=prodigual2
#SBATCH --ntasks=1
#SBATCH --output=logs/prodigual_%j.out
#SBATCH --error=logs/prodigual_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone
module load prodigal/2.6.3

# === Variables ===
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"
fasta=""
output_dir="$scratch/results"

mkdir -p $output_dir

# === Process ===

prodigal -i seeds.fasta -a $output_dir/sequences_proteines.faa -d $output_dir/sequences_nucleotidiques.fna -o annotation.gbk -p meta
    
rclone sync $output_dir $remote/module_05/prodigual2/results
rm annotation.gbk
rm -r output_dir

exit 0
