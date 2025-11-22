#!/usr/bin/env Rscript
# Script to update analysis.Rmd with explicit namespace notation

library(stringr)

# Read the file
content <- readLines("analysis.Rmd")

# Function mappings
replacements <- list(
  # Base R functions
  "\\bcat\\(" = "base::cat(",
  "\\bsprintf\\(" = "base::sprintf(",
  "\\bformat\\(" = "base::format(",
  "\\bnrow\\(" = "base::nrow(",
  "\\bunique\\(" = "base::unique(",
  "\\blength\\(" = "base::length(",
  "\\bmin\\(" = "base::min(",
  "\\bmax\\(" = "base::max(",
  "\\bmean\\(" = "base::mean(",
  "\\bmedian\\(" = "base::median(",
  "\\bsd\\(" = "stats::sd(",
  "\\bsum\\(" = "base::sum(",
  "\\babs\\(" = "base::abs(",
  "\\bifelse\\(" = "base::ifelse(",
  "\\bpaste\\(" = "base::paste(",
  "\\bnames\\(" = "base::names(",
  "\\bprint\\(" = "base::print(",
  "\\bdata\\.frame\\(" = "base::data.frame(",
  "\\bdo\\.call\\(" = "base::do.call(",
  "\\brbind\\(" = "base::rbind(",
  "\\blapply\\(" = "base::lapply(",
  "\\bsapply\\(" = "base::sapply(",
  "\\bduplicated\\(" = "base::duplicated(",
  "\\bsetdiff\\(" = "base::setdiff(",
  "\\brep\\(" = "base::rep(",
  "\\bpmax\\(" = "base::pmax(",
  "\\bwhich\\(" = "base::which(",
  "\\bis\\.na\\(" = "base::is.na(",
  "\\bidentical\\(" = "base::identical(",
  "\\bsort\\(" = "base::sort(",
  
  # Stats functions
  "\\bcor\\.test\\(" = "stats::cor.test(",
  "\\blm\\(" = "stats::lm(",
  "\\becdf\\(" = "stats::ecdf(",
  
  # Graphics functions
  "\\bpar\\(" = "graphics::par(",
  "\\bplot\\(" = "graphics::plot(",
  "\\bhist\\(" = "graphics::hist(",
  "\\bboxplot\\(" = "graphics::boxplot(",
  "\\babline\\(" = "graphics::abline(",
  "\\btext\\(" = "graphics::text(",
  "\\blines\\(" = "graphics::lines(",
  "\\blegend\\(" = "graphics::legend(",
  
  # Lubridate functions
  "\\bymd\\(" = "lubridate::ymd(",
  "\\bymd_hms\\(" = "lubridate::ymd_hms(",
  "\\byears\\(" = "lubridate::years(",
  "\\bdays\\(" = "lubridate::days(",
  
  # igraph functions
  "\\bgraph_from_data_frame\\(" = "igraph::graph_from_data_frame(",
  "\\bV\\(" = "igraph::V(",
  "\\bE\\(" = "igraph::E(",
  "\\bvcount\\(" = "igraph::vcount(",
  "\\becount\\(" = "igraph::ecount(",
  "\\bdegree\\(" = "igraph::degree(",
  "\\bstrength\\(" = "igraph::strength(",
  "\\bbetweenness\\(" = "igraph::betweenness(",
  "\\bedge_density\\(" = "igraph::edge_density(",
  "\\btransitivity\\(" = "igraph::transitivity(",
  "\\bmean_distance\\(" = "igraph::mean_distance(",
  "\\bmodularity\\(" = "igraph::modularity(",
  "\\bcluster_louvain\\(" = "igraph::cluster_louvain(",
  "\\bcount_components\\(" = "igraph::count_components(",
  "\\bis_connected\\(" = "igraph::is_connected(",
  "\\bas_data_frame\\(" = "igraph::as_data_frame(",
  
  # Utils functions
  "\\bwrite\\.csv\\(" = "utils::write.csv(",
  "\\bread\\.csv\\(" = "utils::read.csv(",
  
  # Table function
  "\\btable\\(" = "base::table("
)

# Apply replacements
for (pattern in names(replacements)) {
  content <- str_replace_all(content, pattern, replacements[[pattern]])
}

# Write back
writeLines(content, "analysis.Rmd")
cat("Updated analysis.Rmd with explicit namespace notation\n")

