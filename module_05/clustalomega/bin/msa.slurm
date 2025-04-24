#!/bin/bash

#SBATCH --job-name=clustalomega
#SBATCH --ntasks=1
#SBATCH --output=logs/clustal_%j.out
#SBATCH --error=logs/clustal_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone
module load ClustalOmega/1.2.4
module load seqkit/0.15.0

# === Variables ===
scratch="/storage/scratch/$USER"
rm -rf $scratch

data="$scratch/data"
result="$scratch/result"
remote="lmge-microstore:huserville"

mkdir -p $data
mkdir -p $result

rclone copy $remote/module_05/gta_hunter/prediction/gta_seq.faa $data

# === Process ===
file="$data/gta_seq.faa"

seqkit rmdup -n -o temp.fa $file
mv temp.fa $file

clustalo -i $file -o $result/all_alignement.aln

rclone copy $result/alignement.aln $remote/module_05/clustalomega/results

rm -rf $scratch

exit 0

