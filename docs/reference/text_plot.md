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

Available chart types:
[`plot_bar()`](https://orijitghosh.github.io/rtui/reference/plot_bar.md),
[`plot_line()`](https://orijitghosh.github.io/rtui/reference/plot_line.md),
[`plot_scatter()`](https://orijitghosh.github.io/rtui/reference/plot_scatter.md),
[`plot_hist()`](https://orijitghosh.github.io/rtui/reference/plot_hist.md),
[`plot_box()`](https://orijitghosh.github.io/rtui/reference/plot_box.md),
[`plot_stacked_bar()`](https://orijitghosh.github.io/rtui/reference/plot_stacked_bar.md),
[`plot_multiple_bar()`](https://orijitghosh.github.io/rtui/reference/plot_multiple_bar.md),
[`plot_heatmap()`](https://orijitghosh.github.io/rtui/reference/plot_heatmap.md),
[`plot_candlestick()`](https://orijitghosh.github.io/rtui/reference/plot_candlestick.md),
[`plot_error()`](https://orijitghosh.github.io/rtui/reference/plot_error.md),
[`plot_event()`](https://orijitghosh.github.io/rtui/reference/plot_event.md).
