#' Get the drives on the current machine
#'
#' On Windows machines, the standard drive is `C:/`, but there may be other drives.
#' You can use this function to allow [`file_browser()`] to browse in other drives.
#'
#' @return On Windows: the names of available drives. On non-Windows machines: the root
#' path `"/"` is returned.
#' @examples
#' if (interactive()) {
#'
#' ### Simple app that lets you browse each drive
#'
#' library(shiny)
#'
#' ui <- fluidPage(
#'   selectInput("drive", "Select drive", get_drives()),
#'   file_browser_ui("files")
#' )
#'
#' server <- function(input, output, session) {
#'   file_browser_server("files", path = reactive(input$drive))
#' }
#'
#' shinyApp(ui, server)
#'
#' ##########################
#'
#' ### App that defaults to the home directory on C:/ drive
#'
#' library(shiny)
#'
#' ui <- fluidPage(
#'   selectInput("drive", "Select drive", get_drives()),
#'   file_browser_ui("files")
#' )
#'
#' server <- function(input, output, session) {
#'   path <- reactive({
#'     if (input$drive == "C:/" || input$drive == "/") {
#'       "~"
#'     } else {
#'       input$drive
#'     }
#'   })
#'   file_browser_server("files", path = path, root = reactive(input$drive))
#' }
#'
#' shinyApp(ui, server)
#'
#' }
#' @export
get_drives <- function() {
  if (Sys.info()["sysname"] == "Windows") {
    names(which(sapply(paste0(LETTERS, ":/"), dir.exists)))
  } else {
    "/"
  }
}
