# =============================================================================
# Shared UI Components
# =============================================================================

homeUI <- function() {
  tagList(
    div(
      class = "dashboard-home",
      
      h2("RAP Unified Dashboard"),
      
      p(
        "This dashboard combines the CUSUM RAP and Geospatial RAP tools into a ",
        "single interface for upload, filtering, analysis, visualization, and export."
      ),
      
      fluidRow(
        column(
          width = 6,
          div(
            class = "info-card",
            h3("CUSUM Analysis"),
            p(
              "Run early detection analysis using CUSUM methods, configure expected ",
              "frequency, detection period, ARL0, and relative risk settings, and review ",
              "alert outputs."
            )
          )
        ),
        column(
          width = 6,
          div(
            class = "info-card",
            h3("Geospatial Analysis"),
            p(
              "Explore geographic patterns, prevalence maps, and spatial clustering ",
              "outputs using the uploaded API-POP-compatible dataset."
            )
          )
        )
      ),
      
      br(),
      
      div(
        class = "info-card",
        h3("Recommended workflow"),
        tags$ol(
          tags$li("Upload a prepared API-POP output file."),
          tags$li("Review and adjust the global filters."),
          tags$li("Configure CUSUM and geospatial settings."),
          tags$li("Select which plots, maps, and tables to show in the dashboard."),
          tags$li("Export the desired outputs.")
        )
      )
    )
  )
}

helpUI <- function() {
  div(
    class = "content-wrapper help-page-wrapper",
    div(
      class = "well-custom help-page",
      
      h2("Help"),
      
      p(
        "This unified dashboard combines the CUSUM RAP and Geospatial RAP tools ",
        "into a shared interface for data upload, filtering, analysis, visualization, ",
        "and export."
      ),
      
      div(
        class = "help-card",
        h3("General workflow"),
        tags$ol(
          tags$li("Upload one or more API-POP-compatible files."),
          tags$li("Use the global filters to select geographic level, locations, year, and week."),
          tags$li("Configure the CUSUM and geospatial settings as needed."),
          tags$li("Run the analyses."),
          tags$li("Customize which outputs are displayed in the dashboard.")
        )
      ),
      
      div(
        class = "help-card",
        h3("CUSUM RAP"),
        p(
          "The CUSUM tool is used for early detection of unusual increases in cases ",
          "over time. It supports automatic or manual expected frequency settings, ",
        ),
        tags$ul(
          tags$li(strong("Detection period: "), "Number of recent weeks used for detection."),
          tags$li(strong("Expected frequency: "), "Can be calculated automatically or entered manually."),
          tags$li(strong("ARL0: "), "Average run length under the null condition."),
          tags$li(strong("Relative risk: "), "Risk increase to detect.")
        ),
        h3(),
        
        tags$ul(
          tags$li(
            tags$a(
              href = "docs/cusum/HELP_en.pdf",
              target = "_blank",
              "Open CUSUM help document — English"
            )
          ),
          tags$li(
            tags$a(
              href = "docs/cusum/HELP_es.pdf",
              target = "_blank",
              "Abrir documento de ayuda CUSUM — Español"
            )
          )
        )
      ),
      
      div(
        class = "help-card",
        h3("Geospatial RAP"),
        p(
          "The Geospatial tool is used to visualize spatial patterns, generate ",
          "prevalence maps, and identify local spatial clusters using the selected ",
          "geographic level and time window."
        ),
        tags$ul(
          tags$li(strong("Geographic level: "), "Administrative level used for maps and summaries."),
          tags$li(strong("Year/week filters: "), "Time period used for mapped outputs."),
          tags$li(strong("Location filters: "), "Subset of locations included in analysis.")
        ),
        h3(),
        
        tags$ul(
          tags$li(
            tags$a(
              href = "docs/geospatial/HELP_en.pdf",
              target = "_blank",
              "Open Geospatial help document — English"
            )
          ),
          tags$li(
            tags$a(
              href = "docs/geospatial/HELP_es.pdf",
              target = "_blank",
              "Abrir documento de ayuda Geospatial — Español"
            )
          )
        )
      ),
      
      div(
        class = "help-card",
        
        h3("Input data"),
        
        p(
          "The dashboard expects standardized API-POP-compatible data. The same ",
          "uploaded data can be used by both the CUSUM and Geospatial modules, ",
          "as long as the required columns are available."
        ),
        
        p(
          actionLink(
            "show_api_pop_structure",
            "View required API-POP file structure",
            class = "help-link"
          )
        )
      )
    )
  )
}

rap_header <- function(title = "Unified RAP Dashboard") {
  tagList(
    div(class = "nav-bar", div(class = "nav-content", div(class = "header-logo-left"))),
    div(class = "hero-section", div(class = "hero-content", h1(class = "app-title", title)))
  )
}

app_navbar <- function() {
  div(
    class = "menu-bar-tier",
    div(
      class = "custom-navbar unified-navbar",
      actionLink("nav_home", "Home"),
      actionLink("nav_dashboard", "Dashboard"),
      actionLink("nav_cusum", "Legacy CUSUM"),
      actionLink("nav_geo", "Legacy Geospatial"),
      actionLink("nav_help", "Help")
    )
  )
}

summary_card <- function(label, value) {
  div(class = "summary-card", div(class = "summary-label", label), div(class = "summary-value", value))
}

empty_state <- function(title, text) {
  div(class = "empty-state", h3(title), p(text))
}

output_card <- function(title, output_ui, class = "dashboard-output-card") {
  div(class = class, div(class = "output-card-title", title), output_ui)
}

legacy_cusum_page <- function() {
  tagList(
    div(
      class = "content-wrapper",
      div(
        class = "module-title-strip",
        h2("Legacy CUSUM Analysis")
      )
    ),
    cusumUI("cusum_analysis")
  )
}

legacy_geospatial_page <- function() {
  tagList(
    div(
      class = "content-wrapper",
      div(
        class = "module-title-strip",
        h2("Legacy Geospatial Analysis")
      )
    ),
    geospatialUI("geospatial_analysis")
  )
}


