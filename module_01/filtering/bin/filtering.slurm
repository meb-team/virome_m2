#!/bin/bash

#SBATCH --job-name=filtering
#SBATCH --ntasks=1
#SBATCH --output=logs/filtering_%j.out
#SBATCH --error=logs/filtering_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=fast


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


module load gcc/8.1.0
module load python/3.7.1
module load numpy
module load pandas

# === Variables ===
OUTPUT_DIR="tmp/module_01/filtering/results"
REMOTE_PATH="lmge-microstore:huserville/module_01"
LOCAL_DIR="/storage/scratch/$USER/module_01"

mkdir -p $OUTPUT_DIR
mkdir -p $LOCAL_DIR/filtering/results
mkdir -p $LOCAL_DIR/annotate/results

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone sync $REMOTE_PATH/filtering/results $LOCAL_DIR/filtering/results                   # Path to the results from populate_table.slurm
rclone sync $REMOTE_PATH/mmseq2/results/clusterRes_cluster.tsv $LOCAL_DIR/mmseq2/         # Path to the results of the clustering

# === Process ===

./module_01/filtering/bin/filtering.py -p module_01/filtering/results/representative_cluster.tsv -c $LOCAL_DIR/mmseq2/clusterRes_cluster.tsv -o $OUTPUT_DIR

rclone sync $OUTPUT_DIR/eco $REMOTE_PATH/filtering/results

rm -r $OUTPUT_DIR

exit 0
