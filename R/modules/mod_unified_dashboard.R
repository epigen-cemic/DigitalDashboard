# =============================================================================
# Unified Dashboard Module
# -----------------------------------------------------------------------------
# This file only coordinates the dashboard.
# UI pieces and server responsibilities are split into dashboard/* files.
# =============================================================================

unifiedDashboardUI <- function(id) {
  ns <- NS(id)
  
  div(
    class = "content-wrapper unified-dashboard-wrapper",
    div(
      class = "well-custom",
      fluidRow(
        column(
          width = 3,
          dashboard_sidebar_ui(ns)
        ),
        column(
          width = 9,
          dashboard_main_ui(ns)
        )
      )
    )
  )
}


unifiedDashboardServer <- function(id, app_state) {
  moduleServer(id, function(input, output, session) {
    
    # -------------------------------------------------------------------------
    # File upload and file manager
    # -------------------------------------------------------------------------
    dashboard_file_server(
      input = input,
      output = output,
      session = session,
      app_state = app_state
    )
    
    # -------------------------------------------------------------------------
    # Global filters
    # -------------------------------------------------------------------------
    dashboard_filter_server(
      input = input,
      output = output,
      session = session,
      app_state = app_state
    )
    
    # -------------------------------------------------------------------------
    # CUSUM analysis
    # -------------------------------------------------------------------------
    dashboard_cusum_server(
      input = input,
      output = output,
      session = session,
      app_state = app_state
    )
    
    # -------------------------------------------------------------------------
    # Geospatial analysis
    # -------------------------------------------------------------------------
    dashboard_geo_server(
      input = input,
      output = output,
      session = session,
      app_state = app_state
    )
    
    # -------------------------------------------------------------------------
    # Dashboard outputs
    # -------------------------------------------------------------------------
    dashboard_output_server(
      input = input,
      output = output,
      session = session,
      app_state = app_state
    )
  })
}