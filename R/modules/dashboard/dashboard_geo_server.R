dashboard_geo_server <- function(input, output, session, app_state) {
  
  observeEvent(input$run_geo, {
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
      
      if (identical(input$time_mode, "single")) {
        wk <- c(wk[2], wk[2])
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
      
      showNotification(
        "Spatial analysis completed.",
        type = "message"
      )
    }, error = function(e) {
      showNotification(
        paste("Spatial analysis error:", e$message),
        type = "error",
        duration = 12
      )
    })
  })
}