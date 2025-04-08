# 🎈 🎈 🎈 Welcome to the module number four ! 🎈 🎈 🎈

## Requirements

Firstly, to use Dram-v, you have to create a conda environment and download the dependencies.
You can find more informations about Dram-v [here](https://github.com/WrightonLabCSU/DRAM).
```
singularity pull docker://quay.io/biocontainers/dram:1.5.0--pyhdfd78af_0
```

To use DRAM-v and to be able to predict AMGs you have to make sure you ran VirSorter2 with the correct option : 
If you didn't, i suggere you to follow the **zero** step here. This step will reprocess the seeds of each ecosystem with virsorter2 and keep only the
interesting file for DRAM-v. The other prediction files will be deleted. To perform this step, you need a conda version of VirSorter2 : virsorter run --prep-for-dramv -w test.out -i test.fa -j 4 all
```
conda create -n vs2 -c conda-forge -c bioconda virsorter=2
```

Once you have this conda environment, you can follow the **zero** step in the Usage section.
If you already have the required files, you can pass the **zero** step but you have to make sure that the path to the
vs2 annotation for dram-v is correct in the sbatch module_04/dramv/bin/dram_annot.slurm script.

## Usage
The **zero** step is to reprocess the seeds with the correct option of VirSorter2 to have required file for AMGs prediction.
So, firstly you need to download the vs2 database.
```
sbatch -p fast -q fast module_04/dramv/bin/install_vs2.slurm
```

Once the database is correctly installed. You can re-run the seeds for each ecosystem with VirSorter2 to have the required file for DRAM-v
```
sbatch module_04/dramv/bin/vs2.slurm
```

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
