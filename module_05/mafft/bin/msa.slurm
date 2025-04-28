#!/bin/bash

#SBATCH --job-name=mafft
#SBATCH --ntasks=1
#SBATCH --output=logs/mafft_%j.out
#SBATCH --error=logs/mafft_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone
module load seqkit/0.15.0
module load gcc/8.1.0
module load openmpi/3.0.0
module load  MAFFT/7.427

# === Variables ===
scratch="/storage/scratch/$USER"
rm -rf $scratch

data="$scratch/data"
result="module_05/maaft/results"
remote="lmge-microstore:huserville"

mkdir -p $data
mkdir -p $result

rclone copy $remote/module_05/gta_hunter/prediction/gta_seq.faa $data

# === Process ===
file="$data/gta_seq.faa"

seqkit rmdup -n -o temp.fa $file
mv temp.fa $file

cat "$file" | sed 's/\*//g' > "${file}.tmp" && mv "${file}.tmp" "$file"

mafft --thread 16 --auto $file > $result/all_alignment.aln

rclone copy $result/all_alignement.aln/ $remote/module_05/mafft/results

rm -rf $scratch

exit 0

