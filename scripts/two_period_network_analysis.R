# ============================================================================
# TWO-PERIOD NETWORK ANALYSIS: Pre-Election vs Post-Election Comparison
# Focus: 1 Year Before vs 1 Year After November 22, 2023 Election
# ============================================================================

library(dplyr)
library(lubridate)
library(igraph)
library(ggplot2)

# ============================================================================
# RESEARCH DESIGN
# ============================================================================

cat("===============================================================================\n")
cat("TWO-PERIOD NETWORK ANALYSIS: Pre-Election vs Post-Election Comparison\n")
cat("Focus: 1 Year Before vs 1 Year After November 22, 2023 Election\n")
cat("===============================================================================\n\n")

cat("RESEARCH QUESTION:\n")
cat("How do co-voting patterns between parties change from before to after the election?\n\n")

cat("TEMPORAL DESIGN:\n")
cat("• PRE-ELECTION: November 22, 2022 - November 21, 2023 (1 year before)\n")
cat("• POST-ELECTION: November 23, 2023 - November 22, 2024 (1 year after)\n")
cat("• Election Date: November 22, 2023\n")
cat("• Cabinet Formation: July 2, 2024 (within post-election period)\n\n")

cat("NETWORK STRUCTURE:\n")
cat("• ALL edges included (complete cooperation network)\n")
cat("• Edges weighted by number of agreements between parties\n")
cat("• Minimum 5 shared votes required for edge creation\n\n")

cat("VISUALIZATION:\n")
cat("• RED nodes = Left-wing parties (SP, PvdD, GroenLinks, PvdA, etc.)\n")
cat("• ORANGE nodes = Center parties (D66, Volt)\n")  
cat("• BLUE nodes = Right-wing parties (VVD, CDA, PVV, FVD, etc.)\n")
cat("• Node size = degree centrality (more connections = larger)\n")
cat("• Edge thickness = cooperation strength (more agreements = thicker)\n")
cat("• EDGE HIGHLIGHTING: Edges 30% above mean weight shown prominently\n")
cat("  (Weaker edges very faint to clearly show strongest cooperation patterns)\n\n")

# ============================================================================
# LOAD AND PREPARE DATA
# ============================================================================

cat("Loading data...\n")

# Load pre-election data (2023) - for pre-election period
voting_data_2023 <- read.csv("data/voting_data_2023_preelection.csv", stringsAsFactors = FALSE)
voting_data_2023$date <- ymd_hms(voting_data_2023$GewijzigdOp)

# Load post-election data (2024) - for post-election period
voting_data_2024 <- read.csv("data/voting_data_clean.csv", stringsAsFactors = FALSE)
voting_data_2024$date <- ymd_hms(voting_data_2024$GewijzigdOp)

cat(sprintf("Total 2023 records: %d\n", nrow(voting_data_2023)))
cat(sprintf("Total 2024 records: %d\n\n", nrow(voting_data_2024)))

# ============================================================================
# CREATE TEMPORAL PERIODS
# ============================================================================

cat("Creating temporal periods...\n")

# Election date
election_date <- ymd("2023-11-22")

# Period 1: PRE-ELECTION (1 year before election)
# November 22, 2022 - November 21, 2023
pre_start <- election_date - years(1)
pre_end <- election_date - days(1)

data_pre <- voting_data_2023 %>%
  filter(date >= pre_start & date <= pre_end)

cat("PRE-ELECTION (Nov 22, 2022 - Nov 21, 2023):\n")
cat(sprintf("  Votes: %d\n", nrow(data_pre)))
cat(sprintf("  Motions: %d\n", length(unique(data_pre$Besluit_Id))))
cat(sprintf("  Parties: %d\n", length(unique(data_pre$ActorFractie))))
cat(sprintf("  Date range: %s to %s\n\n", min(data_pre$date), max(data_pre$date)))

# Period 2: POST-ELECTION (1 year after election)
# November 23, 2023 - November 22, 2024
post_start <- election_date + days(1)
post_end <- election_date + years(1)

# Combine 2023 and 2024 data for post-election period
data_post_2023 <- voting_data_2023 %>%
  filter(date >= post_start)

