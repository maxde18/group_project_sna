#!/bin/bash

echo "==============================================================================="
echo "RUNNING ALL NETWORK ANALYSES"
echo "Dutch Parliament Electoral Cycle Study (2023-2024)"
echo "==============================================================================="
echo ""

echo "PRIMARY ANALYSIS"
echo "==============================================================================="
echo ""

echo "[1/8] ⭐ One-Year Comparison (Raw Weights)..."
Rscript scripts/pre_election_vs_post_formation_analysis.R
echo ""

echo "[2/8] ⭐ One-Year Comparison (Z-Score Normalized)..."
Rscript scripts/pre_election_vs_post_formation_analysis_normalized.R
echo ""

echo "[3/8] ⭐ Ideology Correlation Analysis..."
Rscript scripts/ideology_correlation_analysis.R
echo ""

echo ""
echo "VALIDATION"
echo "==============================================================================="
echo ""



echo ""
echo "==============================================================================="
echo "✓ ALL ANALYSES COMPLETE!"
echo "==============================================================================="
echo ""
echo "Primary Analysis Outputs:"
echo "  • results/visualizations/network_comparison_pre_vs_post_formation.pdf"
echo "  • results/visualizations/detailed_pre_vs_post_formation_analysis.pdf"
echo "  • results/visualizations/ideology_correlation_analysis.pdf"
echo "  • results/statistics/pre_vs_post_formation_comparison.csv"
echo "  • results/statistics/node_attributes_pre_election.csv"
echo "  • results/statistics/node_attributes_post_formation.csv"
echo ""
echo "All Results:"
echo "  • Visualizations: results/visualizations/"
echo "  • Statistics: results/statistics/"
echo "  • Edge Lists: results/edge_lists/"
echo ""
