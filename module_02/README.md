premiere étape : création de la base de données refseq viral avec mmseq2 (script module_02/MMseq2/bin/crea_db.sh)

deuxième étape : rassembler tous les contigs représentatifs isolés au module d'avant dans un fichier fasta (module_02/MMseq2/bin/tax_fasta.sh).
etape longue donc recommandation slurm HPC parallélisation

troisième étape : annotation taxonomique


# 🎈 🎈 🎈 Welcome to the module number two ! 🎈 🎈 🎈 

This second module includes the assignement of viral taxonomy for representative contigs of each cluster (cf. module_01).. 

XXXXXXXX Mettre schéma XXXXXXX

## Requirements

First, you need to be sure that you have run the first module (module_01) to have a full access to data.

You will probably have to modify the paths in the scripts.


I suggest you to work on a HPC because this step can take a while...
For this module, you will need of some programs on your machine.

We are using (MMseqs2)[https://github.com/soedinglab/MMseqs2] Version: 24479bc27c3f33a3c0121f916038c605beef3e79.
```
# install by brew
brew install mmseqs2
# install via conda
conda install -c conda-forge -c bioconda mmseqs2
# install docker
docker pull ghcr.io/soedinglab/mmseqs2
# MMseqs2-GPU mostly-static AVX2 build requiring glibc >= 2.29 and nvidia driver >=525.60.13 (see below)
wget https://mmseqs.com/latest/mmseqs-linux-gpu.tar.gz; tar xvfz mmseqs-linux-gpu.tar.gz; export PATH=$(pwd)/mmseqs/bin/:$PATH
# static build with AVX2 (fastest)
wget https://mmseqs.com/latest/mmseqs-linux-avx2.tar.gz; tar xvfz mmseqs-linux-avx2.tar.gz; export PATH=$(pwd)/mmseqs/bin/:$PATH
# static build with SSE4.1
wget https://mmseqs.com/latest/mmseqs-linux-sse41.tar.gz; tar xvfz mmseqs-linux-sse41.tar.gz; export PATH=$(pwd)/mmseqs/bin/:$PATH
# static build with SSE2 (slowest, for very old systems)
wget https://mmseqs.com/latest/mmseqs-linux-sse2.tar.gz; tar xvfz mmseqs-linux-sse2.tar.gz; export PATH=$(pwd)/mmseqs/bin/:$PATH
```

I recommend you to have snakemake on your machine to run the pipeline automatically.
```
# If you don't have conda on your machine :
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
source ~/.bashrc

# When you have conda on your machine :
conda create -c conda-forge -n snakemake snakemake
conda activate snakemake
```
## Usage

I recommand you to follow the all-in-one steps. This option is running the entire module automatically. Make sure you have snakemake (cf. Requirements).
If you want to look after the different steps you can follow the step-by-step part (you don't need snakemake for this).

### Module all-in-one

faire snakemake XXXXXXXXXXXXXx 

### Module step-by-step

XXXXXXXXX
