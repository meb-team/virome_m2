#!/usr/bin/env python3


import argparse
import numpy as np
import pandas as pd


def filter_tsv(data, out):
    """
    This function aims to delete the rows with an e-value > 0.001.

    :param data : the dataframe containing informations from eggNOGmapper
    :param out : the output path to stock the filtered TSV file
    : return : the filtered dataframe
    """

    data.columns = [col.lstrip('#') for col in data.columns]

    data['evalue'] = pd.to_numeric(data['evalue'], errors='coerce')

    initial_count = len(data)

    filtered_data = data[data['evalue'] <= 0.001]

    final_count = len(filtered_data)

    print(f"Deleted rows : {initial_count - final_count}")
    filtered_data.to_csv(f"{out}/filtered_eggmapper_annotations.tsv", sep='\t', index=False)
    ko=data['KEGG_ko']

    return filtered_data


def collect_ko(df, kolist_df):
    """
    This function keeps the rows with the selected KEGG Ontology (KO) from a list from VIBRANT bio-informatic tool.
    This list of KO are used to predict the AMGs from other functionnal proteins. At the end, the dataframe will contain
    only information about hypothetical AMGs proteins.

    :param df : the filtered dataframe (e-value < 0.001)
    :param kolist_df : the dataframe containing the list of the selected KO
    :return the dataframe of AMGs
    """

    ko_set = set(kolist_df['KO'].astype(str))

    def has_matching_ko(ko_field):
        if pd.isna(ko_field) or ko_field == "-":
            return False
        return any(ko.strip().replace("ko:", "") in ko_set for ko in ko_field.split(","))

    filtered = df[df['KEGG_ko'].apply(has_matching_ko)].copy()

    return filtered


def rebuild_tsv(df, ecosystem_txt_path):
    """
    This function creates a column to add ecosystem information about the AMG protein. Each
    protein is associated with an ecosystem from where the sequence has been collected.

    :param df : the AMG dataframe
    :param ecosystem_txt_path : the path to the ecosystem annotation for each contig 
    :return : the AMG dataframe with the ecosystem informations for each proteins
    """

    columns_to_keep = [
        "query",
        "KEGG_ko",
        "max_annot_lvl",
        "Description",
        "Preferred_name",
        "GOs",
        "KEGG_Pathway",
        "KEGG_Module",
        "KEGG_Reaction",
        "KEGG_rclass",
        "BiGG_Reaction",
        "PFAMs"
    ]
    
    existing_columns = [col for col in columns_to_keep if col in df.columns]
    df_selected = df[existing_columns].copy()


    ecosystem_map = {}
    with open(ecosystem_txt_path, 'r') as f:
        for line in f:
            if '==' in line:
                key, value = line.strip().split('==', 1)
                ecosystem_map[key] = value

    def extract_srr(query):
        return query.rsplit('_', 1)[0]

    df['ecosystem'] = df['query'].apply(lambda q: ecosystem_map.get(extract_srr(q), 'unknown'))

    return df


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Filter clusters and assign them to biomes based on their members.")
    parser.add_argument("--annot", "-a", help="Path to the protein annotation file (from eggNOGmapper tool).", type=str, required=True)
    parser.add_argument("--out", "-o", help="Path to store the different result files.", type=str, required=True)
    parser.add_argument("--kolist", "-ko", help="Path to the list of KO considered as AMGs by VIBRANT tool.", type=str, required=True)
    parser.add_argument("--ecosystem", "-e", help="Path to the list of contigs annotated with their respective ecosystem.", type=str, required=True)

    args = parser.parse_args()

    annot=args.annot
    out=args.out
    kolist=args.kolist
    eco_txt=args.ecosystem

    data=pd.read_csv(annot, sep='\t', low_memory=False)
    ko_df=pd.read_csv(kolist, sep='\t', low_memory=False)

    filtered_data=filter_tsv(data, out)
    amg_df=collect_ko(filtered_data, ko_df)
    amg_df=rebuild_tsv(amg_df, eco_txt)
    amg_df.replace('-', np.nan, inplace=True)
    amg_df['max_annot_lvl'] = amg_df['max_annot_lvl'].where(~amg_df['max_annot_lvl'].str.contains('\|'), amg_df['max_annot_lvl'].str.split('|').str[1])

    amg_df.to_csv(f"{out}/AMG.tsv", sep='\t', index=False)


    



