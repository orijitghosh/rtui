# Create a select dropdown widget

Create a select dropdown widget

## Usage

``` r
select(
  options,
  value = NULL,
  prompt = "Select...",
  id = NULL,
  classes = NULL,
  tooltip = NULL
)
```

## Arguments

- options:

  Named character vector (values displayed, names used as keys) or
  unnamed character vector (values used as both keys and display).

- value:

  Initial selected value (or NULL for no selection).

- prompt:

  Placeholder text when nothing is selected.

- id:

  Optional widget id.

- classes:

  Optional CSS classes (character vector).

- tooltip:

  Optional tooltip text shown on hover.

## Value

An `rtui_spec` list.
