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



def visual(contig_count):

    if not os.path.exists("data_prep/figure"):
        subprocess.run(['mkdir', "data_prep/figure"])
    else:
        None

    ecosystems = list(contig_count.keys())
    tools = list(next(iter(contig_count.values())).keys())

    colors = {'dvf': 'blue', 'vibrant': 'orange', 'vs2': 'green'}
    fig, ax = plt.subplots(figsize=(10, 6))
    bar_width = 0.2
    index = np.arange(len(ecosystems))

    for i, tool in enumerate(tools):
        counts = [contig_count[ecosystem][tool] for ecosystem in ecosystems]
        ax.bar(index + i * bar_width, counts, bar_width, label=tool, color=colors[tool])

    ax.set_xlabel('Ecosystems')
    ax.set_ylabel('Number of predicted viral contigs')
    ax.set_title('Comparison of the number of contigs per tools per ecosystems.')
    ax.set_xticks(index + bar_width)
    ax.set_xticklabels(ecosystems)
    ax.legend(title='Tools')

    plt.tight_layout()
    plt.savefig('data_prep/figure/ecosystem_comparison.png', format='png')



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description = """This script aims to create some figures using the contigs predicted by the prediction tools.""")

    parser.add_argument("--path", "-p", help="Defines the path where the data are located. Usage : -p path folder/", type=str)
    parser.add_argument("--out", "-o", help="Defines the path where the figure created can be stored. Usage : -p path folder/", type=str)

    args = parser.parse_args()

    print("Start the visualization..."

    nb_contigs = count("data_test/results")
    visual(nb_contigs)

    print("End of the program. You can see the results here : data_prep/figure")
