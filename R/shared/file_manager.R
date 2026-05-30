format_file_size <- function(bytes) {
  if (is.null(bytes) || is.na(bytes)) {
    return("")
  }
  
  if (bytes < 1024) {
    return(paste0(bytes, " B"))
  }
  
  if (bytes < 1024^2) {
    return(paste0(round(bytes / 1024, 1), " KB"))
  }
  
  paste0(round(bytes / 1024^2, 1), " MB")
}

get_year_week_range <- function(dat) {
  if (is.null(dat) || nrow(dat) == 0) {
    return("")
  }
  
  year_col <- intersect(
    c("year", "Year", "anio", "año", "ANO", "ANIO"),
    names(dat)
  )
  
  week_col <- intersect(
    c("week", "Week", "semana", "Semana", "epiweek", "epi_week"),
    names(dat)
  )
  
  if (length(year_col) > 0 && length(week_col) > 0) {
    year_col <- year_col[1]
    week_col <- week_col[1]
    
    tmp <- dat |>
      dplyr::filter(
        !is.na(.data[[year_col]]),
        !is.na(.data[[week_col]])
      ) |>
      dplyr::mutate(
        .year = as.integer(.data[[year_col]]),
        .week = as.integer(.data[[week_col]])
      ) |>
      dplyr::arrange(.year, .week)
    
    if (nrow(tmp) == 0) {
      return("")
    }
    
    first <- tmp[1, ]
    last <- tmp[nrow(tmp), ]
    
    return(
      paste0(
        "W", first$.week, " Y", first$.year,
        " to ",
        "W", last$.week, " Y", last$.year
      )
    )
  }
  
  date_col <- intersect(
    c("date", "Date", "fecha", "Fecha", "event_date", "week_start"),
    names(dat)
  )
  
  if (length(date_col) > 0) {
    date_col <- date_col[1]
    
    dates <- suppressWarnings(as.Date(dat[[date_col]]))
    dates <- dates[!is.na(dates)]
    
    if (length(dates) == 0) {
      return("")
    }
    
    first_date <- min(dates)
    last_date <- max(dates)
    
    first_year <- lubridate::isoyear(first_date)
    first_week <- lubridate::isoweek(first_date)
    
    last_year <- lubridate::isoyear(last_date)
    last_week <- lubridate::isoweek(last_date)
    
    return(
      paste0(
        "W", first_week, " Y", first_year,
        " to ",
        "W", last_week, " Y", last_year
      )
    )
  }
  
  ""
}

refresh_active_dashboard_data <- function(app_state) {
  app_state$data_version <- as.integer(if (is.null(app_state$data_version)) 0L else app_state$data_version) + 1L

  active_ids <- app_state$active_file_ids
  
  active_ids <- active_ids[
    active_ids %in% names(app_state$uploaded_files)
  ]
  
  app_state$active_file_ids <- active_ids
  
  if (length(active_ids) == 0) {
    app_state$raw_data <- NULL
    app_state$file_names <- NULL
    app_state$last_error <- NULL
    
    app_state$cusum_prepared <- NULL
    app_state$cusum_results <- NULL
    app_state$geo_results <- NULL
    
    return(invisible(NULL))
  }
  
  active_data <- lapply(
    active_ids,
    function(id) app_state$uploaded_files[[id]]$data
  )
  
  app_state$raw_data <- dplyr::bind_rows(active_data)
  app_state$file_names <- vapply(
    active_ids,
    function(id) app_state$uploaded_files[[id]]$name,
    character(1)
  )
  
  app_state$last_error <- NULL
  
  app_state$cusum_prepared <- NULL
  app_state$cusum_results <- NULL
  app_state$geo_results <- NULL
  
  invisible(NULL)
}