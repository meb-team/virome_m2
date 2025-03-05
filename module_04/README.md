#🎈 🎈 🎈 Welcome to the module number four ! 🎈 🎈 🎈

## Requirements

Firstly, to use Dram-v, you have to create a conda environment and download the dependencies.
You can find more informations about Dram-v [here](https://github.com/WrightonLabCSU/DRAM).

If you don't have conda :
```
mkdir -p miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3/miniconda.sh
bash miniconda3/miniconda.sh -b -u -p miniconda3
rm miniconda3/miniconda.sh
source miniconda3/bin/activate 
```

When you have conda on your machine :
```
wget https://raw.githubusercontent.com/WrightonLabCSU/DRAM/master/environment.yaml
conda env create -f environment.yaml -n DRAM
```

## Usage
The first **step** is to create the databases for Dram-v (KEGG, UniRef90, PFAM, dbscan, RefSeq Viral, VOGDB and MEROPS).
This step can consume a lot of RAMs and CPUs. More information [here](https://github.com/WrightonLabCSU/DRAM).
If you are working on a HPC (recommended) :
```
sbatch module_04/dramv/bin/install_db.slurm
```
