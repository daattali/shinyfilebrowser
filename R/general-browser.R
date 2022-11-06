general_browser_ui <- function(id, height = NULL, width = "100%", bigger = FALSE) {
  ns <- shiny::NS(id)

  width_css <- paste0("width: ", htmltools::validateCssUnit(width), ";")
  height_css <- if (!is.null(height)) paste0("height: ", htmltools::validateCssUnit(height)) else ""
  style <- paste(width_css, height_css)

  class <- "shiny-file-browser"
  if (bigger) {
    class <- paste(class, "shiny-browser-bigger")
  }

  shiny::div(
    shiny::singleton(shiny::tags$head(shiny::tags$style(FILEBROWSER_CSS))),
    class = class,
    style = style,
    shiny::div(
      class = "current-wd",
      shiny::uiOutput(ns("current_wd"))
    ),
    shiny::div(
      class = "file-list",
      shiny::uiOutput(ns("file_list"))
    )
  )
}

general_browser_server <- function(
    real_fs,
    id,
    path,
    extensions = NULL,
    root = NULL,
    include_hidden = NULL,
    include_empty = NULL,
    show_path = NULL,
    show_extension = NULL,
    show_size = NULL,
    show_icons = NULL,
    parent_text = NULL
) {
  moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      wd <- reactiveVal(NULL)
      selected <- reactiveVal(NULL)
      path_r <- make_reactive(path)
      extensions_r <- make_reactive(extensions)
      root_r <- make_reactive(root)
      show_path_r <- make_reactive(show_path)
      show_icons_r <- make_reactive(show_icons)

      observeEvent(path_r(), {
        if (real_fs) {
          initial_path <- make_path(path_r())
        } else {
          initial_path <- ""
        }
        wd(initial_path)
        selected(NULL)
      })

      is_legal_path <- function(path) {
        if (real_fs) {
          is.null(root_r()) || is_subdir(root_r(), path)
        } else {
          TRUE
        }
      }

      is_path <- function(path) {
        if (real_fs) {
          !is.na(suppressWarnings(file.info(path)$isdir))
        } else {
          is_end_path <- path %in% path_r()
          is_parent_path <- sum(grepl(paste0(path, "/"), path_r(), fixed = TRUE)) > 0
          is_end_path || is_parent_path
        }
      }

      is_dir <- function(path) {
        if (real_fs) {
          suppressWarnings(file.info(path)$isdir)
        } else {
          !path %in% path_r()
        }
      }

      output$current_wd <- renderUI({
        if (!show_path_r()) return()

        crumbs <- make_breadcrumbs(wd())
        if (!real_fs) {
          home_crumb <- stats::setNames("Home", "")
          crumbs <- c(home_crumb, crumbs)
        }

        crumbs_html <- lapply(seq_along(crumbs), function(idx) {
          class <- "file-breadcrumb"
          if (is_legal_path(names(crumbs[idx]))) {
            class <- paste(class, "file-breadcrumb-clickable")
          }

          tagList(
            if (idx > 1) span(HTML("&rsaquo;"), class = "file-breadcrumb-separator"),
            span(
              unname(crumbs[idx]),
              onclick = create_file_onclick(names(crumbs[idx]), ns = ns),
              class = class
            )
          )
        })
        div(crumbs_html, class = "current-wd-breadcrumbs")
      })

      at_root <- reactive({
        if (real_fs) {
          !is.null(wd()) && !is.null(root_r()) && make_path(wd()) == make_path(root_r())
        } else {
          !is.null(wd()) && wd() == ""
        }
      })

      get_files_dirs <- reactive({
        if (real_fs) {
          get_files_dirs_real(path = wd(), extensions = extensions_r(), hidden = include_hidden, root = root_r())
        } else {
          get_files_dirs_fake(path = wd(), paths = path_r())
        }
      })

      output$file_list <- renderUI({
        files_dirs <- get_files_dirs()

        dirs_rows <- lapply(files_dirs$dirs, function(dir) {
          create_file_row(FILEBROWSER_TYPE_DIR, dir, show_icons = show_icons_r(), ns = ns)
        })
        files_rows <- lapply(files_dirs$files, function(file) {
          if (real_fs) {
            size <- suppressWarnings(file.info(file)$size)
            if (size == 0 && !include_empty) {
              return(NULL)
            }

            if (show_size) {
              size <- natural_size(size)
            } else {
              size <- NULL
            }
          } else {
            size <- NULL
          }

          if (show_extension) {
            file_text <- basename(file)
          } else {
            file_text <- tools::file_path_sans_ext(basename(file))
          }

          create_file_row(FILEBROWSER_TYPE_FILE, file, file_text, size, show_icons = show_icons_r(),  ns = ns)
        })

        dirs_rows <- drop_null(dirs_rows)
        files_rows <- drop_null(files_rows)

        if (at_root()) {
          parent_row <- NULL
        } else {
          parent_row <- create_file_row(FILEBROWSER_TYPE_PARENT, dirname(wd()), parent_text, show_icons = show_icons_r(), ns = ns)
        }

        tagList(
          parent_row,
          dirs_rows,
          files_rows,
          if (length(dirs_rows) == 0 && length(files_rows) == 0) div("No files here")
        )
      })

      observeEvent(input$file_clicked, {
        if (!is_legal_path(input$file_clicked)) {
          return()
        }

        if (!is_path(input$file_clicked)) {
          return()
        }

        if (is_dir(input$file_clicked)) {
          wd( input$file_clicked )
        } else {
          selected( input$file_clicked )
        }
      })

      return(list(
        path = wd,
        selected = selected
      ))
    }
  )
}

