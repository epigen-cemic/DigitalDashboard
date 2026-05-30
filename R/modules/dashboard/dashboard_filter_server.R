dashboard_filter_server <- function(input, output, session, app_state) {
  ns <- session$ns
  
  output$global_level_ui <- renderUI({
    selectInput(
      ns("global_level"),
      "Geographic Level",
      choices = cusum_geo_choices,
      selected = unname(cusum_geo_choices)[2],
      width = "100%"
    )
  })
  
  
  output$global_locations_ui <- renderUI({
    req(app_state$raw_data, input$global_level)
    
    target_col <- geo_level_to_column(
      config[[active_country]]$levels,
      input$global_level
    )
    
    shiny::validate(
      shiny::need(
        !is.null(target_col) &&
          target_col %in% names(app_state$raw_data),
        "Selected level is not available in the uploaded data."
      )
    )
    
    locations <- sort(unique(app_state$raw_data[[target_col]]))
    locations <- locations[!is.na(locations) & locations != ""]
    
    selectizeInput(
      ns("target_locations"),
      "Locations",
      choices = locations,
      selected = locations,
      multiple = TRUE,
      options = list(
        placeholder = "Select locations",
        plugins = list("remove_button")
      ),
      width = "100%"
    )
  })
  
  
  output$global_year_ui <- renderUI({
    req(app_state$raw_data)
    
    yrs <- available_years(app_state$raw_data)
    
    shiny::validate(
      shiny::need(
        length(yrs) > 0,
        "No years found."
      )
    )
    
    selectInput(
      ns("selected_year"),
      "Year",
      choices = yrs,
      selected = max(yrs),
      width = "100%"
    )
  })
  
  
  output$global_week_ui <- renderUI({
    req(app_state$raw_data, input$selected_year)

    weeks <- available_weeks_for_year(
      app_state$raw_data,
      input$selected_year
    )

    shiny::validate(
      shiny::need(
        length(weeks) > 0,
        "No weeks found for selected year."
      )
    )

    min_week <- min(weeks)
    max_week <- max(weeks)
    selected_mode <- if (is.null(input$time_mode)) "single" else input$time_mode

    slider_value <- if (identical(selected_mode, "range")) {
      if (max_week > min_week) c(max_week - 1L, max_week) else c(max_week, max_week)
    } else {
      max_week
    }

    div(
      class = "dashboard-time-window-row",
      div(
        class = "dashboard-time-window-mode",
        selectInput(
          ns("time_mode"),
          "Map Time Window",
          choices = c(
            "Selected single week" = "single",
            "Selected week range" = "range"
          ),
          selected = selected_mode,
          width = "100%"
        )
      ),
      div(
        class = "dashboard-time-window-slider",
        sliderInput(
          ns("week_range"),
          "Epidemiological Week(s)",
          min = min_week,
          max = max_week,
          value = slider_value,
          step = 1
        )
      )
    )
  })

  observeEvent(input$week_range, {
    if (!identical(input$time_mode, "range")) {
      return()
    }

    wk <- as.integer(input$week_range)
    if (length(wk) < 2 || any(is.na(wk))) {
      return()
    }

    if ((wk[2] - wk[1]) >= 1L) {
      return()
    }

    min_week <- min(as.integer(input$week_range), na.rm = TRUE)
    max_week <- max(as.integer(input$week_range), na.rm = TRUE)
    overall_min <- suppressWarnings(min(available_weeks_for_year(app_state$raw_data, input$selected_year)))
    overall_max <- suppressWarnings(max(available_weeks_for_year(app_state$raw_data, input$selected_year)))

    if (is.na(overall_min) || is.na(overall_max) || overall_min == overall_max) {
      return()
    }

    if (wk[2] < overall_max) {
      new_value <- c(wk[1], wk[1] + 1L)
    } else {
      new_value <- c(wk[2] - 1L, wk[2])
    }

    updateSliderInput(session, "week_range", value = new_value)
  }, ignoreInit = TRUE)

  observeEvent(input$global_level, {
    app_state$cusum_prepared <- NULL
    app_state$cusum_results <- NULL
    app_state$geo_results <- NULL
    showNotification(
      "Geographic level changed. Run Analysis again to refresh outputs.",
      type = "message"
    )
  }, ignoreInit = TRUE)

  observeEvent(input$target_locations, {
    app_state$cusum_prepared <- NULL
    app_state$cusum_results <- NULL
    showNotification(
      "Selected locations changed. Run Analysis again to refresh CUSUM outputs.",
      type = "message"
    )
  }, ignoreInit = TRUE)
}
