dashboard_geo_server <- function(input, output, session, app_state) {
  
  run_dashboard_geo <- function(show_message = TRUE) {
    tryCatch({
      req(
        app_state$raw_data,
        input$global_level,
        input$selected_year,
        input$week_range
      )
      
      validation_msg <- validate_api_pop_data(
        app_state$raw_data,
        require_population = TRUE
      )
      
      shiny::validate(
        shiny::need(
          is.null(validation_msg),
          validation_msg
        )
      )
      
      wk <- as.integer(input$week_range)
      time_mode <- if (is.null(input$time_mode)) "single" else input$time_mode
      
      if (identical(time_mode, "single")) {
        wk <- c(wk[1], wk[1])
      } else {
        if (length(wk) < 2) {
          wk <- c(wk[1], wk[1])
        }
        wk <- sort(wk[1:2])
        if ((wk[2] - wk[1]) < 1L) {
          available_wk <- available_weeks_for_year(app_state$raw_data, input$selected_year)
          max_available_week <- suppressWarnings(max(available_wk, na.rm = TRUE))
          min_available_week <- suppressWarnings(min(available_wk, na.rm = TRUE))
          if (!is.na(max_available_week) && wk[2] < max_available_week) {
            wk[2] <- wk[1] + 1L
          } else if (!is.na(min_available_week) && wk[1] > min_available_week) {
            wk[1] <- wk[2] - 1L
          }
        }
      }
      
      analysis_df <- prepare_geospatial_dataset(
        df = app_state$raw_data,
        selected_level = input$global_level,
        selected_year = as.integer(input$selected_year),
        week_from = wk[1],
        week_to = wk[2],
        config = config,
        active_country = active_country
      )
      
      shiny::validate(
        shiny::need(
          !is.null(analysis_df) && nrow(analysis_df) > 0,
          "No geospatial data available for the selected inputs."
        )
      )
      
      sf_layer <- load_geospatial_layer(
        input$global_level,
        config,
        active_country
      )
      
      expected_len <- config[[active_country]]$mapping[[input$global_level]]$code_length
      
      sf_layer$id <- stringr::str_pad(
        as.character(sf_layer$id),
        width = expected_len,
        pad = "0"
      )
      
      analysis_df$analysis_unit_id <- as.character(
        analysis_df$analysis_unit_id
      )
      
      joined_sf <- join_analysis_to_geometry(
        sf_layer,
        analysis_df
      ) |>
        dplyr::filter(!is.na(.data[[target_var]]))
      
      shiny::validate(
        shiny::need(
          nrow(joined_sf) > 0,
          "Spatial join failed. CSV IDs do not match map IDs."
        )
      )
      
      app_state$geo_results <- compute_lisa(
        joined_sf,
        target_var = target_var
      )
      
      if (isTRUE(show_message)) {
        showNotification(
          "Spatial analysis completed.",
          type = "message"
        )
      }
    }, error = function(e) {
      showNotification(
        paste("Spatial analysis error:", e$message),
        type = "error",
        duration = 12
      )
    })
  }

  observeEvent(input$run_analysis, {
    run_dashboard_geo(show_message = TRUE)
  })

  observeEvent(
    list(
      input$selected_year,
      input$week_range,
      input$time_mode
    ),
    {
      if (!isTRUE(input$reactive_display) || is.null(app_state$geo_results)) {
        return()
      }
      run_dashboard_geo(show_message = FALSE)
    },
    ignoreInit = TRUE
  )
}
