# Electoral Cycle Network Analysis: Dutch Parliament 2023-2024

## Overview

This repository contains a comprehensive social network analysis of co-voting patterns between political parties in the Dutch House of Representatives during the 2023-2024 electoral cycle. The **primary analysis** compares party cooperation networks from **1 year before the 2023 election** vs. **1 year after the 2024 cabinet formation**, examining how party voting behavior changes across this critical transition period. Supplementary analyses explore shorter time windows (3-month and 1-month) for robustness checks.

---

## Repository Structure

```
├── README.md                      # This file
│ 
├── report/                        # Quarto report documents
│   ├── SNA4DSprojectTemplate2025.qmd   # Main report source
│   ├── r-references.bib           # Bibliography
│   ├── Picture1.png               # Kieskompas visualization
│   ├── Picture2.png               # Extracted coordinates
│   └── _output/                   # Rendered PDFs
├── data/                          # Raw voting data
│   ├── voting_data_2023_preelection.csv  # 2023 voting records
│   ├── voting_data_clean.csv      # 2024 voting records
│   └── political_axes_data.csv    # Party ideology (Kieskompas 2023)
├── scripts/                       # R analysis scripts
│   ├── fetch_voting_data.R        # Fetch data from Tweede Kamer API
│   │
│   ├── pre_election_vs_post_formation_analysis.R ⭐ # PRIMARY: 1 year comparison (raw)
│   ├── pre_election_vs_post_formation_analysis_normalized.R ⭐ # (z-score)
│   │
│   ├── ideology_correlation_analysis.R # Test correlation between ideology dimensions
│   │
│   ├── three_month_pre_election_vs_post_formation.R # 3 month comparison (raw)
│   ├── three_month_pre_election_vs_post_formation_normalized.R # (z-score)
│   │
│   ├── one_month_pre_election_vs_post_formation.R # 1 month comparison (raw)
│   ├── one_month_pre_election_vs_post_formation_normalized.R # (z-score)
│   │
│   ├── analyze_components.R       # Component analysis
│   ├── generate_network_statistics.R # Comprehensive statistics
│   ├── analyze_vote_unanimity.R   # Vote distribution validation
│   └── add_ideology_attributes.R  # Helper: Add Kieskompas data to networks
└── results/
    ├── visualizations/            # Network plots (PDFs)
    ├── statistics/                # Summary statistics (CSV)
    └── edge_lists/                # Network edge data (CSV)
```

---

## Analysis Approaches

### Temporal Comparisons

| Analysis | Time Periods | Use Case | Status |
|----------|-------------|----------|---------|
| **1-Year Comparison** ⭐ | 1 year before election vs 1 year after formation | Long-term structural changes | **PRIMARY ANALYSIS** |
| **3-Month Comparison** | 3 months before election vs 3 months after formation | Robustness check (medium-term) | Supplementary |
| **1-Month Snapshot** | 1 month before election vs 1 month after formation | Robustness check (short-term) | Supplementary |

### Network Types

- **Raw Weight Networks**: Edges weighted by absolute number of agreements
  - Shows actual cooperation volume
  - Affected by voting activity levels

- **Z-Score Normalized Networks**: Edges weighted by standardized cooperation
  - Formula: `z = (weight - mean) / sd`
  - Compares relative cooperation patterns
  - Independent of vote volume differences

---

## Quick Start

### 1. Render the Report

```bash
cd report/
quarto render SNA4DSprojectTemplate2025.qmd
```

**Output:** `report/_output/SNA4DSprojectTemplate2025.pdf`

### 2. Fetch Data from API (Optional)

**Note:** The data is already included in the repository. Only run this if you need to update with the latest votes from the Tweede Kamer.

```bash
Rscript scripts/fetch_voting_data.R
```

This fetches voting data via the Open Data Portal API and saves:
- `data/voting_data_2023_preelection.csv` (2023 votes)
- `data/voting_data_clean.csv` (2024 votes)

### 3. Run Network Analysis

**PRIMARY ANALYSIS (1-Year Comparison):**
```bash
# Raw weights (for descriptive analysis)
Rscript scripts/pre_election_vs_post_formation_analysis.R

# Z-score normalized (for QAP/ERGM)
Rscript scripts/pre_election_vs_post_formation_analysis_normalized.R
```

**Ideology Correlation Analysis:**
```bash
# Test correlation between left/right and conservative/progressive dimensions
Rscript scripts/ideology_correlation_analysis.R
```

**Supplementary Analyses (Robustness Checks):**
```bash
# 3-month comparison
Rscript scripts/three_month_pre_election_vs_post_formation.R
Rscript scripts/three_month_pre_election_vs_post_formation_normalized.R

# 1-month snapshot
Rscript scripts/one_month_pre_election_vs_post_formation.R
Rscript scripts/one_month_pre_election_vs_post_formation_normalized.R
```

**Run All Analyses at Once:**
```bash
./run_all_analyses.sh
```