data_post_2024 <- voting_data_2024 %>%
  filter(date <= post_end)

data_post <- bind_rows(data_post_2023, data_post_2024)

cat("POST-ELECTION (Nov 23, 2023 - Nov 22, 2024):\n")
cat(sprintf("  Votes: %d\n", nrow(data_post)))
cat(sprintf("  Motions: %d\n", length(unique(data_post$Besluit_Id))))
cat(sprintf("  Parties: %d\n", length(unique(data_post$ActorFractie))))
cat(sprintf("  Date range: %s to %s\n\n", min(data_post$date), max(data_post$date)))

# ============================================================================
# NETWORK CREATION FUNCTIONS
# ============================================================================

calculate_party_agreements <- function(data) {
  
  # Create party-motion voting matrix
  party_votes <- data %>%
    select(ActorFractie, Besluit_Id, Soort) %>%
    distinct()
  
  cat(sprintf("  Clean voting records: %d\n", nrow(party_votes)))
  
  # Self-join to get all party pairs per motion
  agreements <- party_votes %>%
    inner_join(party_votes, by = "Besluit_Id", suffix = c("_1", "_2")) %>%
    filter(ActorFractie_1 < ActorFractie_2)  # Avoid duplicates
  
  # Calculate agreement statistics
  party_agreement_summary <- agreements %>%
    group_by(ActorFractie_1, ActorFractie_2) %>%
    summarise(
      total_votes = n(),
      agreements = sum(Soort_1 == Soort_2),
      disagreements = sum(Soort_1 != Soort_2),
      agreement_rate = agreements / total_votes,
      .groups = 'drop'
    ) %>%
    filter(total_votes >= 5)  # Minimum 5 shared votes
  
  cat(sprintf("  Party pairs: %d\n", nrow(party_agreement_summary)))
  cat(sprintf("  Mean agreements: %.1f\n", mean(party_agreement_summary$agreements)))
  cat(sprintf("  Mean agreement rate: %.3f\n\n", mean(party_agreement_summary$agreement_rate)))
  
  return(party_agreement_summary)
}

create_party_network <- function(agreements, all_parties) {
  
  # Include ALL edges (no threshold filtering)
  edges <- agreements %>%
    select(from = ActorFractie_1, to = ActorFractie_2, 
           weight = agreements, agreement_rate, total_votes)
  
  cat(sprintf("    Total party pairs: %d\n", nrow(agreements)))
  cat(sprintf("    Mean agreements: %.1f\n", mean(agreements$agreements)))
  cat(sprintf("    Including ALL %d edges in network\n", nrow(edges)))
  
  # Create network
  g <- graph_from_data_frame(edges, directed = FALSE, vertices = all_parties)
  
  # Add party attributes for visualization
  V(g)$degree <- degree(g)
  V(g)$strength <- strength(g)
  V(g)$betweenness <- betweenness(g, weights = NA)
  
  # Party categories for coloring based on ideology
  V(g)$party_type <- case_when(
    V(g)$name %in% c("SP", "PvdD", "BIJ1", "GroenLinks", "PvdA", "DENK") ~ "Left",
    V(g)$name %in% c("D66", "Volt") ~ "Center", 
    V(g)$name %in% c("VVD", "CDA", "ChristenUnie", "BBB", "PVV", "FVD", "SGP", "JA21") ~ "Right",
    TRUE ~ "Center"
  )
  
  # Ideology for layout (approximate left-right positions)
  V(g)$ideology <- case_when(
    V(g)$name %in% c("SP", "PvdD", "BIJ1") ~ 1,           # Left
    V(g)$name %in% c("GroenLinks", "PvdA", "DENK") ~ 2,   # Center-left
    V(g)$name %in% c("D66", "Volt") ~ 3,                  # Center
    V(g)$name %in% c("VVD", "CDA", "ChristenUnie", "BBB") ~ 4,  # Center-right
    V(g)$name %in% c("PVV", "FVD", "SGP", "JA21") ~ 5,    # Right
    TRUE ~ 3  # Default center
  )
  
  cat(sprintf("    Final network: %d nodes, %d edges, density = %.3f\n\n", 
              vcount(g), ecount(g), edge_density(g)))
  
  return(g)
}

