# Draw a candlestick chart on a plot widget

Draw a candlestick chart on a plot widget

## Usage

``` r
plot_candlestick(
  app,
  id,
  dates,
  data,
  title = NULL,
  colors = NULL,
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

- dates:

  Character vector of date labels.

- data:

  A list with components `open`, `close`, `high`, `low` — each a numeric
  vector of the same length.

- title:

  Optional chart title.

- colors:

  Optional character vector of two colours: up and down.

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