**Additional Validation:**
```bash
# Analyze vote unanimity (validates that agreements reflect cooperation)
Rscript scripts/analyze_vote_unanimity.R

# Generate comprehensive statistics across all periods
Rscript scripts/generate_network_statistics.R
```

---

## Key Files

### Documentation
- **`README.md`** - Project overview and quick start guide
- **`report/SNA4DSprojectTemplate2025.qmd`** ⭐ - Full methodology section (Dataset + Biases)

### Primary Analysis Outputs (1-Year Comparison)

| File | Content |
|------|---------|
| `network_comparison_pre_vs_post_formation.pdf` ⭐ | Side-by-side network visualization (raw weights) |
| `detailed_pre_vs_post_formation_analysis.pdf` ⭐ | Degree distributions, communities, party types |
| `network_changes_pre_vs_post_formation.pdf` ⭐ | Network metrics comparison & percent changes |
| `pre_vs_post_formation_comparison.csv` ⭐ | Network statistics comparison table |
| `node_attributes_pre_election.csv` ⭐ | Node attributes with Kieskompas coordinates (for QAP) |
| `node_attributes_post_formation.csv` ⭐ | Node attributes with Kieskompas coordinates (for QAP) |
| `edges_pre_election.csv` | Edge list (pre-election network) |
| `edges_post_formation.csv` | Edge list (post-formation network) |

### Ideology Analysis

| File | Content |
|------|---------|
| `ideology_correlation_analysis.pdf` | Correlation tests & visualizations |
| `ideology_correlation_results.csv` | Pearson & Spearman correlation statistics |
| `ideology_quadrant_classification.csv` | Party classifications by ideology quadrant |

### Supplementary Analyses (Robustness Checks)

| File | Content |
|------|---------|
| `network_comparison_three_month_pre_vs_post_formation.pdf` | 3-month comparison (raw) |
| `network_comparison_three_month_pre_vs_post_formation_normalized.pdf` | 3-month comparison (z-score) |
| `three_month_pre_vs_post_formation_comparison.csv` | 3-month comparison stats |
| `network_comparison_one_month_pre_vs_post_formation.pdf` | 1-month snapshot (raw) |
| `network_comparison_one_month_pre_vs_post_formation_normalized.pdf` | 1-month snapshot (z-score) |
| `one_month_pre_vs_post_formation_comparison.csv` | 1-month comparison stats |

### Validation

| File | Content |
|------|---------|
| `vote_unanimity_summary.pdf` | Vote balance validation (confirms cooperation patterns) |
| `vote_unanimity_statistics.csv` | Vote distribution analysis by period |

---

## Data Sources

### Parliamentary Voting Data
- **Source:** Tweede Kamer OData API
- **Coverage:** 2023-2024 electoral cycle
- **Records:** 82,365 votes across 5,213 motions from 23 parties
- **Files:** 
  - `voting_data_2023_preelection.csv` (69,544 records)
  - `voting_data_clean.csv` (49,472 records)

### Party Ideology Data
- **Source:** Kieskompas 2023
- **Dimensions:** Left-Right & Conservative-Progressive axes
- **Scale:** -1 to +1 on each dimension
- **Coverage:** 18 parties with coordinates
- **File:** `political_axes_data.csv`
- **Use:** Node attributes for Study 1 (QAP analysis) and Study 2 (ERGM)
- **Correlation:** Strong negative correlation (r = -0.846, p < 0.001)
  - Left-wing parties tend to be progressive
  - Right-wing parties tend to be conservative
  - **Implication:** Potential multicollinearity if both dimensions used as predictors

---

## Temporal Periods

### Key Political Events
- **Election Date:** November 22, 2023
- **Cabinet Formation:** July 5, 2024 (Schoof I)

### Primary Analysis: One-Year Comparison ⭐
- **Pre-Election Period:** November 22, 2022 - November 21, 2023 (1 year before election)
  - **Data:** 3,309 motions, 69,544 votes, 25 parties
  - **Context:** Final year of Rutte IV cabinet before election
- **Post-Formation Period:** July 5, 2024 - July 4, 2025 (1 year after formation)
  - **Data:** 5,004 motions, 33,177 votes, 17 parties  
  - **Context:** First year of Schoof I cabinet
- **Network Structure:** 
  - Both networks include same 28 unique parties (for QAP compatibility)
  - Inactive parties connected with minimal edges (0.001 weight) for ERGM compatibility

### Supplementary Analysis: Three-Month Comparison
- **Pre-Election:** August 22, 2023 - November 21, 2023 (3 months before election)
  - 1,102 motions, 23,850 votes, 22 parties
- **Post-Formation:** July 5, 2024 - October 4, 2024 (3 months after formation)
  - 243 motions, 1,599 votes, 15 parties

### Supplementary Analysis: One-Month Snapshot
- **Pre-Election:** October 22, 2023 - November 21, 2023 (1 month before election)
  - 588 motions, 12,447 votes, 21 parties
- **Post-Formation:** July 5, 2024 - August 4, 2024 (1 month after formation)
  - 27 motions, 269 votes, 15 parties

---

## Network Construction

