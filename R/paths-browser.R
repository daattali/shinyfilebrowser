paths_browser_ui <- function(id, height = NULL) {
  ns <- NS(id)

  style <- if (!is.null(height)) paste0("height: ", htmltools::validateCssUnit(height))

  div(
    singleton(tags$head(tags$style(FILEBROWSER_CSS))),
    class = "shiny-file-browser",
    style = style,
    div(class = "current-wd", uiOutput(ns("current_wd"))),
    div(class = "file-list", uiOutput(ns("file_list")))
  )
}

paths_browser_server <- function(
    id,
    paths,
    show_extension = TRUE,
    parent_text = ".."
) {
  moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      paths_r <- make_reactive(paths)

      wd <- reactiveVal(NULL)
      selected <- reactiveVal(NULL)

      observeEvent(paths_r(), {
        wd("")
        selected(NULL)
      })

      output$current_wd <- renderUI({
        home_crumb <- setNames("Home", "")
        crumbs <- c(home_crumb, make_breadcrumbs(wd()))
        crumbs_html <- lapply(seq_along(crumbs), function(idx) {
          tagList(
            if (idx > 1) span(HTML("&rsaquo;"), class = "file-breadcrumb-separator"),
            span(
              unname(crumbs[idx]),
              onclick = create_file_onclick(names(crumbs[idx]), ns = ns),
              class = "file-breadcrumb",
              class = "file-breadcrumb-clickable"
            )
          )
        })
        div(crumbs_html, class = "current-wd-breadcrumbs")
      })

      at_root <- reactive({
        !is.null(wd()) && wd() == ""
      })

      get_files_dirs <- reactive({
        get_files_dirs_paths(path = wd(), paths = paths_r())
      })

      output$file_list <- renderUI({
        files_dirs <- get_files_dirs()

        dirs_rows <- lapply(files_dirs$dirs, function(dir) {
          create_file_row(FILEBROWSER_TYPE_DIR, dir, ns = ns)
        })
        files_rows <- lapply(files_dirs$files, function(file) {
          if (show_extension) {
            file_text <- basename(file)
          } else {
            file_text <- tools::file_path_sans_ext(basename(file))
          }

          create_file_row(FILEBROWSER_TYPE_FILE, file, file_text, ns = ns)
        })

        dirs_rows <- drop_null(dirs_rows)
        files_rows <- drop_null(files_rows)

        if (at_root()) {
          parent_row <- NULL
        } else {
          parent <- dirname(wd())
          if (parent == ".") {
            parent <- ""
          }
          parent_row <- create_file_row(FILEBROWSER_TYPE_PARENT, parent, parent_text, ns = ns)
        }

        tagList(
          parent_row,
          dirs_rows,
          files_rows,
          if (length(dirs_rows) == 0 && length(files_rows) == 0) div("No files here")
        )
      })

      observeEvent(input$file_clicked, {
        files_dirs <- get_files_dirs()

        isdir <- !input$file_clicked %in% files_dirs$files

        if (isdir) {
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

get_files_dirs_paths <- function(path, paths) {
  if (path != "") {
    path <- paste0(path, "/")
  }
  paths_in_wd <- paths[startsWith(paths, path)]
  paths_in_wd <- substring(paths_in_wd, nchar(path) + 1)

  parts <- strsplit(paths_in_wd, "/")
  all_files <- unlist(lapply(parts, head, 1))
  files_idx <- lengths(parts) == 1
  files <- unique(all_files[files_idx])
  dirs <- unique(all_files[!files_idx])

  if (length(files) > 0) {
    files <- paste0(path, files)
  }
  if (length(dirs) > 0) {
    dirs <- paste0(path, dirs)
  }

  list(files = files, dirs = dirs)
}

create_file_row <- function(type = FILEBROWSER_TYPES, path, text = basename(path), meta = NULL, ns = shiny::NS(NULL)) {
  type <- match.arg(type)

  if (type == FILEBROWSER_TYPE_PARENT) {
    icon_type <- "arrow-left"
  } else if (type == FILEBROWSER_TYPE_DIR) {
    icon_type <- "folder"
  } else if (type == FILEBROWSER_TYPE_FILE) {
    icon_type <- "file-alt"
  }

  if (!is.null(meta)) {
    meta <- tagList(
      "-",
      span(meta, class = "file-meta")
    )
  }

  div(
    class = paste0("file-row file-type-", type),
    onclick = create_file_onclick(path, ns = ns),
    div(icon(icon_type, class = "fa-fw", verify_fa = FALSE), class = "file-icon"),
    div(
      class = "file-contents",
      span(text, class = "file-name"),
      meta
    )
  )
}

create_file_onclick <- function(new_path, ns = shiny::NS(NULL)) {
  glue::glue(
    "Shiny.setInputValue('{{ ns('file_clicked') }}', '{{ new_path }}', {priority: 'event'})",
    .open = "{{", .close = "}}"
  )
}
