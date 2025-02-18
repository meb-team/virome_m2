#!/usr/bin/env python3

import argparse
import pandas as pd
import os
import glob


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
        description="This script processes multiple TSV files from CheckV analysis results.")

    parser.add_argument("--input_dir", "-i", help="Path to the folder containing TSV files. Default: module_02/MMseq2/results/biome_taxo/", type=str, default="module_02/MMseq2/results/biome_taxo/")
    parser.add_argument("--output_dir", "-o", help="Path to the output folder. Default: module_02/MMseq2/results/", type=str, default="module_02/MMseq2/results/rebuild_taxo")

    args = parser.parse_args()

    input_dir = args.input_dir
    output_dir = args.output_dir

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    tsv_files = glob.glob(os.path.join(input_dir, "*.tsv"))

    if not tsv_files:
        print(f"No file .tsv found here :  {input_dir}")
    else:
        for file_path in tsv_files:
            file_name = os.path.basename(file_path)
            prefix = file_name.split("_")[0]
            output_file = os.path.join(output_dir, f"{prefix}_taxo_seeds.tsv")

            print(f"Processing {file_path} → {output_file}")

            data = building_TSV(file_path)
            data.to_csv(output_file, sep="\t", index=False)

        print("Job done  !")
