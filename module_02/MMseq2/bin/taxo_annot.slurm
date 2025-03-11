#!/bin/bash

#SBATCH --job-name=tax_annotation
#SBATCH --output=logs/taxo_annotation_%A_%a.out
#SBATCH --error=logs/taxo_annotation_%A_%a.err
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=16 # Nb CPUs per tasks
#SBATCH --mem=128G         # RAM memory
#SBATCH --time=3-00:00:00
#SBATCH --partition=lmge
#SBATCH --array=0-21

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variables are used
set -o pipefail

#module load MMseqs2/13-45111
#module load MMseqs2/10-6d92c

REMOTE_PATH="lmge-microstore:huserville"
scratch="/storage/scratch/$USER"

dir1="$scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq"
dir2="$scratch/module_02/MMseq2/results/eco_fasta"

mkdir -p $dir1
mkdir -p $dir2

rclone copy $REMOTE_PATH/module_02/MMseq2/taxonomy/mmseqs_vrefseq/ $scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq --ignore-errors --multi-thread-streams 1
rclone copy $REMOTE_PATH/module_02/MMseq2/results/eco_fasta $scratch/module_02/MMseq2/results/eco_fasta --ignore-errors --multi-thread-streams 1

echo "Vérification des fichiers copiés..."
ls -lh $scratch/module_02/MMseq2/results/eco_fasta

# === Variable definition ===

DB="$scratch/module_02/MMseq2/taxonomy/mmseqs_vrefseq/refseq_viral"
OUTPUT="$scratch/module_02/MMseq2/results/eco_taxo"
BIOME_DIR="$scratch/module_02/MMseq2/results/eco_fasta"
mmseq_path="module_02/MMseq2/bin/mmseqs2_16.747c6.sif"

mkdir -p "$OUTPUT"

echo "BIOME_DIR: $BIOME_DIR"
ls -lh "$BIOME_DIR"

#mmseqs createindex $DB $scratch/module_02/MMseq2/taxonomy

# === Process ===

fasta_files=($(ls "$BIOME_DIR"/*.fa "$BIOME_DIR"/*.fasta 2>/dev/null))
echo "Fichiers trouvés : ${fasta_files[@]}"

query="${fasta_files[$SLURM_ARRAY_TASK_ID]}"
basename_query=$(basename "$query")
ecosystem_name=$(echo "$basename_query" | cut -d'_' -f1)

mkdir -p $OUTPUT/$ecosystem_name

echo "Processing $query (Ecosystem: $ecosystem_name) - Job ID: $SLURM_ARRAY_TASK_ID"

# Créer la base de données pour MMseqs
singularity exec "$mmseq_path" mmseqs createdb "$query" "$OUTPUT/$ecosystem_name/indexed"

# Exécuter l'annotation taxonomique avec MMseqs
singularity exec "$mmseq_path" mmseqs taxonomy "$OUTPUT/$ecosystem_name/indexed" "$DB" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/tmp" --tax-lineage 1 --lca-mode 3 --threads 16

# Générer le fichier TSV avec les résultats
singularity exec "$mmseq_path"  mmseqs createtsv "$OUTPUT/$ecosystem_name/indexed" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_results.tsv"

# Créer le rapport taxonomique
singularity exec "$mmseq_path" mmseqs taxonomyreport "$DB" "$OUTPUT/$ecosystem_name/${ecosystem_name}_res" "$OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_report"

rclone copy $OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_results.tsv $REMOTE_PATH/module_02/MMseq2/results/eco_taxo/$ecosystem_name
rclone copy $OUTPUT/$ecosystem_name/${ecosystem_name}_taxo_report $REMOTE_PATH/module_02/MMseq2/results/eco_taxo/$ecosystem_name

# Nettoyer les résultats intermédiaires
rm "$OUTPUT"/"$ecosystem_name"/"${ecosystem_name}"_res.*
rm "$OUTPUT"/"$ecosystem_name"/indexed*
rm -r "$OUTPUT"/tmp/
rm -rf $scratch

echo "Job $SLURM_ARRAY_TASK_ID - $query processed!"

exit 0
