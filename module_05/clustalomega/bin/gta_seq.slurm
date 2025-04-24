#!/bin/bash

#SBATCH --job-name=gta_seq
#SBATCH --ntasks=1
#SBATCH --output=logs/gta_seq_%j.out
#SBATCH --error=logs/gta_seq_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variable
set -o pipefail


source miniconda3/bin/activate
conda init
conda activate gta_seq

module load seqkit/0.15.0

# === Variables ===
scratch="/storage/scratch/$USER"
rm -rf $scratch
remote="lmge-microstore:huserville"
gta="$scratch/data/gta"
prot_seq="$scratch/data/seq"
result="$scratch/res"

mkdir -p $gta
mkdir -p $prot_seq
mkdir -p $result

echo "Synchronisation des données..."
rclone copy $remote/module_05/prodigual/results/sequences_proteines.faa $prot_seq
rclone copy $remote/module_05/gta_hunter/prediction/GTA_prediction.txt $gta

# === Process ===
echo "Début du traitement"

cat $gta/GTA_prediction.txt | grep 'GTA' > $gta/gta.txt
cut -f1 $gta/gta.txt | sed 's/^>//' > $gta/gta_ids.txt

seqkit replace -p '^([^#]+) #.*' -r '$1' -o $prot_seq/sequences_clean.faa $prot_seq/sequences_proteines.faa

seqkit grep -f $gta/gta_ids.txt $prot_seq/sequences_clean.faa > $result/gta_seq.faa

rclone copy $result/gta_seq.faa $remote/module_05/gta_hunter/prediction

echo "Fin du traitement"

exit 0
