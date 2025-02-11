#!/usr/bin/R
# install.packages("ComplexUpset")

library("ggplot2")
library("ComplexUpset")

file <- read.table("../representative_cluster2.tsv",header=TRUE,sep="\t")
TAB <- file[, c("Representative_contig", "vs2_seed", "vibrant_seed", "dvf_seed", "checkv_quality")]
names(TAB) <- c("Contigs", "VS2", "vibrant", "DVF", "checkV")

tools <- colnames(TAB)[2:4]

TAB[tools]=TAB[tools]==1   #TRUE or FALSE 

upsetplt <-upset(
    TAB,
    tools,
    base_annotations=list(
        'Intersection size'=intersection_size(
            counts=FALSE,
            mapping=aes(fill=checkV)
        ) + scale_fill_manual(values=c(
            'Complete'='#07ce04', 'High-quality'='#8ffa37',
            'Medium-quality'='#fffb00', 'Low-quality'='#ff8513',
            'Not-determined'='#d4d4d4'
        ))
    ),
    width_ratio=0.1
)

svg("../figure/UpsetPlot_before_filter.svg", width = 35, height = 20)  
print(upsetplt)  
dev.off() 
