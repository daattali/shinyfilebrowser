#' Path browser
#'
#' Display a simple path browser that allows the user to browse paths and
#' select a path. This is essentially equivalent to allowing the user to
#' navigate a tree structure. The path browser can also be used as a list selector.\cr\cr
#' Note that all of the server arguments (except `id`) accept either reactive
#' values or regular values.
#' @param id Unique ID for the module
#' @name paths_browser
NULL

#' @rdname paths_browser
#' @param height The height of the path browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param width The width of the path browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param bigger (boolean) If `TRUE`, make the rows larger and more spacious.
#' @export
path_browser_ui <- function(id, height = NULL, width = "100%", bigger = FALSE) {
  general_browser_ui(id = id, height = height, width = width, bigger = bigger)
}

#' @rdname paths_browser
#' @inheritParams file_browser_server
#' @param paths List of paths that the user can browse and select from. Use `/` as a
#' path separator, but do not use `/` as a leading slash.
#' @return List with reactive elements:
#'   - selected: The selected path (`NULL` before a path is selected)
#'   - path: The path that is currently displayed in the path browser
#' @export
path_browser_server <- function(
    id,
    paths,
    show_path = TRUE,
    show_extension = TRUE,
    show_icons = TRUE,
    clear_selection_on_navigate = FALSE,
    text_parent = "..",
    text_empty = "No items here"
) {
  general_browser_server(
    type = BROWSER_TYPE_PATH,
    id = id,
    path = paths,
    show_path = show_path, show_extension = show_extension, show_icons = show_icons,
    text_parent = text_parent, text_empty = text_empty,
    clear_selection_on_navigate = clear_selection_on_navigate
  )
}
