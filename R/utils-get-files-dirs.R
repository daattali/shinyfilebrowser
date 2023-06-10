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
    regex <- paste0("\\.", extensions, "$", collapse = "|")
    files <- files[grepl(regex, files, ignore.case = TRUE)]
  }

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
