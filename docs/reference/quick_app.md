# Run a TUI app in one call

Convenience wrapper around
[`tui_app()`](https://orijitghosh.github.io/rtui/reference/tui_app.md)
that creates and immediately runs the application, returning the final
state. Ideal for simple single-screen apps.

## Usage

``` r
quick_app(...)
```

## Value

The final `RtuiState` object (invisibly).

## Details

**Important:** Must be run from a real terminal (not RStudio, R GUI, or
Jupyter). Save your code as a `.R` file and run with `Rscript my_app.R`.
