#!/usr/bin/env python3

import argparse
import os 
import pandas as pd


def cluster_num(data):
    cluster_dict = {}
    cluster_id = 1

    for rep in data['representative'].unique():
        if rep not in cluster_dict:
            cluster_dict[rep] = cluster_id
            cluster_id +=1

    data['cluster'] = data['representative'].map(cluster_dict)

    return data


def parse_info(identifier):
    parts = identifier.split("==")

    return {
        "contig": parts[0],
        "ecosystem": parts[1] if len(parts) > 1 else "NA",
        "tool": parts[2] if len(parts) > 2 else "NA"
    }


def merge_info(data):
    records = []

    for _, row in data.iterrows():
        rep_info = parse_info(row['representative'])
        mem_info = parse_info(row['member'])

        records.append({
        "Contig": mem_info['contig'],
        "Prediction tool": mem_info['tool'],
        "Cluster": row['cluster'],
        "Cluster Representative": rep_info['contig'],
        "Ecosystem": mem_info['ecosystem']
    })

    df = pd.DataFrame(records)
    df.set_index("Contig", inplace=True)

    return df


def filter_clusters(df):
    start = len(df)

    print(f"Start with {start} contigs") 

    cluster_counts = df['Cluster'].value_counts()
    valid_clusters = cluster_counts[cluster_counts > 1].index
    df = df[df['Cluster'].isin(valid_clusters)]

    cluster_tool_counts = df.groupby("Cluster")['Prediction tool'].nunique()
    valid_clusters = cluster_tool_counts[cluster_tool_counts > 1].index
    df = df[df['Cluster'].isin(valid_clusters)]

    end = len(df)
    deleted = start - end 

    print(f"End with {end} contigs")
    print(f"Number of contigs deleted : {deleted}")

    return df


def add_checkv_info(df, checkv_base_path):
    checkv_columns = ["contig_length", "provirus", "viral_genes", "host_genes", "checkv_quality", "completeness"]
    checkv_data = []

    for contig, row in df.iterrows():
        ecosystem = row["Ecosystem"]
        tool = row["Prediction tool"]
        checkv_path = os.path.join(checkv_base_path, tool, f"{ecosystem}_{tool}_checkv/quality_summary.tsv")

        if os.path.exists(checkv_path):
            checkv_df = pd.read_csv(checkv_path, sep='\t')
            checkv_row = checkv_df[checkv_df["contig_id"] == contig]

            if not checkv_row.empty:
                checkv_info = checkv_row.iloc[0][checkv_columns].to_dict()
            else:
                checkv_info = {col: "NA" for col in checkv_columns}
        else:
            checkv_info = {col: "NA" for col in checkv_columns}

        checkv_data.append(checkv_info)
        print(len(checkv_data))

    checkv_df = pd.DataFrame(checkv_data, index=df.index)
    df = pd.concat([df, checkv_df], axis=1)

    return df


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the report  are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -o path folder/", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path="module_01/MMseq2/results/clusterRes_cluster.tsv"

    if args.out:
        out = args.out
    else:
        out="module_01/filtering/results"

    if not os.path.exists(out):
        os.makedirs(out)

    print("Start the filtering...")

    data = pd.read_csv(path, sep='\t', header=None, names=['representative', 'member'])
    path_checkv = "module_01/checkV/results"

    df_cluster_num = cluster_num(data)
    cluster_df = merge_info(df_cluster_num)
    filter_df = filter_clusters(cluster_df)
    complete_df = add_checkv_info(filter_df, path_checkv)

    print(complete_df)

    complete_df.to_csv(f"{out}/representative_cluster.tsv", sep='\t')

    print("Job finish !")

