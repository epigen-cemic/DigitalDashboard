# Geospatial Help

**Digital Dashboard**  
Using and interpreting maps in the Digital Dashboard  
Documentation revision: June 2026  
Language: English

---

# 1. Scope in the Dashboard

The Geospatial component aggregates cases and population for the selected geographic level and time window, joins those results to the configured GeoPackage layer, and produces prevalence and spatial-cluster outputs.

> **All units are mapped.** The current Dashboard maps every available unit at the selected level and time window. The Locations selector currently affects CUSUM only.

Population is required because prevalence is calculated as cases divided by population and multiplied by the configured rate multiplier, currently 100,000.


# 2. Configure the maps

| Control | Meaning |
| --- | --- |
| Geographic Level | Administrative level and spatial layer used for maps. |
| Year | Epidemiological year included in the mapped output. |
| Single Week | Uses one epidemiological week. |
| Week Range | Aggregates cases across an inclusive week interval; the range must contain at least two weeks when possible. |
| Population | Required denominator; repeated weekly population values are deduplicated before aggregation. |
| Run Analysis | Rebuilds the mapped data and spatial statistics. |

1. Activate the required data files.
2. Choose Geographic Level.
3. Select year and Single Week or Week Range.
4. Select Run Analysis.
5. Use Display to show the prevalence map, LISA map, table, layout, font size, and decimals.

> **Identifier matching.** CSV geographic codes must match the configured spatial identifiers after normalization and zero padding. Unmatched codes cannot be mapped.


# 3. Read the outputs

The prevalence map shows cases per 100,000 for every matched unit. Its legend remains visible and map popups provide unit name, identifier, cases, population, prevalence, LISA category, and p-value when available.

Global Moran's I summarizes overall spatial autocorrelation. A statistically meaningful positive value suggests similar values cluster; a negative value suggests neighbouring dissimilarity. It does not identify which units form local clusters.

| LISA category | Meaning |
| --- | --- |
| High-High | High-value unit surrounded by high-value neighbours; potential hot spot. |
| Low-Low | Low-value unit surrounded by low-value neighbours; potential cold spot. |
| High-Low | High-value unit among low-value neighbours; spatial outlier. |
| Low-High | Low-value unit among high-value neighbours; inverse outlier. |
| Not Significant | No local association meeting the current significance rule. |

The results table contains identifiers, names, cases, population, weeks, prevalence, LISA category, and p-value. Prepared Data records the aggregation, identifier normalization, join, and spatial calculation steps.


# 4. Interpret responsibly

- Moran and LISA describe spatial association, not causation.
- LISA classifications depend on neighbour definitions, available units, data quality, and the selected time window.
- Small populations can create unstable prevalence values.
- A cluster can reflect reporting intensity, access, mobility, population structure, or local practice rather than transmission alone.
- Compare maps with CUSUM trends, denominators, local intelligence, and surveillance context.

> **Range maps.** In week-range mode, cases are summed across the selected weeks while repeated population records are deduplicated before the denominator is aggregated.


# 5. Troubleshooting

| Problem | Check |
| --- | --- |
| Map is blank or missing units | Check active data, population, GeoPackage availability, layer configuration, and identifier matching. |
| Locations does not filter maps | This is current Dashboard behavior; maps use all units at the selected level. |
| No Moran banner or LISA | There may be too few matched units, no variance, missing neighbours, or a failed spatial test. |
| Unexpected prevalence | Review population deduplication, selected time window, and rate multiplier. |
| No map download | Screenshot packages may be unavailable; CSV data downloads can still work. |
| Display changed but map data did not | Structural filter changes require Run Analysis. |

