#!/bin/bash

#SBATCH --job-name=minimap
#SBATCH --output=logs/minimap_%A_%a.out
#SBATCH --error=logs/minimap_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone
module load minimap2/2.24

# === Variable definition ===

scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"
db="$scratch/imgvr/"
fasta="$scratch/fasta"
output_dir="$scratch/minimap/results"

mkdir -p $db
mkdir -p $fasta
mkdir -p $output_dir

rclone copy $remote/module_02/minimap/imgvr_db $db
rclone copy $remote/module_02/MMseq2/results/eco_fasta $fasta

# === Process ===

for fasta_file in "$fasta"/*.fa; do
    if [[ -f "$fasta_file" ]]; then
        nb=$(grep '>' $fasta_file | wc -l)
        filename=$(basename -- "$fasta_file")
        ecosystem=$(echo "$filename" | cut -d'_' -f1)  # Extraction de l'écosystème
        output="$output_dir/${ecosystem}_results.paf"
        
        echo "Processing $fasta_file (Ecosystem: $ecosystem)"
        minimap2 -t 32 -x asm5 -N $nb "$fasta_file" "$db/IMGVR_all_nucleotides.fna.gz" > "$output"
        rclone copy $output $remote/module_02/minimap/results/$ecosystem

    fi
done

rm -rf $scratch
