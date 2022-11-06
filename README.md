# shinyfilebrowser

**Work in progress**

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
