#!/usr/bin/env python3

import argparse
import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


def load_data(path):
    """
    This function aims to load all the dataframe and concat them into one big dataframe. A column "ecosystem" is created.
    The values are also cleaned and standardized to avoid errors.

    :path : the path where the .tsv are stocked (given in input by -i)
    :return : a dataframe containing all the informations for each ecosystem
    """
    all_data=[]
    for file in os.listdir(path):
        if file.endswith(".tsv"):
            eco=file.split("_")[0]
            file_path=os.path.join(path, file)
            data=pd.read_csv(file_path, sep="\t")
            data["ecosystem"]=eco
            all_data.append(data)

    final_data=pd.concat(all_data, ignore_index=True)
    final_data["seed_length"]=pd.to_numeric(final_data["seed_length"], errors="coerce")
    final_data["provirus_seed"]=final_data["provirus_seed"].str.strip().str.capitalize()
    final_data["checkv_quality"]=final_data["checkv_quality"].str.strip().str.capitalize()

    return final_data


def plot_colored_swarm(df, title):
    quality_palette = {
    "Not-determined": "#B0B0B0",
    "Low-quality": "#FFA500",
    "Medium-quality": "#FFFF00",
    "High-quality": "#32CD32",
    "Complete": "#1E90FF"
    }

    sns.set(style="whitegrid")
    box_palette = sns.color_palette("Set3")

    plt.figure(figsize=(14, 6))
    
    sns.boxplot(x="ecosystem", y="seed_length", data=df, palette=box_palette, showfliers=False)
    
    sns.stripplot(
        x="ecosystem",
        y="seed_length",
        data=df,
        hue="checkv_quality",
        palette=quality_palette,
        dodge=False,
        jitter=0.25,
        size=3,
        alpha=0.7
    )
    
    plt.title(title)
    plt.xticks(rotation=45, ha="right")
    plt.ylabel("Seed Length (Genome Size)")
    plt.legend(title="CheckV Quality", bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.savefig(f"{out}/{title}_size_distribution.svg", dpi=300)
    

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="This script processes multi TSV files for each ecosystem, to perform statistical analysis.")

    parser.add_argument("--input_dir", "-i", help="Path to the folder containing TSV files.", type=str, required=True)
    parser.add_argument("--output_dir", "-o", help="Path to the output folder.", type=str, required=True)

    args = parser.parse_args()

    path = args.input_dir
    out = args.output_dir

    if not os.path.exists(out):
        os.makedirs(out)

    data = load_data(path)

    # all the viruses
    plot_colored_swarm(data, "All_viruses")

    # No prophage
    viruses_only = data[data["provirus_seed"] == "No"]
    plot_colored_swarm(viruses_only, "No_provirus")

    # Only prophage
    prophages_only = data[data["provirus_seed"] == "Yes"]
    plot_colored_swarm(prophages_only, "Prophage")


