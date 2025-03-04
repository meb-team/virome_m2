#!/bin/bash

#SBATCH --job-name=populate_table
#SBATCH --ntasks=1
#SBATCH --output=logs/populate_%j.out
#SBATCH --error=logs/populate_%j.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --time=7-00:00:00
#SBATCH --partition=long


# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail


module load gcc/8.1.0
module load python/3.7.1
module load numpy
module load pandas

# === Variables ===
OUTPUT_DIR="module_01/filtering/results"
REMOTE_PATH="lmge-microstore:huserville/module_01"
LOCAL_DIR="/storage/scratch/$USER/module_01"

mkdir -p $OUTPUT_DIR

# === Synchronisation des données ===
echo "Synchronisation des données depuis le stockage distant..."
rclone sync "$REMOTE_PATH/checkV/results" "$LOCAL_DIR/checkV/results" --exclude "**/tmp/**"
rclone sync "$REMOTE_PATH/annotate/results" "$LOCAL_DIR/annotate/results"
# defines cluster path
TOOL="$LOCAL_DIR/annotate/results/contig_tools_list.tsv"

CLUSTER="tmp2/clusterRes_cluster.tsv"


# === Process ===

./module_01/filtering/bin/populate_table.py -p $CLUSTER -t $TOOL -c "$LOCAL_DIR/checkV/results" -o $OUTPUT_DIR

exit 0

