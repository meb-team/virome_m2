#!/bin/bash

#SBATCH --job-name=checkV_QC
#SBATCH --output=logs/checkV_QC_%A_%a.out
#SBATCH --error=logs/checkV_QC_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast
#SBATCH --array=0-5               # Your number of SRR

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone
module load seqkit

# === Variable definition ===
scratch="/storage/scratch/$USER"
home="/home/$USER"                                   # Path to your home (useful to bind your home to the singularity structure)
path_checkv="module_01/checkV/bin/checkv.sif"        # Path to the checkV tool
remote=""
data="module_00/results/merge"                       # path to the results of module_00
result="module_01/results/checkv"                    # Path to the results of CheckV analysis
#result="$scratch/module_01/results/checkv"

mkdir -p $data
mkdir -p $result

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy $remote/$data $data
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi


# === Process ===

input_dir=$data
output_root=$result

mapfile -t data_files < <(find "$input_dir" -type f -name "*.fa" | sort)

num_files=${#data_files[@]}
if [[ $num_files -eq 0 ]]; then
    echo "No FASTA files found. Exiting."
    exit 1
fi

if [[ "$SLURM_ARRAY_TASK_ID" -ge "$num_files" ]]; then
    echo "SLURM_ARRAY_TASK_ID ($SLURM_ARRAY_TASK_ID) exceeds number of input files ($num_files)"
    exit 1
fi

file="${data_files[$SLURM_ARRAY_TASK_ID]}"
echo "Processing file : $file"

srr_dir=$(basename "$(dirname "$file")")
ecosystem=$(basename "$(dirname "$(dirname "$file")")")

output_dir="$output_root/$ecosystem/$srr_dir"
mkdir -p "$output_dir"

base_name=$(basename "$file" .fa)

echo "Running CheckV on $file → $output_dir/${base_name}_checkV"

clean_file="${output_dir}/${base_name}_clean.fa"
awk '/^>/{sub(/ .*/, "", $0)}1' "$file" > "$clean_file"

seqkit rmdup -n "$clean_file" -o "${clean_file%.fa}.nodup.fa"

singularity exec --bind "$home" "$path_checkv" checkv end_to_end "${clean_file%.fa}.nodup.fa" "$output_dir/${base_name}_checkV" -t8

rm "$clean_file" "${clean_file%.fa}.nodup.fa"

if [[ -n "$remote" ]]; then
    rclone copy "$output_dir/${base_name}_checkV" "$remote/$output_dir/${base_name}_checkV"
fi

echo "Done processing $file"

exit 0
