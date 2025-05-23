# Description

To predict the AMGs from the other viral proteins, the script module_04/eggmapper/bin/AMG_prediction.slurm uses a list of 
KEGG Ontology (module_04/eggmapper/data/VIBRANT_AMGs.tsv). This list of KO is from the viral prediction tool [VIBRANT](https://github.com/AnantharamanLab/VIBRANT).

Indeed, this viral prediction tool can also predict the AMGs. The authors defines a list of KO that can be associated with AMGs if a gene
present in a viral sequence has one of these KOs.

So here is the methodology for the module_04 :
- We predict the viral proteins, thanks to [Prodigal](https://github.com/hyattpd/Prodigal). 
- We annote the predicted proteins thanks to [eggNOGmapper](https://github.com/eggnogdb/eggnog-mapper).
- We filter the annotations (e-value > 0.001).
- We select the predicted proteins with KOs that matches with the KO list from VIBRANT.

The final selected proteins are the potential AMGs. 
