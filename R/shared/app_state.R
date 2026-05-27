# =============================================================================
# Shared Application State
# =============================================================================

create_app_state <- function() {
  reactiveValues(
    uploaded_files = list(),
    active_file_ids = character(0),
    
    raw_data = NULL,
    file_names = NULL,
    last_error = NULL,
    
    cusum_prepared = NULL,
    cusum_results = NULL,
    geo_results = NULL
  )
}