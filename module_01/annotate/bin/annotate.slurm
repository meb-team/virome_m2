#!/bin/bash

#SBATCH --job-name=annotate_contigs
#SBATCH --output=logs/annotate_contigs_%j.out
#SBATCH --error=logs/annotate_contigs_%j.err
#SBATCH --time=04:00:00  # Temps max d'exécution
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition=fast


# === Initialisation ===
# set -e  # Arrêter le script en cas d'erreur
set -u  # Arrêter si utilisation de variables non définies
set -o pipefail

module load rclone

# === Variables ===
scratch="/storage/scratch/$USER"
remote=""
base_dir="module_01/results/checkv"                                     # path to the results of CheckV
mkdir -p module_01/annotate/results                                     # Path to the results of this script (annotation)
output_file="module_01/annotate/results/all_annotated_contigs.fasta"    # File created

> "$output_file"

# === Process ===

for ecosystem in "$base_dir"/*; do
    if [ -d "$ecosystem" ]; then
        eco_name=$(basename "$ecosystem")
        echo "Traitement de l'écosystème : $eco_name"

        find "$ecosystem" -type f \( -name "viruses.fna" -o -name "proviruses.fna" \) | while read -r fasta_file; do
            while IFS= read -r line; do
                if [[ $line == ">"* ]]; then
                    # Ajoute le suffixe ==ecosystem au header
                    echo "${line}==${eco_name}" >> "$output_file"
                else
                    echo "$line" >> "$output_file"
                fi
            done < "$fasta_file"
        done
    fi
done

echo "✅ File generated : $output_file"
