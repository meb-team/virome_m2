#!/usr/bin/env python3

import argparse


def parse_file(path):
    Dtaxo = {}
    with open(path, 'r') as f1:
        for lig in f1:
            Dline = {'d': 'NA', 'k': 'NA', 'p': 'NA', 'c': 'NA', 'o': 'NA', 'f': 'NA', 'g': 'NA', 's': 'NA'}
            li = lig.rstrip().split("\t")
            for r in (l[-1].split(";")):
                if r[0] in Dline:
                    Dline[r[0]] = r[2:]
            Dtaxo[l[0]] = Dline
    return Dtaxo


def write_tsv(dict, out):
    with open(f"{out}/test.tsv") as f2:
        f2.write("ID\tDomain\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n")
        for i, j in dict.items():
            f2.write(i)
            for r in ['d', 'k', 'p', 'c', 'o', 'f', 'g', 's']:  # Respect de l'ordre des colonnes
                f2.write(f"\t{j[r]}")
            f2.write("\n") # nouvelle ligne


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the quality reports from CheckV analysis.""")

    parser.add_argument("--path", "-p", help="Defines the path where the TSV taxo results is located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the rebuilding TSV created can be stored. Usage : -o path folder/", type=str)
    parser.add_argument("--file", "-f", help"Defines the path where the TSV containing cluster informations is located. Usage : -f path/to/file", type=str)

    args = parser.parse_args()

    if args.path:
        path = args.path
    else:
        path=""
    if args.file:
        file="module_01/filtering/results/filtered_representative_cluster.tsv"
    if args.out:
        out = args.out
    else:
        out="module_02/MMseq2/results/"
    if not os.path.exists(out):
        os.makedirs(out)
