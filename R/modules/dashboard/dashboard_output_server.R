dashboard_output_server <- function(input, output, session, app_state) {
  ns <- session$ns
  
  output$summary_cards <- renderUI({
    raw_rows <- if (is.null(app_state$raw_data)) {
      "—"
    } else {
      format(nrow(app_state$raw_data), big.mark = ",")
    }
    
    cusum_units <- if (is.null(app_state$cusum_results)) {
      "—"
    } else {
      length(unique(app_state$cusum_results$analysis_unit_id))
    }
    
    alarms <- if (
      is.null(app_state$cusum_results) ||
      !"alarm" %in% names(app_state$cusum_results)
    ) {
      "—"
    } else {
      sum(app_state$cusum_results$alarm, na.rm = TRUE)
    }
    
    map_units <- if (is.null(app_state$geo_results)) {
      "—"
    } else {
      nrow(app_state$geo_results)
    }
    
    div(
      class = "summary-container dashboard-summary",
      summary_card("Rows loaded", raw_rows),
      summary_card("CUSUM units", cusum_units),
      summary_card("CUSUM alarms", alarms),
      summary_card("Mapped units", map_units)
    )
  })
  
  
  output$unit_selector_ui <- renderUI({
    req(app_state$cusum_results)
    
    units <- sort(unique(app_state$cusum_results$analysis_unit_id))
    
    selectInput(
      ns("unit_selector"),
      "CUSUM location",
      choices = units,
      selected = units[1],
      width = "100%"
    )
  })
  
  
  output$cusum_overview <- renderPlot({
    req(app_state$cusum_results)
    
    compact <- identical(as.character(input$layout_columns), "2")
    
    plot_cusum_alarms_overview(
      app_state$cusum_results,
      compact = compact
    )
  })
  
  
  output$cusum_series <- renderPlot({
    req(app_state$cusum_results, input$unit_selector)
    
    df_unit <- app_state$cusum_results |>
      dplyr::filter(analysis_unit_id == input$unit_selector)
    
    plot_cusum_series_unit(
      df_unit,
      unit_label = nice_unit_label(input$unit_selector)
    )
  })
  
  
  output$cusum_process <- renderPlot({
    req(app_state$cusum_results, input$unit_selector)
    
    df_unit <- app_state$cusum_results |>
      dplyr::filter(analysis_unit_id == input$unit_selector)
    
    plot_cusum_process_unit(
      df_unit,
      unit_label = nice_unit_label(input$unit_selector),
      h = input$param_h,
      k = unique(df_unit$k_value)[1],
      arl0 = input$param_arl0
    )
  })
  
  
  output$prevalence_map <- leaflet::renderLeaflet({
    req(app_state$geo_results)
    
    render_prevalence_map(
      app_state$geo_results,
      target_var,
      is_offline,
      input$global_level,
      config,
      active_country
    )
  })
  
  
  output$lisa_map <- leaflet::renderLeaflet({
    req(app_state$geo_results)
    
    render_lisa_map(
      app_state$geo_results,
      target_var,
      is_offline,
      input$global_level,
      config,
      active_country
    )
  })
  
  
  output$cusum_table <- DT::renderDT({
    req(app_state$cusum_results)
    
    DT::datatable(
      app_state$cusum_results,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
  
  
  output$geo_table <- DT::renderDT({
    req(app_state$geo_results)
    
    DT::datatable(
      sf::st_drop_geometry(app_state$geo_results),
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
  
  
  output$global_moran_banner <- renderUI({
    req(app_state$geo_results)
    
    gm <- compute_global_moran(
      app_state$geo_results,
      target_var = target_var
    )
    
    if (is.null(gm)) {
      return(NULL)
    }
    
    div(
      class = "moran-banner",
      sprintf(
        "Global Moran's I = %s (%s)",
        gm$statistic,
        if (gm$p_value < 0.001) {
          "p < 0.001"
        } else {
          paste0("p = ", gm$p_value)
        }
      )
    )
  })
  
  
  output$main_dashboard <- renderUI({
    selected <- input$visible_outputs
    
    if (is.null(selected) || length(selected) == 0) {
      return(
        empty_state(
          "No outputs selected",
          "Use the Customize Dashboard checkboxes in the sidebar to choose plots, maps, and tables."
        )
      )
    }
    
    width <- if (identical(as.character(input$layout_columns), "1")) {
      12
    } else {
      6
    }
    
    cards <- list()
    
    if ("cusum_overview" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            width,
            output_card(
              "CUSUM alarm overview",
              plotOutput(ns("cusum_overview"), height = "420px")
            )
          )
        )
      )
    }
    
    if ("cusum_series" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            width,
            output_card(
              "CUSUM case series",
              plotOutput(ns("cusum_series"), height = "360px")
            )
          )
        )
      )
    }
    
    if ("cusum_process" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            width,
            output_card(
              "CUSUM process",
              plotOutput(ns("cusum_process"), height = "360px")
            )
          )
        )
      )
    }
    
    if ("prevalence_map" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            width,
            output_card(
              "Prevalence map",
              tagList(
                uiOutput(ns("global_moran_banner")),
                leaflet::leafletOutput(
                  ns("prevalence_map"),
                  height = "480px"
                )
              )
            )
          )
        )
      )
    }
    
    if ("lisa_map" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            width,
            output_card(
              "LISA cluster map",
              leaflet::leafletOutput(
                ns("lisa_map"),
                height = "480px"
              )
            )
          )
        )
      )
    }
    
    if ("tables" %in% selected) {
      cards <- append(
        cards,
        list(
          column(
            12,
            output_card(
              "Results tables",
              tabsetPanel(
                tabPanel(
                  "CUSUM Results",
                  DT::DTOutput(ns("cusum_table"))
                ),
                tabPanel(
                  "Geospatial Results",
                  DT::DTOutput(ns("geo_table"))
                )
              )
            )
          )
        )
      )
    }
    
    cusum_selector <- if (
      any(c("cusum_series", "cusum_process") %in% selected)
    ) {
      div(
        class = "dashboard-control-strip",
        uiOutput(ns("unit_selector_ui"))
      )
    } else {
      NULL
    }
    
    if (is.null(app_state$raw_data)) {
      tagList(
        empty_state(
          "Upload data to begin",
          "Use the shared input panel to upload one or more API-POP CSV files. Your uploaded data and settings remain available while you move around the dashboard."
        ),
        cusum_selector,
        do.call(fluidRow, cards)
      )
    } else {
      tagList(
        cusum_selector,
        do.call(fluidRow, cards)
      )
    }
  })
}