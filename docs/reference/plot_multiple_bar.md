# Draw a grouped (multiple) bar chart on a plot widget

Multiple data series are shown side-by-side.

## Usage

``` r
plot_multiple_bar(
  app,
  id,
  labels,
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

- labels:

  Character vector of bar labels (x-axis categories).

- data:

  A list of named numeric vectors, one per series. Names become legend
  labels. E.g. `list(Q1 = c(10, 20), Q2 = c(15, 25))`.

- title:

  Optional chart title.

- colors:

  Optional character vector of colours, one per series.

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
