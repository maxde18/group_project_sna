# ============================================================================
# IDEOLOGY CORRELATION ANALYSIS
# Testing relationships between political orientation dimensions
# ============================================================================

library(ggplot2)

cat("===============================================================================\n")
cat("IDEOLOGY CORRELATION ANALYSIS\n")
cat("Testing Kieskompas Political Orientation Dimensions\n")
cat("===============================================================================\n\n")

# ============================================================================
# LOAD DATA
# ============================================================================

cat("Loading Kieskompas ideology data...\n")
ideology_data <- read.csv("data/political_axes_data.csv", stringsAsFactors = FALSE)
names(ideology_data) <- c("left_right", "conservative_progressive", "party")
ideology_data <- ideology_data[!is.na(ideology_data$party) & ideology_data$party != "", ]

cat(sprintf("Parties with ideology data: %d\n\n", nrow(ideology_data)))

# ============================================================================
# DESCRIPTIVE STATISTICS
# ============================================================================

cat("DESCRIPTIVE STATISTICS\n")
cat("======================\n\n")

cat("Left-Right Dimension:\n")
cat(sprintf("  Range: [%.3f, %.3f]\n", min(ideology_data$left_right), max(ideology_data$left_right)))
cat(sprintf("  Mean: %.3f\n", mean(ideology_data$left_right)))
cat(sprintf("  SD: %.3f\n", sd(ideology_data$left_right)))
cat(sprintf("  Median: %.3f\n\n", median(ideology_data$left_right)))

cat("Conservative-Progressive Dimension:\n")
cat(sprintf("  Range: [%.3f, %.3f]\n", min(ideology_data$conservative_progressive), max(ideology_data$conservative_progressive)))
cat(sprintf("  Mean: %.3f\n", mean(ideology_data$conservative_progressive)))
cat(sprintf("  SD: %.3f\n", sd(ideology_data$conservative_progressive)))
cat(sprintf("  Median: %.3f\n\n", median(ideology_data$conservative_progressive)))

# ============================================================================
# CORRELATION ANALYSIS
# ============================================================================

cat("CORRELATION ANALYSIS\n")
cat("====================\n\n")

# Pearson correlation (parametric - assumes linear relationship)
pearson_test <- cor.test(ideology_data$left_right, 
                         ideology_data$conservative_progressive, 
                         method = "pearson")

cat("Pearson Correlation Test:\n")
cat(sprintf("  Correlation coefficient (r): %.4f\n", pearson_test$estimate))
cat(sprintf("  t-statistic: %.4f\n", pearson_test$statistic))
cat(sprintf("  df: %d\n", pearson_test$parameter))
cat(sprintf("  p-value: %.6f\n", pearson_test$p.value))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n", pearson_test$conf.int[1], pearson_test$conf.int[2]))
cat(sprintf("  Interpretation: %s\n\n", 
            ifelse(pearson_test$p.value < 0.001, "*** Highly significant (p < 0.001)",
            ifelse(pearson_test$p.value < 0.01, "** Very significant (p < 0.01)",
            ifelse(pearson_test$p.value < 0.05, "* Significant (p < 0.05)", 
                   "Not significant (p >= 0.05)")))))

# Spearman correlation (non-parametric - rank-based, robust to outliers)
spearman_test <- cor.test(ideology_data$left_right, 
                          ideology_data$conservative_progressive, 
                          method = "spearman")

cat("Spearman Rank Correlation Test:\n")
cat(sprintf("  Correlation coefficient (rho): %.4f\n", spearman_test$estimate))
cat(sprintf("  S statistic: %.4f\n", spearman_test$statistic))
cat(sprintf("  p-value: %.6f\n", spearman_test$p.value))
cat(sprintf("  Interpretation: %s\n\n", 
            ifelse(spearman_test$p.value < 0.001, "*** Highly significant (p < 0.001)",
            ifelse(spearman_test$p.value < 0.01, "** Very significant (p < 0.01)",
            ifelse(spearman_test$p.value < 0.05, "* Significant (p < 0.05)", 
                   "Not significant (p >= 0.05)")))))

# Effect size interpretation (Cohen's guidelines)
r_value <- abs(pearson_test$estimate)
effect_size <- ifelse(r_value < 0.1, "negligible",
               ifelse(r_value < 0.3, "small",
               ifelse(r_value < 0.5, "medium", "large")))

cat(sprintf("Effect Size: %s (|r| = %.3f)\n", effect_size, r_value))
cat("  Cohen's guidelines: small (0.1), medium (0.3), large (0.5)\n\n")

# ============================================================================
# EXPORT RESULTS
# ============================================================================

# Create results summary
correlation_results <- data.frame(
  Test = c("Pearson", "Spearman"),
  Coefficient = c(pearson_test$estimate, spearman_test$estimate),
  Statistic = c(pearson_test$statistic, spearman_test$statistic),
  P_Value = c(pearson_test$p.value, spearman_test$p.value),
  Significant = c(pearson_test$p.value < 0.05, spearman_test$p.value < 0.05),
  stringsAsFactors = FALSE
)

write.csv(correlation_results, 
          "results/statistics/ideology_correlation_results.csv", 
          row.names = FALSE)

cat("Results exported to: results/statistics/ideology_correlation_results.csv\n\n")

# ============================================================================
# VISUALIZATIONS
# ============================================================================

cat("Creating visualizations...\n")

pdf("results/visualizations/ideology_correlation_analysis.pdf", width = 14, height = 10)
par(mfrow = c(2, 2), mar = c(5, 5, 4, 2))

