# Welcome to the module number one ! 🎈 🎈 🎈 

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

You probably will have to modify the paths in the scripts.

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
The **second step** is ..


## Computational analysis 
This computational analysis has been performed on the subdataset created by the data_test/ folder/
The total volume of input data was 2.5 Go. 

1. CheckV : time : XXXXXX (number of CPUs used here : 16). For a 2.5Go of inputs, the volume of the output is XXXXXX.
2. XXXXX

## Results 

XXXXXXXXXXXx

