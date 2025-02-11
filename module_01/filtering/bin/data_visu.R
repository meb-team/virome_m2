#!/usr/bin/env Rscript

# Packages installation
if (!requireNamespace("UpSetR", quietly = TRUE)) install.packages("UpSetR")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")


# Packages loading
library(UpSetR)
library(ggplot2)
library(dplyr)


# Load the data
data <- read.csv("module_01/filtering/results/representative_clusterTEST.tsv", sep = "\t", header = TRUE)


# Data processing
data_upset <- data %>%
  mutate(vs2 = as.numeric(vs2_seed == 1),
         vibrant = as.numeric(vibrant_seed == 1),
         dvf = as.numeric(dvf_seed == 1))


data_upset <- data_upset %>%
  select(vs2, vibrant, dvf, checkv_quality)


# Plot configuration
quality_colors <- c("Complete" = "green",
                    "High-quality" = "limegreen",
                    "Medium-quality" = "yellow",
                    "Low-quality" = "orange",
                    "Not-determined" = "grey")


upset(
  data_upset, 
  sets = c("vs2", "vibrant", "dvf"), 
  sets.bar.color = "black", 
  order.by = "freq", 
  mainbar.y.label = "Intersection size",
  sets.x.label = "Set size",
  text.scale = 1.5,
  point.size = 3,
  line.size = 1.2,
  keep.order = TRUE
) 


legend_plot <- ggplot(data_upset, aes(x = "", fill = checkv_quality)) +
  geom_bar() +
  scale_fill_manual(values = quality_colors) +
  labs(fill = "Quality") +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), axis.title.x = element_blank())


# Export the figure
png("module_01/filtering/figure/UpsetPlot_before_filter.png", width = 2500, height = 1800, res = 300)
grid.arrange(upset_plot, legend_plot, ncol = 1, heights = c(4, 1))
dev.off()
