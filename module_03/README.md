# 🎈 🎈 🎈 Welcome to the module number three (optionnal ! 🎈 🎈 🎈 

This third module creates tables with ecosystemic informations such as Shannon, Simpson, Jaccard, alpha and beta (Bray-Curtis) indexes.

## Requirements

First, you need to be sure that you have run the seconde (module_02) to have a full access to data.

Then, you need a conda environment :
```
# If you don't have conda on your machine :

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
source ~/.bashrc

# When you have conda on your machine :

conda env create -f module_03/env/diversity.yml
```


## Usage

I recommand you to follow the all-in-one steps. This option is running the entire module automatically. Make sure you have snakemake (cf. Requirements).
If you want to look after the different steps you can follow the step-by-step part (you don't need snakemake for this).

### Module all-in-one

faire snakemake XXXXXXXXXXXXXx 

### Module step-by-step

The **first** step is to create the tables containing all results of the indexes for each ecosystems.
```
./module_03/bin/viral_diversity.py
sbatch -q fast -p fast module_03/bin/viral_diversity.slurm # HPC ONLY
```
This will create to table : a table containing Jaccard and Beta indexes and another table with Shannon, alpha and Simpson diversity.
You can retrieve the results here : module_03/results

The **seconde** step is to create a matrix of similarity from Jaccard values and to plot the results (Heatmap).
```
./module_03/bin/visu.py
```
The plot is availaible here : module_03/figure

