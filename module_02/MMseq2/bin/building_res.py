#!/usr/bin/env python3

import argparse



import pandas as pd

# Chargement du fichier d'entrée
input_taxo = "input_taxo.tsv"  # Fichier source
output_taxo = "output_taxo.tsv"  # Fichier de sortie

# Définition des colonnes taxonomiques
columns = ["ID", "Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]

# Initialisation d'une liste pour stocker les résultats
data = []

# Lecture et traitement du fichier
with open(input_taxo, 'r') as f:
    for line in f:
        line = line.rstrip().split("\t")  # Séparation des colonnes du TSV
        taxo_dict = {"ID": line[0], "Domain": "NA", "Kingdom": "NA", "Phylum": "NA", "Class": "NA", 
                     "Order": "NA", "Family": "NA", "Genus": "NA", "Species": "NA"}  # Valeurs par défaut
        
        # Traitement de la classification taxonomique
        for rank in line[-1].split(";"):
            if rank[0] in ["d", "k", "p", "c", "o", "f", "g", "s"]:  # Vérifie si le préfixe est valide
                key = {"d": "Domain", "k": "Kingdom", "p": "Phylum", "c": "Class", "o": "Order", 
                       "f": "Family", "g": "Genus", "s": "Species"}[rank[0]]  # Conversion en colonne DataFrame
                taxo_dict[key] = rank[2:]  # Extraction du nom taxonomique
        
        data.append(taxo_dict)  # Ajout de la ligne à la liste

# Création du DataFrame
df = pd.DataFrame(data, columns=columns)

# Sauvegarde en TSV
df.to_csv(output_taxo, sep="\t", index=False)

print(f"✅ Fichier généré : {output_taxo}")










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
