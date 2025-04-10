# 🎈 🎈 🎈 Welcome to the module number three 🎈 🎈 🎈 

This module aims to analyis the data with some statistical perspective and annotations.
You can run this module after running all the other modules, or, you can run this module inside other ones (see usage from other modules_x).

## Requirements

First, you need to be sure that you have run all the module to guarantee an access to all the required data.

Then, you need a conda environment :
```
# If you don't have conda on your machine :

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
source ~/.bashrc

# When you have conda on your machine :

conda env create -f module_03/env/stat.yml
```


## Usage

The **first** analysis is the calculation of ecosystemic indexes such as Shannon, Simpson or Jaccard indexes. 
This will create to table : a table containing Jaccard and Beta indexes and another table with Shannon, alpha and Simpson diversity.
You will also create a matrix of similarity from Jaccard values and to plot the results (Heatmap).

```
sbatch -q fast -p fast module_03/bin/diversity/viral_diversity.slurm
sbatch -p fast -q fast module_03/bin/diversity/visu.slurm

```

The **second** analysis is.. XXXXXXXX
