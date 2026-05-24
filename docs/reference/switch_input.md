# Create a switch (toggle) widget

Create a switch (toggle) widget

## Usage

``` r
switch_input(value = FALSE, id = NULL, classes = NULL, tooltip = NULL)
```

## Arguments

- value:

  Initial state (logical).

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
    hstack(static("Dark mode: "), switch_input(value = TRUE, id = "dark")),
    hstack(static("Sound: "), switch_input(value = FALSE, id = "sound")),
    id = "root"
  ),
  on_change = list(
    dark = function(event, state) {
      dark_toggle(state$app, event$value)
      state
    }
  )
)
} # }
```
