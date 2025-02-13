# Welcome to the MMseq2 part !
Here you can find some informations about what we are actually performing here.

If you want more information about MMseq2, click (here)[https://github.com/soedinglab/MMseqs2].
## Database creation
The first step is to create a viral database. Here, we use the RefSeq NCBI database as reference. 
You can find the script here : module_02/MMseq2/bin/crea_db.sh

To create this database, the MMseq2 tool is used.
At the end, you would have this folder as results of the database (not provided on GitHub) :
```
module_02/MMseq2/taxonomy/
├── mmseqs_vrefseq
│   ├── refseq_viral
│   ├── refseq_viral.dbtype
│   ├── refseq_viral.faa
│   ├── refseq_viral_h
│   ├── refseq_viral_h.dbtype
│   ├── refseq_viral_h.index
│   ├── refseq_viral.idx
│   ├── refseq_viral.idx.dbtype
│   ├── refseq_viral.index
│   ├── refseq_viral.lookup
│   ├── refseq_viral_mapping
│   ├── refseq_viral_names.dmp
│   ├── refseq_viral_nodes.dmp
│   ├── refseq_viral_merged.dmp
│   ├── refseq_viral.source
│   ├── refseq_viral_taxonomy
│   └── refseq_viral_delnodes.dmp
├── taxdump
│   ├── delnodes.dmp
│   ├── merged.dmp
│   ├── names.dmp
│   └── nodes.dmp
```

## Collect fasta sequences
Here, we are collecting the fasta sequences related to the contigs identified as representative at the end of the module_01.
Each representative contigs (named 'seeds') are associated with their fasta sequence. A single fasta file is created at the end of the script.
You can find the script here : module_02/MMseq2/bin/tax_fasta.sh
The final file is named *'tax_fasta_seed.fa'*.

## Taxonomic annotations
In this part, we are using the Refseq database and the *'tax_fasta_seed.fa'* fasta file previously created to perform a taxonomic annotations of the sequences.
The Last Common Ancestor (LCA) is the method used to retrieve taxonomy with MMseq2.
At the end, you would have this folder as taxonomic results :

XXXXXXXX

## Data mining

XXXX


