# ==========================
# DESCRIPTION :
# This script annotates contig names with ecosystem names from CheckV results and generates a separate TSV file
# containing the list of contig names and their corresponding tools.
# Author  : SERVILLE Hugo
# Date    : 06/02/2025
# Version : 1.0
# ==========================

# === Initialization ===
set -e  # Stop the script if error
set -u  # Stop the script unknown variables
set -o pipefail

# === Variable definition ===

RESULTS_DIR="module_01/checkV/results"
mkdir -p "module_01/annotate/results"
OUTPUT_FILE="module_01/annotate/results/all_annotated_contigs.fasta"
TSV_FILE="module_01/annotate/results/contig_tools_list.tsv"
> "$OUTPUT_FILE"
> "$TSV_FILE"

# === Function definition ===
process_fasta() {
    local fasta_file="$1"
    local ecosystem="$2"
    local tool="$3"

    # Annotate the FASTA file with the ecosystem name
    awk -v eco="$ecosystem" -v tool="$tool" '
        /^>/ {
            sub(/\|\|.*/, "", $0);  # Remove everything after "||" (for vs2)
            print $0 "==" eco;
            next
        }
        {print}
    ' "$fasta_file" >> "$OUTPUT_FILE"

    # Record the contig names and the tools used in the TSV file
    grep "^>" "$fasta_file" | sed 's/^>//' | while read contig; do
        echo -e "$contig\t$tool" >> "$TSV_FILE"
    done
}

# === Process data ===
echo "Starting job..."

for tool_dir in "$RESULTS_DIR"/*/; do
    tool=$(basename "$tool_dir")  # Collect the tool name

    for eco_dir in "$tool_dir"/*/; do
        ecosystem=$(basename "$eco_dir" | cut -d'_' -f1)  # Collect the ecosystem name

        for fasta in "$eco_dir"/viruses.fna "$eco_dir"/proviruses.fna; do
            if [[ -f "$fasta" ]]; then
                process_fasta "$fasta" "$ecosystem" "$tool"
            fi
        done
    done
done

echo "Job finished! You can retrieve the results here:"
echo "FASTA file: module_01/annotate/results/all_annotated_contigs.fasta"
echo "TSV file: module_01/annotate/results/contig_tools_list.tsv"

exit 0
