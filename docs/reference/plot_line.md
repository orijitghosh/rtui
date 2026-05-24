# Draw a line plot on a plot widget

Draw a line plot on a plot widget

## Usage

``` r
plot_line(
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

  Optional line colour.

- marker:

  Optional marker character (e.g. `"braille"`, `"dot"`, `"hd"`).

- xlabel:

  Optional x-axis label.

- ylabel:

  Optional y-axis label.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
