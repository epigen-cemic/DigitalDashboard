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
    
    sliderInput(
      ns("week_range"),
      "Epidemiological Week(s)",
      min = min(weeks),
      max = max(weeks),
      value = c(max(weeks), max(weeks)),
      step = 1
    )
  })
}