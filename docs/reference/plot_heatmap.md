# Draw a heatmap on a plot widget

Draw a heatmap on a plot widget

## Usage

``` r
plot_heatmap(
  app,
  id,
  matrix,
  title = NULL,
  color = NULL,
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

- matrix:

  A numeric matrix or data.frame of values.

- title:

  Optional chart title.

- color:

  Optional colour scheme.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
