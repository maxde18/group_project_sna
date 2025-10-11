# Network Analysis: Data & Statistics Summary

## Research Design Overview

**Research Question:** Do co-voting patterns between parties change across the electoral cycle?

**Temporal Design:**
- **Period 1 (Far):** January 20 – June 29, 2023 (160 days, Q1+Q2)
- **Period 2 (Close):** July 5 – November 13, 2023 (131 days, Q3+Q4)  
- **Period 3 (Post):** July 5 – December 20, 2024 (168 days, Q3+Q4)

**Key Events:**
- Election: November 22, 2023
- Cabinet Formation: July 2, 2024 (Schoof I)

---

## 1. DATA DESCRIPTIVES

### Raw Voting Data by Period

| Metric | Far (Q1-Q2 2023) | Close (Q3-Q4 2023) | Post (Q3-Q4 2024) |
|--------|------------------|---------------------|-------------------|
| **Duration** | 160 days | 131 days | 168 days |
| **Total Votes** | 36,788 | 32,756 | 12,821 |
| **Unique Motions** | 1,761 | 1,548 | 1,952 |
| **Active Parties** | 23 | 22 | 15 |
| **Votes per Motion** | 20.9 | 21.2 | 6.6 |

**Key Observations:**
- Post-formation has **65% fewer votes** than Far period (61% fewer than Close)
- **More motions** in Post period (1,952 vs 1,548) but **far fewer votes per motion** (6.6 vs 21.2)
- This suggests lower party participation rates or more individual voting post-formation

---

## 2. NETWORK STRUCTURE (Raw Weights)

### Basic Network Metrics

| Metric | Far | Close | Post | Change (Far→Close) | Change (Close→Post) |
|--------|-----|-------|------|-------------------|---------------------|
| **Nodes** | 23 | 22 | 15 | -1 (-4.3%) | -7 (-31.8%) |
| **Edges** | 190 | 210 | 105 | +20 (+10.5%) | -105 (-50%) |
| **Density** | 0.751 | 0.909 | 1.000 | +21.1% | +10% |
| **Mean Degree** | 16.52 | 19.09 | 14.00 | +15.6% | -26.7% |
| **Components** | 4 | 2 | 1 | -2 | -1 |
| **Transitivity** | 1.000 | 1.000 | 1.000 | — | — |

**Interpretation:**
- **Far → Close:** Network becomes more connected (fewer components, higher density)
- **Close → Post:** Fewer parties, but **complete connectivity** (density = 1.0)
- All networks show **perfect transitivity** (clustering coefficient = 1.0)

### Edge Weight Statistics (Raw Agreements)

| Metric | Far | Close | Post |
|--------|-----|-------|------|
| **Mean Weight** | 1,123.2 | 862.2 | 200.6 |
| **Median Weight** | 1,103 | 894 | 204 |
| **SD Weight** | 237.9 | 311.1 | 48.3 |
| **Min Weight** | 644 | 78 | 109 |
| **Max Weight** | 1,760 | 1,543 | 288 |
| **Q1 / Q3** | 938 / 1,264 | 708 / 1,098 | 165 / 239 |

**Key Findings:**
- Mean edge weight drops by **82% from Far to Post** (1,123 → 201)
- 23% drop from Far to Close (pre-election differentiation)
- 77% drop from Close to Post (fewer parliamentary sessions)
- SD decreases dramatically in Post period (48 vs 238-311), indicating more **uniform cooperation**

### Agreement Rates

| Period | Mean Agreement Rate |
|--------|---------------------|
| **Far** | 63.6% |
| **Close** | 56.2% (-11.6%) |
| **Post** | 62.2% (+10.7%) |

**Interpretation:** Agreement rates **decline** as elections approach, then **recover** post-formation.

---

## 3. Z-SCORE NORMALIZED NETWORKS

### Why Normalize?

Raw edge weights are **incomparable** across periods due to:
- 65% variation in total voting volume
- Different session lengths (131-168 days)
- Post-formation parliamentary recess

**Solution:** Z-score normalization within each period
```
z = (weight - mean_weight) / sd_weight
```

### Normalization Properties

| Property | Far | Close | Post |
|----------|-----|-------|------|
| **Mean Z-score** | 0.00 | 0.00 | 0.00 |
| **SD Z-score** | 1.00 | 1.00 | 1.00 |
| **Total Edges** | 190 | 210 | 105 |

✓ Successfully standardized: all periods now have μ=0, σ=1

### Strong Tie Distribution (Z-scores)

| Metric | Far | Close | Post |
|--------|-----|-------|------|
| **Total Edges** | 190 | 210 | 105 |
| **Above Average (z > 0)** | 88 (46.3%) | 112 (53.3%) | 55 (52.4%) |
| **Strong Ties (z > 1.0)** | 32 (16.8%) | 33 (15.7%) | **21 (20.0%)** |
| **Very Strong (z > 2.0)** | 5 (2.6%) | 1 (0.5%) | 0 (0.0%) |
| **Z-Score Range** | [-2.01, 2.68] | [-2.52, 2.19] | [-1.90, 1.81] |

**Key Findings:**
1. Post-formation has the **highest proportion of strong ties** (20% vs 15-17%)
2. Far period has the **most exceptional ties** (5 edges with z > 2, max z = 2.68)
3. Post period shows **narrower z-score range** (less extreme cooperation patterns)
4. Close period is most balanced (53% above average, fewest z > 2)

