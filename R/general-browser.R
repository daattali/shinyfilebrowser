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
    htmltools::htmlDependency(
      name = "shinyfilebrowser-binding",
      version = as.character(utils::packageVersion("shinyfilebrowser")),
      package = "shinyfilebrowser",
      src = "assets/shinyfilebrowser",
      stylesheet = "shinyfilebrowser.css"
    ),
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
    return_path = TRUE,
    id,
    path,
    extensions = NULL,
    root = NULL,
    include_hidden = FALSE,
    include_empty = TRUE,
    show_path = TRUE,
    show_extension = TRUE,
    show_size = TRUE,
    show_icons = TRUE,
    text_parent = "..",
    text_empty = "No files here"
) {
  shiny::moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      wd <- shiny::reactiveVal(NULL)
      selected <- shiny::reactiveVal(NULL)

      path_r <- make_reactive(path)
      extensions_r <- make_reactive(extensions)
      root_r <- make_reactive(root)
      include_hidden_r <- make_reactive(include_hidden)
      include_empty_r <- make_reactive(include_empty)
      show_path_r <- make_reactive(show_path)
      show_extension_r <- make_reactive(show_extension)
      show_size_r <- make_reactive(show_size)
      show_icons_r <- make_reactive(show_icons)
      text_parent_r <- make_reactive(text_parent)
      text_empty_r <- make_reactive(text_empty)

      values_asis <- shiny::reactiveVal(NULL)

      shiny::observeEvent(path_r(), ignoreNULL = FALSE, {
        if (real_fs) {
          initial_path <- make_path(path_r())
        } else {
          if (is.null(names(path_r()))) {
            if (any(grepl("^/+", path_r()))) {
              stop("Paths should not begin with a slash")
            }
          } else {
            values_asis(fill_names(path_r()))
          }
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

      output$current_wd <- shiny::renderUI({
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

          shiny::tagList(
            if (idx > 1) shiny::span(shiny::HTML("&rsaquo;"), class = "file-breadcrumb-separator"),
            shiny::span(
              unname(crumbs[idx]),
              onclick = create_file_onclick(names(crumbs[idx]), ns = ns),
              class = class
            )
          )
        })
        shiny::div(crumbs_html, class = "current-wd-breadcrumbs")
      })

      at_root <- shiny::reactive({
        if (real_fs) {
          !is.null(wd()) && !is.null(root_r()) && make_path(wd()) == make_path(root_r())
        } else {
          !is.null(wd()) && wd() == ""
        }
      })

      get_files_dirs <- shiny::reactive({
        if (real_fs) {
          get_files_dirs_real(path = wd(), extensions = extensions_r(), hidden = include_hidden_r(), root = root_r())
        } else {
          if (is.null(path_r())) {
            list(files = character(0), dirs = character(0))
          } else if (is.null(values_asis())) {
            get_files_dirs_fake(path = wd(), paths = path_r())
          } else {
            list(files = values_asis(), dirs = character(0))
          }
        }
      })

      output$file_list <- shiny::renderUI({
        files_dirs <- get_files_dirs()

        dirs_rows <- lapply(files_dirs$dirs, function(dir) {
          create_file_row(FILEBROWSER_TYPE_DIR, dir, show_icons = show_icons_r(), ns = ns)
        })
        files_rows <- lapply(files_dirs$files, function(file) {
          if (real_fs) {
            size <- suppressWarnings(file.info(file)$size)
            if (size == 0 && !include_empty_r()) {
              return(NULL)
            }

            if (show_size_r()) {
              size <- natural_size(size)
            } else {
              size <- NULL
            }
          } else {
            size <- NULL
          }

          if (!is.null(values_asis())) {
            file_text <- names(which(values_asis() == file))[1]
          } else if (show_extension_r()) {
            file_text <- basename(file)
          } else {
            file_text <- tools::file_path_sans_ext(basename(file))
          }

          active <- !is.null(selected()) && file == selected()

          create_file_row(FILEBROWSER_TYPE_FILE, file, file_text, size, show_icons = show_icons_r(), active = active, ns = ns)
        })

        dirs_rows <- drop_null(dirs_rows)
        files_rows <- drop_null(files_rows)

        if (at_root()) {
          parent_row <- NULL
        } else {
          parent_row <- create_file_row(FILEBROWSER_TYPE_PARENT, dirname(wd()), text_parent_r(), show_icons = show_icons_r(), ns = ns)
        }

        shiny::tagList(
          parent_row,
          dirs_rows,
          files_rows,
          if (length(dirs_rows) == 0 && length(files_rows) == 0) shiny::div(class = "file-empty", text_empty_r())
        )
      })

      shiny::observeEvent(input$file_clicked, {
        if (!is_legal_path(input$file_clicked)) {
          return()
        }

        if (!is_path(input$file_clicked)) {
          return()
        }

        if (is_dir(input$file_clicked)) {
          wd( input$file_clicked )
        } else {
          if (!is.null(selected()) && selected() == input$file_clicked) {
            selected(NULL)
          } else {
            selected( input$file_clicked )
          }
        }
      })

      if (return_path) {
        return(list(
          path = wd,
          selected = selected
        ))
      } else {
        return(selected)
      }
    }
  )
}

