# =============================================================================
# App-level UI and Server
# =============================================================================

appUI <- function() {
  fluidPage(
    shinyjs::useShinyjs(),
    
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "config.css"
      ),
      tags$script(HTML("
        (function () {
          var isLoadingOutput = false;
          var plotOutputIds = [
            'dashboard-cusum_overview',
            'dashboard-cusum_series',
            'dashboard-cusum_process',
            'dashboard-prevalence_map',
            'dashboard-lisa_map'
          ];

          function isDashboardPlot(event) {
            return plotOutputIds.indexOf(event.name) !== -1;
          }

          function showDashboardLoading() {
            isLoadingOutput = true;
            $('#dashboard-loading-overlay')
              .addClass('is-visible')
              .attr('aria-hidden', 'false');
          }

          function hideDashboardLoading() {
            isLoadingOutput = false;
            $('#dashboard-loading-overlay')
              .removeClass('is-visible')
              .attr('aria-hidden', 'true');
          }

        $(document)
          .off('shiny:inputchanged.dashboardLoading')
          .on('shiny:inputchanged.dashboardLoading', function (event) {
            if (event.name === 'dashboard-run_analysis') {
              showDashboardLoading();
            }
          })
          .off('shiny:outputinvalidated.dashboardLoading')
          .on('shiny:outputinvalidated.dashboardLoading', function (event) {
            if (isDashboardPlot(event)) {
              showDashboardLoading();
            }
          })
          .off('shiny:idle.dashboardLoading')
          .on('shiny:idle.dashboardLoading', function () {
            if (isLoadingOutput) {
              hideDashboardLoading();
            }
          });
        }());
      "))
    ),
    
    rap_header("Digital Dashboard"),
    
    app_navbar(),
    
    tagList(
      tabsetPanel(
        id = "main_tabs",
        type = "hidden",
        
        tabPanel("home", homeUI()),
        
        tabPanel("dashboard", unifiedDashboardUI("dashboard")),
        
        tabPanel("display", dashboard_display_ui(NS("dashboard"))),
        
        
        tabPanel("help", helpUI())
      ),
      tags$div(
        id = "dashboard-loading-overlay",
        class = "dashboard-loading-overlay",
        role = "status",
        `aria-live` = "polite",
        `aria-hidden` = "true",
        tags$div(
          class = "dashboard-loading-dialog",
          tags$div(
            class = "dashboard-loading-spinner",
            `aria-hidden` = "true"
          ),
          tags$div(class = "dashboard-loading-title", "Loading..."),
          tags$div(
            class = "dashboard-loading-message",
            "Processing data and updating results."
          )
        )
      )
    )
  )
}


appServer <- function(input, output, session) {
  app_state <- create_app_state()
  
  observeEvent(input$nav_home, {
    updateTabsetPanel(session, "main_tabs", selected = "home")
  })
  
  observeEvent(input$nav_dashboard, {
    updateTabsetPanel(session, "main_tabs", selected = "dashboard")
  })
  
  observeEvent(input$nav_display, {
    updateTabsetPanel(session, "main_tabs", selected = "display")
  })
  
  
  observeEvent(input$nav_help, {
    updateTabsetPanel(session, "main_tabs", selected = "help")
  })
  
  observeEvent(input$show_api_pop_structure, {
    showModal(
      modalDialog(
        title = "Required API-POP file structure",
        size = "l",
        easyClose = TRUE,
        
        div(
          class = "api-pop-structure-modal",
          
          p(
            "The uploaded file should contain one row per geographic unit and ",
            "epidemiological time period. The dashboard uses these columns to run ",
            "the CUSUM and Geospatial analyses."
          ),
          
          tags$table(
            class = "uploaded-files-table api-pop-structure-table",
            
            tags$thead(
              tags$tr(
                tags$th("Column"),
                tags$th("Required"),
                tags$th("Description"),
                tags$th("Example")
              )
            ),
            
            tags$tbody(
              tags$tr(
                tags$td("year"),
                tags$td("Yes"),
                tags$td("Epidemiological year."),
                tags$td("2026")
              ),
              tags$tr(
                tags$td("week"),
                tags$td("Yes"),
                tags$td("Epidemiological week number."),
                tags$td("8")
              ),
              tags$tr(
                tags$td("level1"),
                tags$td("Yes"),
                tags$td("First geographic level, usually province or equivalent."),
                tags$td("Buenos Aires")
              ),
              tags$tr(
                tags$td("level2"),
                tags$td("Recommended"),
                tags$td("Second geographic level, usually department or equivalent."),
                tags$td("La Plata")
              ),
              tags$tr(
                tags$td("level3"),
                tags$td("Optional"),
                tags$td("Third geographic level, if available."),
                tags$td("001")
              ),
              tags$tr(
                tags$td("cases"),
                tags$td("Yes"),
                tags$td("Observed suspected cases or event count."),
                tags$td("12")
              ),
              tags$tr(
                tags$td("population"),
                tags$td("Required for Geospatial"),
                tags$td("Population denominator used for rates and prevalence maps."),
                tags$td("150000")
              )
            )
          ),
          
          br(),
          
          div(
            class = "empty-state",
            strong("Minimum recommended structure:"),
            tags$pre(
              paste(
                "year,week,level1,level2,cases,population",
                "2026,6,Buenos Aires,La Plata,12,150000",
                "2026,7,Buenos Aires,La Plata,15,150000",
                "2026,8,Buenos Aires,La Plata,10,150000",
                sep = "\n"
              )
            )
          ),
          
          p(
            "Column names may be standardized during import depending on the current ",
            "configuration, but the dataset still needs to contain equivalent year, ",
            "week, location, case/count, and population information."
          )
        ),
        footer = modalButton("Close")
      )
    )
  })
  
  unifiedDashboardServer("dashboard", app_state)
}
