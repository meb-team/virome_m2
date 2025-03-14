#!/usr/bin/env python3

import argparse
from collections import defaultdict
import os
import pandas as pd

def filter(data):
    df_filtered = data[data['cluster_size'] > 1].copy()
    df_filtered.loc[:, 'tools_seed'] = df_filtered.apply(lambda row: {col for col in ['dvf_seed', 'vibrant_seed', 'vs2_seed'] if row[col] == 1}, axis=1)
    df_filtered.loc[:, 'tools_cluster'] = df_filtered.apply(lambda row: {col for col in ['dvf_cluster', 'vibrant_cluster', 'vs2_cluster'] if row[col] == 1}, axis=1)
    df_filtered.loc[:, 'mix_tools'] = df_filtered.apply(lambda row: row['tools_seed'].union(row['tools_cluster']), axis=1)
    df_filtered = df_filtered[df_filtered['mix_tools'].apply(len) > 1]
    df_filtered = df_filtered.drop(columns=['tools_seed', 'tools_cluster','mix_tools'])

    df_filtered_1 = data[(data['cluster_size'] == 1) & (data['checkv_quality'].isin(['Complete', 'High-quality']))]
    
    return pd.concat([df_filtered, df_filtered_1])


def get_cluster_biomes(cluster_file):
    cluster_biome_dict = defaultdict(set)
    with open(cluster_file, 'r') as f:
        for line in f:
            contig1, contig2 = line.strip().split('\t')
            seed, biome = contig1.split('==')
            cluster_biome_dict[seed].add(biome)
            
            if '==' in contig2:
                contig2_name, biome2 = contig2.split('==')
                cluster_biome_dict[seed].add(biome2)
    
    return cluster_biome_dict


def subtable(data, cluster_biomes, out):
    biome_dict = defaultdict(list)
    for seed, biomes in cluster_biomes.items():
        for biome in biomes:
            biome_dict[biome].append(seed)
    
    for biome, contigs in biome_dict.items():
        subdata = data[data['Representative_contig'].isin(contigs)]
        file = f"{out}/{biome}_filtered_representative_cluster.tsv"
        subdata.to_csv(file, sep='\t', index=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Filter clusters and assign them to biomes based on their members.")
    parser.add_argument("--path", "-p", help="Path to the clustering TSV file.", type=str, required=True)
    parser.add_argument("--out", "-o", help="Path to store filtered TSVs.", type=str, required=True)
    parser.add_argument("--clusters", "-c", help="Path to the cluster composition TSV file.", type=str, required=True)
    
    args = parser.parse_args()
    
    if not os.path.exists(args.out):
        os.makedirs(args.out)
    
    out_biome = f"{args.out}/eco"
    if not os.path.exists(out_biome):
        os.makedirs(out_biome)
    
    data = pd.read_csv(args.path, sep='\t', low_memory=False)
    print("Start filtering the TSV file...")
    data_filt = filter(data)
    
    print("Processing cluster composition file...")
    cluster_biomes = get_cluster_biomes(args.clusters)
    
    print("Generating biome-specific tables...")
    subtable(data_filt, cluster_biomes, out_biome)
    
    print(f"Job complete. Results stored in: {args.out}")

