# 🎈 🎈 🎈 Welcome to the module number one ! 🎈 🎈 🎈 

This first module includes the steps of quality control of the predicted viral contigs. 

First, you need to be sure that you have the correct files. I suggest you to look after the data_prep/ or data_test/ folders.
You should have a result folder like this : 

```
data_test/results/
├── dvf/
│   ├── air_predicted_seq.fa
│   ├── human_predicted_seq.fa
│   └── metalakes_predicted_seq.fa
├── vibrant/
│   ├── air_predicted_seq.fa
│   ├── human_predicted_seq.fa
│   └── metalakes_predicted_seq.fa
└── vs2/
    ├── air_predicted_seq.fa
    ├── human_predicted_seq.fa
    └── metalakes_predicted_seq.fa
```

You will probably have to modify the paths in the scripts.

## Requirements

I suggest you to work on a HPC because this step can take a while...
For this module, you will need of some programs on your machine.

Firstly, Singularity v.3.7.4 is used. I suggest you to read the [documentation](https://docs.sylabs.io/guides/3.0/user-guide/installation.html).

Check if you have Singularity already installed on your machine :
```bash
singularity --version
```
If not :
```bash
sudo apt update
sudo apt install singularity-container
```

Then, you have to install CheckV (v1.0.1) via singularity :
```bash
singularity pull shub://DerrickWood/CheckV
```
## usage

I recommand you to follow the all-in-one steps. This option is running the entire module automatically. Make sure you have snakemake (cf. Requirements).
If you want to look after the different steps you can follow the step-by-step part (you don't need snakemake for this).

### Module all-in-one

faire snakemake XXXXXXXXXXXXXx 

### Module step-by-step

The **first step** is to run the CheckV tool for each fasta file.

If you are not working on a HPC : 
```bash
chmod+x module_01/checkV/bin/qc_checkv.sh
./module_01/checkV/bin/qc_checkv.sh
```

If you are working on a HPC (recommended) :
```bash
In building (slurm)... XXXXXXXXXXXXXXXXXXX
```
The **second step** is to annotate the contigs with their prediction tool, their ecosystems and if they are viruses or proviruses before the clustering. This step is usefull because some contigs could have
the same IDs between prediction tools because the same SSR has been analyzed for the three prediction tools.

No need to work on a slurm script here :
```bash
chmod +x module_01/annotate/bin/annotate.sh
./module_01/annotate/bin/annotate.sh
```
The **third step** is to cluster the different contigs. The MMseq2 tool is used to cluster the annotate sequences.
```bash
chmod +x module_01/MMseq2/bin/clustering.sh
./module_01/MMseq2/bin/clustering.sh
```
The **forth step** is the exploration and the filtration of the clustering results. At the end, only clusters with contigs predicted by at least 2 different prediction tools will
be keep for the next  analysis. 
```
chmod +x module_01/filtering/bin/filtering.py
./module_01/filtering/bin/filtering.py
```

## Computational analysis 
This computational analysis has been performed on the subdataset created by the data_test/ folder. This dataset is containing approximately 180,000 contigs.
The total volume of input data was 1.5 Go. 

Here are the results collected working with shell (no HPC) : 
1. CheckV : time : around 6 hours (number of CPUs used here : 16). For a 1.5Go of inputs, the total volume of the outputs is 20Go.
2. MMseq2 : time : around 40 s for a 1.4Go of inputs corresponding of the test dataset.

Here are the results collected working with HPC :
1. XXXXXXXX
2. XXXXXXXX


