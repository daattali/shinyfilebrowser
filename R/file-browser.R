#' File browser
#'
#' Display a simple file browser of the server-side file system.\cr\cr
#' Note that all of the server arguments (except `id`) accept either reactive
#' values or regular values.
#' @param id Unique ID for the module
#' @name file_browser
NULL

#' @rdname file_browser
#' @param height The height of the file browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param width The width of the file browser. Must be a valid CSS unit (like `"100%"`,
#' `"400px"`, `"auto"`) or a number which will be the number of pixels.
#' @param bigger (boolean) If `TRUE`, make the rows larger and more spacious.
#' @export
file_browser_ui <- function(id, height = NULL, width = "100%", bigger = FALSE) {
  general_browser_ui(id = id, height = height, width = width, bigger = bigger)
}

#' @rdname file_browser
#' @param path The initial path the file browser should show.
#' @param extensions List of file extensions that should be shown.
#' If `NULL`, all file types are shown.
#' @param root The path that should be considered root, which means that the user cannot
#' navigate to any parent of this root. By default, the `path` parameter acts as the root.
#' Use `NULL` to allow the user to navigate the entire filesystem.
#' @param show_path If `TRUE`, show the current path above the browser.
#' @param show_extension If `TRUE`, show file extensions in the file names.
#' @param show_size If `TRUE`, show file sizes along the file names.
#' @param show_icons If `TRUE`, show icons on the left column beside the file names.
#' @param include_hidden If `TRUE`, show hidden files and folders.
#' @param include_empty If `TRUE`, show empty files (files with size 0 bytes).
#' @param text_parent The text to use to indicate the parent directory.
#' @param text_empty The text show when a folder has nothing to show.
#' @param clear_selection_on_navigate If `TRUE`, the selected path will be cleared
#' when navigating to a new directory.
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
    clear_selection_on_navigate = FALSE,
    text_parent = "..",
    text_empty = "No files here"
) {
  general_browser_server(
    type = "file",
    id = id,
    path = path,
    extensions = extensions, root = root,
    include_hidden = include_hidden, include_empty = include_empty,
    show_path = show_path, show_extension = show_extension, show_size = show_size, show_icons = show_icons,
    text_parent = text_parent, text_empty = text_empty,
    clear_selection_on_navigate = clear_selection_on_navigate
  )
}
