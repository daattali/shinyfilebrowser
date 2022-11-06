# shinyfilebrowser

**Work in progress**

Example 1: file browser from the current working directory, the user cannot navigate above the working directory.

```r
library(shiny)
library(shinyfilebrowser)

ui <- fluidPage(
  "Current path:",
  textOutput("cur_wd", inline = TRUE), br(),
  "Selected file:",
  textOutput("selected", inline = TRUE), br(),
  file_browser_ui("files")
)

server <- function(input, output, session) {
  filebrowser <- file_browser_server("files")
  output$cur_wd <- renderText({
    filebrowser$path()
  })
  output$selected <- renderText({
    filebrowser$selected()
  })
}

shinyApp(ui, server)
```

Example 2: file browser starting at the user's home but allowing the user to navigate anywhere in the file system.

```r
library(shiny)
library(shinyfilebrowser)

ui <- fluidPage(
  "Current path:",
  textOutput("cur_wd", inline = TRUE), br(),
  "Selected file:",
  textOutput("selected", inline = TRUE), br(),
  file_browser_ui("files")
)

server <- function(input, output, session) {
  filebrowser <- file_browser_server("files", path = "~", root = NULL)
  output$cur_wd <- renderText({
    filebrowser$path()
  })
  output$selected <- renderText({
    filebrowser$selected()
  })
}

shinyApp(ui, server)
```

Example 3: path browser used to select an item from a list

```r
library(shiny)
library(shinyfilebrowser)

paths <- c("Bob", "Mary", "Dean", "John", "Julie")

ui <- fluidPage(
  "Current path:",
  textOutput("cur_wd", inline = TRUE), br(),
  "Selected file:",
  textOutput("selected", inline = TRUE), br(),
  path_browser_ui("paths", bigger = TRUE)
)

server <- function(input, output, session) {
  pathbrowser <- path_browser_server("paths", paths = paths, show_path = FALSE, show_icons = FALSE)
  output$cur_wd <- renderText({
    pathbrowser$path()
  })
  output$selected <- renderText({
    pathbrowser$selected()
  })
}

shinyApp(ui, server)
```

Example 4: path browser used to select an item from a "tree"

```r
library(shiny)
library(shinyfilebrowser)

paths <- c(
  "vehicles/planes/boeing/747",
  "vehicles/planes/boeing/737",
  "vehicles/planes/airbus/A320",
  "vehicles/planes/airbus/A380",
  "vehicles/cars/honda/civic",
  "vehicles/cars/mazda/mazda 3",
  "vehicles/cars/mazda/mazda cx5",
  "vehicles/cars/toy car",
  "vehicles/train",
  "vehicles/bicycle",
  "countries/france",
  "countries/spain",
  "countries/usa/new york",
  "countries/usa/california",
  "fruits",
  "drinks"
)

ui <- fluidPage(
  "Current path:",
  textOutput("cur_wd", inline = TRUE), br(),
  "Selected file:",
  textOutput("selected", inline = TRUE), br(),
  path_browser_ui("paths")
)

server <- function(input, output, session) {
  pathbrowser <- path_browser_server("paths", paths = paths)
  output$cur_wd <- renderText({
    pathbrowser$path()
  })
  output$selected <- renderText({
    pathbrowser$selected()
  })
}

shinyApp(ui, server)
```
