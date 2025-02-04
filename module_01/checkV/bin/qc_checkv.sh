#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to perfom a quality control on the fasta file containing predicted viral contigs. These contigs are from different tools (VirSorter2, DeepVirFinder, VIBRANT).
# The tool CheckV is used here to check the quality of the contigs.
# Author  : SERVILLE Hugo
# Date    : 03/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===

#home="/home/serville/"
home="/databis/serville/" # Path to your home (useful to bind yoyr home to the singularity structure)
path_checkv="module_01/checkV/bin/checkv.sif" # Path to the checkV tool

dvf_file="data_test/results/dvf/" # path to the merged results of DeepVirFinder for different ecosystems
vs2_file="data_test/results/vs2/" # path to the merged results of VirSorter2 for different ecosystems
vib_file="data_test/results/vibrant/" # path to the merged results of VIBRANT for different ecosystems

dvf_out="module_01/checkV/results/dvf" # path to the results of checkV for DeepVirFinder
vs2_out="module_01/checkV/results/vs2" # path to the results of checkV for VirSorter2
vib_out="module_01/checkV/results/vibrant" # path to the results of checkV for VIBRANT

mkdir -p "$vs2_out"
mkdir -p "$vib_out"
mkdir -p "$dvf_out"

# === Collecting ecosystem ID ===
echo "Scanning for ecosystems in $vs2_file..."

ecosystems=($(find "$vs2_file" -mindepth 1 -maxdepth 1 -type f -name "*.fa" -exec basename {} .fa \; | cut -d'_' -f1))
# The same ecosystems are here for the 3 tools so we can only use the vs2 path
if [ ${#ecosystems[@]} -eq 0 ]; then
    echo "No ecosystems found in $vs2_file. Exiting."
    exit 1
fi

echo "Found ecosystems: ${ecosystems[*]}"

# === Process ===

for eco in "${ecosystems[@]}"; do
    echo "Start processing ${eco}...."

    # Process VirSorter2
    echo "Quality control for VirSorter2 predicted contigs"

    files=($vs2_file${eco}_*)

    if [ -e "${files[0]}" ]; then
        echo "Processing files: ${files[*]}"
        singularity exec --bind "$home" "$path_checkv" checkv end_to_end "${files[@]}" "$vs2_out/${eco}_vs2_checkv" -t$(($(nproc) / 2 ))
    else
        echo "No matching files for ${eco}_* in $vs2_file"
    fi

    # Process DeepVirFinder
    echo "Quality control for DeepVirFinder"

    files=($dvf_file${eco}_*)

    if [ -e "${files[0]}" ]; then
        echo "Processing files: ${files[*]}"
        singularity exec --bind "$home" "$path_checkv" checkv end_to_end "${files[@]}" "$dvf_out/${eco}_dvf_checkv" -t$(($(nproc) / 2 ))
    else
        echo "No matching files for ${eco}_* in $dvf_file"
    fi

    # Process VIBRANT
    echo "Quality control for VIBRANT"

    files=($vib_file${eco}_*)

    if [ -e "${files[0]}" ]; then
        echo "Processing files: ${files[*]}"
        singularity exec --bind "$home" "$path_checkv" checkv end_to_end "${files[@]}" "$vib_out/${eco}_vibrant_checkv" -t$(($(nproc) / 2 ))
    else
        echo "No matching files for ${eco}_* in $vib_file"
    fi

done

./module_01/checkV/bin/qc_visu.py 

exit 0

