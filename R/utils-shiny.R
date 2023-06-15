BROWSER_TYPE_FILE <- "file"
BROWSER_TYPE_PATH <- "path"
BROWSER_TYPE_LIST <- "list"
BROWSER_TYPES <- c(BROWSER_TYPE_FILE, BROWSER_TYPE_PATH, BROWSER_TYPE_LIST)

FILE_TYPE_PARENT <- "parent"
FILE_TYPE_DIR <- "dir"
FILE_TYPE_FILE <- "file"
FILE_TYPES <- c(FILE_TYPE_PARENT, FILE_TYPE_DIR, FILE_TYPE_FILE)

make_reactive <- function(x) {
  if (shiny::is.reactive(x)) {
    x
  } else {
    shiny::reactive(x)
  }
}

create_file_row <- function(type = FILE_TYPES, path, text = basename(path),
                            show_icons = TRUE, meta = NULL, active = FALSE, ns = shiny::NS(NULL)) {
  type <- match.arg(type)

  if (path == ".") {
    path <- ""
  }

  icon_div <- NULL
  if (show_icons) {
    if (type == FILE_TYPE_PARENT) {
      icon_type <- "arrow-left"
    } else if (type == FILE_TYPE_DIR) {
      icon_type <- "folder"
    } else if (type == FILE_TYPE_FILE) {
      icon_type <- "file-alt"
    }
    icon_div <- shiny::div(
      shiny::icon(icon_type, class = "fa-fw", verify_fa = FALSE),
      class = "file-icon"
    )
  }

  if (!is.null(meta)) {
    meta <- shiny::tagList(
      "-",
      shiny::span(meta, class = "file-meta")
    )
  }

  shiny::div(
    class = paste0("file-row file-type-", type, if (active) " file-selected"),
    onclick = create_file_onclick(path, ns = ns),
    icon_div,
    shiny::div(
      class = "file-contents",
      shiny::span(text, class = "file-name"),
      meta
    )
  )
}

create_file_onclick <- function(new_path, ns = shiny::NS(NULL)) {
  paste0("Shiny.setInputValue('", ns('file_clicked'), "', '", new_path, "', {priority: 'event'})")
}
