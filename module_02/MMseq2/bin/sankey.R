# Charger les bibliothèques nécessaires
install.packages("pavian")
install.packages("sankeyD3")
install.packages("htmlwidgets")
install.packages("webshot")

library("htmlwidgets")
library("sankeyD3")
library("webshot")
library("data.table")  # Pour charger efficacement le TSV

# Vérifier que l'argument (fichier d'entrée) est fourni
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Erreur : Aucun fichier TSV fourni en argument.")
}
file <- args[1]  # Récupération du fichier TSV

# Charger le fichier TSV
df <- fread(file, sep = "\t", header = TRUE)

# Vérifier que le fichier contient bien les colonnes attendues
expected_cols <- c("ID", "Domain", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
missing_cols <- setdiff(expected_cols, colnames(df))
if (length(missing_cols) > 0) {
  stop(paste("Colonnes manquantes dans le fichier :", paste(missing_cols, collapse = ", ")))
}

# Convertir en format liens pour Sankey
edges <- list()
ranks <- expected_cols[-1]  # Exclure ID
for (i in seq_along(ranks)[-length(ranks)]) {
  source_col <- ranks[i]
  target_col <- ranks[i + 1]
  
  sub_df <- df[, .(source = get(source_col), target = get(target_col))]
  sub_df <- sub_df[!is.na(target) & target != "NA" & target != "", ]
  
  edges[[i]] <- sub_df
}

edges_df <- rbindlist(edges)
edges_df <- unique(edges_df[, .(source, target)])

# Création des nœuds
nodes <- unique(c(edges_df$source, edges_df$target))
nodes_df <- data.frame(name = nodes, stringsAsFactors = FALSE)

# Création des liens
edges_df$source <- match(edges_df$source, nodes_df$name) - 1
edges_df$target <- match(edges_df$target, nodes_df$name) - 1
edges_df$value <- 1  # On met une valeur constante pour les liens

# Générer le Sankey diagram
sankey <- sankeyNetwork(
  Links = edges_df,
  Nodes = nodes_df,
  Source = "source",
  Target = "target",
  Value = "value",
  NodeID = "name",
  fontSize = 12,
  nodeWidth = 15,
  nodeCornerRadius = 5,
  units = "reads",
  linkGradient = TRUE
)

# Sauvegarde en HTML et PDF
output_html <- paste0("sankey_", tools::file_path_sans_ext(basename(file)), ".html")
output_pdf <- paste0("sankey_", tools::file_path_sans_ext(basename(file)), ".pdf")

saveWidget(sankey, output_html, selfcontained = TRUE)
webshot(output_html, output_pdf)

cat("✅ Sankey généré :", output_html, "et", output_pdf, "\n")
