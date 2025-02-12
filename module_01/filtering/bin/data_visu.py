#!/usr/bin/env python3

import argparse
from collections import Counter
import matplotlib.pyplot as plt
import os
import pandas as pd
import seaborn


def quality(file, out, test):
    """
    Function to create a barplot of the different quality categories from CheckV analysis.

    :param file_quality : the path to the TSV file containing the data.
    :param eco : the ecosytem results processed
    :param tool : the predicted tool results processed
    :param out : the path where the figure will be saved
    :return : None
    """

    df_quality = pd.read_csv(file, sep="\t", header=0)

    Lorder=["Complete","High-quality","Medium-quality","Low-quality","Not-determined"]
    Lcolor=["#07ce04","#8ffa37","#fffb00","#ff8513","#d4d4d4"]

    seaborn.set_style("whitegrid")
    plt.figure(figsize=(10,6))
    seaborn.countplot(x="checkv_quality",data=df_quality,order=Lorder,palette=Lcolor)

    if test==True:
        plt.savefig(f"{out}/quality_summary.png",format='png')
    elif not test:
        plt.savefig(f"{out}/filtered_quality_summary.png",format='png')
    else:
        print("ERROR ???")

    return None



def prophage_quality(file, out, test):
    """
    Function to create a barplot of the different quality categories from CheckV analysis,
    separating the data into provirus and other categories.

    :param file: The path to the TSV file containing the data.
    :param out: The path where the figure will be saved.
    :return: None
    """
    df_quality = pd.read_csv(file, sep="\t", header=0)

    df_quality['provirus_seed'] = df_quality['provirus_seed'].astype(str)

    Lorder = ["Complete", "High-quality", "Medium-quality", "Low-quality", "Not-determined"]
    Lcolor = ["#07ce04", "#8ffa37", "#fffb00", "#ff8513", "#d4d4d4"]

    plt.figure(figsize=(12, 6))

    seaborn.countplot(x="checkv_quality", data=df_quality, order=Lorder, palette=Lcolor, hue="provirus_seed")

    plt.legend(title="Provirus Seed", loc="upper left")
    plt.xlabel("Quality Categories")
    plt.ylabel("Count")
    plt.title("Distribution of Quality Categories (Provirus vs Non-provirus)")

    plt.tight_layout()

    if test==True:
        plt.savefig(f"{out}/quality_summary_provirus.png", format='png')
    elif not test:
        plt.savefig(f"{out}/filtered_quality_summary_provirus.png", format='png')
    else:
        print("ERROR ???")

    return None



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the TSV file located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -o path folder/", type=str)
    parser.add_argument("--fpath", "-fp", help="Defines the path where the filtered TSV file is located. Usage : -fp path/folder", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path="module_01/filtering/results/representative_cluster.tsv"

    if args.fpath:
        fpath = args.fpath
    else:
        fpath="module_01/filtering/results/filtered_representative_cluster.tsv"

    if args.out:
        out = args.out
    else:
        out="module_01/filtering/figure"

    if not os.path.exists(out):
        os.makedirs(out)

    print("Start the visualizations for quality...")

    test=True
    quality(path, out, test)
    prophage_quality(path, out, test)
    test=False
    quality(fpath, out, test)
    prophage_quality(fpath, out, test)

    print("Job finish : figure created !")
