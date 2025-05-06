#!/bin/bash

#SBATCH --job-name=data_prep
#SBATCH --output=logs/data_prep_%A_%a.out
#SBATCH --error=logs/data_prep_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast
#SBATCH --array=0-5               # Number of SRR in your list


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone
module load seqkit


# === Variable definition ===
#############################
#  TO MODIFY FOR FIRST USE
vs2_path="data_test/vs2"          # Path to the VirSorter2 predictions : exemple : /data/mnt/prophage/vs2/ (SOERE)
dvf_path="data_test/dvf"          # Path to the DeepVirFinder predictions : exemple : /data/mnt/prophage/dvf/ (SOERE)
vib_path="data_test/vibrant"      # Path to the Vibrant predictions : exemple :	/data/mnt/prophage/vibrant/ (SOERE)
raw_data="../data"                # Path to the raw data (assembling data) for each SRR : exemple : /data/mnt/Microstore/metaplasmidome/assembly/new (SOERE)
remote=""                         # Path to stock the results for rclone : exemple lmge-microstore:huserville
##############################

scratch="/storage/scratch/$USER"
#result="$scratch/module_00/result"
result="module_00/results"

mkdir -p $result


# === Pre-Process === 
srr_list_file=$1

# Check if this file exists
if [ ! -f "$srr_list_file" ]; then
    echo "Error : The file $srr_list_file does not exist."
    exit 1
fi

srr_name=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" $srr_list_file)


# === Process ===
echo "Processing SRR: $srr_name"


# DeepVirFinder prediction data processing
found_dir=$(find "$dvf_path" -mindepth 2 -maxdepth 2 -type d -name "$srr_name" | head -n1)
if [[ -n "$found_dir" ]]; then
    eco=$(basename "$(dirname "$found_dir")")
    echo "Écosystème : $eco"
else
    echo "Dossier $srr_name non trouvé dans $dvf_path"
    eco="unknown"
fi

dvf_data="$dvf_path/$eco/$srr_name"
dvf_output="$result/$eco/$srr_name"
output_file="$dvf_output/dvf_predicted_seq.fa"

mkdir -p $dvf_output

echo "Processing $srr_name for $eco (DeepVirFinder).."

cat $dvf_data/*.txt | awk '{if($3>=0.70&&$1!="name"){print $1}}' > $dvf_output/${srr_name}.tmp

seqkit grep -n -f "$dvf_output/${srr_name}.tmp" -o "$output_file" $raw_data/$eco/${srr_name}.fasta.gz
rm $dvf_output/${srr_name}.tmp

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy "$output_file" "$remote/module_00/results/$eco/$srr_name"
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi

echo "End of the process for DeepVirFinder data for $srr_name ($eco)"



# Vibrant prediction data processing 
found_dir=$(find "$vib_path" -mindepth 2 -maxdepth 2 -type d -name "$srr_name" | head -n1)
if [[ -n "$found_dir" ]]; then
    eco=$(basename "$(dirname "$found_dir")")
    echo "Écosystème : $eco"
else
    echo "Dossier $srr_name non trouvé dans $vib_path"
    eco="unknown"
fi

vib_data="$vib_path/$eco/$srr_name/VIBRANT_phages_${srr_name}/${srr_name}.phages_combined.fna"
vib_output="$result/$eco/$srr_name"
output_file="$vib_output/vib_predicted_seq.fa"

mkdir -p $vib_output

echo "Processing $srr_name for $eco (vibrant).."

cat $vib_data | grep '>' | sed 's/^>//' > $vib_output/${srr_name}.tmp

seqkit grep -n -f "$vib_output/${srr_name}.tmp" -o "$output_file" $raw_data/$eco/${srr_name}.fasta.gz
rm $vib_output/${srr_name}.tmp

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy "$output_file" "$remote/module_00/results/$eco/$srr_name"
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi

echo "End of the process for vibrant data for $srr_name ($eco)"



# Virsorter2 prediction data processing
found_dir=$(find "$vs2_path" -mindepth 2 -maxdepth 2 -type d -name "${srr_name}.fasta" | head -n1)

if [[ -n "$found_dir" ]]; then
    eco=$(basename "$(dirname "$found_dir")")
    echo "Écosystème : $eco"
else
    echo "Dossier $srr_name non trouvé dans $vs2_path"
    eco="unknown"
fi

vs2_data="$vs2_path/$eco/${srr_name}.fasta"
vs2_output="$result/$eco/$srr_name"
output_file="$vs2_output/vs2_predicted_seq.fa"

mkdir -p "$vs2_output"

echo "Processing $srr_name for $eco (vs2).."
cat $vs2_data/*.fa | grep '>' | sed 's/^>//' | cut -d '|' -f1 > $vs2_output/${srr_name}.tmp

seqkit grep -n -f "$vs2_output/${srr_name}.tmp" -o "$output_file" $raw_data/$eco/${srr_name}.fasta.gz
rm $vs2_output/${srr_name}.tmp

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy "$output_file" "$remote/module_00/results/$eco/$srr_name"
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi

echo "End of the process for vs2 data for $srr_name ($eco)"


