options(repos = c(CRAN = "https://cran.rstudio.com/"))

install.packages("remotes")
remotes::install_github("fbreitwieser/pavian")

install.packages("htmlwidgets")
install.packages("webshot")

# Charger les bibliothèques
library("htmlwidgets")
library("pavian")
library("webshot")

# Fonction pour générer le diagramme Sankey
build_sankey_network <- function(my_report, taxRanks = c("D","K","P","C","O","F","G","S"), maxn=10,
                                 zoom = FALSE, title = NULL, ...) {
  stopifnot("taxRank" %in% colnames(my_report))
  if (!any(taxRanks %in% my_report$taxRank)) {
    warning("Le rapport ne contient aucun des taxRanks spécifiés - Ignoré")
    return()
  }
  
  my_report <- subset(my_report, taxRank %in% taxRanks)
  my_report <- plyr::ddply(my_report, "taxRank", function(x) x[utils::tail(order(x$cladeReads,-x$depth), n=maxn), , drop = FALSE])
  my_report <- my_report[, c("name","taxLineage","taxonReads", "cladeReads","depth", "taxRank")]
  my_report <- my_report[!my_report$name %in% c('-_root'), ]
  
  splits <- strsplit(my_report$taxLineage, "\\|")
  root_nodes <- sapply(splits[sapply(splits, length) ==2], function(x) x[2])
  sel <- sapply(splits, length) >= 3
  splits <- splits[sel]
  
  links <- data.frame(do.call(rbind, lapply(splits, function(x) utils::tail(x[x %in% my_report$name], n=2))), stringsAsFactors = FALSE)
  colnames(links) <- c("source","target")
  links$value <- my_report[sel,"cladeReads"]
  
  my_taxRanks <- taxRanks[taxRanks %in% my_report$taxRank]
  taxRank_to_depth <- stats::setNames(seq_along(my_taxRanks)-1, my_taxRanks)
  
  nodes <- data.frame(name=my_report$name,
                      depth=taxRank_to_depth[my_report$taxRank],
                      value=my_report$cladeReads,
                      stringsAsFactors=FALSE)
  
  names_id = stats::setNames(seq_len(nrow(nodes)) - 1, nodes[,1])
  links$source <- names_id[links$source]
  links$target <- names_id[links$target]
  links <- links[links$source != links$target, ]
  nodes$name <- sub("^._","", nodes$name)
  links$source_name <- nodes$name[links$source + 1]
  
  if (!is.null(links))
    sankeyD3::sankeyNetwork(
      Links = links,
      Nodes = nodes,
      doubleclickTogglesChildren = TRUE,
      Source = "source",
      Target = "target",
      Value = "value",
      NodeID = "name",
      NodeGroup = "name",
      NodePosX = "depth",
      NodeValue = "value",
      dragY = TRUE,
      xAxisDomain = my_taxRanks,
      numberFormat = "pavian",
      title = title,
      nodeWidth = 15,
      linkGradient = TRUE,
      nodeShadow = TRUE,
      nodeCornerRadius = 5,
      units = "cladeReads",
      fontSize = 12,
      iterations = maxn * 100,
      align = "none",
      highlightChildLinks = TRUE,
      orderByPath = TRUE,
      scaleNodeBreadthsByString = TRUE,
      zoom = zoom,
      ...
    )
}

# Récupérer le fichier passé en argument
file <- commandArgs(trailingOnly = TRUE)[1]

# Définir le dossier de sortie
output_dir <- file.path("module_02/MMseq2/results/sankey")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Extraire le nom du fichier sans le chemin
file_basename <- basename(file)

# Définir les chemins de sortie
output1 <- file.path(output_dir, paste0("sankey_", file_basename, ".html"))
output2 <- file.path(output_dir, paste0("sankey_", file_basename, ".pdf"))

print(paste("Fichier HTML de sortie :", output1))
print(paste("Fichier PDF de sortie :", output2))

# Lire le rapport et générer le Sankey
sank <- build_sankey_network(read_report(file))

# Sauvegarde du fichier HTML
saveWidget(sank, output1, selfcontained = TRUE, libdir = NULL, background = "white", title = class(sank)[[1]], knitrOptions = list())

# Sauvegarde en PDF
webshot(output1, output2)
