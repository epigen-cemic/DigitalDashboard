dashboard_display_ui <- function(ns) {
  div(
    class = "content-wrapper dashboard-display-wrapper",
    div(
      class = "well-custom dashboard-display-page",
      h2("Display"),
      p(
        "Choose which dashboard outputs to show, the output layout, and whether result tables should ",
        "appear with the main outputs or in a separate tab inside the Dashboard page."
      ),
      fluidRow(
        column(
          width = 7,
          div(
            class = "display-settings-card",
            h3("Output content"),
            checkboxGroupInput(
              ns("visible_outputs"),
              "Plots and maps shown in the Output tab",
              choices = c(
                "CUSUM overview" = "cusum_overview",
                "CUSUM series plot" = "cusum_series",
                "CUSUM process plot" = "cusum_process",
                "Prevalence map" = "prevalence_map",
                "LISA cluster map" = "lisa_map"
              ),
              selected = c("cusum_overview", "prevalence_map", "lisa_map")
            ),
            selectInput(
              ns("layout_columns"),
              "Output layout",
              choices = c(
                "Two columns" = 2,
                "One column" = 1
              ),
              selected = 2,
              width = "100%"
            ),
            radioButtons(
              ns("table_display_mode"),
              "Results table location",
              choices = c(
                "Show tables in the Output tab" = "output",
                "Show tables in a separate Output Table tab inside Dashboard" = "separate"
              ),
              selected = "output"
            ),
            tags$hr(),
            h3("Display settings"),
            p(
              class = "display-preview-note",
              "These settings change how information is shown in the app. They do not modify downloaded CSV files."
            ),
            selectInput(
              ns("display_font_size"),
              "Display font size",
              choices = c(
                "Small" = "small",
                "Medium" = "medium",
                "Large" = "large",
                "Extra large" = "extra_large"
              ),
              selected = "medium",
              width = "100%"
            ),
            selectInput(
              ns("display_decimals"),
              "Decimal places shown in result tables",
              choices = as.character(0:6),
              selected = "4",
              width = "100%"
            ),
            checkboxInput(
              ns("reactive_display"),
              "Update outputs automatically when analysis parameters change",
              value = FALSE
            ),
            tags$small(
              class = "display-preview-note",
              "When enabled, results refresh as CUSUM parameters or map time-window inputs change. Changes to the active data, geography level, or selected locations still require Run Analysis."
            )
          )
        ),
        column(
          width = 5,
          div(
            class = "display-settings-card",
            h3("Layout preview"),
            p(
              class = "display-preview-note",
              "This preview summarizes the selected layout. Drag-and-drop positioning is not enabled yet."
            ),
            uiOutput(ns("layout_preview"))
          )
        )
      )
    )
  )
}
