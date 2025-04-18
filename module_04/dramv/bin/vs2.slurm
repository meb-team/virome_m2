#!/bin/bash

#SBATCH --job-name=vs2
#SBATCH --ntasks=1
#SBATCH --output=logs/vs2_%j.out
#SBATCH --error=logs/vs2_%j.err
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
output_dir="res/"
path_vs="module_04/dramv/bin/virsorter2.sif"
home="/home/$USER"
remote="lmge-microstore:huserville"

mkdir -p $output_dir
mkdir -p $scratch/vs2_db
mkdir -p $scratch/eco_fasta

module load seqkit/0.15.0

echo "Synchronizing distant files..."
rclone copy $remote/module_02/MMseq2/results/eco_fasta $scratch/eco_fasta

for file in $scratch/eco_fasta/*.fa; do
    echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    echo "Processing: $file"

    seqkit rmdup -s -o temp.fa $file
    seqkit rmdup -n -o temp2.fa temp.fa
    mv temp2.fa $file
    rm temp.fa

    ecosystem=$(basename "$file" | cut -d'_' -f1)
    eco_output_dir="$output_dir/$ecosystem"

    mkdir -p $eco_output_dir

    cp $file $eco_output_dir/test.fa
    ./$path_vs run --prep-for-dramv -w $eco_output_dir -i $eco_output_dir/test.fa -j 32 --tmpdir $eco_output_dir

    rclone copy $eco_output_dir/for-dramv $remote/module_04/results/vs2/$ecosystem
    rm -r $eco_output_dir

done

exit 0

