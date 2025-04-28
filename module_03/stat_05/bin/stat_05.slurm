#!/bin/bash

#SBATCH --job-name=stat_05
#SBATCH --output=logs/stat05_%a.out
#SBATCH --error=logs/stat05_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone

source miniconda3/bin/activate
conda init
conda activate stat

# === Variable definition ===
scratch="/storage/scratch/$USER"
rm -rf $scratch

remote="lmge-microstore:huserville"
tsv_path="$scratch/tsv"
data="$scratch/data"
result="module_03/stat_05/results"

mkdir -p $tsv_path
mkdir -p $data
mkdir -p $result
 
# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone copy $remote/module_02/MMseq2/results/rebuild_taxo $tsv_path
rclone copy $remote/module_05/gta_hunter/prediction/gta_seq.faa $data

# === Process ===

echo "Begin the statistical analysis for module_01..."


cat $data/gta_seq.faa | grep '>' | sed 's/^>//' | sed -E 's/==([^_]+)_[0-9]+$/==\1/' > $data/ecosystem_list.txt

cat $data/gta_seq.faa \
| grep '>' \
| sed -E 's/^>([^=]+)==.*/\1/' > $data/id_list.txt

sort "$data/id_list.txt" | uniq > "$data/id_list.txt.tmp" && mv "$data/id_list.txt.tmp" "$data/id_list.txt"

./module_03/stat_05/bin/stat_05.py -t $tsv_path -l $data/id_list.txt -o $result -e $data/ecosystem_list.txt

exit 0

