# Create a text-based plot widget

Renders charts directly in the terminal using plotext via
textual-plotext. The widget displays an empty plot area at creation
time. Use the `plot_*()` family of functions to draw data from
callbacks.

## Usage

``` r
text_plot(id = NULL, classes = NULL)
```

## Arguments

- id:

  Optional widget id (required if you want to update the plot later).

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.

## Details

Available chart types: [`plot_bar()`](plot_bar.md),
[`plot_line()`](plot_line.md), [`plot_scatter()`](plot_scatter.md),
[`plot_hist()`](plot_hist.md), [`plot_box()`](plot_box.md),
[`plot_stacked_bar()`](plot_stacked_bar.md),
[`plot_multiple_bar()`](plot_multiple_bar.md),
[`plot_heatmap()`](plot_heatmap.md),
[`plot_candlestick()`](plot_candlestick.md),
[`plot_error()`](plot_error.md), [`plot_event()`](plot_event.md).
