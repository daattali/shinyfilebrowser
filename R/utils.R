drop_null <- function(x) {
  Filter(Negate(is.null), x)
}

fill_names <- function(x) {
  if (is.null(names(x))) {
    names(x) <- x
  } else {
    idx <- which(names(x) == "")
    names(x)[idx] <- x[idx]
  }

  x
}

make_breadcrumbs <- function(path, type = BROWSER_TYPE_FILE, include_root = TRUE) {
  if (path == "") {
    if (is_real_fs(type)) {
      return(character(0))
    } else {
      return(stats::setNames("Home", ""))
    }
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

  if (!is_real_fs(type)) {
    home_crumb <- stats::setNames("Home", "")
    parts <- c(home_crumb, parts)
  }

  parts
}
