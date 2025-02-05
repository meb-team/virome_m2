# MMseq2 informations
MMseqs2 (Many-against-Many sequence searching) is a fast and efficient bioinformatics tool designed for protein and nucleotide 
sequence searches, clustering, and classification. It is widely used for sequence alignment and homology detection because it is
significantly faster and more memory-efficient than BLAST while maintaining similar accuracy.

You can find more information [here](https://github.com/soedinglab/MMseqs2)

# Usage 

During this project I used MMseq2 to cluster the predicted viral contigs from every prediction tools and every ecosystems.
The main goal was to validate or reject contigs by clustering them.

An example of command I used for this project :
```bash
fasta_input="module_01/annotate/results/all_modified_contigs.fasta"
output_dir="module_01/MMSeq2/results"

mmseqs easy-linclust "$fasta_input" "$output_dir/clusterRes" "$output_dir/tmp" --min-seq-id 0.95 -c 0.85 --cov-mode 1
```
- param easy-linclust : linear clustering, scalable with a huge mount of data.
- param --min-seq-id : minimum of % of identity between sequences to cluster them
- param -c : minimum of % of coverage between sequences to cluster them
- param --cov-mod 1 : "greedy" clustering using centroids.

# Results 
As a result, you should have something like that :

```
module_01/MMseq2/results/
├── clusterRes_all_seqs.fasta
├── clusterRes_cluster.tsv
├── clusterRes_rep_seq.fasta
├── tmp/
│   ├── 3056670091281733876/
│   │   ├── clu_h
│   │   ├── clu_h.dbtype
│   │   ├── clu_h.index
│   │   ├── clu.lookup
│   │   ├── clu.source
│   ├── latest

```


