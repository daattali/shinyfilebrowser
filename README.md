# shinyfilebrowser

**Work in progress**

```r
library(shiny)
library(shinyfilebrowser)

ui <- fluidPage(
  file_browser_ui("files")
)

server <- function(input, output, session) {
  fb <- file_browser_server("files")
  observe(message("directory: ", fb$path()))
  observe(message("selected: ", fb$selected()))
}

shinyApp(ui, server)
```
