# Create a pretty table widget (rich-formatted)

Renders a data.frame as a formatted static table (non-interactive). For
an interactive table with sorting and selection, see
[`data_table()`](https://orijitghosh.github.io/rtui/reference/data_table.md).

## Usage

``` r
pretty_table(df, title = NULL, id = NULL, classes = NULL)
```

## Arguments

- df:

  A data.frame to display.

- title:

  Optional table title.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    pretty_table(head(mtcars, 5), title = "Motor Trend Cars", id = "tbl"),
    pretty_table(head(iris, 3), title = "Iris Dataset"),
    id = "root"
  )
)
} # }
```
