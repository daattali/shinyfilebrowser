#' File browser
#'
#' Display a simple file browser of the server-side file system.
#' @param id Unique ID for the module
#' @name file_browser
NULL

#' @rdname file_browser
#' @param height The height of the file browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @export
file_browser_ui <- function(id, height = NULL) {
  general_browser_ui(id = id, height = height)
}

#' @rdname file_browser
#' @param path (reactive or static) The initial path the file browser should show.
#' @param extensions (reactive or static) List of file extensions that should be shown.
#' If `NULL`, all file types are shown.
#' @param root The path that should be considered root, which means that the user cannot
#' navigate to any parent of this root. By default, the `path` parameter acts as the root.
#' Use `NULL` to allow the user to navigate the entire filesystem.
#' @param show_path (boolean) If `TRUE`, show the current path above the browser.
#' @param show_extension (boolean) If `TRUE`, show file extensions in the file names.
#' @param show_size (boolean) If `TRUE`, show file sizes along the file names.
#' @param show_icons (boolean) If `TRUE`, show icons on the left column beside the file names.
#' @param include_hidden (boolean) If `TRUE`, show hidden files and folders.
#' @param include_empty (boolean) If `TRUE`, show empty files (files with size 0 bytes).
#' @param parent_text The text to use to indicate the parent directory.
#' @return List with reactive elements:
#'   - selected: The full normalized path of the selected file (`NULL` before a file is selected)
#'   - path: The full normalized path that is currently displayed in the file browser
#' @export
file_browser_server <- function(
    id,
    path = getwd(),
    extensions = NULL,
    root = path,
    show_path = TRUE,
    show_extension = TRUE,
    show_size = TRUE,
    show_icons = TRUE,
    include_hidden = FALSE,
    include_empty = TRUE,
    parent_text = ".."
) {
  general_browser_server(
    real_fs = TRUE,
    id = id,
    path = path,
    extensions = extensions, root = root,
    include_hidden = include_hidden, include_empty = include_empty,
    show_path = show_path, show_extension = show_extension, show_size = show_size, show_icons = show_icons,
    parent_text = parent_text
  )
}
