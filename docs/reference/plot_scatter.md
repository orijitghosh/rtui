# Draw a scatter plot on a plot widget

Draw a scatter plot on a plot widget

## Usage

``` r
plot_scatter(
  app,
  id,
  x,
  y,
  title = NULL,
  color = NULL,
  marker = NULL,
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

- x:

  Numeric vector of x values.

- y:

  Numeric vector of y values.

- title:

  Optional chart title.

- color:

  Optional point colour.

- marker:

  Optional marker character.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
