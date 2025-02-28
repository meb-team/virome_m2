#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to verify if there is no sequence duplications in the fasta created by merge_prediction.sh
# Author  : SERVILLE Hugo
# Date    : 12/02/2025
# Version : 1.0
# ==========================


# === Initialization ===
# set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
directories=("../data_test/dvf" "../data_test/vibrant" "../data_test/vs2")


# === Process ===

for dir in "${directories[@]}"; do

  for fasta_file in "$dir"/*.fa; do
    if [[ -f "$fasta_file" ]]; then

      total_sequences=$(cat "$fasta_file" | grep '>' | wc -l)
      unique_sequences=$(cat "$fasta_file" | grep '>' | sort | uniq | wc -l)


      if [[ "$total_sequences" -ne "$unique_sequences" ]]; then
        echo "Duplicated sequences found : $fasta_file"

        awk '/^>/ {if (!seen[$0]++) print $0; next} {print}' "$fasta_file" > "$fasta_file.tmp" && mv "$fasta_file.tmp" "$fasta_file"
        echo "Corrected file : $fasta_file"
      else
        echo "No duplication for : $fasta_file"
      fi
    fi
  done
done
