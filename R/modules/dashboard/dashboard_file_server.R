dashboard_file_server <- function(input, output, session, app_state) {
  ns <- session$ns
  
  observeEvent(input$file_upload, {
    req(input$file_upload)
    
    uploaded <- input$file_upload
    
    for (i in seq_len(nrow(uploaded))) {
      file_id <- paste0(
        format(Sys.time(), "%Y%m%d%H%M%S"),
        "_",
        i,
        "_",
        make.names(tools::file_path_sans_ext(uploaded$name[i]))
      )
      
      dat <- tryCatch(
        {
          file_paths <- setNames(
            uploaded$datapath[i],
            uploaded$name[i]
          )
          
          read_api_pop_files(
            file_paths,
            config,
            active_country
          )
        },
        error = function(e) {
          app_state$last_error <- paste(
            "Error loading",
            uploaded$name[i],
            ":",
            e$message
          )
          
          showNotification(
            app_state$last_error,
            type = "error",
            duration = 12
          )
          
          NULL
        }
      )
      
      if (!is.null(dat)) {
        validation_error <- validate_api_pop_data(
          dat,
          require_population = FALSE
        )
        
        if (!is.null(validation_error)) {
          app_state$last_error <- paste(
            "Validation error in",
            uploaded$name[i],
            ":",
            validation_error
          )
          
          showNotification(
            app_state$last_error,
            type = "error",
            duration = 12
          )
        } else {
          file_info <- file.info(uploaded$datapath[i])
          
          app_state$uploaded_files[[file_id]] <- list(
            id = file_id,
            name = uploaded$name[i],
            data = dat,
            rows = nrow(dat),
            cols = ncol(dat),
            year_week_range = get_year_week_range(dat),
            modified_at = file_info$mtime,
            size_bytes = file_info$size,
            uploaded_at = Sys.time()
          )
          
          app_state$active_file_ids <- unique(
            c(app_state$active_file_ids, file_id)
          )
        }
      }
    }
    
    if (length(app_state$uploaded_files) > 0) {
      refresh_active_dashboard_data(app_state)
      
      showNotification(
        "Data uploaded and standardized.",
        type = "message"
      )
    }
  }, ignoreInit = TRUE)
  
  
  output$uploaded_files_ui <- renderUI({
    file_count <- length(app_state$uploaded_files)
    active_count <- length(app_state$active_file_ids)
    
    tagList(
      div(
        class = "uploaded-files-summary",
        div(
          class = "uploaded-files-summary-row",
          span(class = "uploaded-files-label", "Uploaded files"),
          span(class = "uploaded-files-count", file_count)
        ),
        div(
          class = "uploaded-files-summary-row",
          span(class = "uploaded-files-label muted", "Active files"),
          span(class = "uploaded-files-count active", active_count)
        )
      ),
      
      actionButton(
        ns("manage_uploaded_files"),
        "Manage files",
        class = "dashboard-small-button"
      )
    )
  })
  
  
  output$data_status <- renderUI({
    if (is.null(app_state$raw_data)) {
      return(
        tags$small(
          style = "color:#cccccc;",
          "No active data selected."
        )
      )
    }
    
    if (!is.null(app_state$last_error)) {
      return(
        div(
          class = "dashboard-error",
          app_state$last_error
        )
      )
    }
    
    tags$small(
      style = "color:#d9f2d9;",
      sprintf(
        "%s rows loaded from %s active file(s).",
        nrow(app_state$raw_data),
        length(app_state$file_names)
      )
    )
  })
  
  
  observeEvent(input$manage_uploaded_files, {
    files <- app_state$uploaded_files
    
    if (length(files) == 0) {
      showModal(
        modalDialog(
          title = "Uploaded files",
          p("No files have been uploaded."),
          easyClose = TRUE,
          footer = modalButton("Close")
        )
      )
      
      return()
    }
    
    table_rows <- lapply(files, function(x) {
      checked <- x$id %in% app_state$active_file_ids
      
      tags$tr(
        tags$td(
          checkboxInput(
            ns(paste0("file_active_", x$id)),
            label = NULL,
            value = checked,
            width = "20px"
          )
        ),
        tags$td(x$name),
        tags$td(x$rows),
        tags$td(x$year_week_range),
        tags$td(format(x$modified_at, "%Y-%m-%d %H:%M")),
        tags$td(format_file_size(x$size_bytes)),
        tags$td(
          actionButton(
            ns(paste0("remove_file_", x$id)),
            "Remove",
            class = "dashboard-danger-button btn-xs"
          )
        )
      )
    })
    
    showModal(
      modalDialog(
        title = "Uploaded files",
        size = "l",
        easyClose = TRUE,
        
        tags$table(
          class = "uploaded-files-table",
          tags$thead(
            tags$tr(
              tags$th("Active"),
              tags$th("File name"),
              tags$th("Rows"),
              tags$th("Year-Week"),
              tags$th("Date modified"),
              tags$th("Size"),
              tags$th("Actions")
            )
          ),
          tags$tbody(table_rows)
        ),
        
        footer = tagList(
          actionButton(
            ns("apply_file_selection"),
            "Apply selection",
            class = "dashboard-primary-button"
          ),
          actionButton(
            ns("clear_all_files_modal"),
            "Clear all files",
            class = "dashboard-danger-button"
          ),
          modalButton("Close")
        )
      )
    )
  })
  
  
  observeEvent(input$apply_file_selection, {
    files <- app_state$uploaded_files
    
    selected_ids <- names(files)[
      vapply(
        names(files),
        function(id) {
          isTRUE(input[[paste0("file_active_", id)]])
        },
        logical(1)
      )
    ]
    
    app_state$active_file_ids <- selected_ids
    
    refresh_active_dashboard_data(app_state)
    
    removeModal()
    
    showNotification(
      paste(length(selected_ids), "active file(s) selected."),
      type = "message"
    )
  })
  
  
  observeEvent(input$clear_all_files_modal, {
    app_state$uploaded_files <- list()
    app_state$active_file_ids <- character(0)
    
    app_state$raw_data <- NULL
    app_state$file_names <- NULL
    app_state$last_error <- NULL
    
    app_state$cusum_results <- NULL
    app_state$geo_results <- NULL
    app_state$cusum_prepared <- NULL
    
    removeModal()
    
    showNotification(
      "All uploaded files were removed.",
      type = "message"
    )
  })
  
  
  observe({
    files <- app_state$uploaded_files
    
    lapply(names(files), function(file_id) {
      local({
        id <- file_id
        
        observeEvent(input[[paste0("remove_file_", id)]], {
          if (!id %in% names(app_state$uploaded_files)) {
            return()
          }
          
          app_state$uploaded_files[[id]] <- NULL
          
          app_state$active_file_ids <- setdiff(
            app_state$active_file_ids,
            id
          )
          
          refresh_active_dashboard_data(app_state)
          
          removeModal()
          
          showNotification(
            "File removed.",
            type = "message"
          )
        }, ignoreInit = TRUE)
      })
    })
  })
}