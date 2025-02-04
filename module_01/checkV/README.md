# CheckV informations

CheckV (CheckViral) is a bioinformatics tool designed to assess the completeness, quality, and contamination of viral genome sequences, 
particularly from metagenomic data. It helps researchers differentiate between complete, near-complete, and fragmented viral genomes by 
estimating the presence of missing genome regions. CheckV is particularly useful for analyzing uncultivated viral sequences, providing metrics 
such as genome completeness, potential host range, and taxonomy classification. It enhances viral genome curation and is widely used in virology and microbiome research

Click [here](https://www.nature.com/articles/s41587-020-00774-7) to open the article relative to CheckV.

# Usage 

For this project, I used CheckV to check the quality of the predicted viral contigs from different ecosystems.
Summary quality plots are created here : module_01/checkV/figure

An example of command I used in this project :
```bash
home="/home/user"
path_checkv="bin/checkv.sif"
file="predicted_sequence.fa"

singularity exec --bind "$home" "$path_checkv" checkv end_to_end "$file "$out" -t$(($(nproc) / 2 ))
```
- param end_to_end : analyzes a complete viral sequence in a single process.
- param -t : number of CPUs used by the tool

# Results 

As a result, you should have something like that :
```
module_01/
└── checkV/
    └── results/
        └── dvf/
            └── air_dvf_checkv/
                ├── complete_genomes.tsv
                ├── completeness.tsv
                ├── contamination.tsv
                ├── proviruses.fna
                ├── quality_summary.tsv
                ├── viruses.fna
                └── tmp/
```
