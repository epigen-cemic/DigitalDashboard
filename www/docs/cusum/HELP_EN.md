# CUSUM Help

**Digital Dashboard**  
Using and interpreting CUSUM outputs in the Digital Dashboard  
Documentation revision: June 2026  
Language: English

---

# 1. Scope in the Dashboard

The CUSUM component monitors weekly case counts for sustained increases above an expected baseline. It runs inside the shared Digital Dashboard workflow and uses the active uploaded files, selected geographic level, selected CUSUM locations, detection period, and CUSUM parameters.

> **Location behavior.** The Locations selector limits CUSUM units. It does not currently filter the Geospatial maps.

The map year and week controls are for Geospatial analysis. CUSUM instead uses the most recent weekly history required by the detection period and coverage rules.


# 2. Configure CUSUM

| Control | Meaning |
| --- | --- |
| Geographic Level | Administrative level used to create independent CUSUM units. |
| Locations | Selected units to include; an empty selection includes all available units at the chosen level. |
| Detection Period | Recent number of weeks used for CUSUM monitoring. |
| Expected Frequency | Automatic unit-specific expected count or manual weekly rate per 100,000 converted to a count using each unit's population. Population is required in manual mode. |
| Target ARL0 | Desired in-control average run length, used to recommend h. |
| Relative Risk | Increase the procedure is designed to detect; used to calculate k. |
| Calculated k | CUSUM reference value calculated from the expected count and relative risk. |
| h Threshold | Alarm threshold; higher values usually reduce alarm frequency. |

1. Upload and activate the required files.
2. Choose the geographic level and optional Locations.
3. Configure the CUSUM controls.
4. Select Run Analysis.
5. Use Display to choose visible CUSUM plots, table placement, font size, decimals, and reactive presentation changes.

> **Run Analysis.** Changes to files, geographic level, or selected Locations require a new analysis run. Display can reorganize existing results after a successful run.


# 3. Outputs and downloads

- Alarm overview: heatmap of alarm status by unit and recent week.
- Observed/expected series: compares weekly observed counts with the expected baseline.
- CUSUM process: shows accumulation of evidence and the threshold h.
- Weekly results: time-series values, statistic, alarm state, and parameters.
- Unit reference: expected weekly values and reference information once per unit.
- Prepared CUSUM data: cleaned, aggregated, overlap-resolved, and gap-completed dataset used by the analysis.

Download buttons appear only after the associated result exists. CSV downloads retain underlying numeric precision even when the visible tables use fewer decimal places.


# 4. Interpret responsibly

An alarm indicates that accumulated positive deviation from the expected weekly count reached h. It is an early-warning signal, not proof of an outbreak or a causal conclusion.

- Confirm reporting completeness and whether added zero weeks represent true zero cases.
- Check duplicate-file handling and active files.
- Review changes in case definition, laboratory access, surveillance intensity, or reporting delay.
- Compare neighbouring units and the Geospatial outputs where appropriate.
- Document the selected files, filters, expected-frequency method, RR, k, and h when escalating.

> **Interpretation.** A single high week may or may not alarm. Repeated moderate elevations can accumulate and trigger an alarm.


# 5. Troubleshooting

| Problem | Check |
| --- | --- |
| No CUSUM output | Confirm active files, Run Analysis, and that CUSUM outputs are enabled in Display. |
| Locations appear ignored | Locations affect CUSUM only; confirm the CUSUM plots/tables rather than the maps. |
| Coverage warning or stop | Inspect Prepared Data and confirm sufficient observed weeks before zero filling. |
| Manual baseline looks wrong | Enter the expected weekly rate per 100,000 people. The app converts that rate into expected weekly counts for each analysis unit using population. |
| Display changed but data did not | Display changes presentation; structural filters require Run Analysis. |
| CSV values differ from visible decimals | The table is formatted; the download retains full precision. |

