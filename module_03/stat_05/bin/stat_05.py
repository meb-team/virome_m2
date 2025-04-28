#!/usr/bin/env python3

import argparse
import pandas as pd
import os
import glob
import matplotlib.pyplot as plt


def get_class_or_domain(row):
    if pd.isna(row['Class']) or row['Class'] == 'NA':
        if pd.isna(row['Domain']) or row['Domain'] == 'NA':
            return 'NA'
        else:
            return row['Domain']
    else:
        return row['Class']


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="This script processes multi TSV files for each ecosystem, to perform statistical analysis.")

    parser.add_argument("--tsv", "-t", help="Path to the folder containing TSV files (taxonomy).", type=str, required=True)
    parser.add_argument("--list", "-l", help="Path to the list of IDs.", type=str, required=True)
    parser.add_argument("--output_dir", "-o", help="Path to the output folder.", type=str, required=True)

    args = parser.parse_args()

    path = args.tsv
    out = args.output_dir
    liste= args.list

    if not os.path.exists(out):
        os.makedirs(out)

    with open(liste, 'r') as f:
        ids_of_interest = set(line.strip() for line in f)

    path_to_tsv_files = f"{path}/*.tsv"
    list_of_dfs = []

    for file in glob.glob(path_to_tsv_files):
        df = pd.read_csv(file, sep='\t')
        list_of_dfs.append(df)

    full_df = pd.concat(list_of_dfs, ignore_index=True)

    filtered_df = full_df[full_df['ID'].isin(ids_of_interest)].copy()
    filtered_df['Class_Corrected'] = filtered_df.apply(get_class_or_domain, axis=1)

    class_counts = filtered_df['Class_Corrected'].value_counts()

    plt.figure(figsize=(10, 6))
    class_counts.plot(kind='bar', color='skyblue', edgecolor='black')
    plt.xlabel('Class (ou Domain si Class = NA)')
    plt.ylabel('Nombre d\'occurrences')
    plt.title('Répartition des Classes')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()

    plt.savefig(f'{out}/repartition_classes.png', dpi=300)
    plt.close()

