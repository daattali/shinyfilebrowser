FILEBROWSER_TYPE_PARENT <- "parent"
FILEBROWSER_TYPE_DIR <- "dir"
FILEBROWSER_TYPE_FILE <- "file"
FILEBROWSER_TYPES <- c(FILEBROWSER_TYPE_PARENT, FILEBROWSER_TYPE_DIR, FILEBROWSER_TYPE_FILE)
FILEBROWSER_CSS <-
  ".shiny-file-browser { overflow: auto; border: 1px solid #ddd; padding: 0.5rem; user-select: none; font-size: 1.1em; }
  .shiny-file-browser .current-wd {  padding: 0.5rem 0; }
  .shiny-file-browser .current-wd .current-wd-breadcrumbs { display: flex; align-items: center; }
  .shiny-file-browser .current-wd .file-breadcrumb { white-space: nowrap; padding: 0 0.2em; border-radius: 5px; transition: background 0.3s; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable { cursor: pointer; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable:hover { background: #f6f6f6; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable:active { background: #ccc; }
  .shiny-file-browser .current-wd .file-breadcrumb-separator { color: #b5b5b5; margin: 0 0.1em; }
  .shiny-file-browser .file-list { padding: 0 0.1rem; }
  .shiny-file-browser .file-row { display: flex; cursor: pointer; transition: background 0.3s; }
  .shiny-file-browser .file-row:hover { background: #f6f6f6; }
  .shiny-file-browser .file-row:active { background: #ccc; }
  .shiny-file-browser .file-icon { margin-right: 2rem; }
  .shiny-file-browser .file-type-dir .file-contents,
  .shiny-file-browser .file-type-parent .file-contents { font-weight: bold; }
  .shiny-file-browser .file-meta { font-style: italic; }"

#' File browser
#'
#' Display a simple file browser of the server-side file system.
#' @param id Unique ID for the module
#' @import shiny
#' @name file_browser
NULL

#' @rdname file_browser
#' @param height The height of the file browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
file_browser_ui <- function(id, height = NULL) {
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

#' @rdname file_browser
#' @param path (reactive or static) The initial path the file browser should show.
#' @param extensions (reactive or static) List of file extensions that should be shown.
#' If `NULL`, all file types are shown.
#' @param root The path that should be considered root, which means that the user cannot
#' navigate to any parent of this root. By default, the `path` parameter acts as the root.
#' Use `NULL` to allow the user to navigate the entire filesystem.
#' @param include_hidden (boolean) If `TRUE`, show hidden files and folders.
#' @param include_empty (boolean) If `TRUE`, show empty files (files with size 0 bytes).
#' @param show_extension (boolean) If `TRUE`, show file extensions in the file names.
#' @param show_size (boolean) If `TRUE`, show file sizes along the file names.
#' @param parent_text The text to use to indicate the parent directory.
#' @return List with reactive elements:
#'   - selected: The full normalized path of the selected file (`NULL` before a file is selected)
#'   - path: The full normalized path that is currently displayed in the file browser
file_browser_server <- function(
    id,
    path = getwd(),
    extensions = NULL,
    root = path,
    include_hidden = FALSE,
    include_empty = TRUE,
    show_extension = TRUE,
    show_size = TRUE,
    parent_text = ".."
) {
  moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      path_r <- make_reactive(path)
      extensions_r <- make_reactive(extensions)
      root_r <- make_reactive(root)

      wd <- reactiveVal(NULL)
      selected <- reactiveVal(NULL)

      observeEvent(path_r(), {
        wd(make_path(path_r()))
        selected(NULL)
      })

      output$current_wd <- renderUI({
        crumbs <- make_breadcrumbs(wd())
        crumbs_html <- lapply(seq_along(crumbs), function(idx) {
          tagList(
            if (idx > 1) span(HTML("&rsaquo;"), class = "file-breadcrumb-separator"),
            span(
              unname(crumbs[idx]),
              onclick = create_file_onclick(names(crumbs[idx]), ns = ns),
              class = "file-breadcrumb",
              class = if (is_subdir(root_r(), names(crumbs[idx]))) "file-breadcrumb-clickable"
            )
          )
        })
        div(crumbs_html, class = "current-wd-breadcrumbs")
      })

      at_root <- reactive({
        req(wd())
        !is.null(root_r()) && make_path(wd()) == make_path(root_r())
      })

      output$file_list <- renderUI({
        files_dirs <- get_files_dirs(path = wd(), extensions = extensions_r(), hidden = include_hidden, root = root_r())

        dirs_rows <- lapply(files_dirs$dirs, function(dir) {
          create_file_row(FILEBROWSER_TYPE_DIR, dir, ns = ns)
        })
        files_rows <- lapply(files_dirs$files, function(file) {
          size <- suppressWarnings(file.info(file)$size)
          if (size == 0 && !include_empty) {
            return(NULL)
          }

          if (show_size) {
            size <- natural_size(size)
          } else {
            size <- NULL
          }

          if (show_extension) {
            file_text <- basename(file)
          } else {
            file_text <- tools::file_path_sans_ext(basename(file))
          }

          create_file_row(FILEBROWSER_TYPE_FILE, file, file_text, size, ns = ns)
        })

        dirs_rows <- drop_null(dirs_rows)
        files_rows <- drop_null(files_rows)

        if (at_root()) {
          parent_row <- NULL
        } else {
          parent_row <- create_file_row(FILEBROWSER_TYPE_PARENT, dirname(wd()), parent_text, ns = ns)
        }

        tagList(
          parent_row,
          dirs_rows,
          files_rows,
          if (length(dirs_rows) == 0 && length(files_rows) == 0) div("No files here")
        )
      })

      observeEvent(input$file_clicked, {
        if (!is.null(root_r()) && !is_subdir(root_r(), input$file_clicked)) {
          return()
        }

        isdir <- suppressWarnings(file.info(input$file_clicked)$isdir)
        if (is.na(isdir)) {
          return()
        }

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

make_path <- function(path) {
  suppressWarnings(normalizePath(path, winslash = "/"))
}

is_subdir <- function(parent, child) {
  parent <- make_path(parent)
  child <- make_path(child)
  substr(child, 1, nchar(parent)) == parent
}

get_files_dirs <- function(path, extensions = NULL, hidden = FALSE, root = NULL) {
  all_files <- list.files(path = path, all.files = hidden, full.names = TRUE, recursive = FALSE, no.. = TRUE)

  if (!is.null(root)) {
    all_files <- Filter(function(f) is_subdir(root, f), all_files)
  }

  files <- Filter(function(f) suppressWarnings(!file.info(f)$isdir), all_files)
  dirs <- Filter(function(f) suppressWarnings(file.info(f)$isdir), all_files)
  files <- make_path(sort(files))
  dirs <- make_path(sort(dirs))

  if (length(extensions) > 0) {
    regex <- gsub("\\.", "\\\\.", paste0(extensions, "$", collapse = "|"))
    files <- files[grepl(regex, files)]
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

make_breadcrumbs <- function(path, include_root = TRUE) {
  if (path == "") {
    return(character(0))
  }

  parts <- c()
  while (TRUE) {
    name <- basename(path)
    parent <- dirname(path)

    # A path that begins with a slash
    if (path == "/") {
      if (include_root) {
        parts <- c(setNames(path, path), parts)
      }
      break
    }

    # A path that doesn't start with a slash
    if (parent == "" || parent == ".") {
      parts <- c(setNames(name, path), parts)
      break
    }

    # Special case: the C:/ or D:/ etc drives on Windows
    if (dirname(path) == path) {
      parts <- c(setNames(name, path), parts)
      break
    }

    path <- gsub("/+$", "", path)

    parts <- c(setNames(name, path), parts)
    path <- parent
  }
  parts
}
