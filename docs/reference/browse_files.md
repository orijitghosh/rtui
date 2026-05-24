# Interactive file browser

Opens a terminal file browser rooted at the given path. Click a file to
see its path displayed. Press `q` or `escape` to quit. Returns the last
selected file path (or NULL).

## Usage

``` r
browse_files(path = ".", title = NULL, dark = TRUE)
```

## Arguments

- path:

  Root directory to browse (default: current directory).

- title:

  Optional title for the app.

- dark:

  Use dark mode (default TRUE).

## Value

The path of the last selected file (or `NULL`), invisibly.

## Details

**Important:** Must be run from a real terminal (not RStudio, R GUI, or
Jupyter). Save your code as a `.R` file and run with `Rscript`.
