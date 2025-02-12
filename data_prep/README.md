# Collecting data from multi-run viral predictions

## Description

In the bin/ folder you can retrieve a script that aims to collect all the predicted viral sequences in fasta format.
This script collects all the output fasta from the different viral prediction tools (here : DeepVirFinder, VirSorter2, VIBRANT).

⚠️  THIS SCRIPT ONLY WORKS ON THE OUTPUTS FROM THE THREE TOOLS USED IN THIS PROJECT ! ⚠️

This script works on different ecosystem analysis. Make sure you have this kind of path : /tools/ecosystems/runs

At the end, you will have one fasta file for each tool for each ecosytem. If you already have these kind of files, you don't need to use this script and you can read
the next step written on the main README.

## Usage

Make sure you are in the current repository.
I suggest you to run the script on a HPC. 

If you are not working on a HPC : 
```bash
chmod +x data_prep/bin/data_prep/bin/merge_prediction.sh
./data_prep/bin/merge_prediction.sh
./data_prep/bin/doublons_verif.sh
```

If you are working on a HPC :
```bash
in buidling...
```

## Requirements 


You need to have the assembling data stocked somewhere before run the script. To explore the DeepVirFinder results we need to associate the
contig IDs to their sequence (the sequences are not given as a result of the tool).

So, make sure you have seqtk installed on your machine. If not :
```bash
git clone https://github.com/lh3/seqtk.git;
cd seqtk; make
```

Maybe you will have to modify the different paths in the script.

## Results

You should have a results folder. Inside you should have three folders corresponding to the three prediction tools (vs2, dvf, vibrant).
Inside of each folders, you should have fasta files for each ecosystems corresponding to viral predicted sequences.
You can retrieve a summary plot of the data here : data_prep/figure/.
