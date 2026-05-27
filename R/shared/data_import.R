# Shared data import, validation and small formatting helpers for the unified RAP dashboard.

read_api_pop_csv <- function(path) {
  first_line <- readLines(path, n = 1, warn = FALSE)
  if (grepl(";", first_line)) {
    readr::read_csv2(path, show_col_types = FALSE)
  } else {
    readr::read_csv(path, show_col_types = FALSE)
  }
}

normalise_api_pop_columns <- function(df) {
  names(df) <- tolower(trimws(names(df)))

  aliases <- list(
    n_cases    = c("n_cases", "cases", "case_count", "count", "n"),
    population = c("population", "n_population", "pop", "denominator")
  )

  for (std in names(aliases)) {
    hits <- aliases[[std]][aliases[[std]] %in% names(df)]
    if (length(hits) > 0 && hits[1] != std) {
      names(df)[names(df) == hits[1]] <- std
    }
  }

  numeric_cols <- intersect(c("year", "week", "n_cases", "population"), names(df))
  for (col in numeric_cols) {
    df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
  }

  character_cols <- intersect(c("country", "level1", "level2", "level3", "level4"), names(df))
  for (col in character_cols) {
    df[[col]] <- stringr::str_trim(as.character(df[[col]]))
  }

  df
}

pad_spatial_codes <- function(df, config, active_country) {
  mappings <- config[[active_country]]$mapping

  for (level_key in names(mappings)) {
    map <- mappings[[level_key]]
    csv_col <- map$csv_column
    code_length <- map$code_length

    if (!is.null(csv_col) && !is.null(code_length) && csv_col %in% names(df)) {
      df[[csv_col]] <- stringr::str_pad(
        stringr::str_trim(as.character(df[[csv_col]])),
        width = as.integer(code_length),
        pad = "0"
      )
    }
  }

  df
}

read_api_pop_files <- function(file_paths, config, active_country) {
  raw_df <- purrr::map_dfr(file_paths, read_api_pop_csv, .id = "file_index")
  raw_df <- normalise_api_pop_columns(raw_df)
  raw_df$file_index <- suppressWarnings(as.numeric(raw_df$file_index))
  pad_spatial_codes(raw_df, config, active_country)
}

validate_api_pop_data <- function(df, require_population = FALSE) {
  required <- c("country", "year", "week", "n_cases")
  if (require_population) required <- c(required, "population")

  missing <- setdiff(required, names(df))
  if (length(missing) > 0) {
    return(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }

  level_cols <- intersect(c("level1", "level2", "level3", "level4"), names(df))
  if (length(level_cols) == 0) {
    return("At least one geographic level column is required: level1, level2, level3 or level4.")
  }

  bad_years <- any(is.na(df$year) | df$year < 2000 | df$year > 2100)
  bad_weeks <- any(is.na(df$week) | df$week < 1 | df$week > 53)

  if (bad_years) return("The year column contains invalid values. Expected years between 2000 and 2100.")
  if (bad_weeks) return("The week column contains invalid values. Expected epidemiological weeks between 1 and 53.")

  NULL
}

available_years <- function(df) {
  sort(unique(as.integer(df$year[!is.na(df$year)])))
}

available_weeks_for_year <- function(df, year) {
  sort(unique(as.integer(df$week[df$year == as.integer(year) & !is.na(df$week)])))
}

geo_level_to_column <- function(hierarchy_levels, selected_level) {
  generic_map <- c("country", "level1", "level2", "level3", "level4")
  idx <- match(selected_level, hierarchy_levels)
  if (is.na(idx)) return(NULL)
  generic_map[[idx]]
}

nice_unit_label <- function(x) {
  if (is.null(x) || is.na(x)) return("")
  sub(".*\\|", "", as.character(x))
}
