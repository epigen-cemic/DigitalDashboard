# Unified RAP Dashboard

This project combines the **CUSUM RAP** and **Geospatial RAP** tools into one Shiny dashboard. The analytical engines are still kept by domain, but the user workflow is now shared through a unified dashboard layer.

The dashboard provides:

- A shared upload and file-management workflow.
- Global filters used by both tools.
- CUSUM early-detection outputs.
- Geospatial prevalence and cluster-map outputs.
- A customizable dashboard where users choose which plots, maps, and tables to show.
- Optional legacy CUSUM and Geospatial pages for reference.

---

## Run the app

Open the project in RStudio and run:

```r
shiny::runApp(".")
```

Or from the R console while your working directory is the project root:

```r
shiny::runApp()
```

The app starts from `app.R`, which only sources `global.R` and calls:

```r
shinyApp(
  ui = appUI(),
  server = appServer
)
```

The app-level UI and server are defined in:

```text
R/modules/mod_app.R
```

---

## Main navigation

The top navigation contains:

- **Home** — landing page and general description.
- **Dashboard** — the main unified workflow.
- **Legacy CUSUM** — cleaned legacy CUSUM reference page.
- **Legacy Geospatial** — cleaned legacy Geospatial reference page.
- **Help** — documentation links and a modal showing the expected API-POP file structure.

Use the **Dashboard** tab for the current unified workflow.

---

## Current project structure

```text
RAP-Dashboard/
  app.R
  global.R
  config.json
  Unified-RAP-Dashboard.Rproj

  R/
    shared/
      app_state.R
      data_import.R
      file_manager.R
      ui_components.R

    modules/
      mod_app.R
      mod_unified_dashboard.R

      dashboard/
        dashboard_sidebar_ui.R
        dashboard_main_ui.R
        dashboard_file_server.R
        dashboard_filter_server.R
        dashboard_cusum_server.R
        dashboard_geo_server.R
        dashboard_output_server.R

    cusum/
      functions_cusum.R
      functions_io.R
      functions_parameters.R
      functions_plot.R
      mod_cusum.R

    geospatial/
      functions_io.R
      functions_spatial.R
      functions_plot.R
      mod_geospatial.R

  data/
    province_optimized.rds
    department_optimized.rds
    fraction_optimized.rds
    optimize_spatial_data.R
    README.md

  raw_data/
    Argentina.gpkg

  www/
    config.css
    AnalysisforAction_white.png
    default.ico

    docs/
      cusum/
        Documentation.pdf
        HELP_EN.md
        HELP_ES.md
        User_Manual.pdf

      geospatial/
        Geospatial RAP Tool.pdf
        HELP_EN.md
        HELP_ES.md
        User Manual.pdf
```

---

## Source loading order

`global.R` loads packages, shared helpers, analytical engines, legacy modules, and dashboard modules.

The current loading order is:

```text
1. Packages
2. Shared helpers
   - app_state.R
   - data_import.R
   - ui_components.R
   - file_manager.R
3. CUSUM analytical engine
4. Geospatial analytical engine
5. Legacy modules
6. Dashboard module pieces
7. Dashboard coordinator
8. App-level module
9. Runtime config
```

The order matters because `mod_unified_dashboard.R` calls the dashboard helper files, and `mod_app.R` calls `appUI()`, `appServer()`, `homeUI()`, `helpUI()`, and the legacy page wrappers.

---

## Dashboard architecture

The dashboard is intentionally split by responsibility.

### App shell

```text
R/modules/mod_app.R
```

Defines:

- `appUI()`
- `appServer()`

Responsibilities:

- Main app layout.
- Top navigation.
- Hidden tab navigation.
- Shared app state initialization.
- Help modal for API-POP file structure.
- Starting the dashboard, CUSUM legacy, and Geospatial legacy servers.

### Dashboard coordinator

```text
R/modules/mod_unified_dashboard.R
```

Defines:

- `unifiedDashboardUI(id)`
- `unifiedDashboardServer(id, app_state)`

