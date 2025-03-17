#!/usr/bin/env python3

import argparse
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import seaborn as sns


def jac_matrix(path):
    data = pd.read_csv(path, sep="\t")
    if "Jaccard" not in data.columns:
        raise ValueError("TSV file does not contains 'Jaccard' column")
    ecosystems = sorted(set(data["Ecosystem1"]).union(set(data["Ecosystem2"])))
    jaccard_matrix = pd.DataFrame(np.nan, index=ecosystems, columns=ecosystems)
    for _, row in data.iterrows():
        eco1, eco2, jaccard_value = row["Ecosystem1"], row["Ecosystem2"], row["Jaccard"]
        jaccard_matrix.loc[eco1, eco2] = jaccard_value
        jaccard_matrix.loc[eco2, eco1] = jaccard_value

    np.fill_diagonal(jaccard_matrix.values, 1.0)

    return jaccard_matrix



def jac_heatmap(matrix, out):

    plt.figure(figsize=(8, 6))
    sns.heatmap(matrix, annot=True, cmap="viridis", fmt=".2f", linewidths=0.5)
    plt.title("Similarity matrix of Jaccard index")
    plt.xticks(rotation=45, ha='right')
    plt.yticks(rotation=0)
    plt.tight_layout()
    plt.savefig(f"{out}/jaccard_heatmap.png", dpi=300)



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="This script creates a similarity matrix and figure of Jaccard index")

    parser.add_argument("--input_dir", "-i", help="Path to the folder containing TSV file. Default: module_03/results/jaccard_beta.tsv", type=str, default="module_03/results/jaccard_beta.tsv")
    parser.add_argument("--output_dir", "-o", help="Path to the output folder. Default: module_03/figure", type=str, default="module_03/figure")

    args = parser.parse_args()

    input_dir = args.input_dir
    output_dir = args.output_dir

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)


    matrix = jac_matrix(input_dir)
    jac_heatmap(matrix, output_dir)
