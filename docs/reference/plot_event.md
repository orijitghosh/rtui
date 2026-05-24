# Draw an event plot on a plot widget

Draws vertical (or horizontal) lines at given positions — useful for
marking events along a timeline.

## Usage

``` r
plot_event(
  app,
  id,
  positions,
  title = NULL,
  color = NULL,
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

- positions:

  Numeric vector of positions to mark.

- title:

  Optional chart title.

- color:

  Optional colour.

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
