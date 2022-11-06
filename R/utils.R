drop_null <- function(x) {
  Filter(Negate(is.null), x)
}

make_reactive <- function(x) {
  if (shiny::is.reactive(x)) {
    x
  } else {
    shiny::reactive(x)
  }
}

make_path <- function(path) {
  suppressWarnings(normalizePath(path, winslash = "/"))
}

is_subdir <- function(parent, child) {
  parent <- make_path(parent)
  child <- make_path(child)
  startsWith(child, parent)
}

get_files_dirs_real <- function(path, extensions = NULL, hidden = FALSE, root = NULL) {
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

get_files_dirs_fake <- function(path, paths) {
  if (path != "") {
    path <- paste0(path, "/")
  }
  paths_in_wd <- paths[startsWith(paths, path)]
  paths_in_wd <- substring(paths_in_wd, nchar(path) + 1)

  parts <- strsplit(paths_in_wd, "/")
  all_files <- unlist(lapply(parts, utils::head, 1))
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

create_file_row <- function(type = FILEBROWSER_TYPES, path, text = basename(path),
                            show_icons = TRUE, meta = NULL, ns = shiny::NS(NULL)) {
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
    class = paste0("file-row file-type-", type),
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
        parts <- c(stats::setNames(path, path), parts)
      }
      break
    }

    # A path that doesn't start with a slash
    if (parent == "" || parent == ".") {
      parts <- c(stats::setNames(name, path), parts)
      break
    }

    # Special case: the C:/ or D:/ etc drives on Windows
    if (dirname(path) == path) {
      parts <- c(stats::setNames(name, path), parts)
      break
    }

    path <- sub("/+$", "", path)

    parts <- c(stats::setNames(name, path), parts)
    path <- parent
  }
  parts
}

fill_names <- function(x) {
  idx <- which(names(x) == "")
  names(x)[idx] <- x[idx]
  x
}
