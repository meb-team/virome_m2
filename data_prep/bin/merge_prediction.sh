#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to merge all the predicted sequences in one fasta file format for each tools (VIBRANT, VirSorter2, DeepVirFinder) for each ecosystems.
# Author  : SERVILLE Hugo
# Date    : 29/01/2024
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
vs2_file="/data/mnt/prophage/vs2/" # Path to the results of VirSorter2
vs2_output="data_prep/results/vs2" # Path to the output of this script

vib_file="/data/mnt/prophage/vibrant" # Path to the results of VIBRANT
vib_output="data_prep/results/vibrant" # Path to the output of this script

dvf_file="/data/mnt/prophage/dvf" # Path to the results of DeepVirFinder
dvf_output="data_prep/results/dvf" # Path to the output of this script

mkdir -p "$vs2_output"
mkdir -p "$vib_output"
mkdir -p "$dvf_output"

# === Collecting ecosystem ID ===
echo "Scanning for ecosystems in $vs2_file..."

ecosystems=($(find "$vs2_file" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))
# The same ecosystems are here for the 3 tools so we can only use the vs2 path
if [ ${#ecosystems[@]} -eq 0 ]; then
    echo "No ecosystems found in $vs2_file. Exiting."
    exit 1
fi

echo "Found ecosystems: ${ecosystems[*]}"

# === Process ===
for eco in "${ecosystems[@]}"; do
    echo "Processing ecosystem: $eco..."
    

    # VirSorter2 data

    VS2out="$vs2_file$eco/"
    output_file="$vs2_output/${eco}_predicted_seq.fa"

    rm -f "$output_file"

    find "$VS2out" -mindepth 2 -maxdepth 2 -type f -name "*.fa" -exec cat {} >> "$output_file" \;


    # Verification of output vs2 files
    if [ -s "$output_file" ]; then
        echo "Job finished for $eco (VIRSORTER2)! File created: $output_file"
        echo "File size: $(du -h "$output_file" | cut -f1)"
    else
        echo "No sequences found for $eco!"
    fi



    # VIBRANT data
    vibout="$vib_file/$eco/"
    output_file="$vib_output/${eco}_predicted_seq.fa"

    rm -f "$output_file"

    find "$vibout" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
        # Extaction of the folder name (basename)
        foldername=$(basename "$dir")

        # Building path
        fna_file="$dir/VIBRANT_phages_${foldername}/${foldername}.phages_combined.fna"

        # Check if the file is existing
        if [[ -f "$fna_file" ]]; then
            cat "$fna_file" >> "$output_file"
        else
            echo "Missing file : $fna_file"
        fi
    done

    # Verification of output VIBRANT files
    if [ -s "$output_file" ]; then
        echo "Job finished for $eco (VIBRANT)! File created: $output_file"
        echo "File size: $(du -h "$output_file" | cut -f1)"
    else
        echo "No sequences found for $eco!"
    fi



    # DeepVirFinder data

    dvfout="$dvf_file/$eco"

    for ssr in "$dvfout"/*; do
        if [ -d "$ssr" ]; then
            ssr_name=$(basename "$ssr")
        fi

        output_file="$dvf_output/${ssr_name}_dvf_id_tmp_{eco}.txt"
        fasta_file="/data/mnt/Microstore/metaplasmidome/assembly/new/$eco/${ssr_name}.fasta.gz"
        predicted_fasta="$dvf_output/${ssr_name}_predicted.fna"


        rm -f "$output_file"

        cat "$ssr"/*.txt | awk '{if($3>=0.70&&$1!="name"){print $1}}' > "$output_file"

        if [ ! -f "$fasta_file" ]; then
            echo "Missing Fasta file: $ssr_name : $fasta_file"
            continue
        fi

        done
##############################
#    txt_dir="data_prep/results/dvf"
#    fasta_dir="/data/mnt/Microstore/metaplasmidome/assembly/new/$eco"
#    output_file="tmp/${eco}_predicted.fasta"
#
#    rm -f "$output_file"
#
#    for txt_file in "$txt_dir"/*_dvf_id_tmp.txt; do
#        base_name=$(basename "$txt_file" _dvf_id_tmp.txt)
#        seqtk subseq "$fasta_dir/${base_name}.fasta.gz" "$txt_file" >> "$output_file"
#    done
###############################"

    if [ -s "${eco}_output.fasta" ]; then
        echo "Job finished for $eco (DeepVirFinder)! File created: ${eco}_output.fasta"
        echo "File size: $(du -h '${eco}_output.fasta' | cut -f1)"
    else
        echo "No sequences found for $eco!"
    fi


    #rm -f "$dvf_output"/*_dvf_id_tmp.txt "$dvf_output"/*_predicted.fna

done

echo "Job finished !"

exit 0