### Edge Definition
- **Nodes:** Political parties
- **Edges:** Co-voting agreements between party pairs
- **Edge Weight (Raw):** Number of motions where both parties voted the same way
- **Edge Weight (Z-Score):** Standardized cooperation within each period

### Filtering
- Minimum 5 shared votes required for edge creation
- Duplicate votes removed (one vote per party per motion)
- **Note:** Raw data contains 2,745 duplicate votes (same party voting multiple times on same motion) which are properly deduplicated

### Visualization (Based on Kieskompas 2023 Data)
- **RED nodes** = Left-wing parties (BIJ1, PvdD, GroenLinks-PvdA, SP, DENK, ChristenUnie, 50PLUS)
- **ORANGE nodes** = Center parties (Volt, D66, NSC, BBB)
- **BLUE nodes** = Right-wing parties (CDA, VVD, SGP, PVV, JA21, FVD, BVNL)
- **Node size** = Degree centrality (more connections = larger)
- **Edge thickness** = Cooperation strength
- **Edge highlighting:** 
  - Raw networks: 30% above mean weight
  - Z-score networks: z > 1.0

---

## Requirements

### R Packages
```r
install.packages(c("lubridate", "igraph", "ggplot2"))
```

**Note:** Scripts use only base R, `lubridate`, `igraph`, and `ggplot2`. No `dplyr` or `tidyr` dependencies.

### Report Rendering
```bash
# Install Quarto: https://quarto.org/docs/get-started/
```

---

## Key Findings

### Primary Finding: One-Year Comparison (Pre-Election vs. Post-Formation) ⭐

**Network Structure Changes:**
- **Active Nodes:** 25 → 17 parties (-32.0%)
  - Both networks include same 28 total nodes for QAP/ERGM compatibility
- **Edges:** 223 → 112 (-49.8%)
- **Density:** 0.743 → 0.824 (+10.8%)
- **Mean Degree:** 17.8 → 13.2 (-26.1%)
- **Transitivity:** High in both periods (clustering coefficient)
- **Components:** 5 → 3 (network became more integrated)

**Interpretation:**
- **Fewer active parties** but **higher density** → more concentrated cooperation
- **Network consolidation** post-formation (fewer disconnected components)
- Despite fewer parties, remaining parties cooperate more intensively

**Kieskompas Ideology Findings:**
- **Strong correlation** between left/right and conservative/progressive (r = -0.846, p < 0.001)
- **8 Left-Progressive parties** (BIJ1, Volt, PvdD, GroenLinks-PvdA, D66, DENK, SP, ChristenUnie)
- **8 Right-Conservative parties** (CDA, VVD, BBB, SGP, PVV, JA21, BVNL, FVD)
- **2 Left-Conservative parties** (50PLUS, NSC)
- **0 Right-Progressive parties**
- **Implication:** Single ideology dimension may be sufficient for QAP (multicollinearity concern)

### Robustness Checks

**Three-Month Comparison:**
- Nodes: 22 → 15 (-31.8%), Edges: 211 → 105 (-50.2%), Density: 0.913 → 1.000 (+9.5%)
- Similar pattern to 1-year analysis

**One-Month Snapshot:**
- Nodes: 21 → 15 (-28.6%), Edges: 210 → 61 (-70.9%), Density: 1.000 → 0.581 (-41.9%)
- Note: Limited post-formation data (only 27 motions)

### Data Validation

**Vote Unanimity Analysis:**
- **Mean Agreement Rate:** 55-56% across all periods
- **Near-Unanimous Votes:** ~20% of motions
- **Balanced Votes:** ~30% of motions
- **Conclusion:** Agreement rates reflect genuine cooperation patterns, not unanimous voting

---

## Research Design

This project consists of two complementary studies examining party cooperation networks:

### Study 1: QAP Analysis (Network Comparison)
- **Research Question:** Does party voting behavior change significantly between the pre-election and post-formation periods?
- **Method:** Quadratic Assignment Procedure (QAP) to test network similarity
- **Networks:** Both pre-election and post-formation networks (same 28 nodes)
- **Node Attributes:** Kieskompas ideology data (left/right, conservative/progressive)
- **Focus:** Whether cooperation patterns are significantly different across time periods

### Study 2: ERGM Analysis (Network Formation)
- **Research Question:** What factors predict tie formation in party cooperation networks?
- **Method:** Exponential Random Graph Models (ERGM)
- **Network Requirements:** 
  - Connected networks (no isolates) → achieved via minimal edges (0.001 weight)
  - Rich attribute data for hypothesis testing
- **Hypotheses:** Testing effects of ideology, government status, party size, etc.
- **Focus:** Understanding mechanisms behind cooperation network structure

---

## Citation

```bibtex
@misc{dutch_parliament_network_2025,
  title={Electoral Cycle Network Analysis: Dutch Parliament 2023-2024},
  author={[Your Name]},
  year={2025},
  url={[Repository URL]}
}
```

---

## License

This project is for academic research purposes.

---

## Contact

For questions or issues, please open an issue in the repository.
