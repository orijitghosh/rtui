# Create a data table widget

A full-featured interactive table with sorting, row/cell/column
selection, and zebra striping. For a quick one-liner data explorer, see
[`data_viewer()`](https://orijitghosh.github.io/rtui/reference/data_viewer.md).

## Usage

``` r
data_table(
  df,
  id = NULL,
  classes = NULL,
  cursor = c("row", "cell", "column", "none"),
  zebra_stripes = FALSE,
  sortable = FALSE
)
```

## Arguments

- df:

  A data.frame to display.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- cursor:

  Type of cursor: `"cell"`, `"row"` (default), `"column"`, or `"none"`.

- zebra_stripes:

  Whether to show alternating row colours (default FALSE).

- sortable:

  Whether clicking column headers sorts the table (default FALSE). When
  `TRUE`, each click toggles ascending/descending sort.

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
# Interactive sortable table
quick_app(
  layout = vstack(
    header(),
    data_table(mtcars, id = "cars",
               cursor = "row",
               zebra_stripes = TRUE,
               sortable = TRUE),
    footer()
  ),
  bindings = list(binding("q", "quit_app", "Quit", priority = TRUE)),
  on_action = function(event, state) {
    if (event$value == "quit_app") return(quit())
    state
  }
)

# Dynamically add rows
on_click = list(
  add_btn = function(event, state) {
    new_row <- data.frame(mpg = 25, cyl = 4, disp = 100)
    update(state$app, "cars", add_rows = as.list(new_row))
    state
  },
  clear_btn = function(event, state) {
    update(state$app, "cars", clear_data = TRUE)
    state
  }
)
} # }
```
