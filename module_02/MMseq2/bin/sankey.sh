#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to execute the sankey.R R script to create sankey graphe for each taxonomy report files.
# Author  : SERVILLE Hugo
# Date    : 19/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
# set -e  # Stop the script if error
# set -u  # Stop the script unknown variables
# set -o pipefail

# === Variable definition ===
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"  # Aller au dossier module_02/MMseq2
DATA_DIR="$BASE_DIR/MMseq2/results/biome_taxo"
SCRIPT_R="$BASE_DIR/MMseq2/bin/sankey.R"

mkdir -p "module_02/MMseq2/results/sankey"

if [ ! -d "$DATA_DIR" ]; then
  echo "Le dossier des données $DATA_DIR n'existe pas !"
  exit 1
fi

# Vérifier si le script R existe
if [ ! -f "$SCRIPT_R" ]; then
  echo "Le script R $SCRIPT_R est introuvable !"
  exit 1
fi

# Boucler sur tous les fichiers se terminant par _taxo_report
for FILE in "$DATA_DIR"/*"_taxo_report"; do
  if [ -f "$FILE" ]; then
    echo "Exécution de $SCRIPT_R sur $FILE"
    Rscript "$SCRIPT_R" "$FILE"
  fi
done
