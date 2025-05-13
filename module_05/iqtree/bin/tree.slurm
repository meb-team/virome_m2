#!/bin/bash

#SBATCH --job-name=iqtree
#SBATCH --ntasks=1
#SBATCH --output=logs/iqtree_%j.out
#SBATCH --error=logs/iqtree_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=150G
#SBATCH --time=06:00:00
#SBATCH --partition=normal

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone

source miniconda3/bin/activate
conda init
conda activate iqtree_env

# === Variables ===
echo "variable"
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"

data="$scratch/msa"
results="module_05/iqtree/results/"

mkdir -p $data
mkdir -p $results

echo "data"
rclone copy $remote/module_05/mafft/results/all_alignment.aln $data

# === Process ===
echo "process"

iqtree -s $data/all_alignment.aln -m TEST -bb 1000 -alrt 1000

ls $data

rm $data/all_alignment.aln
cp $data/* module_05

exit 0

