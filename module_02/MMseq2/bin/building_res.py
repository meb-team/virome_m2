#!/usr/bin/env python3

import argparse
import pandas as pd
import os


def building_TSV(path):
    columns = ["ID", "Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    data = []

    with open(path, 'r') as f:
        for line in f:
            line = line.rstrip().split("\t")
            taxo_dict = {"ID": line[0], "Domain": "NA", "Kingdom": "NA", "Phylum": "NA", "Class": "NA",
                     "Order": "NA", "Family": "NA", "Genus": "NA", "Species": "NA"}

            for rank in line[-1].split(";"):
                if rank[0] in ["d", "k", "p", "c", "o", "f", "g", "s"]:
                    key = {"d": "Domain", "k": "Kingdom", "p": "Phylum", "c": "Class", "o": "Order",
                       "f": "Family", "g": "Genus", "s": "Species"}[rank[0]]
                    taxo_dict[key] = rank[2:]
            data.append(taxo_dict)

    df = pd.DataFrame(data, columns=columns)

    return df


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the TSV taxo results is located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the rebuilding TSV created can be stored. Usage : -o path folder/", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path="module_02/MMseq2/results/taxo_results.tsv"

    if args.out:
        out = args.out
    else:
        out="module_02/MMseq2/results/"

    if not os.path.exists(out):
        os.makedirs(out)


    data = building_TSV(path)

    data.to_csv(f"{out}/taxo_seeds.tsv", sep="\t", index=False)

    print(f"Job finish ! File created : {out}/taxo_seeds.tsv")
