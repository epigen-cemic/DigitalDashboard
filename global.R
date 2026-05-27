# =============================================================================
# Global setup
# =============================================================================

# Core Shiny & Web
library(shiny)
library(shinyjs)
library(DT)
library(htmltools)
library(jsonlite)

# Data manipulation
library(dplyr)
library(tidyr)
library(purrr)
library(rlang)
library(readr)
library(lubridate)
library(ISOweek)
library(stringr)

# Visualization
library(ggplot2)

# Spatial analysis & visualization
library(sf)
library(spdep)
library(leaflet)

# Utilities
library(here)

# Shared dashboard helpers
source("R/shared/app_state.R")
source("R/shared/data_import.R")
source("R/shared/ui_components.R")
source("R/shared/file_manager.R")

# Original analytical engines preserved by domain
source("R/cusum/functions_parameters.R")
source("R/cusum/functions_cusum.R")
source("R/cusum/functions_plot.R")
source("R/cusum/functions_io.R")

source("R/geospatial/functions_io.R")
source("R/geospatial/functions_spatial.R")
source("R/geospatial/functions_plot.R")

# Legacy modules
source("R/cusum/mod_cusum.R")
source("R/geospatial/mod_geospatial.R")

# Dashboard module pieces
source("R/modules/dashboard/dashboard_sidebar_ui.R")
source("R/modules/dashboard/dashboard_main_ui.R")
source("R/modules/dashboard/dashboard_file_server.R")
source("R/modules/dashboard/dashboard_filter_server.R")
source("R/modules/dashboard/dashboard_cusum_server.R")
source("R/modules/dashboard/dashboard_geo_server.R")
source("R/modules/dashboard/dashboard_output_server.R")

# Dashboard module coordinator
source("R/modules/mod_unified_dashboard.R")
source("R/modules/mod_app.R")

sf::sf_use_s2(FALSE)

config_path <- file.path(getwd(), "config.json")
config <- jsonlite::fromJSON(config_path)

active_country <- "Argentina"
target_var     <- "prevalence_100k"
is_offline     <- FALSE

cusum_geo_choices <- config[[active_country]]$levels
names(cusum_geo_choices) <- tools::toTitleCase(cusum_geo_choices)

country_mappings <- config[[active_country]]$mapping
valid_keys <- names(country_mappings)[sapply(country_mappings, function(x) {
  x$csv_column %in% c("level2", "level3")
})]
geospatial_geo_choices <- valid_keys
names(geospatial_geo_choices) <- sapply(valid_keys, function(k) {
  cfg <- country_mappings[[k]]
  if (!is.null(cfg$ui_label)) cfg$ui_label else cfg$layer_name
})


