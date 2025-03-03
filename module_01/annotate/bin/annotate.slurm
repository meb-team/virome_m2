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
set -e  # Arrêter le script en cas d'erreur
set -u  # Arrêter si utilisation de variables non définies
set -o pipefail

module load rclone

# === Variables ===
REMOTE_PATH="lmge-microstore:huserville/module_01/checkV/results"
LOCAL_DIR="/storage/scratch/huservil/module_01/checkV/results"
OUTPUT_DIR="module_01/annotate/results"
OUTPUT_FILE="$OUTPUT_DIR/all_annotated_contigs.fasta"
TSV_FILE="$OUTPUT_DIR/contig_tools_list.tsv"
ECO_FILE="$OUTPUT_DIR/contig_eco_list.tsv"

mkdir -p "$OUTPUT_DIR"
> "$OUTPUT_FILE"
> "$TSV_FILE"
> "$ECO_FILE"

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone sync "$REMOTE_PATH" "$LOCAL_DIR"

# === Fonction d'annotation ===
process_fasta() {
    local fasta_file="$1"
    local ecosystem="$2"
    local tool="$3"

    awk -v eco="$ecosystem" -v tool="$tool" '
        /^>/ {
            sub(/\|\|.*/, "", $0);
            sub(/ .*/, "", $0);
            print $0 "==" eco;
            next
        }
        {print}
    ' "$fasta_file" >> "$OUTPUT_FILE"

    grep "^>" "$fasta_file" | sed 's/^>//' | while read contig; do
        echo -e "$contig\t$tool" >> "$TSV_FILE"
    done
}

# === Traitement des données ===
echo "Début du traitement..."

for tool_dir in "$LOCAL_DIR"/*/; do
    tool=$(basename "$tool_dir")

    for eco_dir in "$tool_dir"/*/; do
        ecosystem=$(basename "$eco_dir" | cut -d'_' -f1)

        # Parcourir les sous-dossiers des SRR
        find "$eco_dir" -type d -name "SRR*" | while read srr_dir; do
            for fasta in "$srr_dir/proviruses.fna" "$srr_dir/viruses.fna"; do
                if [[ -f "$fasta" ]]; then
                    process_fasta "$fasta" "$ecosystem" "$tool"
                fi
            done
        done
    done
done

cat "$OUTPUT_FILE" | grep '>' | sed 's/^.//' | sort | uniq > "$ECO_FILE"

echo "Traitement terminé ! Résultats disponibles :"
echo "FASTA : $OUTPUT_FILE"
echo "TSV : $TSV_FILE"
echo "ECO : $ECO_FILE"

rm -r $LOCAL_DIR

exit 0