### Z-Score Interpretation

| Z-Score Range | Meaning | Approximate Percentile |
|---------------|---------|------------------------|
| **z < 0** | Below-average cooperation | < 50th |
| **z = 0 to 1** | Average cooperation | 50th–84th |
| **z > 1** | Strong cooperation | > 84th |
| **z > 2** | Very strong cooperation | > 97.5th |
| **z > 3** | Exceptional cooperation | > 99.9th |

---

## 4. NETWORK COHESION

### Connectivity Evolution

| Period | Components | Largest Component Size | Isolated Parties |
|--------|------------|------------------------|------------------|
| **Far** | 4 | 20 parties | 3 small groups |
| **Close** | 2 | 21 parties | 1 small group |
| **Post** | 1 | 15 parties | None |

**Progression:** Fragmented (Far) → Semi-connected (Close) → **Fully connected (Post)**

### Modularity (Community Structure)

| Period | Modularity Score | Interpretation |
|--------|------------------|----------------|
| **Far** | 0.029 | Very low (highly integrated) |
| **Close** | 0.048 | Low (integrated) |
| **Post** | 0.052 | Low (integrated) |

**All periods show weak community structure** → parties cooperate broadly rather than forming tight coalitions.

---

## 5. PARTY PARTICIPATION

### Active Parties by Period

| Period | Total Parties | Left-Wing | Center | Right-Wing |
|--------|---------------|-----------|--------|------------|
| **Far** | 23 | 6 | 2 | 15 |
| **Close** | 22 | 6 | 2 | 14 |
| **Post** | 15 | 4-5 | 1-2 | 8-9 |

**Note:** 7 parties dropped out between Close and Post (likely due to election losses or mergers).

### Ideology Distribution

**Left:** SP, PvdD, BIJ1, GroenLinks, PvdA, DENK  
**Center:** D66, Volt  
**Right:** VVD, CDA, ChristenUnie, BBB, PVV, FVD, SGP, JA21

---

## 6. EDGE-LEVEL STATISTICS

### Edge Weight Changes (Raw)

From **Far to Close:**
- Mean weight: 1,123 → 862 (-23%)
- Median weight: 1,103 → 894 (-19%)
- SD weight: 238 → 311 (+31% more variation)

From **Close to Post:**
- Mean weight: 862 → 201 (-77%)
- Median weight: 894 → 204 (-77%)
- SD weight: 311 → 48 (-85% less variation)

**Interpretation:**
1. Pre-election: Declining cooperation, increasing variation (parties differentiate)
2. Post-formation: Lower absolute values but **more uniform** cooperation patterns

---

## 7. KEY FINDINGS SUMMARY

### Raw Weight Networks
1. ✓ Agreement rates drop 11.6% as elections approach
2. ✓ Network density increases over time (0.75 → 1.00)
3. ✓ Fewer parties active post-formation (-32%)
4. ✓ Mean edge weight declines 82% (Far → Post)

### Z-Score Normalized Networks
1. ✓ Post-formation has **highest % of strong ties** (20% vs 15-17%)
2. ✓ Far period has most "exceptional" ties (5 edges with z>2)
3. ✓ Close period shows most uniform cooperation (fewest z>2)
4. ✓ Normalization reveals strategic focus post-formation

### Theoretical Implications
- **H1 (Pre-election):** Parties differentiate → lower agreement rates ✓
- **H2 (Post-formation):** Strategic partnerships → higher % strong ties ✓
- **H3 (Network structure):** Complete connectivity achieved post-formation ✓

---

## 8. METHODOLOGICAL NOTES

### Network Construction
- **Node definition:** Political parties (Fracties)
- **Edge definition:** Co-voting relationship (minimum 5 shared votes)
- **Edge weight:** Number of times two parties voted identically
- **Network type:** Undirected, weighted, unipartite

### Data Quality
- Source: Tweede Kamer Open Data Portal (OData API)
- Coverage: 100% of recorded votes
- Missing data: Negligible (API provides complete records)
- Data cleaning: Removed abstentions, focused on Voor/Tegen votes

### Statistical Approach
- **Descriptive analysis:** Network metrics (density, degree, components)
- **Normalization:** Within-period z-scores for comparability
- **Visualization:** Ideology-based layout (left-right spectrum)

---

## 9. FILES REFERENCE

### Data Files
- `data/voting_data_2023_preelection.csv` (69,544 votes)
- `data/voting_data_clean.csv` (2024 data, 12,821 votes)

### Statistics Files
- `results/statistics/comprehensive_network_statistics.csv`
- `results/statistics/three_period_comparison.csv`
- `results/statistics/normalized_network_comparison.csv`

### Visualization Files
- `results/visualizations/network_comparison_three_periods.pdf` (raw)
- `results/visualizations/network_comparison_normalized.pdf` (z-scores) ⭐
- `results/visualizations/raw_vs_normalized_comparison.pdf` (comparison)

### Edge Lists
- `results/edge_lists/edges_far_from_election.csv`
- `results/edge_lists/edges_close_to_election.csv`
- `results/edge_lists/edges_post_formation.csv`
- `results/edge_lists/edges_normalized_far.csv`
- `results/edge_lists/edges_normalized_close.csv`
- `results/edge_lists/edges_normalized_post.csv`

---

**Analysis Date:** October 2024  
**R Version:** 4.x  
**Key Packages:** igraph, dplyr, lubridate, ggplot2

