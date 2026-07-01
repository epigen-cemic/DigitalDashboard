# User Manual

**Digital Dashboard**  
Unified CUSUM and geospatial analysis workflow  
Documentation revision: June 2026  
Language: English

---

# 1. What the Dashboard does

The Digital Dashboard combines the CUSUM RAP and Geospatial RAP workflows in one interface. One upload and one set of shared filters feed early-warning plots, prevalence maps, LISA maps, tables, prepared datasets, and downloads.

| Navigation page | Purpose |
| --- | --- |
| Home | Overview and recommended workflow. |
| Dashboard | Upload, filters, CUSUM parameters, Run Analysis, outputs, tables, and prepared data. |
| Display | Choose visible plots/maps, layout, table location, font size, decimals, and optional reactive updates. |
| Help | Workflow summary and documentation links. |

> **Two different location behaviors.** The Locations selector limits CUSUM units. The current Geospatial workflow still maps all units available at the selected geographic level and time window.


# 2. Input files and file management

Use prepared API-POP-compatible delimited files. The file picker lists several extensions, but the supplied importer reads CSV-formatted text and detects comma or semicolon separators. CSV is therefore the reliable supported format for this build.

| Column | Requirement | Meaning |
| --- | --- | --- |
| country | Yes for current validation | Country value. Current source fixes active_country to Argentina. |
| year | Yes | Epidemiological year, 2000-2100. |
| week | Yes | Epidemiological week, 1-53. |
| level1..level4 | At least one | Geographic hierarchy columns used by the configured level. |
| n_cases | Yes | Observed cases; aliases cases, case_count, count, n. |
| population | Required for maps and manual mu0 | Population denominator used for prevalence maps and to convert the manual weekly rate per 100,000 into unit-specific expected counts; aliases n_population, pop, denominator. |

Each uploaded file is stored in the current session with its row count, column count, epidemiological range, modification time, and size. New files are active by default.

- Manage files: activate or deactivate files without re-uploading.
- Remove inactive files: deletes unchecked files from the current session.
- Clear all files: removes all uploaded data and analysis results from the session.
- Changing active files invalidates existing CUSUM and geospatial results; run the analysis again.

> **No database write.** The current Dashboard analyses uploaded session data. It does not append the upload to a persistent epidemiological database.


# 3. Shared filters and CUSUM settings

| Control | Effect |
| --- | --- |
| Geographic Level | Sets the administrative level used by both analytical engines. |
| Detection Period | Number of recent weeks used by CUSUM; UI range 8-260, default 52. |
| Locations | Selected by default for all available units. Changes affect CUSUM only in the current implementation. |
| Year | Year used for geospatial maps and the available week slider. |
| Map Time Window | Single week or inclusive week range. Range mode enforces at least two weeks when possible. |
| Expected Frequency | Automatic unit-level expected count or manual weekly rate per 100,000 converted to a count using each unit's population. |
| Target ARL0 | Used to display a recommended h. |
| Relative Risk | Used to calculate k. |
| h Threshold | CUSUM alarm threshold. |
| Run Analysis | Refreshes both CUSUM and Geospatial outputs using the current active data and selections. |

Calculated k and recommended h appear under the CUSUM settings when enough information is available.

> **Run required after structural changes.** Changes to active data, Geographic Level, or Locations require Run Analysis. Display settings can be changed before or after a run.


# 4. Configure the Display page

Display settings may be configured before the first analysis or changed afterward. They control presentation, not the underlying data.

| Setting | Options and behavior |
| --- | --- |
| Visible outputs | CUSUM overview, CUSUM series, CUSUM process, Prevalence map, LISA map. |
| Output layout | One or two columns. |
| Results table location | Inside Output, or in a separate Output Table tab within Dashboard. |
| Display font size | Small, Medium, Large, or Extra large. |
| Decimal places | 0-6 decimals in on-screen tables; CSV precision is unchanged. |
| Reactive display | After a successful run, CUSUM parameter changes and map year/week/time-mode changes can refresh results automatically. |

Reactive display does not automatically apply active-file, geographic-level, or location changes. Those changes still require Run Analysis.


