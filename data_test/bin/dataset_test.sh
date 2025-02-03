#!/bin/bash

# ==========================
# DESCRIPTION :
# This script aims to create a subdataset of predicted sequences to run tests. 
# Author  : SERVILLE Hugo
# Date    : 31/01/2024
# Version : 1.0
# ==========================


# === Initialization ===
# set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===

vs2_output="data_test/results/vs2"
vs2_file="/data/mnt/prophage/vs2"

vib_file="/data/mnt/prophage/vibrant"
vib_output="data_test/results/vibrant"

dvf_file="/data/mnt/prophage/dvf" # Path to the results of DeepVirFinder
dvf_output="data_test/results/dvf" # Path to the output of this script
# === Process for VirSorter2===

rm -f "$vs2_output/air_predicted_seq.fa"
rm -f "$vs2_output/human_predicted_seq.fa"
rm -f "$vs2_output/metalakes_predicted_seq.fa"

find "$vs2_file/air" -mindepth 2 -maxdepth 2 -type f -name "*.fa" | head -n 50 | xargs cat >> "$vs2_output/air_predicted_seq.fa"
find "$vs2_file/human" -mindepth 2 -maxdepth 2 -type f -name "*.fa" | head -n 50 | xargs cat >> "$vs2_output/human_predicted_seq.fa"
find "$vs2_file/metalakes" -mindepth 2 -maxdepth 2 -type f -name "*.fa" | head -n 50 | xargs cat >> "$vs2_output/metalakes_predicted_seq.fa"

# === Process for DeepVirFinder ===

ls -d "$dvf_file/air"/*/ | head -n 50 | while read -r ssr; do
    if [ -d "$ssr" ]; then
        ssr_name=$(basename "$ssr")
    fi
    output_file="$dvf_output/${ssr_name}-dvf_id_tmp_air.txt"
    rm -f "$output_file"
    cat "$ssr"/*.txt | awk '{if($3>=0.70&&$1!="name"){print $1}}' > "$output_file"
done

TXT_DIR="data_test/results/dvf"
FASTA_DIR="/data/mnt/Microstore/metaplasmidome/assembly/new/air"
OUTPUT_FASTA="data_test/results/dvf/air_predicted_seq.fa"

> "$OUTPUT_FASTA"

for txt_file in "$TXT_DIR"/*.txt; do
    filename=$(basename "$txt_file")
    ssr_name=$(echo "$filename" | cut -d'-' -f1)

    fasta_file="$FASTA_DIR/${ssr_name}.fasta.gz"

    if [[ ! -f "$fasta_file" ]]; then
        echo "Fichier FASTA non trouvé pour $ssr_name, ignoré."
        continue
    fi
    seqtk subseq <(zcat "$fasta_file") "$txt_file" >> "$OUTPUT_FASTA"

done
rm data_test/results/dvf/*.txt



ls -d "$dvf_file/human"/*/ | head -n 50 | while read -r ssr; do
    if [ -d "$ssr" ]; then
        ssr_name=$(basename "$ssr")
    fi
    output_file="$dvf_output/${ssr_name}-dvf_id_tmp_human.txt"
    rm -f "$output_file"
    cat "$ssr"/*.txt | awk '{if($3>=0.70&&$1!="name"){print $1}}' > "$output_file"
done

FASTA_DIR="/data/mnt/Microstore/metaplasmidome/assembly/new/human"
OUTPUT_FASTA="data_test/results/dvf/human_predicted_seq.fa"

> "$OUTPUT_FASTA"

for txt_file in "$TXT_DIR"/*.txt; do
    filename=$(basename "$txt_file")
    ssr_name=$(echo "$filename" | cut -d'-' -f1)

    fasta_file="$FASTA_DIR/${ssr_name}.fasta.gz"

    if [[ ! -f "$fasta_file" ]]; then
        echo "Fichier FASTA non trouvé pour $ssr_name, ignoré."
        continue
    fi
    seqtk subseq <(zcat "$fasta_file") "$txt_file" >> "$OUTPUT_FASTA"

done
rm data_test/results/dvf/*.txt



ls -d "$dvf_file/metalakes"/*/ | head -n 50 | while read -r ssr; do
    if [ -d "$ssr" ]; then
        ssr_name=$(basename "$ssr")
    fi
    output_file="$dvf_output/${ssr_name}-dvf_id_tmp_metalakes.txt"
    rm -f "$output_file"
    cat "$ssr"/*.txt | awk '{if($3>=0.70&&$1!="name"){print $1}}' > "$output_file"
done

FASTA_DIR="/data/mnt/Microstore/metaplasmidome/assembly/new/metalakes"
OUTPUT_FASTA="data_test/results/dvf/metalakes_predicted_seq.fa"

> "$OUTPUT_FASTA"

for txt_file in "$TXT_DIR"/*.txt; do
    filename=$(basename "$txt_file")
    ssr_name=$(echo "$filename" | cut -d'-' -f1)

    fasta_file="$FASTA_DIR/${ssr_name}.fasta.gz"

    if [[ ! -f "$fasta_file" ]]; then
        echo "Fichier FASTA non trouvé pour $ssr_name, ignoré."
        continue
    fi
    seqtk subseq <(zcat "$fasta_file") "$txt_file" >> "$OUTPUT_FASTA"

done
rm data_test/results/dvf/*.txt

# === Process for Vibrant ===
output_file="$vib_output/air_predicted_seq.fa"

rm -f "$output_file"

find "$vib_file/air" -mindepth 1 -maxdepth 1 -type d | head -n 50 | while read -r dir; do
    foldername=$(basename "$dir")

    fna_file="$dir/VIBRANT_phages_${foldername}/${foldername}.phages_combined.fna"

    if [[ -f "$fna_file" ]]; then
        cat "$fna_file" >> "$output_file"
    else
        echo "Missing file : $fna_file"
    fi
done


output_file="$vib_output/human_predicted_seq.fa"

rm -f "$output_file"

find "$vib_file/human" -mindepth 1 -maxdepth 1 -type d | head -n 50 | while read -r dir; do
    foldername=$(basename "$dir")

    fna_file="$dir/VIBRANT_phages_${foldername}/${foldername}.phages_combined.fna"

    if [[ -f "$fna_file" ]]; then
        cat "$fna_file" >> "$output_file"
    else
        echo "Missing file : $fna_file"
    fi
done


output_file="$vib_output/metalakes_predicted_seq.fa"

rm -f "$output_file"

find "$vib_file/metalakes" -mindepth 1 -maxdepth 1 -type d | head -n 50 | while read -r dir; do
    foldername=$(basename "$dir")

    fna_file="$dir/VIBRANT_phages_${foldername}/${foldername}.phages_combined.fna"

    if [[ -f "$fna_file" ]]; then
        cat "$fna_file" >> "$output_file"
    else
        echo "Missing file : $fna_file"
    fi
done

echo "Job finished !"

# ./data_prep/bin/data_visu.py -p "data_test/results/" -o "data_prep/figure/"

exit 0
