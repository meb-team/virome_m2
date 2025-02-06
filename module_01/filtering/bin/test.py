#!/usr/bin/env python3

import argparse
import os
import pandas as pd
import subprocess


def filter(data):
    """
    Function to filter the dataframe by the cluster size and adjust names of the contigs.

    :param data : the dataframe containing cluster informations (TSV format)
    :return df_filtered : the dataframe with sorted and filtered data
    :return ecosystem_dict : a dictionnary { representative_contig : ecosystem}
    """
    ecosystem_dict = {}
    new_index = []

    df_grouped = data.groupby('representative')['member'].apply(list).reset_index()
    df_grouped['cluster_size'] = df_grouped['member'].apply(len)
    df_filtered = df_grouped[df_grouped['cluster_size'] > 1]
    df_filtered.set_index('representative', inplace=True)

    for contig in df_filtered.index:
        parts = contig.split('==')

        if len(parts) == 2:
            nomcontig, ecosysteme = parts
        else:
            nomcontig, ecosysteme = parts[0], None

        ecosystem_dict[nomcontig] = ecosysteme
        new_index.append(nomcontig)

    df_filtered.index = new_index
    df_copy = df_filtered.copy()
    df_copy['member'] = df_copy['member'].apply(lambda members: [m.split('==')[0] for m in members])

    return df_copy, ecosystem_dict



def rep_tool(data, path_tool):
    data["vs2_seed"] = 0
    data["vibrant_seed"] = 0
    data["dvf_seed"] = 0

    print("Start collecting representative contig informations...")
    total_row = data.shape[0]
    count = 1
    for contig in data.index:

         grep = f"cat {path_tool} | grep '{contig}'"
         res = subprocess.run(grep, shell=True, capture_output=True, text=True)
         re = res.stdout

         if "vs2" in re:
             data.at[contig, "vs2_seed"] = 1
         if "vibrant" in re:
             data.at[contig, "vibrant_seed"] = 1
         if "dvf" in re:
             data.at[contig, "dvf_seed"] = 1

         print(f"Done for representative contigs: {count}/{total_row}")
         count+=1

    print(data)

    return data



def seq_tool(data, path_tool):

    data["vs2_cluster"] = 0
    data["vibrant_cluster"] = 0
    data["dvf_cluster"] = 0
    count = 0
    total_row = data.shape[0]

    for contig, members in data["member"].items():
        if isinstance(members, str):
            try:
                members = ast.literal_eval(members)
            except:
                members = []

        for member in members:
            if member == contig:
                continue

            grep_cmd = f"grep -F '{member}' {path_tool}"
            res = subprocess.run(grep_cmd, shell=True, capture_output=True, text=True)
            result_str = res.stdout

            if "vs2" in result_str:
                data.at[contig, "vs2_cluster"] += 1
            if "vibrant" in result_str:
                data.at[contig, "vibrant_cluster"] += 1
            if "dvf" in result_str:
                data.at[contig, "dvf_cluster"] += 1

        print(f"Done for contigs : {count}/{total_row}")
        count+=1
    print(data)
    return data



def retrieve_checkV_info(data, eco_dict, path_checkv):
    return None



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

    data = pd.read_csv(path, sep='\t', header=None, names=['representative', 'member'])
    path_tool = "module_01/annotate/results/contig_tools_list.tsv"

    data_df,eco_rep = filter(data)
    df_rep = rep_tool(data_df, path_tool)
    # df_tool = seq_tool(data_df, path_tool)
    full_data = retrieve_checkV_info(data_df, eco_rep, path_checkv)

    full_data.to_csv(f"{out}/representative_cluster.tsv", sep='\t')



