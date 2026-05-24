# Draw a histogram on a plot widget

Draw a histogram on a plot widget

## Usage

``` r
plot_hist(
  app,
  id,
  data,
  bins = 10L,
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

- data:

  Numeric vector of data values.

- bins:

  Number of bins (default 10).

- title:

  Optional chart title.

- color:

  Optional bar colour.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
