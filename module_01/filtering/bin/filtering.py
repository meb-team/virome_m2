#!/usr/bin/env python3

import argparse
import os
import pandas as pd


def cluster_num(data):
    """
    Function to attribute each cluster to a number from 1 to n clusters.

    param data : the TSV file resulting of MMseq2 clustering
    return : a dataframe containing the contigs, the representant of each clusters and the cluster in int format.
    """
    cluster_dict = {}
    cluster_id = 1

    for rep in data['representative'].unique():
        if rep not in cluster_dict:
            cluster_dict[rep] = cluster_id
            cluster_id +=1

    data['cluster'] = data['representative'].map(cluster_dict)

    return data


def parse_info(identifier):
    """
    Function to identify the ecosystem and the prediction tool for each contigs

    param identifier : contig IDs from a dataframe
    return : a dictionnary containing the IDs contigs, the ecosystems and the tool as keys
    """
    parts = identifier.split("==")

    return {
        "contig": parts[0],
        "ecosystem": parts[1] if len(parts) > 1 else "NA",
        "tool": parts[2] if len(parts) > 2 else "NA"
    }


def merge_info(data):
    """
    Function to merge all the informations into one dataframe. For each contigs, there are prediction_tool, cluster, cluster representative and ecosystem columns.

    param data : a dataframe resulting of cluster_num().
    return : a dataframe containing all the informations relative to the contigs and the clusters.
    """
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
    """
    Function to filter the dataframe resulting of merge_info(). The clusters with less than 2 contigs are deleted. And the clusters containing less than 2
    different prediction tools are deleted. Only contigs with double-cross validation are kept.

    :param df : the dataframe resulting of merge_info().
    : return : a filtered dataframe.
    """
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
    """
    Function to retrieve, collect and merge some CheckV results to each contigs present in the dataframe after filtering. The following informations are
    associated for each contigs : the lenght of each contig, if the contig is a provirus/prophage, the number of viral genes, the number of host genes, the
    CheckV quality results and the CheckV quality score.

    :param df : the dataframe after filtering resulting from filter_clusters.
    :param checkv_base_path : the path where the results of CheckV are stored
    :return : a dataframe containing all these informations.
    """
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
        print("Contig processed :",len(checkv_data))

    checkv_df = pd.DataFrame(checkv_data, index=df.index)
    df = pd.concat([df, checkv_df], axis=1)

    return df


def retry_checkv_for_na(df, checkv_base_path):
    """
    Function to handle some NA. Some NA are here because of an issue of non-unique contig during the clustering.
    For every NA we re-check the informations for the IDs but we remove the '_1' at the end of the name of the contigs.

    :param df : the dataframe resulting of add_checkv_info()
    :param checkv_base_path : the path where the results of CheckV are stored
    :return : the dataframe with less NA (hopefully).
    """
    na_rows = df[df.isna().any(axis=1)].copy()
    na_rows["Contig_modified"] = na_rows.index.str.rstrip("_1")

    for contig, row in na_rows.iterrows():
        if contig != row["Contig_modified"]:
            ecosystem = row["Ecosystem"]
            tool = row["Prediction tool"]
            checkv_path = os.path.join(checkv_base_path, tool, f"{ecosystem}_{tool}_checkv/quality_summary.tsv")

            if os.path.exists(checkv_path):
                checkv_df = pd.read_csv(checkv_path, sep='\t')
                checkv_row = checkv_df[checkv_df["contig_id"] == row["Contig_modified"]]

                if not checkv_row.empty:
                    df.loc[contig, checkv_row.columns] = checkv_row.iloc[0]

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
    complete_df_NA = retry_checkv_for_na(complete_df, path_checkv)

    print(complete_df)

    complete_df_NA.to_csv(f"{out}/representative_clusterTEST.tsv", sep='\t')

    print("Job finish !")

