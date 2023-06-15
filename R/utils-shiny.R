FILEBROWSER_TYPE_PARENT <- "parent"
FILEBROWSER_TYPE_DIR <- "dir"
FILEBROWSER_TYPE_FILE <- "file"
FILEBROWSER_TYPES <- c(FILEBROWSER_TYPE_PARENT, FILEBROWSER_TYPE_DIR, FILEBROWSER_TYPE_FILE)

make_reactive <- function(x) {
  if (shiny::is.reactive(x)) {
    x
  } else {
    shiny::reactive(x)
  }
}

create_file_row <- function(type = FILEBROWSER_TYPES, path, text = basename(path),
                            show_icons = TRUE, meta = NULL, active = FALSE, ns = shiny::NS(NULL)) {
  type <- match.arg(type)

  if (path == ".") {
    path <- ""
  }

  icon_div <- NULL
  if (show_icons) {
    if (type == FILEBROWSER_TYPE_PARENT) {
      icon_type <- "arrow-left"
    } else if (type == FILEBROWSER_TYPE_DIR) {
      icon_type <- "folder"
    } else if (type == FILEBROWSER_TYPE_FILE) {
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

