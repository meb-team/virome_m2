#!/usr/bin/env python3


import argparse
import matplotlib.pyplot as plt
import os
import pandas as pd
import seaborn


def visual(file_quality, eco, tool, out)
    """
    Function to create a barplot of the different quality categories from CheckV analysis.

    :param file_quality : the path to the TSV file containing the data.
    :param eco : the ecosytem results processed
    :param tool : the predicted tool results processed 
    :param out : the path where the figure will be saved
    :return : None
    """

    df_quality = pd.read_csv(file_quality, sep="\t", header=None)"

    Lorder=["Complete","High-quality","Medium-quality","Low-quality","Not-determined"]
    Lcolor=["#07ce04","#8ffa37","#fffb00","#ff8513","#d4d4d4"]

    seaborn.set_style("whitegrid")
    plt.figure(figsize=(10,6))
    seaborn.countplot(x=1,data=df_quality,order=Lorder,palette=Lcolor)
    plt.savefig(f"{out}/{eco}_{tool}.png",format='png')



def parse_data(path, pathout)
    if not os.path.exists(pathout):
        os.makedirs(pathout)



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the report  are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -o path folder/", type=str)

    args = parser.parse_args()

    path = args.path
    out = args.out
    path="module_01/checkV/results"
    out="module_01/checkV/figure"
