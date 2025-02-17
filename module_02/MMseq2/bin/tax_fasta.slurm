#!/bin/bash
#SBATCH --job-name=fasta_seed_creation
#SBATCH --output=module_02/MMseq2/fasta_seed_creation.out
#SBATCH --error=module_02/MMseq2/fasta_seed_creation.err
#SBATCH --time=01:00:00  # Max time execution
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=2 # Nb of CPUs per tasks
#SBATCH --mem=8G          # RAM memory

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
TSV="module_01/filtering/results/filtered_representative_cluster.tsv"
FASTA="module_01/MMseq2/results/clusterRes_rep_seq.fasta"
OUTPUT="module_02/MMseq2/results"
mkdir -p "$OUTPUT"

# === Process ===

cut -f1 "$TSV" > "$OUTPUT/contig_ids.txt"
sed 's/==.*//' "$FASTA" > "$OUTPUT/cleaned_fasta.fa"

seqtk subseq "$OUTPUT/cleaned_fasta.fa" "$OUTPUT/contig_ids.txt" > "$OUTPUT/tax_fasta_seed.fa"

rm "$OUTPUT/contig_ids.txt" "$OUTPUT/cleaned_fasta.fa"

echo "File $OUTPUT/tax_fasta_seed.fa created !"