# ============================================================================
# CREATE NETWORKS FOR BOTH PERIODS
# ============================================================================

cat("\nCREATING PARTY COOPERATION NETWORKS\n")
cat("====================================\n")

cat("Processing PRE-ELECTION period...\n")
agreements_pre <- calculate_party_agreements(data_pre)

cat("Processing POST-ELECTION period...\n")
agreements_post <- calculate_party_agreements(data_post)

# Get unique parties for each period
parties_pre <- unique(data_pre$ActorFractie)
parties_pre <- parties_pre[!is.na(parties_pre)]

parties_post <- unique(data_post$ActorFractie)
parties_post <- parties_post[!is.na(parties_post)]

# For visualization consistency, use union of all parties
all_parties_for_layout <- unique(c(parties_pre, parties_post))

cat(sprintf("Parties in PRE period: %d\n", length(parties_pre)))
cat(sprintf("Parties in POST period: %d\n", length(parties_post)))
cat(sprintf("Total unique parties across both periods: %d\n\n", length(all_parties_for_layout)))

# Create networks using only parties active in each specific period
cat("Creating PRE-ELECTION network:\n")
g_pre <- create_party_network(agreements_pre, parties_pre)

cat("Creating POST-ELECTION network:\n")
g_post <- create_party_network(agreements_post, parties_post)

# ============================================================================
# NETWORK COMPARISON STATISTICS
# ============================================================================

cat("\nNETWORK COMPARISON STATISTICS\n")
cat("=============================\n")

comparison_df <- data.frame(
  Metric = c("Nodes", "Edges", "Density", "Mean Degree", "Transitivity", 
             "Avg Path Length", "Modularity", "Components"),
  Pre = c(
    vcount(g_pre),
    ecount(g_pre),
    edge_density(g_pre),
    mean(degree(g_pre)),
    transitivity(g_pre),
    ifelse(is_connected(g_pre), mean_distance(g_pre), NA),
    ifelse(ecount(g_pre) > 0, modularity(cluster_louvain(g_pre)), NA),
    count_components(g_pre)
  ),
  Post = c(
    vcount(g_post),
    ecount(g_post),
    edge_density(g_post),
    mean(degree(g_post)),
    transitivity(g_post),
    ifelse(is_connected(g_post), mean_distance(g_post), NA),
    ifelse(ecount(g_post) > 0, modularity(cluster_louvain(g_post)), NA),
    count_components(g_post)
  )
)

comparison_df <- comparison_df %>%
  mutate(
    Change_Pre_to_Post = Post - Pre,
    PctChange_Pre_to_Post = ifelse(Pre != 0, (Post - Pre) / Pre * 100, NA)
  )

print(comparison_df)

# ============================================================================
# NETWORK VISUALIZATIONS
# ============================================================================

cat("\nCREATING NETWORK VISUALIZATIONS\n")
cat("(Highlighting edges 30% above mean weight for clarity)\n")

# Color schemes based on political ideology
party_colors <- c("Left" = "#E74C3C",      # Red for left-wing parties
                  "Center" = "#F39C12",    # Orange for centrist parties  
                  "Right" = "#3498DB")     # Blue for right-wing parties

# ============================================================================
# 1. SIDE-BY-SIDE NETWORK COMPARISON (2 NETWORKS)
# ============================================================================

pdf("results/visualizations/network_comparison_two_periods.pdf", width = 16, height = 8)
par(mfrow = c(1, 2), mar = c(2, 2, 4, 2))

# Common layout for comparison
set.seed(42)
# Use ideology-based layout for meaningful positioning
layout_coords <- matrix(0, nrow = length(all_parties_for_layout), ncol = 2)
for(i in 1:length(all_parties_for_layout)) {
  party <- all_parties_for_layout[i]
  if(party %in% V(g_pre)$name) {
    ideology_pos <- V(g_pre)$ideology[V(g_pre)$name == party][1]
  } else if(party %in% V(g_post)$name) {
    ideology_pos <- V(g_post)$ideology[V(g_post)$name == party][1]
  } else {
    ideology_pos <- 3
  }
  layout_coords[i, 1] <- ideology_pos + runif(1, -0.3, 0.3)
  layout_coords[i, 2] <- runif(1, -1, 1)
}

