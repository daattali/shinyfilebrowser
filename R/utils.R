drop_null <- function(x) {
  Filter(Negate(is.null), x)
}

fill_names <- function(x) {
  idx <- which(names(x) == "")
  names(x)[idx] <- x[idx]
  x
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
