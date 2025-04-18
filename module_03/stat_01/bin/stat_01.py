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

    plt.figure(figsize=(14, 6))
    
    sns.boxplot(x="ecosystem", y="seed_length", data=df, showfliers=False, color="white")


    sns.stripplot(
        x="ecosystem",
        y="seed_length",
        data=df,
        hue="checkv_quality",
        palette=quality_palette,
        dodge=False,
        jitter=0.3,
        size=2,
        alpha=0.3
    )
    
    plt.title(title)
    plt.xticks(rotation=45, ha="right")
    plt.ylabel("Seed Length (Genome Size)")
    plt.yscale("log")
    plt.legend(title="CheckV Quality", bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.savefig(f"{out}/{title}_size_distribution.png")
    plt.savefig(f"{out}/{title}_size_distribution.svg")

    

def plot_completion_proportion(df, out):
    """
    Plot a stacked bar chart showing the proportion of complete vs incomplete viruses per ecosystem,
    excluding unknown or undetermined quality. Displays proportions (%) instead of counts.
    """
    # On filtre les valeurs indésirables
    df_clean = df[~df["checkv_quality"].isna()]
    df_clean = df_clean[~df_clean["checkv_quality"].str.lower().str.strip().eq("not-determined")]

    # Classification
    def classify_completeness(q):
        return "Complete" if q.lower() == "complete" else "Incomplete"

    df_clean["completeness_status"] = df_clean["checkv_quality"].apply(classify_completeness)

    # Groupement
    count_df = df_clean.groupby(["ecosystem", "completeness_status"]).size().reset_index(name="count")

    # Calcul des pourcentages par écosystème
    count_df["percentage"] = count_df.groupby("ecosystem")["count"].transform(lambda x: x / x.sum() * 100)

    # Pivot pour le barplot
    pivot_df = count_df.pivot(index="ecosystem", columns="completeness_status", values="percentage").fillna(0)

    # S'assurer des colonnes
    for col in ["Complete", "Incomplete"]:
        if col not in pivot_df.columns:
            pivot_df[col] = 0

    pivot_df = pivot_df[["Complete", "Incomplete"]]

    # Plot en % (pourcentage)
    pivot_df.plot(
        kind="bar",
        stacked=True,
        figsize=(12, 6),
        color={
            "Complete": "#1E90FF",   # Bleu
            "Incomplete": "#FFA500"  # Orange
        }
    )

    plt.ylabel("Proportion (%)")
    plt.title("Proportion de virus complets vs incomplets par écosystème")
    plt.xticks(rotation=45, ha="right")
    plt.legend(title="Statut de complétude")
    plt.tight_layout()
    plt.savefig(f"{out}/completeness_viruses_stacked_barplot_percentage.svg", dpi=300)
    plt.savefig(f"{out}/completeness_viruses_stacked_barplot_percentage.png", dpi=300)

    plt.close()


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


    plot_completion_proportion(data, out)
