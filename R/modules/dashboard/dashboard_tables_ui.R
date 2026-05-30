dashboard_tables_ui <- function(ns) {
  div(
    class = "content-wrapper dashboard-output-table-wrapper",
    div(
      class = "well-custom dashboard-output-table-page",
      h2("Output Table"),
      uiOutput(ns("dashboard_tables_panel"))
    )
  )
}
