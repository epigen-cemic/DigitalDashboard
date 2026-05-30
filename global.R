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

# ---------------------------------------------------------
# Load all R files for the Digital Dashboard
# ---------------------------------------------------------

source_r_folder <- function(path, recursive = FALSE, exclude = character()) {
  files <- list.files(
    path,
    pattern = "\\.R$",
    full.names = TRUE,
    recursive = recursive
  )
  
  files <- files[!basename(files) %in% exclude]
  
  invisible(lapply(sort(files), source))
}

# Shared helpers
source_r_folder("R/shared", recursive = TRUE)
# Analytical engines
source_r_folder("R/cusum", recursive = TRUE)
source_r_folder("R/geospatial", recursive = TRUE)
# Dashboard module pieces
source_r_folder("R/modules/dashboard",recursive = TRUE)
# Dashboard module coordinators
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


