#!/bin/bash
#SBATCH --job-name=tax_annotation
#SBATCH --output=module_02/MMseq2/tax_annotation.out
#SBATCH --error=module_02/MMseq2/tax_annotation.err
#SBATCH --time=02:00:00  # Max time execution
#SBATCH --ntasks=1        # Nb of tasks
#SBATCH --cpus-per-task=4 # Nb CPUs per tasks
#SBATCH --mem=16G         # RAM memory

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===
query="module_02/MMseq2/results/tax_fasta_seed.fa"
DB="module_02/MMseq2/taxonomy/mmseqs_vrefseq/refseq_viral"
OUTPUT="module_02/MMseq2/results"

# === Process ===
mmseqs createdb "$query" "$OUTPUT/indexed"

mmseqs taxonomy "$OUTPUT/indexed" "$DB" "$OUTPUT/res" "$OUTPUT/tmp" --tax-lineage 1 --lca-mode 3

mmseqs createtsv "$OUTPUT/indexed" "$OUTPUT" taxo_results.tsv

mmseqs taxonomyreport "$DB" "$OUTPUT" taxo_report

