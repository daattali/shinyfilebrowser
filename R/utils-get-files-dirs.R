make_path <- function(path) {
  suppressWarnings(normalizePath(path, winslash = "/"))
}

is_subdir <- function(parent, child) {
  parent <- make_path(parent)
  child <- make_path(child)
  startsWith(child, parent)
}

get_initial_path <- function(path, type) {
  if (type == "file") {
    if (!dir.exists(path)) {
      stop("file_browser: Initial path does not exist: ", path)
    }
    make_path(path)
  } else if (type == "path") {
    if (!is.null(names(path))) {
      stop("path_browser: Paths cannot be named lists, consider using `list_selector` instead.")
    }
    if (any(grepl("^/+", path))) {
      stop("path_browser: Paths should not begin with a slash.")
    }
    if (!all(nzchar(path))) {
      stop("path_browser: Paths should not be empty.")
    }
    ""
  } else {
    ""
  }
}

is_legal_path <- function(path, real_fs, root) {
  if (real_fs) {
    is.null(root) || is_subdir(root, path)
  } else {
    TRUE
  }
}

is_path <- function(path, real_fs, all_paths) {
  if (real_fs) {
    !is.na(suppressWarnings(file.info(path)$isdir))
  } else {
    is_end_path <- path %in% all_paths
    is_parent_path <- sum(grepl(paste0(path, "/"), all_paths, fixed = TRUE)) > 0
    is_end_path || is_parent_path
  }
}

is_dir <- function(path, real_fs, all_paths) {
  if (real_fs) {
    suppressWarnings(file.info(path)$isdir)
  } else {
    !path %in% all_paths
  }
}

get_files_dirs_real <- function(path, extensions = NULL, hidden = FALSE, root = NULL) {
  files <- list.files(path = path, all.files = hidden, full.names = TRUE, recursive = FALSE, no.. = TRUE)
  dirs <- list.dirs(path = path, full.names = TRUE, recursive = FALSE)

  files <- unique(make_path(files))
  dirs <- unique(make_path(dirs))

  # it's not possible to non-recursively get only files but no folders
  files <- setdiff(files, dirs)

  # there's no way to only get non-hidden directories, so need to manually filter those out
  if (!hidden) {
    dirs <- dirs[grep("^\\.", basename(dirs), invert = TRUE)]
  }

  # make sure we don't show files/dirs that are inaccessible (for example, a file linked
  # to a parent folder we can't access. This happens in Windows, where the home dir has a
  # link to Videos which is in the parent directory.)
  if (!is.null(root)) {
    files <- Filter(function(f) is_subdir(root, f), files)
    dirs <- Filter(function(f) is_subdir(root, f), dirs)
  }

  if (length(extensions) > 0) {
    regex <- paste0("\\.", extensions, "$", collapse = "|")
    files <- files[grepl(regex, files, ignore.case = TRUE)]
  }

  files <- files[order(basename(files))]
  dirs <- dirs[order(basename(dirs))]

  list(files = files, dirs = dirs)
}

get_files_dirs_fake <- function(path, paths) {
  if (length(paths) == 0) {
    return()
  }
  paths <- unlist(paths)
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