# PRE-ELECTION network
V(g_pre)$color <- party_colors[V(g_pre)$party_type]
V(g_pre)$size <- pmax(8, sqrt(V(g_pre)$degree) * 4)

# Highlight strongest edges: 30% above mean weight
mean_weight_pre <- mean(E(g_pre)$weight)
weight_threshold_pre <- mean_weight_pre * 1.30
edges_to_show_pre <- which(E(g_pre)$weight >= weight_threshold_pre)

# Set edge properties - stronger edges are more visible
E(g_pre)$width <- pmax(0.5, (E(g_pre)$weight / max(E(g_pre)$weight)) * 3)
E(g_pre)$color <- ifelse(E(g_pre)$weight >= weight_threshold_pre, 
                         rgb(0.5, 0.5, 0.5, 0.85),  # Prominent for strong edges
                         rgb(0.5, 0.5, 0.5, 0.08))  # Very faint for weaker edges

cat(sprintf("  PRE: Highlighting %d/%d edges (30%% above mean of %.1f = threshold: %.1f)\n", 
            length(edges_to_show_pre), ecount(g_pre), mean_weight_pre, weight_threshold_pre))

plot(g_pre,
     layout = layout_coords[match(V(g_pre)$name, all_parties_for_layout), ],
     vertex.label.cex = 0.7,
     vertex.label.color = "black",
     vertex.label.family = "sans",
     vertex.frame.color = "white",
     main = "PRE-ELECTION\n(Nov 22, 2022 - Nov 21, 2023)")

# POST-ELECTION network
V(g_post)$color <- party_colors[V(g_post)$party_type]
V(g_post)$size <- pmax(8, sqrt(V(g_post)$degree) * 4)

# Highlight strongest edges: 30% above mean weight
mean_weight_post <- mean(E(g_post)$weight)
weight_threshold_post <- mean_weight_post * 1.30
edges_to_show_post <- which(E(g_post)$weight >= weight_threshold_post)

# Set edge properties - stronger edges are more visible
E(g_post)$width <- pmax(0.5, (E(g_post)$weight / max(E(g_post)$weight)) * 3)
E(g_post)$color <- ifelse(E(g_post)$weight >= weight_threshold_post, 
                          rgb(0.5, 0.5, 0.5, 0.85),  # Prominent for strong edges
                          rgb(0.5, 0.5, 0.5, 0.08))  # Very faint for weaker edges

cat(sprintf("  POST: Highlighting %d/%d edges (30%% above mean of %.1f = threshold: %.1f)\n", 
            length(edges_to_show_post), ecount(g_post), mean_weight_post, weight_threshold_post))

plot(g_post,
     layout = layout_coords[match(V(g_post)$name, all_parties_for_layout), ],
     vertex.label.cex = 0.7,
     vertex.label.color = "black",
     vertex.label.family = "sans",
     vertex.frame.color = "white",
     main = "POST-ELECTION\n(Nov 23, 2023 - Nov 22, 2024)")

dev.off()

# ============================================================================
# 2. DETAILED ANALYSIS
# ============================================================================

pdf("results/visualizations/detailed_two_period_analysis.pdf", width = 16, height = 12)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 2))

# Degree distributions
hist(degree(g_pre), breaks = 20, col = "#E74C3C", border = "white",
     main = "Degree Distribution - Pre-Election", xlab = "Degree", ylab = "Frequency")
hist(degree(g_post), breaks = 20, col = "#3498DB", border = "white",
     main = "Degree Distribution - Post-Election", xlab = "Degree", ylab = "Frequency")

# Community detection
communities_pre <- cluster_louvain(g_pre)
communities_post <- cluster_louvain(g_post)

plot(communities_pre, g_pre, 
     layout = layout_coords[match(V(g_pre)$name, all_parties_for_layout), ],
     vertex.label.cex = 0.6, main = "Communities - Pre-Election")
