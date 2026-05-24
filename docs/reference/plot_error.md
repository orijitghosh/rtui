# Draw error bars on a plot widget

Draw error bars on a plot widget

## Usage

``` r
plot_error(
  app,
  id,
  x,
  y,
  xerr = NULL,
  yerr = NULL,
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

- x:

  Numeric vector of x values.

- y:

  Numeric vector of y values.

- xerr:

  Optional numeric vector of x error bar sizes.

- yerr:

  Optional numeric vector of y error bar sizes.

- title:

  Optional chart title.

- color:

  Optional colour.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
