# Collecting test data from multi-run viral predictions to perfom analysis with a subdataset !

## Description

In the bin/ folder you can retrieve a script that aims to collect some of predicted viral sequences in fasta format.
This script collects the output fasta from the different viral prediction tools (here : DeepVirFinder, VirSorter2, VIBRANT).

⚠️  THIS SCRIPT ONLY WORKS ON THE OUTPUTS FROM THE THREE TOOLS USED IN THIS PROJECT ! ⚠️

This script works on different ecosystem analysis. Make sure you have this kind of path : /tools/ecosystems/runs

At the end, you will have one fasta file for each tool for each ecosytem (3 ecosystems here). 

This dataset for running tests has a volume of 2.5Go.

## Usage

Make sure you are in the current repository.

```bash
chmod +x data_test/bin/dataset_test.sh
./data_test/bin/dataset_test.sh
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

'schéma'
