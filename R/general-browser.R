general_browser_ui <- function(id, height = NULL, width = "100%", bigger = FALSE) {
  ns <- shiny::NS(id)

  width_css <- paste0("width: ", htmltools::validateCssUnit(width), ";")
  height_css <- if (!is.null(height)) paste0("height: ", htmltools::validateCssUnit(height)) else ""
  style <- paste(width_css, height_css)

  class <- "shiny-file-browser"
  if (bigger) {
    class <- paste(class, "shiny-browser-bigger")
  }

  shiny::div(
    htmltools::htmlDependency(
      name = "shinyfilebrowser-binding",
      version = as.character(utils::packageVersion("shinyfilebrowser")),
      package = "shinyfilebrowser",
      src = "assets/shinyfilebrowser",
      stylesheet = "shinyfilebrowser.css"
    ),
    class = class,
    style = style,
    shiny::icon(id = ns("loader"), "circle-notch", class = "loader fast-spin fa-2x"),
    shiny::div(
      class = "current-wd",
      shiny::uiOutput(ns("current_wd"))
    ),
    shiny::div(
      class = "file-list",
      shiny::uiOutput(ns("file_list"))
    )
  )
}

general_browser_server <- function(
    type = BROWSER_TYPES,
    id,
    path,
    extensions = NULL,
    root = NULL,
    include_hidden = FALSE,
    include_empty = TRUE,
    show_path = TRUE,
    show_extension = TRUE,
    show_size = TRUE,
    show_icons = TRUE,
    text_parent = "..",
    text_empty = "No files here",
    html = FALSE,
    clear_selection_on_navigate = FALSE
) {

  type <- match.arg(type)

  shiny::moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      wd <- shiny::reactiveVal(NULL)
      selected <- shiny::reactiveVal(NULL)

      path_r <- make_reactive(path)
      extensions_r <- make_reactive(extensions)
      root_r <- make_reactive(root)
      include_hidden_r <- make_reactive(include_hidden)
      include_empty_r <- make_reactive(include_empty)
      show_path_r <- make_reactive(show_path)
      show_extension_r <- make_reactive(show_extension)
      show_size_r <- make_reactive(show_size)
      show_icons_r <- make_reactive(show_icons)
      text_parent_r <- make_reactive(text_parent)
      text_empty_r <- make_reactive(text_empty)
      html_r <- make_reactive(html)
      clear_selection_on_navigate_r <- make_reactive(clear_selection_on_navigate)

      shiny::observeEvent(root_r(), ignoreNULL = FALSE, {
        if (type == BROWSER_TYPE_FILE) {
          if (!is.null(root_r()) && !dir.exists(root_r())) {
            stop("file_browser: Root path does not exist: ", root_r())
          }
        }
      })

      shiny::observeEvent(path_r(), ignoreNULL = FALSE, {
        initial_path <- get_initial_path(path = path_r(), type = type)
        wd(initial_path)
        selected(NULL)
      })

      output$current_wd <- shiny::renderUI({
        if (!show_path_r()) return()
        make_breadcrumbs_ui(wd = wd(), type = type, root = root_r(), ns = ns)
      })

      output$file_list <- shiny::renderUI({
        shiny::removeUI(selector = paste0("#", ns("loader")))

        make_file_list_ui(
          wd = wd(), type = type, paths = path_r(), root = root_r(),
          extensions = extensions_r(), hidden = include_hidden_r(),
          show_icons = show_icons_r(), include_empty = include_empty_r(),
          show_size = show_size_r(), show_extension = show_extension_r(),
          text_parent = text_parent_r(), text_empty = text_empty_r(), html = html_r(),
          selected = selected(), ns = ns
        )
      })

      shiny::observeEvent(input$file_clicked, {
        if (!is_legal_path(input$file_clicked, type, root_r())) {
          return()
        }

        if (!is_path(input$file_clicked, type, path_r())) {
          return()
        }

        if (is_dir(input$file_clicked, type, path_r())) {
          wd( input$file_clicked )
          if (clear_selection_on_navigate_r()) {
            selected(NULL)
          }
        } else {
          if (!is.null(selected()) && selected() == input$file_clicked) {
            selected(NULL)
          } else {
            selected( input$file_clicked )
          }
        }
      })

      return_path <- (type != BROWSER_TYPE_LIST)

      if (return_path) {
        return(list(
          path = wd,
          selected = selected
        ))
      } else {
        return(selected)
      }
    }
  )
}

