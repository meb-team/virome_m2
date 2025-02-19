#!/usr/bin/env python3

import pandas as pd
import numpy as np
import os
import seaborn as sns
import matplotlib.pyplot as plt

# 🔹 Charger le fichier TSV avec les indices de Jaccard
input_file = "module_03/results/jaccard_beta.tsv"  # Remplace par ton fichier
df = pd.read_csv(input_file, sep="\t")

# 🔹 Vérifier que la colonne "Jaccard" est bien présente
if "Jaccard" not in df.columns:
    raise ValueError("Le fichier TSV ne contient pas de colonne 'Jaccard'. Vérifie le format !")

# 🔹 Extraire la liste unique des écosystèmes
ecosystems = sorted(set(df["Ecosystem1"]).union(set(df["Ecosystem2"])))

# 🔹 Créer une matrice vide remplie de NaN
jaccard_matrix = pd.DataFrame(np.nan, index=ecosystems, columns=ecosystems)

# 🔹 Remplir la matrice avec les valeurs de Jaccard
for _, row in df.iterrows():
    eco1, eco2, jaccard_value = row["Ecosystem1"], row["Ecosystem2"], row["Jaccard"]
    jaccard_matrix.loc[eco1, eco2] = jaccard_value
    jaccard_matrix.loc[eco2, eco1] = jaccard_value  # La matrice est symétrique

# 🔹 Remplir la diagonale avec 1 (Jaccard avec lui-même)
np.fill_diagonal(jaccard_matrix.values, 1.0)

# 🔹 Afficher la matrice (optionnel)
print("\nMatrice de similarité Jaccard :\n", jaccard_matrix)

# 🔹 Tracer la heatmap avec Seaborn
plt.figure(figsize=(8, 6))
sns.heatmap(jaccard_matrix, annot=True, cmap="coolwarm", fmt=".2f", linewidths=0.5)
plt.title("Matrice de Similarité Jaccard")
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)
plt.tight_layout()

# 🔹 Sauvegarde la figure (optionnel)
plt.savefig("module_03/figure/jaccard_heatmap.png", dpi=300)
