# Welcome to the MMseq2 part !
Here you can find some informations about what we are actually performing here.

If you want more information about MMseq2, click [here](https://github.com/soedinglab/MMseqs2).
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
At the end, you would have a taxonomic report and a TSV file.


## Data mining

This finale part aims to create a TSV file more readable. Indeed, each columns correspond the classifications for each seeds (representative contigs of clusters).
The TSV is looking like that :
| ID                                      | Domain  | Kingdom         | Phylum       | Class          | Order         | Family        | Genus           | Species                  |
|-----------------------------------------|---------|----------------|--------------|---------------|--------------|--------------|----------------|--------------------------|
| 50m_S10_L004_9350                      | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | Kyanoviridae | NA             | NA                       |
| 10S1_S5_L002_5558                      | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | NA             | NA                       |
| 10S1_S5_L002_5810                      | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | Crassvirales | NA           | NA             | Crassvirales sp.        |
| ZellerG_2014__CCIS45793747ST-4-0.part-1_727 | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | NA             | NA                       |
| 50m_S10_L004_40096                      | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | NA             | NA                       |
| DRR147671_3193                          | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | Kyanoviridae | Bellamyvirus   | Bellamyvirus bellamy    |
| ERR3230155_218241                       | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | NA             | NA                       |
| 3_S1_L001_106                           | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | NA             | Rhodoferax phage P26218 |
| CosteaPI_2017__peacemaker-11-0-0.part-1_105 | Viruses | Heunggongvirae  | Uroviricota  | Caudoviricetes | NA           | NA           | Brigitvirus    | Brigitvirus brigit      |


All the results are from the MMseq2 tool.
You have one TSV file per ecosystem.


