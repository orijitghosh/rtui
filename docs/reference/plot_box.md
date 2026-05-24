# Draw a box plot on a plot widget

Draw a box plot on a plot widget

## Usage

``` r
plot_box(
  app,
  id,
  data,
  title = NULL,
  colors = NULL,
  orientation = c("vertical", "horizontal"),
  xlabel = NULL,
  ylabel = NULL,
  clear = TRUE
)
```

## Arguments

- app:

  An `RtuiApp` object.

- id:

  Widget id of a `text_plot`.

- data:

  A list of numeric vectors, one per group. E.g.
  `list(grpA = rnorm(50), grpB = rnorm(50))`.

- title:

  Optional chart title.

- colors:

  Optional character vector of colours, one per group.

- orientation:

  `"vertical"` (default) or `"horizontal"`.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
