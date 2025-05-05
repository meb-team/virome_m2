#!/bin/bash

#SBATCH --job-name=dramv
#SBATCH --ntasks=1
#SBATCH --output=logs/dramv_%j.out
#SBATCH --error=logs/dramv_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=normal

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

# === Variables ===
scratch="/storage/scratch/$USER"
rm -rf $scratch
output_dir="$scratch/module_04/dramv/results"
fasta="$scratch/fasta"
db="$scratch/module_04/dramv/db"
annot="$scratch/module_04/vs2"

mkdir -p $fasta
mkdir -p $db
mkdir -p $output_dir
mkdir -p $annot

echo "Synchronizing distant files..."
rclone copy lmge-microstore:huserville/module_02/MMseq2/results/eco_fasta $fasta
rclone copy lmge-microstore:huserville/module_04/dramv/db $db
rclone copy lmge-microstore:huserville/module_04/results/vs2/ $annot

source miniconda3/bin/activate
conda init
conda activate DRAM

module load seqkit/0.15.0

DRAM-setup.py import_config --config_loc module_04/dramv/CONFIG/my_old_config.txt

# === Process each FASTA file sequentially ===
for file in $fasta/*.fa; do
    echo "Processing: $file"

    seqkit rmdup -s -o temp.fa $file
    seqkit rmdup -n -o temp2.fa temp.fa
    mv temp2.fa $file
    rm temp.fa

    cat $file | awk -F"__" '{print $1}' | grep -v '>' | sort | uniq > $fasta/contig.txt
    
    ecosystem=$(basename "$file" | cut -d'_' -f1)
    echo $ecosystem
    echo "BBBBBBBB"
    eco_output_dir="$output_dir/$ecosystem"

    mkdir -p "$eco_output_dir"
  
    cat	$annot/$ecosystem/*.tab | awk -F"__" '{print $1}' | grep -v '>' | sort | uniq > $fasta/contig.txt

    seqkit grep -f "$fasta/contig.txt" "$file" -o "${file%.fa}_filtered.fa"
    mv "${file%.fa}_filtered.fa" "$file"

    rm $fasta/contig.txt

    DRAM-v.py annotate -i $file -v $annot/$ecosystem/*.tab -o $eco_output_dir/annotation --threads 32
    DRAM-v.py distill -i $eco_output_dir/annotation/annotations.tsv -o $eco_output_dir/annotation/distilled

    rclone copy $eco_output_dir lmge-microstore:huserville/module_04/dramv/results/$ecosytem
    rm -r $eco_output_dir

done

rm -rf "$scratch"

exit 0
