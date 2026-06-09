dashboard_cusum_server <- function(input, output, session, app_state) {
  
  prepared_cusum_data <- reactive({
    req(
      app_state$raw_data,
      input$global_level,
      input$target_locations
    )
    
    hierarchy_levels <- config[[active_country]]$levels
    generic_map <- c("country", "level1", "level2", "level3", "level4")
    level_depth <- match(input$global_level, hierarchy_levels)
    
    shiny::validate(
      shiny::need(
        !is.na(level_depth),
        "Invalid CUSUM geographic level."
      )
    )
    
    process_target_data(
      raw_df = app_state$raw_data,
      target_locations = input$target_locations,
      target_col = generic_map[level_depth],
      req_cols = generic_map[1:level_depth],
      overlap_method = "sum",
      hierarchy_levels = hierarchy_levels,
      selected_level = input$global_level
    )
  })
  
  
  current_k <- reactive({
    req(input$param_rr)
    
    mu_val <- if (identical(input$mu_method, "manual")) {
      req(input$param_mu)
      input$param_mu
    } else {
      req(prepared_cusum_data())
      unit_mu <- get_phase1_baseline_by_unit(
        prepared_cusum_data(),
        as.numeric(input$detection_period)
      )
      mean(unit_mu, na.rm = TRUE)
    }
    
    calculate_k_from_rr(input$param_rr, mu_val)
  })
  
  
  output$calculated_k_ui <- renderUI({
    k <- tryCatch(
      current_k(),
      error = function(e) NULL
    )
    
    if (is.null(k)) {
      return(
        tags$small(
          style = "color:#cccccc;",
          "k will be calculated after data/parameters are available."
        )
      )
    }
    
    tags$small(
      style = "color:#f9ff42; font-style:italic;",
      paste("Calculated k:", round(k[1], 3))
    )
  })
  
  
  output$recommended_h_ui <- renderUI({
    rec <- tryCatch(
      recommend_h(input$param_arl0, current_k()),
      error = function(e) NA
    )
    
    if (is.na(rec)) {
      return(
        tags$small(
          style = "color:#cccccc;",
          "Recommended h unavailable."
        )
      )
    }
    
    tags$small(
      style = "color:#f9ff42; font-style:italic;",
      paste("Recommended h:", rec)
    )
  })
  
  
  run_dashboard_cusum <- function(show_message = TRUE) {
    tryCatch({
      req(
        prepared_cusum_data(),
        input$param_h,
        input$param_rr,
        input$detection_period
      )
      
      prepared_df <- prepared_cusum_data()
      
      shiny::validate(
        shiny::need(
          !is.null(prepared_df) && nrow(prepared_df) > 0,
          "No prepared CUSUM data available."
        )
      )
      
      max_week_index <- max(prepared_df$time_index, na.rm = TRUE)
      window_size <- as.numeric(input$detection_period)
      
      shiny::validate(
        shiny::need(
          max_week_index >= window_size,
          sprintf(
            "You requested %d weeks, but only %d are available.",
            window_size,
            max_week_index
          )
        )
      )
      
      start_week <- max(0, max_week_index - window_size)
      
      final_mu <- if (identical(input$mu_method, "manual")) {
        input$param_mu
      } else {
        get_phase1_baseline_by_unit(prepared_df, window_size)
      }
      
      calculated_k <- calculate_k_from_rr(
        input$param_rr,
        final_mu
      )
      
      res <- run_cusum_all_units(
        df = prepared_df,
        unit_var = "analysis_unit_id",
        baseline_filter = function(d) d$time_index > start_week,
        detect_filter = function(d) d$time_index > start_week,
        k = calculated_k,
        h = input$param_h,
        fixed_mu = final_mu,
        reset = TRUE
      )
      
      if (length(calculated_k) == 1 || is.null(names(calculated_k))) {
        res$k_value <- calculated_k[1]
      } else {
        res$k_value <- as.numeric(calculated_k[as.character(res$analysis_unit_id)])
      }
      
      app_state$cusum_prepared <- prepared_df
      app_state$cusum_results <- res
      
      units <- sort(unique(res$analysis_unit_id))
      
      updateSelectInput(
        session,
        "unit_selector",
        choices = units,
        selected = units[1]
      )
      
      if (isTRUE(show_message)) {
        showNotification(
          "CUSUM analysis completed.",
          type = "message"
        )
      }
    }, error = function(e) {
      showNotification(
        paste("CUSUM error:", e$message),
        type = "error",
        duration = 12
      )
    })
  }

  observeEvent(input$run_analysis, {
    run_dashboard_cusum(show_message = TRUE)
  })

  observeEvent(
    list(
      input$param_mu,
      input$param_arl0,
      input$param_rr,
      input$param_h,
      input$mu_method,
      input$detection_period
    ),
    {
      if (!isTRUE(input$reactive_display) || is.null(app_state$cusum_results)) {
        return()
      }
      run_dashboard_cusum(show_message = FALSE)
    },
    ignoreInit = TRUE
  )
}
