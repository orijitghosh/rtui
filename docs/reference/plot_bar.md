# Draw a bar chart on a plot widget

Draw a bar chart on a plot widget

## Usage

``` r
plot_bar(
  app,
  id,
  labels,
  values,
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

- labels:

  Character vector of bar labels.

- values:

  Numeric vector of bar values.

- title:

  Optional chart title.

- color:

  Optional bar colour (e.g. `"red"`, `"blue"`, `"green"`).

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
