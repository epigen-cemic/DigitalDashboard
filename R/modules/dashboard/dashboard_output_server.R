dashboard_output_server <- function(input, output, session, app_state) {
  ns <- session$ns
  default_outputs <- c("cusum_overview", "prevalence_map", "lisa_map")
  `%||%` <- function(x, y) {
    if (is.null(x) || length(x) == 0) y else x
  }
  selected_outputs <- reactive({
    input$visible_outputs %||% default_outputs
  })
  layout_columns <- reactive({
    as.character(input$layout_columns %||% "2")
  })
  table_display_mode <- reactive({
    input$table_display_mode %||% "output"
  })
  display_font_size <- reactive({
    input$display_font_size %||% "medium"
  })
  table_decimals <- reactive({
    value <- suppressWarnings(as.integer(input$display_decimals %||% 4))
    if (is.na(value)) value <- 4
    max(0, min(6, value))
  })
  dashboard_font_base_size <- reactive({
    switch(
      display_font_size(),
      small = 12,
      medium = 14,
      large = 16,
      extra_large = 18,
      14
    )
  })
  observe({
    size <- display_font_size()
    all_classes <- paste0(
      "dashboard-font-",
      c("small", "medium", "large", "extra-large")
    )
    selected_class <- paste0(
      "dashboard-font-",
      if (identical(size, "extra_large")) "extra-large" else size
    )
    shinyjs::runjs(sprintf(
      "document.body.classList.remove(%s); document.body.classList.add('%s');",
      paste(sprintf("'%s'", all_classes), collapse = ","),
      selected_class
    ))
  })
  add_dashboard_plot_font <- function(plot) {
    plot + ggplot2::theme(
      text = ggplot2::element_text(size = dashboard_font_base_size()),
      plot.title = ggplot2::element_text(size = dashboard_font_base_size() + 3, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = dashboard_font_base_size()),
      axis.title = ggplot2::element_text(size = dashboard_font_base_size()),
      axis.text = ggplot2::element_text(size = max(9, dashboard_font_base_size() - 1)),
      legend.title = ggplot2::element_text(size = dashboard_font_base_size()),
      legend.text = ggplot2::element_text(size = max(9, dashboard_font_base_size() - 1))
    )
  }
  build_dashboard_table_filter_ui <- function(id_prefix, df) {
    if (is.null(df) || nrow(df) == 0) {
      return(NULL)
    }
    column_choices <- names(df)
    selected_col <- column_choices[[1]]
    div(
      class = "table-filter-bar dashboard-table-filter-bar",
      tags$label(
        class = "table-filter-inline-label",
        "Search by:"
      ),
      selectInput(
        ns(paste0(id_prefix, "_filter_col")),
        label = NULL,
        choices = column_choices,
        selected = selected_col,
        width = "220px"
      ),
      uiOutput(ns(paste0(id_prefix, "_filter_value_ui")), inline = TRUE)
    )
  }
  build_dashboard_table_filter_value_ui <- function(id_prefix, df, selected_col) {
    if (is.null(df) || is.null(selected_col) || !selected_col %in% names(df)) {
      return(NULL)
    }
    values <- df[[selected_col]]
    if (is.numeric(values)) {
      range_values <- range(values, na.rm = TRUE)
      if (!all(is.finite(range_values))) {
        return(NULL)
      }
      return(
        div(
          class = "table-filter-values",
          numericInput(
            ns(paste0(id_prefix, "_filter_min")),
            label = NULL,
            value = range_values[[1]],
            min = range_values[[1]],
            max = range_values[[2]],
            width = "130px"
          ),
          tags$span(class = "table-filter-separator", "to"),
          numericInput(
            ns(paste0(id_prefix, "_filter_max")),
            label = NULL,
            value = range_values[[2]],
            min = range_values[[1]],
            max = range_values[[2]],
            width = "130px"
          )
        )
      )
    }
    textInput(
      ns(paste0(id_prefix, "_filter_text")),
      label = NULL,
      value = "",
      placeholder = paste("Search", selected_col),
      width = "260px"
    )
  }
  apply_dashboard_table_filter <- function(df, id_prefix) {
    selected_col <- input[[paste0(id_prefix, "_filter_col")]]
    if (is.null(df) || is.null(selected_col) || !selected_col %in% names(df)) {
      return(df)
    }
    values <- df[[selected_col]]
    if (is.numeric(values)) {
      min_value <- suppressWarnings(as.numeric(input[[paste0(id_prefix, "_filter_min")]]))
      max_value <- suppressWarnings(as.numeric(input[[paste0(id_prefix, "_filter_max")]]))
      if (!is.null(min_value) && is.finite(min_value)) {
        df <- df[is.na(df[[selected_col]]) | df[[selected_col]] >= min_value, , drop = FALSE]
      }
      if (!is.null(max_value) && is.finite(max_value)) {
        df <- df[is.na(df[[selected_col]]) | df[[selected_col]] <= max_value, , drop = FALSE]
      }
      return(df)
    }
    text_value <- input[[paste0(id_prefix, "_filter_text")]]
    if (is.null(text_value) || !nzchar(text_value)) {
      return(df)
    }
    keep <- grepl(text_value, as.character(values), ignore.case = TRUE, fixed = TRUE)
    df[keep, , drop = FALSE]
  }
  dashboard_datatable <- function(df, page_length = 10) {
    numeric_cols <- names(df)[vapply(df, is.numeric, logical(1))]
    decimal_cols <- numeric_cols[vapply(numeric_cols, function(col) {
      values <- df[[col]]
      values <- values[is.finite(values)]
      length(values) > 0 && any(abs(values - round(values)) > sqrt(.Machine$double.eps), na.rm = TRUE)
    }, logical(1))]
    table <- DT::datatable(
      df,
      extensions = "Buttons",
      options = list(
        pageLength = page_length,
        scrollX = TRUE,
        searchHighlight = TRUE,
        dom = "Blrtip",
        buttons = list(
          list(
            extend = "colvis",
            text = "Show / hide columns"
          )
        ),
        columnDefs = list(
          list(className = "dt-left", targets = "_all")
        )
      ),
      rownames = FALSE
    )
    if (length(decimal_cols) > 0) {
      table <- DT::formatRound(table, columns = decimal_cols, digits = table_decimals())
    }
    table
  }
  has_cusum_results <- reactive({
    !is.null(app_state$cusum_results) && nrow(app_state$cusum_results) > 0
  })
  has_geo_results <- reactive({
    !is.null(app_state$geo_results) && nrow(app_state$geo_results) > 0
  })
  has_any_results <- reactive({
    has_cusum_results() || has_geo_results()
  })
  download_button_if <- function(condition, output_id, label) {
    if (isTRUE(condition)) {
      downloadButton(ns(output_id), label, class = "dashboard-download-button")
    } else {
      NULL
    }
  }
  table_card_ui <- function() {
    if (!has_any_results()) {
      return(
        output_card(
          "Results tables",
          empty_state(
            "No result tables available",
            "Run the CUSUM and/or Geospatial analysis to populate the result tables."
          )
        )
      )
    }
    table_tabs <- list()
    if (has_cusum_results()) {
      table_tabs <- append(
        table_tabs,
        list(
          tabPanel(
            "CUSUM Weekly Results",
            uiOutput(ns("cusum_table_filter_ui")),
            DT::DTOutput(ns("cusum_table"))
          ),
          tabPanel(
            "CUSUM Reference",
            uiOutput(ns("cusum_reference_table_filter_ui")),
            DT::DTOutput(ns("cusum_reference_table"))
          )
        )
      )
    }
    if (has_geo_results()) {
      table_tabs <- append(
        table_tabs,
        list(
          tabPanel(
            "Geospatial Results",
            uiOutput(ns("geo_table_filter_ui")),
            DT::DTOutput(ns("geo_table"))
          )
        )
      )
    }
    output_card(
      "Results tables",
      tagList(
        div(
          class = "dashboard-card-actions",
          download_button_if(has_cusum_results(), "download_cusum_results_csv", "Download CUSUM CSV"),
          download_button_if(has_geo_results(), "download_geo_results_csv", "Download Geospatial CSV")
        ),
        do.call(tabsetPanel, table_tabs)
      )
    )
  }
  map_png_packages_available <- function() {
    requireNamespace("htmlwidgets", quietly = TRUE) &&
      requireNamespace("webshot2", quietly = TRUE)
  }
  map_download_ui <- function(has_data, download_id, label) {
    if (!isTRUE(has_data) || !map_png_packages_available()) {
      return(NULL)
    }
    downloadButton(
      ns(download_id),
      label,
      class = "dashboard-download-button"
    )
  }
  save_leaflet_png <- function(map, file, width = 1400, height = 900) {
    if (!map_png_packages_available()) {
      stop(
        "Map PNG export requires the optional packages htmlwidgets and webshot2.",
        call. = FALSE
      )
    }
    tmp_html <- tempfile(fileext = ".html")
    htmlwidgets::saveWidget(
      widget = map,
      file = tmp_html,
      selfcontained = FALSE
    )
    html_path <- normalizePath(tmp_html, winslash = "/")
    webshot2::webshot(
      url = paste0("file:///", html_path),
      file = file,
      vwidth = width,
      vheight = height
    )
  }
  output$layout_preview <- renderUI({
    selected <- selected_outputs()
    columns <- layout_columns()
    table_mode <- table_display_mode()
    if (length(selected) == 0) {
      return(
        div(
          class = "layout-preview-empty",
          "No plots or maps selected."
        )
      )
    }
    labels <- c(
      cusum_overview = "CUSUM overview",
      cusum_series = "CUSUM series",
      cusum_process = "CUSUM process",
      prevalence_map = "Prevalence map",
      lisa_map = "LISA map"
    )
    preview_items <- lapply(selected, function(id) {
      div(
        class = "layout-preview-tile",
        labels[[id]] %||% id
      )
    })
    if (identical(table_mode, "output")) {
      preview_items <- append(
        preview_items,
        list(div(class = "layout-preview-tile table-tile", "Results tables"))
      )
    }
    div(
      class = paste("layout-preview-grid", paste0("cols-", columns)),
      preview_items
    )
  })
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
  cusum_location_columns <- function(df) {
    candidates <- c("country", "level1", "level2", "level3")
    candidates[candidates %in% names(df)]
  }
  cusum_location_label <- function(col) {
    switch(
      col,
      country = "Country",
      level1 = "Province",
      level2 = "Department",
      level3 = "Level 3",
      col
    )
  }
  cusum_filtered_locations <- reactive({
    req(app_state$cusum_results)
    df <- app_state$cusum_results
    cols <- cusum_location_columns(df)
    if (length(cols) == 0) {
      return(df)
    }
    for (col in cols) {
      input_id <- paste0("cusum_filter_", col)
      value <- input[[input_id]]
      if (!is.null(value) && nzchar(value) && col %in% names(df)) {
        df <- df[df[[col]] == value, , drop = FALSE]
      }
    }
    df
  })
  selected_cusum_unit <- reactive({
    req(app_state$cusum_results)
    df <- cusum_filtered_locations()
    if (is.null(df) || nrow(df) == 0) {
      units <- sort(unique(app_state$cusum_results$analysis_unit_id))
      return(units[1])
    }
    units <- sort(unique(df$analysis_unit_id))
    units[1]
  })
  output$unit_selector_ui <- renderUI({
    req(app_state$cusum_results)
    df_all <- app_state$cusum_results
    cols <- cusum_location_columns(df_all)
    if (length(cols) == 0) {
      units <- sort(unique(df_all$analysis_unit_id))
      return(
        selectizeInput(
          ns("unit_selector_fallback"),
          "CUSUM location",
          choices = units,
          selected = units[1],
          width = "100%",
          options = list(dropdownParent = "body")
        )
      )
    }
    selector_items <- list()
    df_scope <- df_all
    for (col in cols) {
      choices <- sort(unique(df_scope[[col]]))
      choices <- choices[!is.na(choices) & nzchar(as.character(choices))]
      input_id <- paste0("cusum_filter_", col)
      current <- input[[input_id]]
      selected <- if (!is.null(current) && current %in% choices) current else choices[1]
      selector_items <- append(
        selector_items,
        list(
          div(
            class = "dashboard-location-selector-item",
            selectizeInput(
              ns(input_id),
              cusum_location_label(col),
              choices = choices,
              selected = selected,
              width = "100%",
              options = list(dropdownParent = "body")
            )
          )
        )
      )
      if (!is.null(selected) && length(selected) == 1 && !is.na(selected)) {
        df_scope <- df_scope[df_scope[[col]] == selected, , drop = FALSE]
      }
    }
    div(
      class = "dashboard-location-selector-row",
      selector_items
    )
  })
  output$cusum_overview <- renderPlot({
    req(app_state$cusum_results)
    compact <- identical(layout_columns(), "2")
    add_dashboard_plot_font(
      plot_cusum_alarms_overview(
        app_state$cusum_results,
        compact = compact
      )
    )
  })
  output$cusum_series <- renderPlot({
    req(app_state$cusum_results, selected_cusum_unit())
    df_unit <- app_state$cusum_results |>
      dplyr::filter(analysis_unit_id == selected_cusum_unit())
    add_dashboard_plot_font(
      plot_cusum_series_unit(
        df_unit,
        unit_label = nice_unit_label(selected_cusum_unit())
      )
    )
  })
  output$cusum_process <- renderPlot({
    req(app_state$cusum_results, selected_cusum_unit())
    df_unit <- app_state$cusum_results |>
      dplyr::filter(analysis_unit_id == selected_cusum_unit())
    add_dashboard_plot_font(
      plot_cusum_process_unit(
        df_unit,
        unit_label = nice_unit_label(selected_cusum_unit()),
        h = input$param_h,
        k = unique(df_unit$k_value)[1],
        arl0 = input$param_arl0
      )
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
  output$cusum_table_filter_ui <- renderUI({
    req(app_state$cusum_results)
    build_dashboard_table_filter_ui("cusum_table", format_cusum_weekly_table(app_state$cusum_results))
  })
  output$cusum_table_filter_value_ui <- renderUI({
    req(app_state$cusum_results)
    df <- format_cusum_weekly_table(app_state$cusum_results)
    build_dashboard_table_filter_value_ui("cusum_table", df, input$cusum_table_filter_col)
  })
  output$cusum_reference_table_filter_ui <- renderUI({
    req(app_state$cusum_results)
    build_dashboard_table_filter_ui("cusum_reference_table", format_cusum_reference_table(app_state$cusum_results))
  })
  output$cusum_reference_table_filter_value_ui <- renderUI({
    req(app_state$cusum_results)
    df <- format_cusum_reference_table(app_state$cusum_results)
    build_dashboard_table_filter_value_ui("cusum_reference_table", df, input$cusum_reference_table_filter_col)
  })
  output$geo_table_filter_ui <- renderUI({
    req(app_state$geo_results)
    build_dashboard_table_filter_ui("geo_table", sf::st_drop_geometry(app_state$geo_results))
  })
  output$geo_table_filter_value_ui <- renderUI({
    req(app_state$geo_results)
    df <- sf::st_drop_geometry(app_state$geo_results)
    build_dashboard_table_filter_value_ui("geo_table", df, input$geo_table_filter_col)
  })
  output$cusum_table <- DT::renderDT({
    req(app_state$cusum_results)
    df <- format_cusum_weekly_table(app_state$cusum_results)
    df <- apply_dashboard_table_filter(df, "cusum_table")
    dashboard_datatable(df, page_length = 25)
  }, server = FALSE)
  output$cusum_reference_table <- DT::renderDT({
    req(app_state$cusum_results)
    df <- format_cusum_reference_table(app_state$cusum_results)
    df <- apply_dashboard_table_filter(df, "cusum_reference_table")
    dashboard_datatable(df, page_length = 25)
  }, server = FALSE)
  output$geo_table <- DT::renderDT({
    req(app_state$geo_results)
    df <- sf::st_drop_geometry(app_state$geo_results)
    df <- apply_dashboard_table_filter(df, "geo_table")
    dashboard_datatable(df)
  }, server = FALSE)
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

  output$prepared_data_panel <- renderUI({
    logs <- list()
    if (is.null(app_state$raw_data)) {
      logs <- append(logs, list(tags$li("No active uploaded data is currently selected.")))
    } else {
      logs <- append(
        logs,
        list(
          tags$li(sprintf("%s active row(s) loaded from %s active file(s).", format(nrow(app_state$raw_data), big.mark = ","), length(app_state$file_names %||% character(0)))),
          tags$li("Column names were standardized during import where configured aliases were found."),
          tags$li("Geographic code columns were padded with leading zeroes when a code_length is configured."),
          tags$li("Active uploaded files were combined into one dashboard dataset for analysis.")
        )
      )
    }
    if (!is.null(app_state$cusum_prepared)) {
      logs <- append(logs, list(tags$li("CUSUM prepared data is available from the latest CUSUM run.")))
    }
    prepared_output <- if (!is.null(app_state$cusum_prepared)) {
      tagList(
        h4("CUSUM prepared data"),
        div(
          class = "dashboard-card-actions",
          downloadButton(ns("download_cusum_prepared_csv"), "Download Prepared CUSUM CSV", class = "dashboard-download-button")
        ),
        uiOutput(ns("cusum_prepared_table_filter_ui")),
        DT::DTOutput(ns("cusum_prepared_table"))
      )
    } else if (!is.null(app_state$raw_data)) {
      tagList(
        h4("Active standardized data"),
        div(
          class = "dashboard-card-actions",
          downloadButton(ns("download_active_standardized_csv"), "Download Active Standardized CSV", class = "dashboard-download-button")
        ),
        uiOutput(ns("active_standardized_table_filter_ui")),
        DT::DTOutput(ns("active_standardized_table"))
      )
    } else {
      empty_state("No prepared data available", "Upload one or more API-POP files to review standardized/prepared data here.")
    }
    tagList(
      output_card(
        "Preparation and change log",
        tags$ul(class = "prepared-change-log", logs)
      ),
      output_card(
        "Prepared data preview",
        prepared_output
      )
    )
  })

  output$dashboard_internal_tabs <- renderUI({
    table_mode <- table_display_mode()
    dashboard_tabs <- list(
      tabPanel("Output", uiOutput(ns("main_dashboard")))
    )
    if (identical(table_mode, "separate")) {
      dashboard_tabs <- append(
        dashboard_tabs,
        list(tabPanel("Output Table", uiOutput(ns("dashboard_tables_panel"))))
      )
    }
    dashboard_tabs <- append(
      dashboard_tabs,
      list(tabPanel("Prepared Data", uiOutput(ns("prepared_data_panel"))))
    )
    do.call(
      tabsetPanel,
      c(
        list(id = ns("dashboard_output_tabs"), type = "tabs"),
        dashboard_tabs
      )
    )
  })

  output$main_dashboard <- renderUI({
    selected <- selected_outputs()
    tables_in_output <- identical(table_display_mode(), "output")
    if ((is.null(selected) || length(selected) == 0) && !tables_in_output) {
      return(
        empty_state(
          "No outputs selected",
          "Use the Display tab to choose plots, maps, and table placement."
        )
      )
    }
    width <- if (identical(layout_columns(), "1")) {
      12
    } else {
      6
    }
    cards <- list()
    if ("cusum_overview" %in% selected) {
      cards <- append(
        cards,
        list(
          div(
            class = "dashboard-output-grid-item",
            output_card(
              "CUSUM alarm overview",
              tagList(
                div(
                  class = "dashboard-card-actions",
                  download_button_if(has_cusum_results(), "download_cusum_overview_png", "Download PNG")
                ),
                plotOutput(ns("cusum_overview"), height = "420px")
              )
            )
          )
        )
      )
    }
    if ("cusum_series" %in% selected) {
      cards <- append(
        cards,
        list(
          div(
            class = "dashboard-output-grid-item",
            output_card(
              "CUSUM case series",
              tagList(
                div(
                  class = "dashboard-card-actions",
                  download_button_if(has_cusum_results(), "download_cusum_series_png", "Download PNG")
                ),
                plotOutput(ns("cusum_series"), height = "420px")
              )
            )
          )
        )
      )
    }
    if ("cusum_process" %in% selected) {
      cards <- append(
        cards,
        list(
          div(
            class = "dashboard-output-grid-item",
            output_card(
              "CUSUM process",
              tagList(
                div(
                  class = "dashboard-card-actions",
                  download_button_if(has_cusum_results(), "download_cusum_process_png", "Download PNG")
                ),
                plotOutput(ns("cusum_process"), height = "420px")
              )
            )
          )
        )
      )
    }
    if ("prevalence_map" %in% selected) {
      cards <- append(
        cards,
        list(
          div(
            class = "dashboard-output-grid-item",
            output_card(
              "Prevalence map",
              tagList(
                div(
                  class = "dashboard-card-actions",
                  map_download_ui(has_geo_results(), "download_prevalence_map_png", "Download PNG")
                ),
                uiOutput(ns("global_moran_banner")),
                leaflet::leafletOutput(
                  ns("prevalence_map"),
                  height = "420px"
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
          div(
            class = "dashboard-output-grid-item",
            output_card(
              "LISA cluster map",
              tagList(
                div(
                  class = "dashboard-card-actions",
                  map_download_ui(has_geo_results(), "download_lisa_map_png", "Download PNG")
                ),
                leaflet::leafletOutput(
                  ns("lisa_map"),
                  height = "420px"
                )
              )
            )
          )
        )
      )
    }
    if (tables_in_output) {
      cards <- append(
        cards,
        list(
          div(
            class = "dashboard-output-grid-item dashboard-output-grid-item-full",
            table_card_ui()
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
        do.call(
          div,
          c(
            list(class = paste("dashboard-output-grid", paste0("cols-", layout_columns()))),
            cards
          )
        )
      )
    } else {
      tagList(
        cusum_selector,
        do.call(
          div,
          c(
            list(class = paste("dashboard-output-grid", paste0("cols-", layout_columns()))),
            cards
          )
        )
      )
    }
  })
  output$dashboard_tables_panel <- renderUI({
    if (!identical(table_display_mode(), "separate")) {
      return(
        empty_state(
          "Tables are currently shown in the Output tab",
          "Use the Display tab if you want the CUSUM and Geospatial result tables to appear here instead."
        )
      )
    }
    if (is.null(app_state$cusum_results) && is.null(app_state$geo_results)) {
      return(
        empty_state(
          "No result tables available",
          "Run the CUSUM and/or Geospatial analysis to populate this tab."
        )
      )
    }
    table_card_ui()
  })
  output$download_cusum_overview_png <- downloadHandler(
    filename = function() {
      paste0("cusum_alarm_overview_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(app_state$cusum_results)
      compact <- identical(layout_columns(), "2")
      p <- add_dashboard_plot_font(
        plot_cusum_alarms_overview(
          app_state$cusum_results,
          compact = compact
        )
      )
      ggplot2::ggsave(file, plot = p, width = 12, height = 7, dpi = 300, bg = "white")
    }
  )
  output$download_cusum_series_png <- downloadHandler(
    filename = function() {
      paste0("cusum_case_series_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(app_state$cusum_results, selected_cusum_unit())
      df_unit <- app_state$cusum_results |>
        dplyr::filter(analysis_unit_id == selected_cusum_unit())
      p <- add_dashboard_plot_font(
        plot_cusum_series_unit(
          df_unit,
          unit_label = nice_unit_label(selected_cusum_unit())
        )
      )
      ggplot2::ggsave(file, plot = p, width = 12, height = 7, dpi = 300, bg = "white")
    }
  )
  output$download_cusum_process_png <- downloadHandler(
    filename = function() {
      paste0("cusum_process_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(app_state$cusum_results, selected_cusum_unit())
      df_unit <- app_state$cusum_results |>
        dplyr::filter(analysis_unit_id == selected_cusum_unit())
      p <- add_dashboard_plot_font(
        plot_cusum_process_unit(
          df_unit,
          unit_label = nice_unit_label(selected_cusum_unit()),
          h = input$param_h,
          k = unique(df_unit$k_value)[1],
          arl0 = input$param_arl0
        )
      )
      ggplot2::ggsave(file, plot = p, width = 12, height = 7, dpi = 300, bg = "white")
    }
  )
  output$download_cusum_results_csv <- downloadHandler(
    filename = function() {
      paste0("cusum_results_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(app_state$cusum_results)
      readr::write_csv(app_state$cusum_results, file)
    }
  )
  output$download_geo_results_csv <- downloadHandler(
    filename = function() {
      paste0("geospatial_results_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(app_state$geo_results)
      readr::write_csv(sf::st_drop_geometry(app_state$geo_results), file)
    }
  )
  output$download_prevalence_map_png <- downloadHandler(
    filename = function() {
      paste0("prevalence_map_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(app_state$geo_results)
      map <- render_prevalence_map(
        app_state$geo_results,
        target_var,
        is_offline,
        input$global_level,
        config,
        active_country
      )
      save_leaflet_png(map, file)
    }
  )
  output$download_lisa_map_png <- downloadHandler(
    filename = function() {
      paste0("lisa_cluster_map_", Sys.Date(), ".png")
    },
    content = function(file) {
      req(app_state$geo_results)
      map <- render_lisa_map(
        app_state$geo_results,
        target_var,
        is_offline,
        input$global_level,
        config,
        active_country
      )
      save_leaflet_png(map, file)
    }
  )
  output$cusum_prepared_table_filter_ui <- renderUI({
    req(app_state$cusum_prepared)
    build_dashboard_table_filter_ui("cusum_prepared_table", app_state$cusum_prepared)
  })
  output$cusum_prepared_table_filter_value_ui <- renderUI({
    req(app_state$cusum_prepared)
    build_dashboard_table_filter_value_ui("cusum_prepared_table", app_state$cusum_prepared, input$cusum_prepared_table_filter_col)
  })
  output$active_standardized_table_filter_ui <- renderUI({
    req(app_state$raw_data)
    build_dashboard_table_filter_ui("active_standardized_table", app_state$raw_data)
  })
  output$active_standardized_table_filter_value_ui <- renderUI({
    req(app_state$raw_data)
    build_dashboard_table_filter_value_ui("active_standardized_table", app_state$raw_data, input$active_standardized_table_filter_col)
  })
  output$cusum_prepared_table <- DT::renderDT({
    req(app_state$cusum_prepared)
    df <- apply_dashboard_table_filter(app_state$cusum_prepared, "cusum_prepared_table")
    dashboard_datatable(df)
  })
  output$active_standardized_table <- DT::renderDT({
    req(app_state$raw_data)
    df <- apply_dashboard_table_filter(app_state$raw_data, "active_standardized_table")
    dashboard_datatable(df)
  })
  output$download_cusum_prepared_csv <- downloadHandler(
    filename = function() {
      paste0("cusum_prepared_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(app_state$cusum_prepared)
      readr::write_csv(app_state$cusum_prepared, file)
    }
  )
  output$download_active_standardized_csv <- downloadHandler(
    filename = function() {
      paste0("active_standardized_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(app_state$raw_data)
      readr::write_csv(app_state$raw_data, file)
    }
  )

}
