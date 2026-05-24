# Write a line to a log_view widget

Appends text to a `log_view` (RichLog) widget. Supports Rich markup.

## Usage

``` r
log_write(app, id, text, markup = FALSE)
```

## Arguments

- app:

  An `RtuiApp` object.

- id:

  Widget id of a `log_view`.

- text:

  Text to append.

- markup:

  Whether to interpret Rich markup (default FALSE).

## Value

Invisible `app`.
