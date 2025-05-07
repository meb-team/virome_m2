#!/bin/bash

#SBATCH --job-name=annotation
#SBATCH --output=logs/annotation_%A_%a.out
#SBATCH --error=logs/annotation_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script on unknown variables
set -o pipefail

module load rclone


# === Variable definition ===
remote=""                                  # Path to stock the results for rclone : exemple lmge-microstore:huserville
data="module_00/results/annotate"	   # Path to the results from module_00/bin/data_prep.slurm. If the results are stocked with rclone, please write the remote used

scratch="/storage/scratch/$USER"
#result="$scratch/module_00/result/annotation"
result="module_00/results/annotation"

mkdir -p $result

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    data="$scratch/data"
    mkdir -p $data
    rclone copy $remote/module_00/results/annotate $data
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi


# === Process ===

cat $data/*_tool.tsv > $result/contig_tools_list.tsv
cat $data/*_eco.txt > $result/contig_eco_list.tsv

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy $result/contig_tools_list.tsv $remote/module_00/results/annotation
    rclone copy $result/contig_eco_list.tsv $remote/module_00/results/annotation

else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi

exit 0
