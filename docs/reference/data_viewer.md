# Interactive data viewer

Opens a full-screen interactive data table for exploring a data.frame.
Supports sorting by clicking column headers. Press `q` or `escape` to
quit.

## Usage

``` r
data_viewer(df, title = NULL, dark = TRUE)
```

## Arguments

- df:

  A data.frame to display.

- title:

  Optional title for the app.

- dark:

  Use dark mode (default TRUE).

## Value

The data.frame (invisibly).

## Details

**Important:** Must be run from a real terminal (not RStudio, R GUI, or
Jupyter). Save your code as a `.R` file and run with `Rscript`.
