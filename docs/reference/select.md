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

## Examples

``` r
if (FALSE) { # \dontrun{
quick_app(
  layout = vstack(
    # Simple options
    select(c("Red", "Green", "Blue"), id = "color",
           prompt = "Pick a colour..."),
    # Named options (display => value)
    select(c("Small (S)" = "s", "Medium (M)" = "m", "Large (L)" = "l"),
           id = "size"),
    static("", id = "result"),
    id = "root"
  ),
  on_change = list(
    color = function(event, state) {
      update(state$app, "result",
             content = paste("Colour:", event$value))
      state
    }
  )
)
} # }
```
