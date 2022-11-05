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
