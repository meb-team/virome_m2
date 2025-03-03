#!/bin/bash

#SBATCH --job-name=checkV_QC
#SBATCH --output=logs/checkV_QC_%A_%a.out
#SBATCH --error=logs/checkV_QC_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast
#SBATCH --array=0-1391

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone

# === Variable definition ===

home="/home/$USER" # Path to your home (useful to bind your home to the singularity structure)
path_checkv="module_01/checkV/bin/checkv.sif" # Path to the checkV tool

dvf_file="../data/dvf/" # Path to DeepVirFinder results
vs2_file="../data/vs2/" # Path to VirSorter2 results
vib_file="../data/vibrant/" # Path to VIBRANT results

dvf_out="module_01/checkV/results/dvf"
vs2_out="module_01/checkV/results/vs2"
vib_out="module_01/checkV/results/vibrant"

mkdir -p "$vs2_out" "$vib_out" "$dvf_out" "logs"

# === Process ===

# Collect all FASTA files
data_files=($(find "$vs2_file" "$dvf_file" "$vib_file" -type f -name "*.fa"))
num_files=${#data_files[@]}

if [[ $num_files -eq 0 ]]; then
    echo "No FASTA files found. Exiting."
    exit 1
fi

# #SBATCH --array=0-$(($num_files - 1))

# Get the specific file for this array task
file=${data_files[$SLURM_ARRAY_TASK_ID]}
echo $file
base_name=$(basename "$file" .fa)
base_name=${base_name/_predicted_seq/}

# Extract ecosystem and tool from file path
tool=$(basename "$(dirname "$(dirname "$file")")")
ecosystem=$(basename "$(dirname "$file")")

echo "Processing $file with CheckV..."

# Determine output directory based on input file path
if [[ "$tool" == "vs2" ]]; then
    output_dir="$vs2_out/$ecosystem"
elif [[ "$tool" == "dvf" ]]; then
    output_dir="$dvf_out/$ecosystem"
elif [[ "$tool" == "vibrant" ]]; then
    output_dir="$vib_out/$ecosystem"
fi

# Create the ecosystem-specific directory if it doesn't exist
mkdir -p "$output_dir"

# Run CheckV and save the output
singularity exec --bind "$home" "$path_checkv" checkv end_to_end "$file" "$output_dir/${base_name}_checkV" -t8

# Upload results and clean up
rclone copy "$output_dir/${base_name}_checkV" "lmge-microstore:huserville/$output_dir/${base_name}_checkV"
rm -r "$output_dir/${base_name}_checkV"

echo "Processing completed for $file"

exit 0