Responsibilities:

- Coordinates the dashboard UI and server pieces.
- Keeps the main dashboard module small.
- Delegates file upload, filters, analysis, and output rendering to smaller files.

### Dashboard pieces

```text
R/modules/dashboard/
```

Contains:

| File | Purpose |
|---|---|
| `dashboard_sidebar_ui.R` | Sidebar layout: upload, global filters, CUSUM settings, geospatial settings, output customization. |
| `dashboard_main_ui.R` | Main dashboard panel container. |
| `dashboard_file_server.R` | Multi-file upload, uploaded-file modal, active-file selection, data-status display. |
| `dashboard_filter_server.R` | Global filter UI for level, locations, year, and week range. |
| `dashboard_cusum_server.R` | CUSUM preparation, parameter calculation, and CUSUM execution. |
| `dashboard_geo_server.R` | Geospatial validation, spatial join, prevalence calculation, and LISA computation. |
| `dashboard_output_server.R` | Summary cards, plots, maps, tables, and dynamic dashboard layout. |

---

## Shared helpers

```text
R/shared/
```

| File | Purpose |
|---|---|
| `app_state.R` | Creates the central `reactiveValues()` object used by the dashboard. |
| `data_import.R` | Reads and standardizes API-POP-style uploaded data. |
| `file_manager.R` | File-size formatting, year-week range detection, and active-file data rebuilding. |
| `ui_components.R` | Shared UI components such as header, navbar, home page, help page, cards, and legacy wrappers. |

The dashboard uses one central state object created by:

```r
create_app_state()
```

The most important state fields are:

```text
uploaded_files
active_file_ids
raw_data
file_names
last_error
cusum_prepared
cusum_results
geo_results
```

---

## Uploaded-file workflow

The dashboard supports uploading multiple files at once.

Default behavior:

1. Every successfully uploaded file is added to `app_state$uploaded_files`.
2. Every newly uploaded valid file is active by default.
3. Active files are combined into `app_state$raw_data`.
4. Users can open **Manage files** to activate/deactivate or remove files.
5. The dashboard recalculates based only on active files.

The file manager stores metadata for each uploaded file:

```text
id
name
data
rows
cols
year_week_range
modified_at
size_bytes
uploaded_at
```

The active dashboard dataset is rebuilt by:

```r
refresh_active_dashboard_data(app_state)
```

---

## Global filters

The unified dashboard is designed around shared global filters.

Current global filters include:

- Geographic level
- Detection period
- Locations
- Year
- Epidemiological week range

These filters are shared by the dashboard-level CUSUM and Geospatial workflows.

CUSUM-specific statistical settings remain separate:

- Expected frequency method
- Manual `μ0`
- ARL0
- Relative risk
- Calculated `k`
- Threshold `h`

Geospatial-specific settings remain separate:

- Map time window
- Spatial analysis run button

---

## Expected uploaded data

The dashboard expects API-POP-compatible data with one row per geographic unit and epidemiological time period.

Minimum recommended structure:

```csv
year,week,level1,level2,cases,population
2026,6,Buenos Aires,La Plata,12,150000
2026,7,Buenos Aires,La Plata,15,150000
2026,8,Buenos Aires,La Plata,10,150000
```

Required or recommended fields:

| Field | Requirement | Notes |
|---|---|---|
| `year` | Required | Epidemiological year. |
| `week` | Required | Epidemiological week number. |
| `level1` | Required | First geographic level, usually province or equivalent. |
| `level2` | Recommended | Second geographic level, usually department or equivalent. |
| `level3` | Optional | Third geographic level, if available. |
| `cases` / `n_cases` | Required | Observed suspected cases or event count. |
| `population` | Required for Geospatial; optional for CUSUM | Used for rates, prevalence maps, and spatial analysis. CUSUM only needs population if configured to use population-adjusted expected counts. |

The importer accepts common aliases for case and population columns, such as:

```text
cases
count
n_cases
population
pop
denominator
```

Exact behavior depends on `R/shared/data_import.R` and `config.json`.

