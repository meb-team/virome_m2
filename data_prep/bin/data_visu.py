#!/usr/bin/env python3

import argparse
import matplotlib.pyplot as plt
import numpy as np
import os
import subprocess



def count(path):
    """
    Function to retrieve the different number of contigs per tools per ecosystems.

    :param path : the path to the results folder created by data_prep/ or data_test/
    :return count : a dictionnary containing all the counts.
    """
    count = {}
    tool_list = ['dvf', 'vibrant', 'vs2']

    for tool in tool_list:
        res = subprocess.run(["ls", path+"/"+tool], capture_output=True, text=True)
        eco_list=[]
        re=res.stdout.split()

        for e in re:
            eco=e.split('_')[0]
            eco_list.append(eco)
            cat = subprocess.Popen([f'cat {path}/{tool}/{eco}_*'], stdout=subprocess.PIPE, shell=True)
            grep = subprocess.Popen(['grep', '>'], stdin=cat.stdout, stdout=subprocess.PIPE)
            wc = subprocess.Popen(['wc', '-l'], stdin=grep.stdout, stdout=subprocess.PIPE)

            output = wc.communicate()[0]
            nb = output.decode().strip()

            if eco not in count:
                count[eco] = {}
            count[eco][tool] = nb

    return count



def visual(contig_count, pathout):
    """
    Function to create a barplot of the different counts of predicted contigs per tools per ecosystems.

    :param contig_count : a dictionnary of dictionnary {Ecosystem1 : { Tool1 : count, Tool2 : count}}
    :param pathout : the path where the figure will be saved
    :return : None
    """

    if not os.path.exists("data_prep/figure"):
        os.makedirs("data_prep/figure")

    ecosystems = list(contig_count.keys())
    tools = list(next(iter(contig_count.values())).keys())

    colors = {'dvf': '#6A5ACD', 'vibrant': '#FFB347', 'vs2': '#2E8B57'}

    fig, ax = plt.subplots(figsize=(10, 6))
    bar_width = 0.2
    index = np.arange(len(ecosystems))

    for i, tool in enumerate(tools):
        counts = [int(contig_count[ecosystem][tool]) for ecosystem in ecosystems]
        ax.bar(index + i * bar_width, counts, bar_width, label=tool, color=colors[tool], edgecolor='black', alpha=0.85)

    ax.set_xlabel('Ecosystems', fontsize=12, fontweight='bold')
    ax.set_ylabel('Number of predicted viral contigs', fontsize=12, fontweight='bold')
    ax.set_title('Comparison of the number of contigs per tools per ecosystems.', fontsize=14, fontweight='bold')

    ax.set_xticks(index + bar_width * (len(tools) / 2))
    ax.set_xticklabels(ecosystems, fontsize=11)

    ax.legend(title='Tools', fontsize=11, title_fontsize=12)

    ax.set_ylim(0, max(sum(([int(contig_count[eco][t]) for t in tools] for eco in ecosystems), [])) * 1.1)

    ax.yaxis.grid(True, linestyle='--', alpha=0.7)

    plt.tight_layout()
    plt.savefig(f'{pathout}/ecosystem_comparison.png', format='png')

    return None


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the contigs predicted by the prediction tools.""")

    parser.add_argument("--path", "-p", help="Defines the path where the data are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -o path folder/", type=str)

    args = parser.parse_args()

    pathin = args.path
    pathout = args.out

    print("Start the visualization...")

    nb_contigs = count("data_test/results")
    visual(nb_contigs, pathout)

    print("End of the program. You can see the results here : data_prep/figure")
