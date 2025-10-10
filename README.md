# Electoral Cycle Network Analysis: Dutch Parliament 2023-2024

## Research Question

**Do co-voting patterns between parties change across the electoral cycle?**

---

## Study Design

| Period | Timeframe | Event |
|--------|-----------|-------|
| **Far from Election** | Q1+Q2 2023 | Normal operations (Rutte IV) |
| **Close to Election** | Q3+Q4 2023 | **Election: Nov 22, 2023** |
| **Post Formation** | Q3+Q4 2024 | **New cabinet: July 2, 2024** (Schoof I) |

---

## Repository Structure

```
├── README.md
├── data/                          # Raw voting data
├── scripts/                       # R analysis scripts
│   ├── three_period_network_analysis.R              # Raw weights
│   ├── three_period_network_analysis_normalized.R   # Z-scores ⭐
│   ├── analyze_components.R
│   └── generate_network_statistics.R
├── results/
│   ├── visualizations/            # PDF plots
│   ├── statistics/                # CSV tables
│   └── edge_lists/                # Network data
└── archive/                       # Old analyses
```

---

## Quick Start

### Run Main Analysis (Z-Score Normalized)
```bash
Rscript scripts/three_period_network_analysis_normalized.R
```

**Key output:** `results/visualizations/network_comparison_normalized.pdf`

### Generate Full Statistics
```bash
Rscript scripts/generate_network_statistics.R
```

**Key output:** `results/statistics/comprehensive_network_statistics.csv`

---

## Methodology

### Network Construction
- **Nodes:** Political parties
- **Edges:** Co-voting ties (min 5 shared votes)
- **Weight:** Number of agreements between parties

### Z-Score Normalization

**Why?** Post-formation has 65% fewer votes → raw counts incomparable

**Solution:** Standardize within each period: `z = (weight - mean) / sd`

**Result:** Compare cooperation **patterns** not just volumes

**Interpretation:**
- `z > 1.0`: Strong tie (above average)
- `z > 2.0`: Very strong tie (top ~2%)

---

## Key Visualizations

| File | Content | Best For |
|------|---------|----------|
| `network_comparison_normalized.pdf` ⭐ | Z-score networks | **Answering RQ** |
| `network_comparison_three_periods.pdf` | Raw weight networks | Volume comparison |
| `raw_vs_normalized_comparison.pdf` | Side-by-side | Understanding normalization |
| `comprehensive_network_statistics.csv` | All metrics | Statistical reporting |

**Node colors:** 🔴 Left, 🟠 Center, 🔵 Right

---

## Requirements

```r
install.packages(c("dplyr", "lubridate", "igraph", "ggplot2", "tidyr"))
```

---

## Data Sources

- **Tweede Kamer OData API**
- 2023: 69,544 votes across 3,309 motions
- 2024: 12,821 votes across 1,952 motions (Q3-Q4 only)

---
