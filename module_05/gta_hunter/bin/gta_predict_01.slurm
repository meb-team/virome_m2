#!/bin/bash

#SBATCH --job-name=gta_hunter
#SBATCH --ntasks=1
#SBATCH --output=logs/gta_%j.out
#SBATCH --error=logs/gta_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=80G
#SBATCH --time=1-00:00:00
#SBATCH --partition=normal

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail

module load rclone
module load seqkit

source miniconda3/bin/activate
conda init
conda activate gta

# === Variables ===
scratch="/storage/scratch/$USER"
remote="lmge-microstore:huserville"
gta_path="module_05/gta_hunter/bin/GTA-Hunter/"

mkdir -p $scratch/data
mkdir -p $scratch/results

# === Process ===
rclone copy $remote/module_05/prodigual/results/sequences_proteines.faa $scratch/data

seqkit split -p 20 $scratch/data/sequences_proteines.faa

mkdir -p $scratch/data/new
mv $scratch/data/sequences_proteines.faa.split/* $scratch/data/new
ls $scratch/data/new

#cd $gta_path

count=1
for file in $scratch/data/new/*.faa; do
    echo "$file"
    python $gta_path/GTA_Hunter.py -g $gta_path/data/training/gta/3_gta.faa -v $gta_path/data/training/viral/3_viral.faa -c 10000 -w $gta_path/data/training/gta/3_gta.dist $gta_path/data/training/viral/3_viral.dist -t 0.02 -k 3 -q $file > $scratch/results/gta_${count}.txt

    rclone sync $scratch/results/gta_${count}.txt $remote/module_05/gta_hunter/results/

    ((count++))
done
exit 0
