# Create a data table widget

Create a data table widget

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
