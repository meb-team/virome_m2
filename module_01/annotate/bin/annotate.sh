#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to annotate the contigs name from the checkV results and merge all the sequence into one fasta file.
# Author  : SERVILLE Hugo
# Date    : 04/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===

RESULTS_DIR="module_01/checkV/results"
mkdir -p "module_01/annotate/results"
OUTPUT_FILE="module_01/annotate/results/all_modified_contigs.fasta"
> "$OUTPUT_FILE"

# === Function definition ===a
process_fasta() {
    local fasta_file="$1"
    local ecosystem="$2"
    local tool="$3"
    local extra_tag="$4"

    awk -v eco="$ecosystem" -v tool="$tool" -v tag="$extra_tag" '
        /^>/ {print $0 "==" eco "==" tool "==" tag; next}
        {print}
    ' "$fasta_file" >> "$OUTPUT_FILE"
}


# === Process data ===
echo "Starting job..."
for tool_dir in "$RESULTS_DIR"/*/; do
    tool=$(basename "$tool_dir")  # Collect the tool name

    for eco_dir in "$tool_dir"/*/; do
        ecosystem=$(basename "$eco_dir" | cut -d'_' -f1)  # Collect the ecosystem name

        for fasta in "$eco_dir"/viruses.fna "$eco_dir"/proviruses.fna; do
            if [[ -f "$fasta" ]]; then
                extra_tag=""
                [[ "$fasta" == *"proviruses.fna" ]] && extra_tag="==proviruses"
                process_fasta "$fasta" "$ecosystem" "$tool" "$extra_tag"
            fi
        done
    done
done

echo "Job finish ! You can retrieve the results here : module_01/annotate/results

exit 0
