# 🎈 🎈 🎈 Welcome to the module number four ! 🎈 🎈 🎈

## Requirements

Firstly, to use Dram-v, you have to create a conda environment and download the dependencies.
You can find more informations about Dram-v [here](https://github.com/WrightonLabCSU/DRAM).
```
singularity pull docker://quay.io/biocontainers/dram:1.5.0--pyhdfd78af_0
```

## Usage
The first **step** is to create the databases for Dram-v (KEGG, PFAM, dbscan, RefSeq Viral, VOGDB and MEROPS).
This step can consume a lot of RAMs and CPUs. More information [here](https://github.com/WrightonLabCSU/DRAM).
If you are working on a HPC (recommended) :
```
sbatch module_04/dramv/bin/install_db.slurm
```

The **second** step is to run DRAM-v annotations for your viral contigs !
You should work on a HPC :
```
sbatch module_04/dramv/bin/dram_annot.slurm
```
