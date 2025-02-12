#!/usr/bin/env python3

import argparse
import os
import pandas as pd


def filter(data):
    """
    Function to filter the TSV cluster result. Here we keep the singletons only if they have a good CheckV quality. Here singleton means that
    the contig has not been identified by more than 1 prediction tools. So, if the quality is low, we delete it to avoid false positive.
    Then, for the cluster size > 1, we only keep the cluster where the sequences have been identified by more than 1 prediction tool.
    It's a double cross validation step here. We eliminate the false positive.
    """
    df_filtered = data[data['cluster_size'] > 1].copy() # select cluster size > 1
    df_filtered.loc[:, 'tools_seed'] = df_filtered.apply(lambda row: {col for col in ['dvf_seed', 'vibrant_seed', 'vs2_seed'] if row[col] == 1}, axis=1)
    df_filtered.loc[:, 'tools_cluster'] = df_filtered.apply(lambda row: {col for col in ['dvf_cluster', 'vibrant_cluster', 'vs2_cluster'] if row[col] == 1}, axis=1)
    df_filtered.loc[:, 'mix_tools'] = df_filtered.apply(lambda row: row['tools_seed'].union(row['tools_cluster']), axis=1)
    df_filtered = df_filtered[df_filtered['mix_tools'].apply(len) > 1] # double validation tools cluster
    df_filtered = df_filtered.drop(columns=['tools_seed', 'tools_cluster','mix_tools'])

    df_filtered_1 = data[(data['cluster_size'] == 1) & (data['checkv_quality'].isin(['Complete', 'High-quality']))] # treatment for cluster size = 1

    filtered_data = pd.concat([df_filtered, df_filtered_1])

    return filtered_data



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the clustring TSV  are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the filtered TSV can be stored. Usage : -o path folder/", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path="module_01/filtering/results/representative_cluster.tsv"

    if args.out:
        out = args.out
    else:
        out="module_01/filtering/results"

    if not os.path.exists(out):
        os.makedirs(out)


    data = pd.read_csv(path, sep='\t')

    print("Start filtering the TSV file...")
    data_filt = filter(data)

    data_filt.to_csv(f"{out}/filtered_representative_cluster.tsv", sep='\t', index=False)

    print(f"Job end : You can retrieve the results here : {out}/filtered_representative_cluster.tsv")
