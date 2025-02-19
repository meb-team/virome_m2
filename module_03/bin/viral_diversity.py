#!/usr/bin/env python3

import argparse
from itertools import combinations
import numpy as np
import os
import pandas as pd
from scipy.stats import entropy
import re


def diversity(path):
    """
    This function calculates Shannon index, alpha diversity, and Simpson index for a given ecosystem TSV file.
    This TSV file contains at least a column "Species" for each contig.

    :param path : the path where the TSV file is stocked
    :return result_df : a dataframe containing Shannon, Alpha-diversity, Simpson, Simpson-1 columns
    :return species_counts : the count of each species in the ecosystem
    """
    data = pd.read_csv(path, sep="\t")
    file_name = os.path.basename(path)

    ecosystem = re.match(r"^(.*?)_taxo_seeds\.tsv$", file_name).group(1)

    data = data.dropna(subset=["Species"])

    species_counts = data["Species"].value_counts()
    total_individuals = species_counts.sum()

    shannon_index = entropy(species_counts, base=np.e)

    alpha_diversity = species_counts.nunique()

    simpson_index = sum((species_counts / total_individuals) ** 2)

    one_minus_simpson = 1 - simpson_index

    result_df = pd.DataFrame({
        "Shannon": [shannon_index],
        "Alpha-diversity": [alpha_diversity],
        "Simpson": [simpson_index],
        "1-Simpson": [one_minus_simpson]
    }, index=[ecosystem])

    return result_df, species_counts


def beta_diversity(species_counts_1, species_counts_2):
    """
    This function calculates the beta diversity (Bray-Curtis) for couples of ecosystems.

    :param species_counts_1 : the count of each species for the ecosystem 1
    :param species_counts_2 : the count of each species for the ecosystem 2
    :return the result of the beta-diversity for the couple eco1-eco2
    """
    intersection = sum(min(species_counts_1.get(species, 0), species_counts_2.get(species, 0)) for species in species_counts_1)
    union = sum(species_counts_1) + sum(species_counts_2)

    if union == 0:
        return 0

    return 1 - (2 * intersection) / union


def jaccard_index(species_counts_1, species_counts_2):
    """
    This function calculate the Jaccard index for couples of ecosystems.

    :param species_counts_1 : the count of each species for the ecosystem 1
    :param species_counts_2 : the count of each species for the ecosystem 2
    :return the result of the Jaccard index for the couple eco1-eco2

    """
    species_1 = set(species_counts_1.index)
    species_2 = set(species_counts_2.index)

    intersection = len(species_1 & species_2)
    union = len(species_1 | species_2)

    return intersection / union if union != 0 else 0


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="This script processes multiple TSV files to analyze the viral diversity for each biome studied.")

    parser.add_argument("--input_dir", "-i", help="Path to the folder containing TSV files. Default: module_02/MMseq2/results/biome_taxo/", type=str, default="module_02/MMseq2/results/rebuild_taxo/")
    parser.add_argument("--output_dir", "-o", help="Path to the output folder. Default: module_02/MMseq2/results/", type=str, default="module_03/results")

    args = parser.parse_args()

    input_dir = args.input_dir
    output_dir = args.output_dir

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    all_results = []
    species_data = {}

    # Index calculations
    for file_name in os.listdir(input_dir):
        if file_name.endswith("_taxo_seeds.tsv"):
            file_path = os.path.join(input_dir, file_name)
            result_df, species_counts = diversity(file_path)
            all_results.append(result_df)
            ecosystem = result_df.index[0]
            species_data[ecosystem] = species_counts

    final_df = pd.concat(all_results)

    # Jaccard and beta diversity indexes
    combined_results = []
    for eco1, eco2 in combinations(species_data.keys(), 2):
        jaccard_value = jaccard_index(species_data[eco1], species_data[eco2])
        beta_value = beta_diversity(species_data[eco1], species_data[eco2])

        combined_results.append({
            "Ecosystem1": eco1,
            "Ecosystem2": eco2,
            "Jaccard": jaccard_value,
            "Beta-diversity(Bray-Curtis)": beta_value
        })

    jaccard_beta_df = pd.DataFrame(combined_results)

    jaccard_beta_df.to_csv(f"{output_dir}/jaccard_beta.tsv", sep="\t", index=False)
    final_df.to_csv(f"{output_dir}/diversity.tsv", sep="\t", index=True)
