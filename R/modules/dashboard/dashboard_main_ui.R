dashboard_main_ui <- function(ns) {
  div(
    class = "dashboard-main-panel",
    uiOutput(ns("summary_cards")),
    uiOutput(ns("dashboard_internal_tabs"))
  )
}