---

## CUSUM workflow

The CUSUM dashboard workflow:

1. Uses the active uploaded data.
2. Applies the selected global geographic level and locations.
3. Uses the selected detection period.
4. Estimates or receives expected frequency `μ0`.
5. Calculates `k` from relative risk and `μ0`.
6. Runs the CUSUM process using threshold `h`.
7. Stores results in `app_state$cusum_results`.

CUSUM outputs include:

- CUSUM alarm overview.
- CUSUM case series plot.
- CUSUM process plot.
- CUSUM results table.

Population is not required for the standard CUSUM workflow. It is only needed if the expected frequency model is changed to use population-adjusted rates.

---

## Geospatial workflow

The Geospatial dashboard workflow:

1. Uses the active uploaded data.
2. Validates that population data is available.
3. Applies the selected geographic level, year, and week range.
4. Loads the corresponding optimized spatial layer.
5. Joins the analysis data to geometry.
6. Computes prevalence/rate outputs.
7. Attempts LISA clustering when enough spatial units are available.
8. Stores results in `app_state$geo_results`.

Geospatial outputs include:

- Prevalence map.
- LISA cluster map.
- Global Moran’s I banner when available.
- Geospatial results table.

LISA requires multiple spatial units. If too few units are selected, the app may warn that LISA cannot be computed.

---

## Customizable outputs

The **Customize Dashboard** section lets users choose which outputs to show:

- CUSUM overview
- CUSUM series plot
- CUSUM process plot
- Prevalence map
- LISA cluster map
- Results tables

The layout can be displayed in:

- One column
- Two columns

Compact plot behavior can be used for two-column mode to avoid long location labels overwhelming small plots.

---

## Styling and visual identity

The main stylesheet is:

```text
www/config.css
```

The file is organized so most visual decisions are controlled from the first section:

```css
:root {
  --color-brand-dark: #1E2A15;
  --color-brand-dark-2: #324027;
  --color-brand-sage: #48563F;
  --color-brand-orange: #F69342;
  --color-page-bg: #F8F5F1;
}
```

Prefer changing global CSS variables before editing component-specific selectors.

The dashboard uses:

```text
www/AnalysisforAction_white.png
www/default.ico
```

Template reference files are stored under:

```text
references/templates/
```

---

## Documentation files

Help and manual files are stored in:

```text
www/docs/cusum/
www/docs/geospatial/
```

The Help tab links to these documents and also includes an in-app modal with the expected API-POP file structure.

When linking to files in Shiny, paths inside `www/` are referenced without the `www/` prefix. For example:

```r
href = "docs/cusum/HELP_EN.md"
```

points to:

```text
www/docs/cusum/HELP_EN.md
```

---

## Development notes

- Keep analytical logic in `R/cusum/` and `R/geospatial/`.
- Keep reusable cross-tool helpers in `R/shared/`.
- Keep dashboard-specific UI/server logic in `R/modules/dashboard/`.
- Keep `R/modules/mod_unified_dashboard.R` as a coordinator only.
- Keep `app.R` minimal.
- Use `shiny::validate(shiny::need(...))` instead of `validate(need(...))` because `jsonlite::validate()` masks `shiny::validate()`.
- Avoid placing large new logic directly into `mod_app.R`; move reusable UI to `ui_components.R` and dashboard behavior to the relevant dashboard module file.
- Avoid duplicate CSS selectors. Prefer editing variables in `:root`.

---

## Legacy pages

The legacy CUSUM and Geospatial pages are preserved as reference pages after cleanup.

They are loaded from:

```text
R/cusum/mod_cusum.R
R/geospatial/mod_geospatial.R
```

They should remain separate from the new dashboard workflow. The unified dashboard should be the primary workflow for new development.

---

## Notes

This refactor is intentionally conservative. The mathematical and spatial engines remain separated by domain while the dashboard layer provides a unified user experience.

This lowers the risk of changing validated analysis behavior while still allowing the app to share uploads, filters, layout, styling, and help resources across both tools.