plot(communities_post, g_post,
     layout = layout_coords[match(V(g_post)$name, all_parties_for_layout), ],
     vertex.label.cex = 0.6, main = "Communities - Post-Election")

# Party type comparison
party_type_pre <- table(V(g_pre)$party_type)
party_type_post <- table(V(g_post)$party_type)

barplot(party_type_pre, col = party_colors[names(party_type_pre)],
        main = "Party Ideology Distribution - Pre-Election",
        ylab = "Number of Parties", las = 2)

barplot(party_type_post, col = party_colors[names(party_type_post)],
        main = "Party Ideology Distribution - Post-Election", 
        ylab = "Number of Parties", las = 2)

dev.off()

# ============================================================================
# 3. CHANGE ANALYSIS VISUALIZATION
# ============================================================================

pdf("results/visualizations/network_changes_two_periods.pdf", width = 16, height = 10)
par(mfrow = c(2, 2), mar = c(8, 4, 3, 2))

# Network metrics comparison
metrics_data <- comparison_df %>%
  filter(Metric %in% c("Edges", "Density", "Mean Degree", "Components")) %>%
  select(Metric, Pre, Post)

metrics_matrix <- as.matrix(metrics_data[, -1])
rownames(metrics_matrix) <- metrics_data$Metric

barplot(t(metrics_matrix), beside = TRUE, col = c("#E74C3C", "#3498DB"),
        main = "Network Metrics Comparison",
        ylab = "Value", las = 2,
        legend.text = c("Pre-Election", "Post-Election"),
        args.legend = list(x = "topright"))

# Percent change visualization
valid_changes <- comparison_df[is.finite(comparison_df$PctChange_Pre_to_Post), ]
if(nrow(valid_changes) > 0) {
  barplot(valid_changes$PctChange_Pre_to_Post,
          names.arg = valid_changes$Metric,
          col = ifelse(valid_changes$PctChange_Pre_to_Post > 0, "#2ECC71", "#E74C3C"),
          main = "Percent Change (Pre → Post)",
          ylab = "Percent Change (%)", las = 2)
  abline(h = 0, lty = 2)
} else {
  plot.new()
  text(0.5, 0.5, "No valid percent changes to display", cex = 1.5)
}

# Party activity comparison
party_activity_pre <- data_pre %>% count(ActorFractie, sort = TRUE) %>% head(10)
party_activity_post <- data_post %>% count(ActorFractie, sort = TRUE) %>% head(10)

barplot(party_activity_pre$n, names.arg = party_activity_pre$ActorFractie,
        col = "#E74C3C", main = "Top 10 Most Active Parties - Pre-Election",
        ylab = "Number of Votes", las = 2, cex.names = 0.7)

barplot(party_activity_post$n, names.arg = party_activity_post$ActorFractie,
        col = "#3498DB", main = "Top 10 Most Active Parties - Post-Election",
        ylab = "Number of Votes", las = 2, cex.names = 0.7)

dev.off()

# ============================================================================
# EXPORT NETWORK DATA
# ============================================================================

cat("\nExporting network data...\n")

# Export edge lists
write.csv(igraph::as_data_frame(g_pre, "edges"), 
          "results/edge_lists/edges_pre_election.csv", row.names = FALSE)
write.csv(igraph::as_data_frame(g_post, "edges"), 
          "results/edge_lists/edges_post_election.csv", row.names = FALSE)

# Export comparison statistics
write.csv(comparison_df, "results/statistics/two_period_comparison.csv", row.names = FALSE)

cat("\n===============================================================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("===============================================================================\n")
cat("Generated files:\n")
cat("  1. network_comparison_two_periods.pdf - Side-by-side comparison\n")
cat("  2. detailed_two_period_analysis.pdf - Detailed network analysis\n")
cat("  3. network_changes_two_periods.pdf - Change metrics visualization\n")
cat("  4. edges_pre_election.csv - Edge list for pre-election period\n")
cat("  5. edges_post_election.csv - Edge list for post-election period\n")
cat("  6. two_period_comparison.csv - Statistical comparison\n")
cat("===============================================================================\n")
