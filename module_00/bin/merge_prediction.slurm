#!/bin/bash

#SBATCH --job-name=data_merge
#SBATCH --output=logs/data_merge_%A_%a.out
#SBATCH --error=logs/data_merge_%A_%a.err
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
remote=""                         # Path to stock the results for rclone : exemple lmge-microstore:huserville
data="module_00/results/try"      # Path to the results from module_00/bin/data_prep.slurm. If the results are stocked with rclone, please write the remote used

scratch="/storage/scratch/$USER"
#result="$scratch/module_00/result/merge"
result="module_00/results/merge"

mkdir -p $result

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    data="$scratch/data"
    mkdir -p $data
    rclone copy $remote/module_00/results $data
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi


# === Process ===

SRR_DIRS=($(find $data -mindepth 2 -maxdepth 2 -type d | sort))
SRR_DIR=${SRR_DIRS[$SLURM_ARRAY_TASK_ID]}

ecosystem=$(basename "$(dirname "$SRR_DIR")")
srrname=$(basename "$SRR_DIR")

outdir="$result/$ecosystem/$srrname"
tmp_outfile="$outdir/${srrname}_tmp_sequences.fa"
outfile="$outdir/${srrname}_sequences.fa"

mkdir -p "$outdir"

prediction_file="$outdir/${srrname}_tool.tsv"
ecosystem_file="$outdir/${srrname}_eco.txt"

> "$prediction_file"
> "$ecosystem_file"

MERGED="$outdir/temp_sequences.fa"

for fa_file in "$SRR_DIR"/*_predicted.fa; do
    tool=$(basename "$fa_file" | cut -d'_' -f1)  # dvf, vib, vs2
    tmp_modified="$outdir/$(basename "$fa_file" .fa)_mod.fa"

    awk -v tool="$tool" -v eco="$ecosystem" -v pred="$prediction_file" -v map="$ecosystem_file" '
    BEGIN { OFS = "\t" }
    /^>/ {
        header = substr($0, 2)
        print header, tool >> pred
        print header "==" eco >> map
        print ">" header "==" eco
        next
    }
    { print }
    ' "$fa_file" > "$tmp_modified"
done

cat "$outdir"/*_mod.fa > "$MERGED"

tmp_outfile="$outdir/${srrname}_tmp_sequences.fa"
outfile="$outdir/${srrname}_sequences.fa"

seqkit rmdup -s -o "$tmp_outfile" "$MERGED"
seqkit rmdup -n -o "$outfile" "$tmp_outfile"

rm "$MERGED" "$tmp_outfile" "$outdir"/*_mod.fa

if [[ -n "$remote" ]]; then
    echo "Remote : $remote"
    rclone copy $outdir $remote/module_00/results/merge
else
    echo "No remote, no rclone :). Please define the remote variable if you want to export your results in a distant server using rclone."
fi

echo "Done with $SRR_DIR for $ecosystem"

