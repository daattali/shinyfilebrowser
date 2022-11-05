# Modified from github.com/gerrymanoim/humanize
suffix <- c('kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
natural_size <- function(bytes) {
  fmt <- '%.1f'

  base <- 1000

  if (bytes == 1) {
    return("1 Byte")
  } else if (bytes < base) {
    return(glue::glue("{bytes} Bytes"))
  }

  for (i in seq_along(suffix)) {
    unit <- base ^ (i + 1)
    if (bytes < unit) {
      out_val <- sprintf(fmt, (base * bytes / unit))
      return(glue::glue("{out_val} {suffix[[i]]}"))
    }
  }

  out_val <- sprintf(fmt, (base * bytes / unit))
  return(glue::glue("{out_val} {suffix[[length(suffix)]]}"))
}
