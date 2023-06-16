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

make_breadcrumbs_ui <- function(wd, type, root = NULL, ns = shiny::NS(NULL)) {
  crumbs <- make_breadcrumbs(wd, type)

  crumbs_html <- lapply(seq_along(crumbs), function(idx) {
    class <- "file-breadcrumb"
    if (is_legal_path(names(crumbs[idx]), type, root)) {
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
}

make_file_list_ui <- function(wd, type, paths = NULL, root = NULL, extensions = NULL,
                              hidden = FALSE, show_icons = TRUE, include_empty = FALSE,
                              show_size = TRUE, show_extension = TRUE,
                              text_parent = "", text_empty = "", html = FALSE,
                              selected = NULL, ns = shiny::NS(NULL)) {
  files_dirs <- get_files_dirs(wd = wd, type = type, paths = paths, root = root, extensions = extensions, hidden = hidden)

  dirs_rows <- lapply(files_dirs$dirs, function(dir) {
    create_file_row(FILE_TYPE_DIR, dir, show_icons = show_icons, ns = ns)
  })
  files_rows <- lapply(files_dirs$files, function(file) {
    if (is_real_fs(type)) {
      size <- suppressWarnings(file.info(file)$size)
      if (is.na(size)) {
        return(NULL)
      }
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

    if (type == BROWSER_TYPE_LIST) {
      file_text <- names(which(fill_names(paths) == file))[1]
      if (html) {
        file_text <- shiny::HTML(file_text)
      }
    } else if (show_extension) {
      file_text <- basename(file)
    } else {
      file_text <- tools::file_path_sans_ext(basename(file))
    }

    active <- !is.null(selected) && file == selected

    create_file_row(FILE_TYPE_FILE, file, file_text, size, show_icons = show_icons, active = active, ns = ns)
  })

  dirs_rows <- drop_null(dirs_rows)
  files_rows <- drop_null(files_rows)

  if (at_root(wd = wd, type = type, root = root)) {
    parent_row <- NULL
  } else {
    parent_row <- create_file_row(FILE_TYPE_PARENT, dirname(wd), text_parent, show_icons = show_icons, ns = ns)
  }

  shiny::tagList(
    parent_row,
    dirs_rows,
    files_rows,
    if (length(dirs_rows) == 0 && length(files_rows) == 0) shiny::div(class = "file-empty", text_empty)
  )
}
