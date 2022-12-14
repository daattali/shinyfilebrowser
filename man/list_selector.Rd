% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list-selector.R
\name{list_selector}
\alias{list_selector}
\alias{list_selector_ui}
\alias{list_selector_server}
\title{List selector}
\usage{
list_selector_ui(id, height = NULL, width = "100\%", bigger = TRUE)

list_selector_server(id, choices, html = FALSE, text_empty = "No items")
}
\arguments{
\item{id}{Unique ID for the module}

\item{height}{The height of the list selector Must be a valid CSS unit (like \code{"100\%"},
\code{"400px"}, \code{"auto"}) or a number which will be the number of pixels.}

\item{width}{The width of the list selector Must be a valid CSS unit (like \code{"100\%"},
\code{"400px"}, \code{"auto"}) or a number which will be the number of pixels.}

\item{bigger}{(boolean) If \code{TRUE}, make the rows larger and more spacious.}

\item{choices}{List of values to select from.}

\item{html}{(reactive) If \code{TRUE}, allow HTML to be used in the item names.}

\item{text_empty}{The text show when a folder has nothing to show.}
}
\value{
(reactive) The selected item (\code{NULL} before an item is selected)
}
\description{
Display a simple list selector that allows that user to choose an item.
This is similar to shiny's \code{selectInput()} but with a different interface,
where all the options appear on the screen immediately.\cr\cr
Note that all of the server arguments (except \code{id}) accept either reactive
values or regular values.
}