# 1. Scatterplot with regression line
plot(ideology_data$left_right, ideology_data$conservative_progressive,
     xlab = "Left-Right Dimension", 
     ylab = "Conservative-Progressive Dimension",
     main = sprintf("Political Ideology Dimensions\nPearson r = %.3f, p = %.4f", 
                    pearson_test$estimate, pearson_test$p.value),
     pch = 19, col = "steelblue", cex = 1.5)

# Add regression line
abline(lm(conservative_progressive ~ left_right, data = ideology_data), 
       col = "red", lwd = 2, lty = 2)

# Add reference lines at 0
abline(h = 0, v = 0, col = "gray", lty = 3)

# Add party labels
text(ideology_data$left_right, ideology_data$conservative_progressive, 
     labels = ideology_data$party, pos = 3, cex = 0.6, col = "black")

# 2. Histogram of Left-Right
hist(ideology_data$left_right, 
     breaks = 10, 
     col = "lightblue", 
     border = "white",
     main = "Distribution: Left-Right Dimension",
     xlab = "Left-Right Score",
     ylab = "Frequency")
abline(v = 0, col = "red", lwd = 2, lty = 2)
abline(v = mean(ideology_data$left_right), col = "darkblue", lwd = 2, lty = 2)
legend("topright", 
       legend = c("Center (0)", "Mean"), 
       col = c("red", "darkblue"), 
       lty = 2, lwd = 2, cex = 0.8)

# 3. Histogram of Conservative-Progressive
hist(ideology_data$conservative_progressive, 
     breaks = 10, 
     col = "lightcoral", 
     border = "white",
     main = "Distribution: Conservative-Progressive Dimension",
     xlab = "Conservative-Progressive Score",
     ylab = "Frequency")
abline(v = 0, col = "red", lwd = 2, lty = 2)
abline(v = mean(ideology_data$conservative_progressive), col = "darkred", lwd = 2, lty = 2)
legend("topright", 
       legend = c("Center (0)", "Mean"), 
       col = c("red", "darkred"), 
       lty = 2, lwd = 2, cex = 0.8)

# 4. Boxplots for comparison
boxplot(ideology_data[, c("left_right", "conservative_progressive")],
        names = c("Left-Right", "Conservative-Progressive"),
        col = c("lightblue", "lightcoral"),
        main = "Comparison of Ideology Dimensions",
        ylab = "Score",
        horizontal = FALSE)
abline(h = 0, col = "red", lwd = 2, lty = 2)

dev.off()

cat("Visualization saved to: results/visualizations/ideology_correlation_analysis.pdf\n\n")

# ============================================================================
# QUADRANT ANALYSIS
# ============================================================================

cat("QUADRANT ANALYSIS\n")
cat("=================\n\n")

# Classify parties into quadrants
ideology_data$quadrant <- ifelse(
  ideology_data$left_right < 0 & ideology_data$conservative_progressive > 0, "Left-Progressive",
  ifelse(ideology_data$left_right > 0 & ideology_data$conservative_progressive > 0, "Right-Progressive",
  ifelse(ideology_data$left_right < 0 & ideology_data$conservative_progressive < 0, "Left-Conservative",
         "Right-Conservative"))
)

quadrant_table <- table(ideology_data$quadrant)
cat("Party Distribution by Quadrant:\n")
print(quadrant_table)
cat("\n")

for(q in names(quadrant_table)) {
  parties_in_quadrant <- ideology_data$party[ideology_data$quadrant == q]
  cat(sprintf("%s (%d): %s\n", q, quadrant_table[q], 
              paste(parties_in_quadrant, collapse = ", ")))
}

# Export quadrant classification
write.csv(ideology_data[, c("party", "left_right", "conservative_progressive", "quadrant")], 
          "results/statistics/ideology_quadrant_classification.csv", 
          row.names = FALSE)

cat("\nQuadrant classification exported to: results/statistics/ideology_quadrant_classification.csv\n\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("===============================================================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("===============================================================================\n\n")

cat("KEY FINDINGS:\n")
cat(sprintf("• Pearson correlation: r = %.3f (p = %.4f)\n", 
            pearson_test$estimate, pearson_test$p.value))
cat(sprintf("• Spearman correlation: rho = %.3f (p = %.4f)\n", 
            spearman_test$estimate, spearman_test$p.value))
cat(sprintf("• Effect size: %s\n", effect_size))
cat(sprintf("• The two dimensions are %s\n", 
            ifelse(pearson_test$p.value < 0.05, 
                   ifelse(pearson_test$estimate < 0, 
                          "significantly negatively correlated", 
                          "significantly positively correlated"),
                   "not significantly correlated")))

cat("\nINTERPRETATION:\n")
if(pearson_test$p.value < 0.05) {
  if(pearson_test$estimate < 0) {
    cat("• Left-wing parties tend to be more progressive\n")
    cat("• Right-wing parties tend to be more conservative\n")
    cat("• This suggests the two dimensions are NOT independent\n")
  } else {
    cat("• Left-wing parties tend to be more conservative\n")
    cat("• Right-wing parties tend to be more progressive\n")
    cat("• This is an unusual pattern!\n")
  }
} else {
  cat("• The left-right and conservative-progressive dimensions are independent\n")
  cat("• Parties' economic positions don't predict their social positions\n")
  cat("• Both dimensions provide unique information for QAP analysis\n")
}

cat("\nFILES GENERATED:\n")
cat("  1. ideology_correlation_results.csv - Statistical test results\n")
cat("  2. ideology_correlation_analysis.pdf - Visualizations\n")
cat("  3. ideology_quadrant_classification.csv - Party classifications\n")
cat("===============================================================================\n")

