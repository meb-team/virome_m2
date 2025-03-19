#!/bin/bash

#SBATCH --job-name=dl_db
#SBATCH --output=logs/imgvr_%A_%a.out
#SBATCH --error=logs/imgvr_%A_%a.err
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=8 # Nb CPUs per tasks
#SBATCH --mem=16G         # RAM memory
#SBATCH --time=04:00:00
#SBATCH --partition=fast

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script if unknown variables are used
set -o pipefail


# === Variable definition ===
scratch="/storage/scratch/$USER"
output="$scratch/img_vr"
REMOTE="lmge-microstore:huserville"
login="hugo.serville@etu.uca.fr"
pw="panda698!"

mkdir -p $output

# === Process ===
# Login to IMG/VR
curl 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login=hugo.serville@etu.uca.fr' --data-urlencode 'password=XXXXXXX' -c cookies > /dev/null

# Download README
curl 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/IMG_VR/download/_JAMO/63a22c0c3b5d0133c73fb09b/README.txt' -b cookies > $output/README.txt

# Download Nucleotide sequences
curl 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/IMG_VR/download/_JAMO/63a22c0c3b5d0133c73fb093/IMGVR_all_nucleotides.fna.gz' -b cookies > $output/IMGVR_all_nucleotides.fna.gz

# Download sequences metadata
curl 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/IMG_VR/download/_JAMO/63a22c0c3b5d0133c73fb097/IMGVR_all_Sequence_information.tsv' -b cookies > $output/IMGVR_all_Sequence_information.tsv

# Download host metadata
curl 'https://genome-downloads.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/IMG_VR/download/_JAMO/63a22c0c3b5d0133c73fb099/IMGVR_all_Host_information.tsv' -b cookies > $output/IMGVR_all_Host_information.tsv

rclone copy $output $REMOTE/module_02/minimap/imgvr_db

rm -rf $output
