# =============================================================================
# Shared UI Components
# =============================================================================

homeUI <- function() {
  tagList(
    div(
      class = "dashboard-home",
      
      h2("Digital Dashboard"),
      
      p(
        "The Digital Dashboard combines the CUSUM RAP and Geospatial RAP tools into a ",
        "single interface for upload, filtering, analysis, visualization, display customization, and export."
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
        class = "info-card display-home-card",
        h3("Display"),
        p(
          "The Display tab is the main control area for how dashboard results are presented. ",
          "Use it to choose which CUSUM plots and Geospatial maps are visible, select a one- ",
          "or two-column output layout, and decide whether result tables should appear inside ",
          "the Output tab or in their own Output Table tab inside the Dashboard."
        ),
        p(
          "The Display tab also includes readability and behavior settings. Users can increase the interface ",
          "font size, choose how many decimal places are shown in on-screen result tables, and optionally ",
          "allow outputs to refresh automatically when analysis parameters change. These display settings do not change the downloaded CSV values."
        ),
        p(
          "Download buttons appear on each output card only after the corresponding results are available. ",
          "CUSUM plots can be exported as PNG files, result tables can be exported as CSV files, ",
          "and Geospatial maps can be exported as PNG files ."
        )
      ),
      
      br(),
      
      div(
        class = "info-card",
        h3("Recommended workflow"),
        tags$ol(
          tags$li("Upload one or more prepared API-POP output files."),
          tags$li("Review and adjust the global filters."),
          tags$li("Configure CUSUM settings and choose the geospatial map time window next to the week selector."),
          tags$li("Open the Display tab to select visible outputs, layout, table placement, font size, table decimal display, and optional reactive display behavior."),
          tags$li("Click Run Analysis to refresh both CUSUM and Geospatial outputs."),
          tags$li("Review the dashboard Output, Prepared Data, and optional Output Table tabs."),
          tags$li("Export the desired plots, maps, and tables once results are available.")
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
        "The Digital Dashboard combines the CUSUM RAP and Geospatial RAP tools ",
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
          tags$li("Click Run Analysis."),
          tags$li("Use the Display tab to customize which outputs are shown, whether tables appear in the main output or in a separate dashboard tab, and whether parameter changes should update outputs automatically after the first run.")
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
       
        tags$ul( tags$li(tags$a(href = "docs/2.3.3 Geospatial Analysis - 1.3. CUSUM RAP User Manual.docx", download ="2.3.3 Geospatial Analysis - 1.3. CUSUM RAP User Manual.docx" ,target = "_self", "Download CUSUM user manual")))
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
        
        tags$ul(tags$li(tags$a(href = "docs/2.3.3 Geospatial Analysis - 2.3 User-Manual.docx", download ="2.3.3 Geospatial Analysis - 2.3 User-Manual.docx" ,target = "_self", "Download Geospatial user manual")))
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

rap_header <- function(title = "Digital Dashboard") {
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
      actionLink("nav_display", "Display"),
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