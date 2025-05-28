# 🎈 🎈 🎈 Welcome to the module number four ! 🎈 🎈 🎈

In this module, you are going to do some functionnal annotations of your vOTU sequences and you will predict the Auxilliary Metabolic Genes !

<p align="center">
  <img src="img/module_04.svg" alt="Description" width="60%">
</p>

## Requirements
To perform the functionnal annotation, we are using the eggNOGmapper tool. You can find more information [here](https://github.com/eggnogdb/eggnog-mapper/).
To use this tool, you need to install the conda environment : 

```
conda env create -f module_04/env/eggmapper.yml
```

You will need the fasta files of your vOTU sequences, created in module_02 : 
```
module_02/
    └── MMseq2/
        └── results/
            └── eco_fasta/
                ├── eco1_tax_fasta_seed.fa
                ├── eco2_tax_fasta_seed.fa
                ├── eco3_tax_fasta_seed.fa
                ├── eco4_tax_fasta_seed.fa
```

## Usage
#### The **first** step is to perform a protein prediction of your vOTU sequences.
This step using Prodigual [tool](https://github.com/hyattpd/Prodigal).
```
sbatch module_04/prodigal/bin/prot_prediction.slurm
```
#### The **second** step is do the functionnal annotation.
You need to install the database used by eggNOGmapper
```
sbatch module_04/eggmapper/bin/install_db.slurm
```
Then, you can use the tool to do the annotation :
```
sbatch module_04/eggmapper/bin/run_eggmapper.slurm
```
#### The **Third** step is to collect the AMG from the annotations
```
sbatch module_04/eggmapper/bin/AMG_prediction.slurm
```


## Results

At the end of this module, you will have a TSV file containing 20 columns for AMGs annotations and metadata.
Here is an example of the output file (details of the columns are below) :
| query                  | seed_ortholog           | evalue      | score | eggNOG_OGs                                                                                                                                                                                                                               | max_annot_lvl | COG_category | Description                                                                                                   | Preferred_name | GOs                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | EC               | KEGG_ko                     | KEGG_Pathway                                                                                                                                                                              | KEGG_Module | KEGG_Reaction                                          | KEGG_rclass                                      | BRITE                                        | KEGG_TC | CAZy | BiGG_Reaction | PFAMs                          | ecosystem |
|------------------------|-------------------------|-------------|-------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------------|-----------------------------------------------------------------------------------------------------------------------------|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|---------------------------------------------------------|--------------------------------------------------|----------------------------------------------|---------|------|----------------|----------------------------------|-----------|
| SRR10613493_39709_30   | 53485.EFQ93610          | 7.82e-107   | 313.0 | COG3265@1root,KOG3354@2759 Eukaryota,...                                                                                                                                                                       | Fungi          | F             | Belongs to the gluconokinase GntK GntV family                                                                |                |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | 2.7.1.12         | ko:K00851                   | ko00030,ko01100,ko01110,ko01120,ko01130,ko01200,...                                                                                             |              | R01737                                                 | RC00002,RC00017                                  | ko00000,ko00001,ko01000                      |         |      |                | AAA_18,AAA_33,SKI               | air       |
| SRR10613493_39709_33   | 5016.M2T123             | 5.59e-247   | 689.0 | COG1597@1root,KOG1116@2759 Eukaryota,...                                                                                                                                                                       | Fungi          | IT            | Diacylglycerol kinase catalytic domain (presumed)                                                           | LCB4           | GO:0003674,GO:0003824,...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | 2.7.1.91         | ko:K04718                   | ko00600,ko01100,ko04020,ko04071,...                                                                                                               | M00100       | R01926,R02976                                         | RC00002,RC00017                                  | ko00000,ko00001,ko00002,ko01000              |         |      |                | DAGK_cat                       | air       |
| MCMSL336390_3_1        | 50452.W0USQ7            | 0.0         | 931.0 | 28ISP@1root,2QR3X@2759 Eukaryota,...                                                                                                                                                                             | Streptophyta   | C             | Core component of PSII, binds chlorophyll, catalyzes photochemical processes                              | psbC           | GO:0005575,GO:0005622,...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |                  | ko:K02705                   | ko00195,ko01100,map00195,map01100                                                                                                                 | M00161       |                                                         |                                                  | ko00000,ko00001,ko00002,ko00194              |         |      |                | PSII                           | urban     |
| SRR10613565_536045_1   | 53485.EFQ90134          | 4.19e-240   | 670.0 | COG1012@1root,KOG2455@2759 Eukaryota,...                                                                                                                                                                      | Fungi          | E             | Belongs to the aldehyde dehydrogenase family                                                                | PUT2           | GO:0003674,GO:0003824,...                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | 1.2.1.88         | ko:K00294                   | ko00250,ko00330,ko01100,map00250,map00330,map01100                                                                                                |              | R00245,R00707,R00708,...                              | RC00080,RC00216,RC00242,RC00255                 | ko00000,ko00001,ko01000                      |         |      |                | Aldedh                         | air       |

- Query : Name of the protein (SRR_contig_prot)
- seed_ortholog : Ortholog hit for the query from the eggNOGmapper database
- evalue
- score 
- eggNOG_OGs : A comma-separated, clade depth-sorted (broadest to narrowest), list of Orthologous Groups (OGs) identified for this query. Note that each OG is represented in the following format: OG@tax_id|tax_name
- max_annot_lvl : Tax_name of the level of widest OG used to retrieve orthologs for annotations.
- COG_category : COG category of the narrowest OG with a valid one.
- Description : Description of the narrowest OG with a valid one.
- Preferred_name : Name of the protein.
- GOs
- EC
- KEGG_ko
- KEGG_Pathway
- KEGG_Module
- KEGG_Reaction
- KEGG_rclass
- BRITE
- KEGG_TC
- CAZy
- BiGG_Reaction
- PFAMs
- ecosystem
