#' List selector
#'
#' Display a simple list selector that allows that user to choose an item.
#' This is similar to shiny's `selectInput()` but with a different interface,
#' where all the options appear on the screen immediately.\cr\cr
#' Note that all of the server arguments (except `id`) accept either reactive
#' values or regular values.
#' @param id Unique ID for the module
#' @name list_selector
NULL

#' @rdname list_selector
#' @param height The height of the list selector Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param width The width of the list selector Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param bigger (boolean) If `TRUE`, make the rows larger and more spacious.
#' @export
list_selector_ui <- function(id, height = NULL, width = "100%", bigger = TRUE) {
  general_browser_ui(id = id, height = height, width = width, bigger = bigger)
}

#' @rdname list_selector
#' @inheritParams file_browser_server
#' @param choices List of values to select from.
#' @return (reactive) The selected item (`NULL` before an item is selected)
#' @export
list_selector_server <- function(
    id,
    choices,
    text_empty = "No items"
) {
  general_browser_server(
    real_fs = FALSE, return_path = FALSE,
    id = id,
    path = choices,
    show_path = FALSE,
    show_icons = FALSE,
    text_empty = text_empty
  )
}
