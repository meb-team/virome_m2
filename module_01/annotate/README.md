# Description of the annotation 

Here we are using a shell code to annotate each contig IDs. Indeed, for each contig IDs we add some informations like 
the ecosystem where they come from. This step is important because we merge all the contigs into 
one fasta file to perform the clustering. This merging could create non-unique contig IDs. Thus, with the annotations, we guarantee that there
will be no issue about non-unique IDs. And, the annotations facilitate the next analysis.
Moreover, we create an other TSV file containing the contigs with their prediction tools. This TSV will be usefull after the clustering.
