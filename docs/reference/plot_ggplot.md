# Render a ggplot2 object on a text_plot widget

Extracts data and geom layers from a ggplot2 object and renders them as
terminal charts using plotext. Supports common geom types: `geom_point`,
`geom_line`, `geom_col`/`geom_bar`, `geom_histogram`, `geom_boxplot`,
and `geom_smooth`.

## Usage

``` r
plot_ggplot(app, id, gg, color = NULL, clear = TRUE)
```

## Arguments

- app:

  An `RtuiApp` object.

- id:

  Widget id of a `text_plot`.

- gg:

  A ggplot2 object.

- color:

  Optional default colour override.

- clear:

  Whether to clear existing plot data first (default TRUE).

## Value

Invisible `app`.
