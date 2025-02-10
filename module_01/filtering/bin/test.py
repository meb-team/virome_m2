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
    """
    Function to retrieve the different prediction tools for the seeds (Representative contigs for each clusters).

    :param data : the dataframe containing clusters 
    :param path_tool : the path to a TSV file containing informations about the prediction tools and contigs.
    :return data : the dataframe with 3 new columns for each prediction tools (VirSorter2, VIBRANT, DeepVirFinder)
    """
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

    return data



def seq_tool(data, path_tool):
    """
    Function to collect the prediction tools for each contigs present in the clusters.

    :param data : the dataframe containing clusters
    :param path_tool : the path to a TSV file containing informations about the prediction tools and contigs.
    :return data : the dataframe with 3 new columns for each prediction tools (VirSorter2, VIBRANT, DeepVirFinder)
    """
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

    return data



def get_tool(row):
    if row["vs2_seed"] == 1:
        return "vs2"
    elif row["dvf_seed"] == 1:
        return "dvf"
    elif row["vibrant_seed"] == 1:
        return "vibrant"
    return None



def log_error(message):
    error_file = "module_01/filtering/results/errors_log.txt"
    with open(error_file, 'a') as f:
        f.write(message + "\n")

    print(message)


def get_checkv_data(contig, tool, ecosystem):
    """
    Function to collect the informations of each representative contigs for each ecosystems for each prediction tools
    from the results of CheckV quality summary.

    :param contig : the representative contig ID
    :param tool : the tool associated to {contig} (column vs2 or vib or dvf == 1)
    :param ecosystem :  the ecosystem associated to {contig}
    """
    file_path = f"module_01/checkV/results/{tool}/{ecosystem}_{tool}_checkv/quality_summary.tsv"
    try:
        checkv_df = pd.read_csv(file_path, sep="\t", index_col=0)
        matched_rows = checkv_df[checkv_df.index.astype(str).str.contains(contig, na=False, regex=False)]

        if not matched_rows.empty:
            print(f"Success for {contig}, {tool}, {ecosystem}")
            return matched_rows.iloc[0][["checkv_quality", "completeness", "contig_length", "provirus"]].tolist()
        else:
            if contig.endswith("_1"):
                new_contig = contig[:-2]
                print(f"Retrying with modified contig: {new_contig}")
                return get_checkv_data(new_contig, tool, ecosystem)

            else:
               err = f"FAIL for {contig}, {tool}, {ecosystem}"
               log_error(err)


    except FileNotFoundError:
        err = f"File not found : {contig} : {file_path}"
        log_error(err)
    except Exception as e:
        err = f"Error during the reading of the file {file_path} : {e}"
        log_error(err)

    return [None, None, None, None]



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the report  are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -o path folder/", type=str)
    parser.add_argument("--tool", "-t", help="Defines the path where the metadata of tool predictions are stored for each contigs. Usage : -t path/folder/", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path="module_01/MMseq2/results/clusterRes_cluster.tsv"

    if args.tool:
        path_tool = args.tool
    else:
        path_tool = "module_01/annotate/results/contig_tools_list.tsv"

    if args.out:
        out = args.out
    else:
        out="module_01/filtering/results"

    if not os.path.exists(out):
        os.makedirs(out)

    data = pd.read_csv(path, sep='\t', header=None, names=['representative', 'member'])
    # data2 = data.head(1000)

    data_df,eco_rep = filter(data)
    df_rep = rep_tool(data_df, path_tool)
    df_tool = seq_tool(df_rep, path_tool)

    df_tool["tool"] = df_tool.apply(get_tool, axis=1)

    df_tool["ecosystem"] = df_tool.index.map(eco_rep)

    full_data = df_tool[["checkv_quality", "completeness", "seed_length", "provirus_seed"]] = df_tool.apply(lambda row: pd.Series(get_checkv_data(row.name, row["tool"], row["ecosystem"])), axis=1)

    df_tool.drop(columns=["tool", "ecosystem", "member"], inplace=True)

    df_tool.to_csv(f"{out}/representative_cluster.tsv", sep='\t', index_label="Representative_contig")



