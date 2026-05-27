dashboard_sidebar_ui <- function(ns) {
  div(
    class = "sidebar-dark unified-sidebar",
    
    h3("Shared Inputs"),
    
    fileInput(
      ns("file_upload"),
      "Upload API-POP file(s)",
      multiple = TRUE,
      accept = c(".csv", ".txt", ".tsv", ".xlsx")
    ),
    
    uiOutput(ns("uploaded_files_ui")),
    uiOutput(ns("data_status")),
    
    tags$hr(),
    
    tags$label(class = "control-label", "Global Filters"),
    
    uiOutput(ns("global_level_ui")),
    
    numericInput(
      ns("detection_period"),
      "Detection Period (Weeks)",
      value = 52,
      min = 8,
      max = 260,
      step = 1,
      width = "100%"
    ),
    
    uiOutput(ns("global_locations_ui")),
    uiOutput(ns("global_year_ui")),
    uiOutput(ns("global_week_ui")),
    
    tags$hr(),
    
    tags$label(class = "control-label", "CUSUM Settings"),
    
    radioButtons(
      ns("mu_method"),
      "Expected Frequency (μ0)",
      choices = c(
        "Automatic (Poisson GLM)" = "auto",
        "Manual Input" = "manual"
      ),
      selected = "auto"
    ),
    
    conditionalPanel(
      condition = sprintf("input['%s'] == 'manual'", ns("mu_method")),
      numericInput(
        ns("param_mu"),
        "Manual μ0",
        value = 10,
        min = 0,
        width = "100%"
      )
    ),
    
    numericInput(
      ns("param_arl0"),
      "Target ARL0",
      value = 100,
      min = 1,
      width = "100%"
    ),
    
    numericInput(
      ns("param_rr"),
      "Relative Risk (RR)",
      value = 2,
      min = 1.01,
      step = 0.01,
      width = "100%"
    ),
    
    uiOutput(ns("calculated_k_ui")),
    
    numericInput(
      ns("param_h"),
      "h Threshold",
      value = 5,
      min = 0.001,
      step = 0.001,
      width = "100%"
    ),
    
    uiOutput(ns("recommended_h_ui")),
    
    actionButton(
      ns("run_cusum"),
      "Run CUSUM",
      class = "btn-default dashboard-run-btn"
    ),
    
    tags$hr(),
    
    tags$label(class = "control-label", "Geospatial Settings"),
    
    selectInput(
      ns("time_mode"),
      "Map Time Window",
      choices = c(
        "Selected single week" = "single",
        "Selected week range" = "range"
      ),
      selected = "single",
      width = "100%"
    ),
    
    actionButton(
      ns("run_geo"),
      "Run Spatial Analysis",
      class = "btn-default dashboard-run-btn"
    ),
    
    tags$hr(),
    
    tags$label(class = "control-label", "Customize Dashboard"),
    
    checkboxGroupInput(
      ns("visible_outputs"),
      NULL,
      choices = c(
        "CUSUM overview" = "cusum_overview",
        "CUSUM series plot" = "cusum_series",
        "CUSUM process plot" = "cusum_process",
        "Prevalence map" = "prevalence_map",
        "LISA cluster map" = "lisa_map",
        "Results tables" = "tables"
      ),
      selected = c("cusum_overview", "prevalence_map", "tables")
    ),
    
    selectInput(
      ns("layout_columns"),
      "Layout",
      choices = c(
        "Two columns" = 2,
        "One column" = 1
      ),
      selected = 2,
      width = "100%"
    )
  )
}