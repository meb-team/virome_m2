#!/bin/bash

#SBATCH --job-name=Sankey
#SBATCH --output=logs/sankey_%A_%a.out
#SBATCH --error=logs/sankey_%A_%a.err
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=fast

# === Initialisation  ===
set -e
set -u
set -o pipefail


# === Variable definition ===
remote="lmge-microstore:huserville"
scratch="/storage/scratch/$USER"
DATA_DIR="$scratch/input"
OUTPUT_DIR="module_02/MMseq2/results/sankey"
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"  # Aller au dossier module_02/MMseq2
SCRIPT_R="module_02/MMseq2/bin/sankey.R"

mkdir -p $DATA_DIR
mkdir -p $OUTPUT_DIR

rclone copy $remote/module_02/MMseq2/results/eco_taxo/ $scratch/input

source miniconda3/bin/activate
conda init
conda activate sankey

# === Process ===

for FILE in "$DATA_DIR"/*/*"_taxo_report"; do
  if [ -f "$FILE" ]; then
    echo "Exécution de $SCRIPT_R sur $FILE"
    Rscript "$SCRIPT_R" "$FILE"
  fi
done

