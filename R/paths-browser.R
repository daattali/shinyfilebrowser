#' Path browser
#'
#' Display a simple path browser that allows the user to browse paths and
#' select a path. This is essentially equivalent to allowing the user to
#' navigate a tree structure. The path browser can also be used as a list selector.
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
#' @param paths List of paths that the user can browse and select from. Use `/` as a
#' path separator. Any leading slashes are automatically removed.
#' @param show_path (boolean) If `TRUE`, show the current path above the browser.
#' @param show_extension (boolean) If `TRUE`, show file extensions in the file names.
#' @param show_icons (boolean) If `TRUE`, show icons on the left column beside the file names.
#' @param parent_text The text to use to indicate the parent directory.
#' @return List with reactive elements:
#'   - selected: The full normalized path of the selected file (`NULL` before a file is selected)
#'   - path: The full normalized path that is currently displayed in the file browser
#' @export
path_browser_server <- function(
    id,
    paths,
    show_path = TRUE,
    show_extension = TRUE,
    show_icons = TRUE,
    parent_text = ".."
) {
  paths <- sub("^/+", "", paths)

  general_browser_server(
    real_fs = FALSE,
    id = id,
    path = paths,
    show_path = show_path, show_extension = show_extension, show_icons = show_icons,
    parent_text = parent_text
  )
}