# 5. Run and review the Dashboard

1. Upload and activate the required CSV files.
2. Set Geographic Level, Locations, Detection Period, Year, and Map Time Window.
3. Configure CUSUM parameters.
4. Optionally configure Display.
5. Select Run Analysis.
6. Review Output, Prepared Data, and the optional Output Table tab.

## CUSUM outputs

- CUSUM overview: alarm heatmap across selected CUSUM units.
- CUSUM series plot: observed and expected values for the selected detailed unit.
- CUSUM process plot: cumulative statistic and threshold.
- CUSUM weekly results and unit-level reference tables.

## Geospatial outputs

- Prevalence map for all matched units at the selected level.
- LISA cluster map using the same spatial units and time window.
- Global Moran summary where the data support it.
- Geospatial results table.

## Prepared Data

The Dashboard exposes two prepared datasets: CUSUM prepared data and Active standardized data. Each can be downloaded as CSV. The tables support a selected-column Search by filter.

> **Download availability.** Download buttons appear only after the corresponding result exists. Map image export also depends on optional screenshot packages in the deployment.


# 6. How the two analyses use time and geography

| Dimension | CUSUM | Geospatial |
| --- | --- | --- |
| Locations | Restricted to the selected Locations. | Current implementation ignores the Locations subset and uses all units at Geographic Level. |
| Detection period | Controls the recent CUSUM window. | Not used. |
| Year | CUSUM preparation uses the available weekly history rather than the map Year selector. | Filters the map data to the selected year. |
| Week selection | Not controlled by Map Time Window. | Uses the selected single week or inclusive range. |
| Population | Required for manual mu0; optional for automatic mu0. | Required for prevalence. |
| Geographic level | Builds CUSUM units at the selected level. | Loads and joins the configured layer for the selected level. |

> **Avoid misinterpretation.** Do not assume a selected Locations subset also clips the maps. The current maps remain a complete level-wide comparison.


# 7. Interpretation and exports

- CUSUM alarms are early warnings requiring epidemiological review.
- Prevalence maps are descriptive and depend on numerator and denominator quality.
- Global Moran describes overall spatial autocorrelation; LISA describes local clusters/outliers.
- Display choices do not change the analytical values.

| Export | Typical content |
| --- | --- |
| CUSUM PNG | Selected heatmap, series, or process plot. |
| Geospatial map PNG | Current map when screenshot support is installed. |
| CUSUM CSV | Weekly results or unit reference values. |
| Geospatial CSV | Joined spatial-analysis results. |
| Prepared CUSUM CSV | Dataset used by CUSUM. |
| Active Standardized CSV | Combined active data after column normalisation and code padding. |


# 8. Troubleshooting

| Problem | What to check |
| --- | --- |
| Uploaded XLSX/TSV does not load | Convert to comma- or semicolon-delimited CSV; the current reader is CSV based. |
| CUSUM completes but maps fail | Population, GeoPackage, map IDs, selected level, or year/week coverage may be missing. |
| Maps show all areas despite selected Locations | Expected current behavior; Locations restrict CUSUM only. |
| Range snaps to two weeks | Range mode enforces at least a two-week span when more than one week exists. |
| Outputs look stale | Run Analysis after active-data, level, or location changes. |
| Map download missing | Optional screenshot packages may not be installed. |
| Documentation link fails on Linux | Use the exact case-sensitive filenames included in the updated docs package. |

> **Escalation package.** Provide active filenames, filter values, CUSUM parameters, Display settings, exact error text, and whether CUSUM, Geospatial, or both failed.


# 9. Glossary

| Term | Meaning |
| --- | --- |
| Active file | An uploaded file currently included in the combined session data. |
| Standardized data | Uploaded columns after alias normalization, numeric conversion, trimming, and code padding. |
| Reactive display | Automatic rerun after eligible parameter changes, once an initial result exists. |
| Output Table | Optional Dashboard tab used when table placement is set to separate. |
| Prepared CUSUM data | Aggregated and completed weekly dataset used by the CUSUM engine. |
| Map Time Window | Year-specific week or week range used only by Geospatial analysis. |

