#!/usr/bin/env python3

import argparse
import os
import pandas as pd
from collections import defaultdict


def parse_imgvr_taxo_file(imgvr_path):
    taxo_dict = {}
    df = pd.read_csv(imgvr_path, sep='\t', low_memory=False)
    for _, row in df.iterrows():
        uid = row['UVIG']
        if pd.notna(row['Taxonomic classification']):
            taxo_str = row['Taxonomic classification']
            taxo_parts = taxo_str.split(';')
            taxo_parts = [x.split('__')[1] if '__' in x else 'NA' for x in taxo_parts]
            while len(taxo_parts) < 8:
                taxo_parts.append('NA')
            taxo_dict[uid] = taxo_parts[:8]  # Domain to Species
    return taxo_dict


def parse_paf_file(paf_path):
    matches = defaultdict(list)
    with open(paf_path, 'r') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) < 12:
                continue
            query = parts[0]  # IMG/VR UID (e.g., IMGVR_UViG_...) 
            target = parts[5]  # your contig ID
            tags = parts[12:]
            score = 0
            for tag in tags:
                if tag.startswith('s1:i:'):
                    try:
                        score = int(tag.split(':')[-1])
                    except ValueError:
                        pass
                    break
            matches[target].append((query, score))
    return matches


def select_best_matches(paf_matches):
    best_matches = {}
    for contig, hits in paf_matches.items():
        if not hits:
            continue
        best_hit = max(hits, key=lambda x: x[1])
        best_matches[contig] = best_hit[0]
    return best_matches


def update_tsv(tsv_path, best_matches, img_taxo_dict):
    df = pd.read_csv(tsv_path, sep='\t', low_memory=False)
    taxo_columns = ["Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"]
    updated = 0

    for i, row in df.iterrows():
        if row["Domain"] == "NA" or all(row[col] == "NA" for col in taxo_columns):
            contig = row["ID"]
            if contig in best_matches:
                imgvr_uid = best_matches[contig]
                if imgvr_uid in img_taxo_dict:
                    taxo_values = img_taxo_dict[imgvr_uid]
                    for j, col in enumerate(taxo_columns):
                        df.at[i, col] = taxo_values[j]
                    updated += 1

    return df, updated


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="This script updates MMseq2 taxonomy info using IMG/VR alignments.")

    parser.add_argument("--path", "-p", required=True, type=str,
                        help="Path to TSV folders per ecosystem.")
    parser.add_argument("--out", "-o", required=True, type=str,
                        help="Output folder for updated TSVs.")
    parser.add_argument("--minimap", "-m", required=True, type=str,
                        help="Path to minimap2 result folders per ecosystem.")
    parser.add_argument("--imgvr", "-i", required=True, type=str,
                        help="Path to IMG/VR taxonomy .tsv file.")

    args = parser.parse_args()

    img_taxo_dict = parse_imgvr_taxo_file(args.imgvr)

    for ecosystem in os.listdir(args.path):
        eco_path = os.path.join(args.path, ecosystem)
        print("AAAAAAA", eco_path)
        if not os.path.isdir(eco_path):
            print("PROBLEM")
            continue

        tsv_filename = f"{ecosystem}_taxo_seeds.tsv"
        tsv_path = os.path.join(eco_path, tsv_filename)
        print("BBBBBBB", tsv_path)
        if not os.path.exists(tsv_path):
            print(f"\u274c TSV not found for ecosystem {ecosystem}, skipping...")
            continue

        paf_folder = os.path.join(args.minimap, ecosystem)
        paf_matches = defaultdict(list)

        if os.path.isdir(paf_folder):
            for file in os.listdir(paf_folder):
                if file.endswith(".paf"):
                    paf_path = os.path.join(paf_folder, file)
                    for k, v in parse_paf_file(paf_path).items():
                        paf_matches[k].extend(v)

        best_matches = select_best_matches(paf_matches)
        updated_df, updated_count = update_tsv(tsv_path, best_matches, img_taxo_dict)
        print(updated_df)

        os.makedirs(os.path.join(args.out, ecosystem), exist_ok=True)
        output_path = os.path.join(args.out, ecosystem, tsv_filename)
        updated_df.to_csv(output_path, sep='\t', index=False)

        print(f"\u2705 {ecosystem}: {updated_count} ligne(s) mise(s) à jour -> {output_path}")
