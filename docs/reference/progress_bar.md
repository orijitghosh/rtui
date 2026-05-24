# Create a progress bar widget

Create a progress bar widget

## Usage

``` r
progress_bar(
  total = 100,
  progress = 0,
  show_eta = TRUE,
  show_percentage = TRUE,
  id = NULL,
  classes = NULL
)
```

## Arguments

- total:

  Total value (numeric).

- progress:

  Current progress value (numeric).

- show_eta:

  Show estimated time of arrival.

- show_percentage:

  Show percentage.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

## Value

An `rtui_spec` list.
